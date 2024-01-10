library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_TX is
    Port ( clk : in  STD_LOGIC;
           rst_l : in  STD_LOGIC;
           tx_data : in  STD_LOGIC_VECTOR (7 downto 0);
           tx_write : in STD_LOGIC;
           tx : out  STD_LOGIC;
           tx_done : out  STD_LOGIC);
end UART_TX;

architecture behavioral of UART_TX is

    type state_type is (idle, start, data, stop);
    signal state : state_type := idle;
    signal next_state : state_type := idle;
    signal oversample_count : integer range 0 to 7 := 0; -- counts how many times we've sampled the RX line per bit
    signal next_oversample_count : integer range 0 to 7 := 0;
    signal bit_count : integer range 0 to 7 := 0; -- counts which bit we're on in the data state
    signal next_bit_count : integer range 0 to 7 := 0;

    signal clk_counter : integer range 0 to 127 := 0;

begin

    -- Synchronous process, handles clock and reset
    process (clk, rst_l) begin
        -- Asynchronous reset
        if rst_l = '0' then
            state <= idle;
            
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

end behavioral;