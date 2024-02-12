library IEEE;
library work;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
use work.dlxlib.all;

entity dlx_fetch is
    port (
        clk : in std_logic;
        rst_l : in std_logic;
        addr_selector : in std_logic;
        branch_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        next_pc : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        instr : out std_logic_vector(INSTR_WIDTH-1 downto 0)
    );
end entity dlx_fetch;

architecture hierarchial of dlx_fetch is
    
    component instruction_mem is
        port
        (
            address	: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
            clock : IN STD_LOGIC  := '1';
            q : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
    end component instruction_mem;

    component addr_adder is
        port (
            addr : in unsigned(ADDR_WIDTH-1 downto 0);
            offset : in unsigned(ADDR_WIDTH-1 downto 0);
            result : out unsigned(ADDR_WIDTH-1 downto 0)
        );
    end component addr_adder;
    
    component mux2_1 is
        parameter MUX_WIDTH : integer := 32;
        port (
            sel : in std_logic;
            in0 : in std_logic_vector(MUX_WIDTH-1 downto 0);
            in1 : in std_logic_vector(MUX_WIDTH-1 downto 0);
            out0 : out std_logic_vector(MUX_WIDTH-1 downto 0)
        );
    end component mux2_1;

    signal pc : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal mux_in : unsigned(ADDR_WIDTH-1 downto 0);
    signal nPC : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');

begin

    next_pc <= pc;

    instr_mem_inst : instruction_mem
        port map (
            address => pc,
            clock => clk,
            q => instr
        );
    
    addr_adder_inst : addr_adder
        port map (
            addr => unsigned(pc),
            offset => "0000000001",
            result => mux_in
        );

    mux_inst : mux2_1
        parameter MUX_WIDTH => ADDR_WIDTH;
        port map (
            sel => addr_selector,
            in0 => std_logic_vector(mux_in),
            in1 => branch_addr,
            out0 => nPC
        );
    
    process (clk, rst_l) begin
        if rst_l = '0' then
            pc <= (others => '0');
        elsif rising_edge(clk) then
            pc <= nPC;
        end if;
    end process;
end architecture hierarchial;
