library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.dlxlib.all;

entity dlx_memory is
    port (
        clk : in std_logic;
        rst_l : in std_logic;
        alu_result_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
        data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
        instr_in : in std_logic_vector(INSTR_WIDTH-1 downto 0);
        data_mem_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
        instr_out : out std_logic_vector(INSTR_WIDTH-1 downto 0);
        alu_result_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end dlx_memory;

architecture hierarchial of dlx_memory is

    component data_mem is
        port
        (
            address : IN STD_LOGIC_VECTOR (11 DOWNTO 0);
            clock : IN STD_LOGIC  := '1';
            data : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
            wren : IN STD_LOGIC ;
            q : OUT STD_LOGIC_VECTOR (63 DOWNTO 0)
        );
    end component;

    signal wren : std_logic := '0';

begin

    data_mem_inst : data_mem
    port map
    (
        address => alu_result_in(9 downto 0),
        clock => clk,
        data => data_in,
        wren => wren,
        q => data_mem_out
    );
    
    process (clk, rst_l) begin
        if rst_l = '0' then
            instr_out <= (others => '0');
            alu_result_out <= (others => '0');
        elsif rising_edge(clk) then
            alu_result_out <= alu_result_in;
            instr_out <= instr_in;
        end if;
    end process;

    process(instr_in, rst_l) begin
        if rst_l = '0' then
            wren <= '0';
        else
            wren <= '0';
            if instr_in(63 downto 56) = SW then
                wren <= '1';
            end if;
        end if;
    end process;

end hierarchial;
