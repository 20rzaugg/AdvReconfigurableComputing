library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.LCM_PACKAGE.all;

entity TB_LCM is
end TB_LCM;

architecture Testbench of TB_LCM is

    component LCM is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            v1 : in unsigned(DATA_WIDTH-1 downto 0);
            v2 : in unsigned(DATA_WIDTH-1 downto 0);
            start : in std_logic;
            done : out std_logic := '0';
            vout : out unsigned(DATA_WIDTH-1 downto 0) := (others => '0');
            err : out std_logic := '0'
        );
    end component;

    signal clk : std_logic := '0';
    signal rst_l : std_logic := '1';
    signal v1 : unsigned(DATA_WIDTH-1 downto 0);
    signal v2 : unsigned(DATA_WIDTH-1 downto 0);
    signal start : std_logic := '0';
    signal done : std_logic;
    signal vout : unsigned(DATA_WIDTH-1 downto 0);
    signal err : std_logic;
    signal index : integer := 0;

begin

    DUT : LCM
        port map (
            clk => clk,
            rst_l => rst_l,
            v1 => v1,
            v2 => v2,
            start => start,
            done => done,
            vout => vout,
            err => err
        );

    process begin
        wait for 1 ns;
        clk <= not clk;
    end process;

    process(clk) begin
        if rising_edge(clk) then
            index <= index + 1;
        end if;
    end process;

    process(index) begin
        case index is
            when 1 =>
                v1 <= X"0000000000000011";
                v2 <= X"0000000000000017";
            when 2 =>
                start <= '1';
            when 7 =>
                start <= '0';
            when 150 =>
                report "Simulation finished" severity failure;
            when others =>
                null;
        end case;
    end process;


end Testbench;