library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.dlxlib.all;

entity TBpipelineTBcopy is
end TBpipelineTBcopy;

architecture testbench of TBpipelineTBcopy is
    
    component DLXpipelineTBcopy is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            tx : out std_logic;
            LEDR : out std_logic_vector(9 downto 0);
            HEX0 : out unsigned(7 downto 0);
            HEX1 : out unsigned(7 downto 0);
            HEX2 : out unsigned(7 downto 0);
            HEX3 : out unsigned(7 downto 0);
            HEX4 : out unsigned(7 downto 0);
            HEX5 : out unsigned(7 downto 0);
            rx_data : in std_logic_vector(7 downto 0);
            rx_done : in std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal rst_l : std_logic := '1';
    signal index : integer := 0;
    signal next_index : integer := 0;
    signal tx : std_logic;
    signal rx_data : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_done : std_logic := '0';
    signal LEDR : std_logic_vector(9 downto 0);
    signal HEX0 : unsigned(7 downto 0);
    signal HEX1 : unsigned(7 downto 0);
    signal HEX2 : unsigned(7 downto 0);
    signal HEX3 : unsigned(7 downto 0);
    signal HEX4 : unsigned(7 downto 0);
    signal HEX5 : unsigned(7 downto 0);

begin
    DUT : DLXpipelineTBcopy
        port map (
            clk => clk,
            rst_l => rst_l,
            tx => tx,
            LEDR => LEDR,
            HEX0 => HEX0,
            HEX1 => HEX1,
            HEX2 => HEX2,
            HEX3 => HEX3,
            HEX4 => HEX4,
            HEX5 => HEX5,
            rx_data => rx_data,
            rx_done => rx_done
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
        rst_l <= '1';
        if index > 1400 then
            report "Simulation finished" severity failure;
        else
            next_index <= index + 1;
        end if;
    end process;

    process(index) is begin
        case index is
            when 500 =>
                rx_data <= x"31";
                rx_done <= '1';
            when 501 =>
                rx_done <= '0';
            when 507 =>
                rx_data <= x"35";
                rx_done <= '1';
            when 508 =>
                rx_done <= '0';
            when 513 =>
                rx_data <= x"0D";
                rx_done <= '1';
            when 514 =>
                rx_done <= '0';
            when others =>
                null;
        end case;
    end process;

end testbench;
