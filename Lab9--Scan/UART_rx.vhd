library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- expects clock signal to be (8 x baudrate) Hz
entity UART_RX is
    Port ( 
        clk : in  STD_LOGIC;
        rst_l : in  STD_LOGIC;
        rx : in  STD_LOGIC;
        rx_data : out  STD_LOGIC_VECTOR (7 downto 0);
        rx_done : out  STD_LOGIC
    );
end UART_RX;

architecture Behavioral of UART_RX is

    type state_type is (idle, start, data, stop);
    signal state : state_type := idle;
    signal next_state : state_type := idle;
    signal oversample_reg : integer range 0 to 7 := 0; -- increments when RX line is high, result is high if > 3
    signal next_oversample_reg : integer range 0 to 7 := 0;
    signal oversample_count : integer range 0 to 7 := 0; -- counts how many times we've sampled the RX line per bit
    signal next_oversample_count : integer range 0 to 7 := 0;
    signal bit_count : integer range 0 to 7 := 0; -- counts which bit we're on in the data state
    signal next_bit_count : integer range 0 to 7 := 0;
    signal rx_data_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal next_rx_data_reg : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');

begin
    rx_data <= rx_data_reg;

    -- Synchronous process, handles clock and reset
    process (clk, rst_l) begin
        -- Asynchronous reset
        if rst_l = '0' then
            state <= idle;
        --Rising clock edge
        elsif rising_edge(clk) then
            state <= next_state;
            oversample_count <= next_oversample_count;
            bit_count <= next_bit_count;
            oversample_reg <= next_oversample_reg;
            rx_data_reg <= next_rx_data_reg;
        end if;
    end process;

    process (state, rx, next_state, oversample_reg, oversample_count, bit_count) begin
        next_rx_data_reg <= rx_data_reg;
        case state is
            -------------------------------------------------------------------
            -- IDLE state, wait for start bit
            -------------------------------------------------------------------
            when idle =>
                rx_done <= '0';
                next_oversample_reg <= 0;
                if rx = '0' then
                    next_state <= start;
                    next_bit_count <= 0;
                    next_oversample_count <= 0;
                    next_rx_data_reg <= (others => '0');
                else
                    next_state <= idle;
                    next_bit_count <= 0;
                    next_oversample_count <= 0;
                end if;
            -------------------------------------------------------------------
            -- START state, wait 8 clocks to sample data
            -------------------------------------------------------------------
            when start =>
                rx_done <= '0';
                next_bit_count <= 0;
                next_oversample_reg <= 0;
                if oversample_count = 7 then
                    next_state <= data;
                    next_oversample_count <= 1;
                else
                    next_state <= start;
                    next_oversample_count <= oversample_count + 1;
                end if;
            -------------------------------------------------------------------
            -- DATA state, sample data 8 times per bit, majority rules
            -------------------------------------------------------------------
            when data =>
                rx_done <= '0';
                if oversample_count = 7 then
                    if bit_count = 7 then
                        next_state <= stop;
                        next_oversample_count <= 0;
                        next_bit_count <= 0;
                        next_oversample_reg <= 0;
                    else
                        next_state <= data;
                        next_oversample_count <= 0;
                        next_oversample_reg <= 0;
                        next_bit_count <= bit_count + 1;
                        if oversample_reg > 1 then
                            next_rx_data_reg(bit_count) <= '1';
                        else
                            next_rx_data_reg(bit_count) <= '0';
                        end if;
                    end if;
                else
                    next_state <= data;
                    next_oversample_count <= oversample_count + 1;
                    next_bit_count <= bit_count;
                    if rx = '1' and oversample_count > 1 and oversample_count < 5 then
                        next_oversample_reg <= oversample_reg + 1;
                    else
                        next_oversample_reg <= oversample_reg;
                    end if;
                end if;
            -- No parity bit
            -------------------------------------------------------------------
            -- STOP state, wait 8 clocks to sample stop bit
            -------------------------------------------------------------------
            when stop =>
                next_oversample_reg <= 0;
                if oversample_count = 7 then
                    next_state <= idle;
                    next_oversample_count <= 0;
                    next_bit_count <= 0;
                    rx_done <= '1';
                else
                    rx_done <= '0';
                    next_state <= stop;
                    next_oversample_count <= oversample_count + 1;
                    next_bit_count <= 0;
                end if;
            when others =>
				next_state <= idle;
				next_oversample_count <= 0;
				next_bit_count <= 0;
				rx_done <= '0';
                next_rx_data_reg <= (others => '0');
                next_oversample_reg <= 0;
        end case;
    end process;
end Behavioral;
