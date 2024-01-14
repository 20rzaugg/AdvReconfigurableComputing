library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity UART is
    port (
        ADC_CLK_10 : in std_logic;
        MAX10_CLK1_50 : in std_logic;
        MAX10_CLK2_50 : in std_logic;
        KEY : in std_logic_vector (1 downto 0);
        TX : out std_logic;
        RX : in std_logic
        --GPIO : inout std_logic_vector(35 downto 0);
    );
end UART;

architecture behavioral of UART is

    ---------------------------------------------------------------------------
    -- PLL module
    ---------------------------------------------------------------------------
    component pll1 is
        port (
            areset : IN STD_LOGIC;
		    inclk0 : IN STD_LOGIC;
		    c0 : OUT STD_LOGIC; -- 0.0192 MHz (tx clk)
		    c1 : OUT STD_LOGIC -- 0.1536 MHz (rx clk)
        );
    end component;

    ---------------------------------------------------------------------------
    -- Dual Clock FIFO module
    ---------------------------------------------------------------------------
    component dcfifo is
        generic (
          width : positive;
          depth : positive -- in bits, (i.e. real_depth = 2 ** depth)
        );
        port ( 
          wr : in std_logic;
          wr_data : in std_logic_vector(width - 1 downto 0);
          wr_clk : in std_logic;
          wr_full : out std_logic;
          rd : in std_logic;
          rd_data : out std_logic_vector(width - 1 downto 0);
          rd_clk : in std_logic;
          rd_empty : out std_logic
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

    type state_type is (idle, send);
    signal state : state_type := idle;
    signal next_state : state_type := idle;

    signal uart_clk_rx : std_logic;
    signal uart_clk_tx : std_logic;
    

    -- signals to and from the UART RX and TX modules
    signal rx_out_to_fifo : std_logic_vector(7 downto 0);
    signal uart_in_from_rxfifo : std_logic_vector(7 downto 0);
    signal uart_out_to_txfifo : std_logic_vector(7 downto 0);
    signal tx_in_from_fifo : std_logic_vector(7 downto 0);

    signal rx_fifo_full : std_logic;
    signal rx_fifo_empty : std_logic;
    signal rx_fifo_write : std_logic;
    signal rx_fifo_read : std_logic;

    signal tx_fifo_full : std_logic;
    signal tx_fifo_empty : std_logic;
    signal tx_fifo_write : std_logic;
    signal tx_fifo_read : std_logic;

begin
    rst_l <= not KEY(0);
    ---------------------------------------------------------------------------
    -- PLL Instantiation
    ---------------------------------------------------------------------------
    PLL1_inst : pll1
        port map (
            areset => rst_l,
		    inclk0 => ADC_CLK_10,
		    c0 => uart_clk_tx, -- 0.0192 MHz (tx clk)
		    c1 => uart_clk_rx -- 0.1536 MHz (rx clk)
        );
    
    ---------------------------------------------------------------------------
    -- Dual Clock FIFO Instantiations (one for RX, one for TX)
    ---------------------------------------------------------------------------
    DCFIFO_inst_rx : dcfifo
        generic map (
            width => 8,
            depth => 4
        )
        port map (
            wr => rx_fifo_write,
            wr_data => uart_in_from_rxfifo,
            wr_clk => uart_clk_rx,
            wr_full => rx_fifo_full,
            rd => rx_fifo_read,
            rd_data => tx_data,
            rd_clk => uart_clk,
            rd_empty => rx_fifo_empty
        );

    DCFIFO_inst_tx : dcfifo
        generic map (
            width => 8,
            depth => 4
        )
        port map (
            wr => tx_write,
            wr_data => tx_data,
            wr_clk => uart_clk,
            wr_full => open,
            rd => '1',
            rd_data => open,
            rd_clk => uart_clk,
            rd_empty => tx_done
        );

    ---------------------------------------------------------------------------
    -- UART RX Instantiation  TODO: fix GPIO ports
    ---------------------------------------------------------------------------
    UART_RX_inst : UART_RX
        port map (
            clk => uart_clk,
            rst_l => rst_l,
            rx => RX,
            rx_data => rx_data,
            rx_done => rx_done
        );

    ---------------------------------------------------------------------------
    -- UART TX Instantiation  TODO: fix GPIO ports
    ---------------------------------------------------------------------------
    UART_TX_inst : UART_TX
        port map (
            clk => uart_clk,
            rst_l => rst_l,
            tx_data => tx_data,
            tx_write => tx_write,
            tx => TX,
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

    ---------------------------------------------------------------------------
    -- State machine to handle UART RX and TX
    ---------------------------------------------------------------------------
    process (state, rx_done, tx_done, rx_data, tx_data) begin
        case state is
            when idle =>
                tx_write <= '0';
                if (rx_done = '1') then
                    next_state <= send;
                    --some lovely typecasting :)
                    if (unsigned(rx_data) >= 65 and unsigned(rx_data) <= 90) or (unsigned(rx_data) >= 97 and unsigned(rx_data) <= 122) then
                        tx_data <= rx_data xor "00100000";
                    else
                        --send E for error
                        tx_data <= "01000101"; --nice
                    end if;   
                else
                    next_state <= idle;
                end if;
            when send =>
                tx_write <= '1';
                if tx_done = '1' then
                    next_state <= idle;
                else
                    next_state <= send;
                end if;
            when others =>
                next_state <= idle;
        end case;
    end process;

end behavioral;
