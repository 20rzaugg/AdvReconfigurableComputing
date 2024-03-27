library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.dlxlib.all;

entity TBscanner is
end TBscanner;

architecture testbench of TBscanner is

    component scannerTBcopy is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            instr_in : in std_logic_vector(INSTR_WIDTH-1 downto 0);
            input_buffer_empty : inout std_logic;
            data_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
            rx_data : in std_logic_vector(7 downto 0);
            rx_done : in std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal rst_l : std_logic := '1';
    signal instr_in : std_logic_vector(INSTR_WIDTH-1 downto 0) := (others => '0');
    signal input_buffer_empty : std_logic;
    signal data_out : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rx_data : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_done : std_logic := '0';
    signal index : integer := 0;

begin

    scanner_inst : scannerTBcopy
        port map (
            clk => clk,
            rst_l => rst_l,
            instr_in => instr_in,
            input_buffer_empty => input_buffer_empty,
            data_out => data_out,
            rx_data => rx_data,
            rx_done => rx_done
        );

    process
    begin
        wait for 10 ns;
        clk <= not clk;
    end process;

    process (clk) is begin
        if rising_edge(clk) then
            index <= index + 1;
        end if;
    end process;

    process(index) is begin
        case index is
            when 0 =>
                rx_data <= x"31";
                rx_done <= '1';
            when 1 =>
                rx_done <= '0';
            when 5 =>
                rx_data <= x"35";
                rx_done <= '1';
            when 6 =>
                rx_done <= '0';
            when 10 =>
                rx_data <= x"0D";
                rx_done <= '1';
            when 11 =>
                rx_done <= '0';
            when 15 =>
                instr_in <= x"D5800000";
            when 25 =>
                report "Simulation finished" severity failure;
            when others =>
                null;
        end case;
    end process;

end testbench;