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
    component dcfifo2 IS
	    port
	    (
	    	data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
	    	rdclk		: IN STD_LOGIC ;
	    	rdreq		: IN STD_LOGIC ;
	    	wrclk		: IN STD_LOGIC ;
	    	wrreq		: IN STD_LOGIC ;
	    	q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
	    	rdempty		: OUT STD_LOGIC ;
	    	wrfull		: OUT STD_LOGIC 
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
            areset => not rst_l, --maybe not negated? idk
		    inclk0 => ADC_CLK_10,
		    c0 => uart_clk_tx, -- 0.0192 MHz (tx clk)
		    c1 => uart_clk_rx -- 0.1536 MHz (rx clk)
        );
    
    ---------------------------------------------------------------------------
    -- Dual Clock FIFO Instantiations (one for RX, one for TX)
    ---------------------------------------------------------------------------
    DCFIFO_inst_rx : dcfifo2
        port map (
            data => rx_out_to_fifo,
            rdclk => uart_clk_rx,
            rdreq => rx_fifo_read,
            wrclk => uart_clk_rx,
            wrreq => rx_fifo_write,
            q => uart_in_from_rxfifo,
            rdempty => rx_fifo_empty,
            wrfull => rx_fifo_full
        );

    DCFIFO_inst_tx : dcfifo2
        port map (
            data => uart_out_to_txfifo,
            rdclk => uart_clk_tx,
            rdreq => tx_fifo_read,
            wrclk => uart_clk_tx,
            wrreq => tx_fifo_write,
            q => tx_in_from_fifo,
            rdempty => tx_fifo_empty,
            wrfull => tx_fifo_full
        );

    ---------------------------------------------------------------------------
    -- UART RX Instantiation
    ---------------------------------------------------------------------------
    UART_RX_inst : UART_RX
        port map (
            clk => uart_clk_rx,
            rst_l => rst_l,
            rx => RX,
            rx_data => rx_out_to_fifo,
            rx_done => rx_fifo_write
        );

    ---------------------------------------------------------------------------
    -- UART TX Instantiation
    ---------------------------------------------------------------------------
    UART_TX_inst : UART_TX
        port map (
            clk => uart_clk_tx,
            rst_l => rst_l,
            tx_data => tx_data,
            tx_write => not tx_fifo_empty,
            tx => TX,
            tx_done => tx_fifo_read
        );
    
    ---------------------------------------------------------------------------
    -- Synchronous process to handle state transitions, and Asyncronous reset
    ---------------------------------------------------------------------------
    process (uart_clk_tx, rst_l) begin
        if (rst_l = '0') then
            state <= idle;
        elsif rising_edge(uart_clk_tx) then
            state <= next_state;
        end if;
    end process;

    ---------------------------------------------------------------------------
    -- State machine to handle UART RX and TX
    ---------------------------------------------------------------------------
    process (state, rx_fifo_empty, uart_in_from_rxfifo) begin
        case state is
            when idle =>
                tx_fifo_write <= '0';
                rx_fifo_read <= '0';
                if (rx_fifo_empty = '0') then
                    next_state <= send;
                    --some lovely typecasting :)
                    if (unsigned(uart_in_from_rxfifo) >= 65 and unsigned(uart_in_from_rxfifo) <= 90) or (unsigned(uart_in_from_rxfifo) >= 97 and unsigned(uart_in_from_rxfifo) <= 122) then
                        uart_out_to_txfifo <= uart_in_from_rxfifo xor "00100000";
                    else
                        --send E for error
                        uart_out_to_txfifo <= "01000101"; --nice
                    end if;   
                else
                    next_state <= idle;
                end if;
            when send =>
                tx_fifo_write <= '1';
                rx_fifo_read <= '1';
                next_state <= idle;
            when others =>
                next_state <= idle;
                tx_fifo_write <= '0';
                rx_fifo_read <= '0';
        end case;
    end process;

end behavioral;
