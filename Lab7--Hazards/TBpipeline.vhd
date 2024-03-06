library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use work.dlxlib.all;

entity TBexecute is
end TBexecute;

architecture testbench of TBexecute is
    
    component DLXpipeline is
        port (
            clk : in std_logic;
            rst_l : in std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal rst_l : std_logic := '1';
    signal index : integer := 0;
    signal next_index : integer := 0;

begin
    DUT : DLXpipeline
        port map (
            clk => clk,
            rst_l => rst_l
        );
    rst_l <= '1';

    process
    begin
        wait for 5 ns;
        clk <= not clk;
    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            index <= next_index;
        end if;
    end process;

    process (index) begin
        if index > 100 then
            report "Simulation finished" severity failure;
        else
            next_index <= index + 1;
        end if;
    end process;
end testbench;
