library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use work.dlxlib.all;

entity TBpipeline is
end TBpipeline;

architecture testbench of TBpipeline is
    
    component DLXpipeline is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            tx : out std_logic;
            rx : in std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal rst_l : std_logic := '1';
    signal index : integer := 0;
    signal next_index : integer := 0;
    signal tx : std_logic;
    signal rx : std_logic;

begin
    DUT : DLXpipeline
        port map (
            clk => clk,
            rst_l => rst_l,
            tx => tx,
            rx => rx
        );

    process
    begin
        wait for 10 ns;
        clk <= not clk;
    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            index <= next_index;
        end if;
    end process;

    process (index) begin
        if index = 700 or index = 701 or index = 702 then
            rst_l <= '0';
        else
            rst_l <= '1';
        end if;
        if index > 1400 then
            report "Simulation finished" severity failure;
        else
            next_index <= index + 1;
        end if;
    end process;
end testbench;
