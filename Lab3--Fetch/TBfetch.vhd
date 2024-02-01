library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library dlxlib;
use dlxlib.all;

entity TBfetch is
end TBfetch;

architecture testbench of TBfetch is
    component dlx_fetch is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            addr_selector : in std_logic;
            branch_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            next_pc : out std_logic_vector(ADDR_WIDTH-1 downto 0);
            instr : out std_logic_vectory(DATA_WIDTH-1 downto 0);
        );
    end component;

    signal clk : std_logic := '0';
    signal rst_l : std_logic := '0';
    signal addr_selector : std_logic := '0';
    signal branch_addr : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal next_pc : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal instr : std_logic_vector(DATA_WIDTH-1 downto 0);

    type addr_type is array (0 to 72) of std_logic_vectory(ADDR_WIDTH-1 downto 0);
    signal expected_PC : addr_type := (
        "0000000000",
        "0000000001",
        "0000000010",
        "0000000011",
        "0000000100",
        "0000000101",
        "0000000110",
        "0000000111",
        "0000001000",
        "0000001001",
        "0000001010",
        "0000001011",
        "0000001100",
        "0000001101",
        "0000001110",
        "0000001111",
        "0000010000",
        "0000010001",
        "0000001011",
        "0000001100",
        "0000001101",
        "0000001110",
        "0000001111",
        "0000010000",
        "0000010001",
        "0000001011",
        "0000001100",
        "0000001101",
        "0000001110",
        "0000010000",
        "0000010001",
        "0000010010",
        "0000001001",
        "0000001010",
        "0000001011",
        "0000001100",
        "0000000100",
        "0000000101",
        "0000000110",
        "0000000111",
        "0000001000",
        "0000001001",
        "0000001010",
        "0000001011",
        "0000001100",
        "0000001101",
        "0000001110",
        "0000001111",
        "0000010000",
        "0000010001",
        "0000001011",
        "0000001100",
        "0000001101",
        "0000001110",
        "0000010000",
        "0000010001",
        "0000010010",
        "0000001001",
        "0000001010",
        "0000001011",
        "0000001100",
        "0000000100",
        "0000000101",
        "0000000110",
        "0000000111",
        "0000010011",
        "0000010010",
        "0000010011",
        "0000010100",
        "0000010010",
        "0000010011",
        "0000010100",
        "0000010010"
    );

    type mem_type is array (0 to 72) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal expected_instr : mem_type := (
        x"04200000",
        x"10400000",
        x"10600000",
        x"05400000",
        x"816A0001",
        x"B1600011",
        x"10610000",
        x"204A0001",
        x"BC00000B",
        x"214A0001",
        x"B4000004",
        x"81620001",
        x"B1600010",
        x"0C211800",
        x"20420001",
        x"B400000B",
        x"BBE00000",
        x"08000401",
        x"81620001",
        x"B1600010",
        x"0C211800",
        x"20420001",
        x"B400000B",
        x"BBE00000",
        x"08000401",
        x"81620001",
        x"B1600010",
        x"0C211800",
        x"20420001",
        x"BBE00000",
        x"08000401",
        x"B4000012",
        x"214A0001",
        x"B4000004",
        x"81620001",
        x"B1600010",
        x"816A0001",
        x"B1600011",
        x"10610000",
        x"204A0001",
        x"BC00000B",
        x"214A0001",
        x"B4000004",
        x"81620001",
        x"B1600010",
        x"0C211800",
        x"20420001",
        x"B400000B",
        x"BBE00000",
        x"08000401",
        x"81620001",
        x"B1600010",
        x"0C211800",
        x"20420001",
        x"BBE00000",
        x"08000401",
        x"B4000012",
        x"214A0001",
        x"B4000004",
        x"81620001",
        x"B1600010",
        x"816A0001",
        x"B1600011",
        x"10610000",
        x"204A0001",
        x"08000401",
        x"B4000012",
        x"UUUUUUUU",
        x"UUUUUUUU",
        x"B4000012",
        x"UUUUUUUU",
        x"UUUUUUUU",
        x"B4000012"
    );

begin
    DUT : dlx_fetch
        port map (
            clk => clk,
            rst_l => rst_l,
            addr_selector => addr_selector,
            branch_addr => branch_addr,
            next_pc => next_pc,
            instr => instr
        );

        process
        begin
            wait for 5 ns;
            clk <= not clk;
        end process;
end
end testbench;


