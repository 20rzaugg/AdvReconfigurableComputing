library IEEE;
use IEEE.std_logic_1164.all;

entity UART is
    port (
        ADC_CLK_10 : in std_logic;
        MAX10_CLK1_50 : in std_logic;
        MAX10_CLK2_50 : in std_logic;

        GPIO : inout std_logic_vector(35 downto 0);
    );
end UART;

architecture behavioral of UART is
    --TODO instantiate PLL with frequency 1.536 MHz ???
    component UART_RX is
        Port ( clk : in  STD_LOGIC;
               rst_l : in  STD_LOGIC;
               rx : in  STD_LOGIC;
               rx_data : out  STD_LOGIC_VECTOR (7 downto 0);
               rx_done : out  STD_LOGIC);
    end component;

    signal rst_l : std_logic := '1';
    signal rx_done : std_logic;
    signal rx_data : std_logic_vector(7 downto 0);

begin
    UART_RX_inst : UART_RX
        port map (
            clk => ADC_CLK_10,
            rst_l => rst_l,
            rx => GPIO(0),
            rx_data => rx_data,
            rx_done => rx_done
        );
    -- logic
end behavioral;
