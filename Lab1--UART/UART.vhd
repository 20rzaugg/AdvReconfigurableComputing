library IEEE;
use IEEE.std_logic_1164.all;

entity UART is
    port (
        ADC_CLK_10 : in std_logic;
        MAX10_CLK1_50 : in std_logic;
        MAX10_CLK2_50 : in std_logic;
        KEY : in std_logic_vector (1 downto 0);
        GPIO : inout std_logic_vector(35 downto 0);
    );
end UART;

architecture behavioral of UART is

    ---------------------------------------------------------------------------
    -- 10 MHz to 1.2288 MHz PLL (8 cycles per RX, 64 cycles per TX)
    ---------------------------------------------------------------------------
    component pll1 is
        port (
            inclk0 : in std_logic := '0';
            c0 : out std_logic := '0';
        );
    end component;

    ---------------------------------------------------------------------------
    -- UART RX module
    ---------------------------------------------------------------------------
    component UART_RX is
        port ( clk : in  STD_LOGIC;
               rst_l : in  STD_LOGIC;
               rx : in  STD_LOGIC;
               rx_data : out  STD_LOGIC_VECTOR (7 downto 0);
               rx_done : out  STD_LOGIC);
    end component;

    ---------------------------------------------------------------------------
    -- UART TX module
    ---------------------------------------------------------------------------
    component UART_TX is
        port ( clk : in  STD_LOGIC;
               rst_l : in  STD_LOGIC;
               tx_data : in  STD_LOGIC_VECTOR (7 downto 0);
               tx_write : in STD_LOGIC;
               tx : out  STD_LOGIC;
               tx_done : out  STD_LOGIC);
    end component;

    signal rst_l : std_logic := '0';

    type state_type is (idle, send, wait);
    signal state : state_type := idle;
    signal next_state : state_type := idle;

    signal uart_clk : std_logic;
    signal rx_done : std_logic;
    signal tx_done : std_logic;
    signal rx_data : std_logic_vector(7 downto 0);
    signal tx_data : std_logic_vector(7 downto 0);
    signal tx_write : std_logic;



begin
    rst_l <= ~KEY(0);
    ---------------------------------------------------------------------------
    -- PLL Instantiation
    ---------------------------------------------------------------------------
    PLL1_inst : pll1
        port map (
            inclk0 => ADC_CLK_10,
            c0 => uart_clk
        );
    
    ---------------------------------------------------------------------------
    -- UART RX Instantiation  TODO: fix GPIO ports
    ---------------------------------------------------------------------------
    UART_RX_inst : UART_RX
        port map (
            clk => ADC_CLK_10,
            rst_l => rst_l,
            rx => GPIO(0),
            rx_data => rx_data,
            rx_done => rx_done
        );

    ---------------------------------------------------------------------------
    -- UART TX Instantiation  TODO: fix GPIO ports
    ---------------------------------------------------------------------------
    UART_TX_inst : UART_TX
        port map (
            clk => ADC_CLK_10,
            rst_l => rst_l,
            tx_data => tx_data,
            tx_write => tx_write,
            tx => GPIO(1),
            tx_done => tx_done
        );
    
    ---------------------------------------------------------------------------
    -- Synchronous process to handle state transitions, and Asyncronous reset
    ---------------------------------------------------------------------------
    process (ADC_CLK_10, rst_l) begin
        if (rst_l = '0') then
            state <= idle;
        elsif rising_edge(ADC_CLK_10) then
            state <= next_state;
        end if;
    end process;

    process (state, rx_done, tx_done, rx_data, tx_data) begin
        case state is
            when idle =>
                tx_write <= '0';
                if (rx_done = '1') then
                    next_state <= send;   
                else
                    next_state <= idle;
                end if;
            when send =>
                
                if (tx_done = '1') then
                    next_state <= wait;
                else
                    next_state <= send;
                end if;
            when wait =>
                if (tx_done = '1') then
                    next_state <= idle;
                else
                    next_state <= wait;
                end if;
            when others =>
                next_state <= idle;
        end case;
    end process;

end behavioral;
