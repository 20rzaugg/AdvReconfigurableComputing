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
        bubble : in std_logic;
        decode_pc : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        instr : out std_logic_vector(INSTR_WIDTH-1 downto 0)
    );
end entity dlx_fetch;

architecture hierarchial of dlx_fetch is
    
    component instruction_mem is
        port
        (
            address	: IN STD_LOGIC_VECTOR (9 DOWNTO 0);
            clock : IN STD_LOGIC  := '1';
            q : OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
        );
    end component instruction_mem;

    component addr_adder is
        port (
            addr : in unsigned(ADDR_WIDTH-1 downto 0);
            offset : in unsigned(ADDR_WIDTH-1 downto 0);
            result : inout unsigned(ADDR_WIDTH-1 downto 0);
            bubble : in std_logic
        );
    end component addr_adder;
    
    component MUX2_1 is
        generic (
             MUX_WIDTH : integer := ADDR_WIDTH
        );
        port (
            sel : in std_logic;
            in0 : in std_logic_vector(MUX_WIDTH-1 downto 0);
            in1 : in std_logic_vector(MUX_WIDTH-1 downto 0);
            out0 : out std_logic_vector(MUX_WIDTH-1 downto 0)
        );
    end component mux2_1;

    signal mux_in : unsigned(ADDR_WIDTH-1 downto 0);
    signal fetch_pc : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal next_pc : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    --signal mem_instr : std_logic_vector(INSTR_WIDTH-1 downto 0);

begin

    instr_mem_inst : instruction_mem
        port map (
            address => fetch_pc,
            clock => clk,
            q => instr
        );
    
    addr_adder_inst : addr_adder
        port map (
            addr => unsigned(fetch_pc),
            offset => "0000000001",
            result => mux_in,
            bubble => bubble
        );

    mux_inst : mux2_1
        generic map (
            MUX_WIDTH => ADDR_WIDTH
        )
        port map (
            sel => addr_selector,
            in0 => std_logic_vector(mux_in),
            in1 => branch_addr,
            out0 => next_pc
        );
    
    process (clk, rst_l) begin
        if rst_l = '0' then
            fetch_pc <= (others => '0');
        elsif rising_edge(clk) then
            if bubble = '0' then
                fetch_pc <= next_pc;
                decode_pc <= next_pc;
            else
                fetch_pc <= fetch_pc;
                decode_pc <= fetch_pc;
            end if;
        end if;
    end process;
end architecture hierarchial;
