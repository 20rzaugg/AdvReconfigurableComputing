library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_RX is
    Port ( clk : in  STD_LOGIC;
           rst_l : in  STD_LOGIC;
           rx : in  STD_LOGIC;
           rx_data : out  STD_LOGIC_VECTOR (7 downto 0);
           rx_done : out  STD_LOGIC);
end UART_RX;

architecture Behavioral of UART_RX is

    type state_type is (idle, start, data, stop);
    signal state : state_type := idle;
    signal next_state : state_type := idle;
    signal rx_reg : std_logic_vector(7 downto 0); 
    signal rx_done_reg : std_logic := '0';
    signal oversample_reg : integer range 0 to 7 := 0; -- increments when RX line is high, result is high if > 3
    signal oversample_count : integer range 0 to 7 := 0; -- counts how many times we've sampled the RX line per bit
    signal next_oversample_count : integer range 0 to 7 := 0;
    signal bit_count : integer range 0 to 7 := 0; -- counts which bit we're on in the data state
    signal next_bit_count : integer range 0 to 7 := 0;

    signal clk_counter : integer range 0 to 127 := 0;

begin

    rx_data <= rx_reg;
    rx_done <= rx_done_reg;

    -- Synchronous process, handles clock and reset
    process (clk, rst_l) begin
        -- Asynchronous reset
        if rst_l = '0' then
            state <= idle;
            rx_done_reg <= '0';
            rx_reg <= (others => '0');
            oversample_reg <= 0;
            oversample_count <= 0;
            bit_count <= 0;
            clk_counter <= 0;
        --Rising clock edge
        elsif rising_edge(clk) then
            --Count to 65 to get 19200 baud, oversampled by 8 (supposedly)
            if clk_counter >= 65 then
                clk_counter <= 0;
                state <= next_state;
                oversample_count <= next_oversample_count;
                bit_count <= next_bit_count;
            else
                clk_counter <= clk_counter + 1;
                state <= state;
                oversample_count <= oversample_count;
                bit_count <= bit_count;
            end if;
        end if;
    end process;

    process (state, rx, next_state, rx_reg, oversample_reg, oversample_count, bit_count) begin
        next_state <= state;
        rx_done_reg <= '0';
        rx_reg <= (others => '0');
        oversample_reg <= 0;
        oversample_count <= 0;
        bit_count <= 0;

        case state is
            -------------------------------------------------------------------
            -- IDLE state, wait for start bit
            -------------------------------------------------------------------
            when idle =>
                if rx = '0' then
                    next_state <= start;
                    next_bit_count <= 0;
                    next_oversample_count <= 0;
                else
                    next_state <= idle;
                    next_bit_count <= 0;
                    next_oversample_count <= 0;
                end if;
            -------------------------------------------------------------------
            -- START state, wait 8 clocks to sample data
            -------------------------------------------------------------------
            when start =>
                if oversample_count = 7 then
                    next_state <= data;
                    next_oversample_count <= 0;
                    next_bit_count <= 0;
                else
                    next_state <= start;
                    next_oversample_count <= oversample_count + 1;
                    next_bit_count <= 0;
                end if;
            -------------------------------------------------------------------
            -- DATA state, sample data 8 times per bit, majority rules
            -------------------------------------------------------------------
            when data => --TODO ignore edge samples
                if oversample_count = 7 then
                    if bit_count = 7 then
                        next_state <= stop;
                        next_oversample_count <= 0;
                        next_bit_count <= 0;
                    else
                        next_state <= data;
                        next_oversample_count <= 0;
                        next_bit_count <= bit_count + 1;
                        if oversample_reg > 3 then
                            rx_reg(bit_count) <= '1';
                        else
                            rx_reg(bit_count) <= '0';
                        end if;
                    end if;
                else
                    next_state <= data;
                    next_oversample_count <= oversample_count + 1;
                    next_bit_count <= bit_count;
                    if rx = '1' then
                        oversample_reg <= oversample_reg + 1;
                    else
                        oversample_reg <= oversample_reg;
                    end if;
                end if;
            -- No parity bit
            -------------------------------------------------------------------
            -- STOP state, wait 8 clocks to sample stop bit
            -------------------------------------------------------------------
            --TODO: decide when to set rx_done_reg to '1'
            when stop =>
                if oversample_count = 7 then
                    next_state <= idle;
                    next_oversample_count <= 0;
                    next_bit_count <= 0;
                else
                    next_state <= stop;
                    next_oversample_count <= oversample_count + 1;
                    next_bit_count <= 0;
                    rx_done_reg <= '1';
                end if;
            when stop =>

        end case;
    end process;
end Behavioral;
