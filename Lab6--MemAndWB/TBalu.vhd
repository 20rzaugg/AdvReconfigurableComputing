library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
library WORK;
use work.dlxlib.all;

entity TBalu is
end TBalu;

architecture testbench of TBalu is
    component ALU is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            in1 : in std_logic_vector(DATA_WIDTH-1 downto 0);
            in2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
            opcode : in std_logic_vector(5 downto 0);
            out1 : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0')
        );
    end component;

    signal clk : std_logic := '0'; 
    signal rst_l : std_logic := '1';
    signal in1 : std_logic_vector(DATA_WIDTH-1 downto 0) := x"00000100";
    signal in2 : std_logic_vector(DATA_WIDTH-1 downto 0) := x"00000001";
    signal opcode : std_logic_vector(5 downto 0) := (others => '0');
    signal next_opcode : std_logic_vector(5 downto 0) := (others => '0');
    signal out1 : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

begin

    process begin
        wait for 5 ns;
        clk <= not clk;
    end process;

    process(clk) begin
        if rising_edge(clk) then
            opcode <= next_opcode;
        end if;
    end process;

    process(opcode) begin
        if unsigned(opcode) >= 48 then
            assert false report "Testbench Complete" severity failure;
        else
            next_opcode <= std_logic_vector(unsigned(opcode) + 1);
        end if;
    end process;

    DUT : ALU port map (
        clk => clk,
        rst_l => rst_l,
        in1 => in1,
        in2 => in2,
        opcode => opcode,
        out1 => out1
    );

end testbench;