library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_TX is
    Port ( clk : in  STD_LOGIC;
           rst_l : in  STD_LOGIC;
           tx_data : in  STD_LOGIC_VECTOR (7 downto 0);
           tx_write : in STD_LOGIC;
           tx : out  STD_LOGIC;
           read_from_buffer : out  STD_LOGIC);
end UART_TX;

architecture behavioral of UART_TX is

    type state_type is (idle, read, start, data, stop);
    signal state : state_type := idle;
    signal next_state : state_type := idle;
    signal bit_count : integer range 0 to 7 := 0; -- counts which bit we're on in the data state
    signal next_bit_count : integer range 0 to 7 := 0;

    signal tx_data_reg : std_logic_vector (7 downto 0) := "00000000"; -- lock in TX data so the input signal can be changed during transmission


begin

    -- Synchronous process, handles clock and reset
    process (clk, rst_l) begin
        -- Asynchronous reset
        if rst_l = '0' then
            state <= idle;
            
        --Rising clock edge
        elsif rising_edge(clk) then
            state <= next_state;
            bit_count <= next_bit_count;
        end if;
    end process;

    process (clk, rst_l, state, next_state, bit_count, next_bit_count, tx_data, tx_write, tx_data_reg) begin
        case state is
            -------------------------------------------------------------------
            -- IDLE state, wait for tx_write to go high
            -------------------------------------------------------------------
            when idle =>
                tx <= '1';
                tx_data_reg <= tx_data_reg;
                if tx_write = '1' then
                    next_state <= read;
                    next_bit_count <= 0;
                    read_from_buffer <= '1';
                else
                    next_state <= idle;
                    next_bit_count <= 0;
                    read_from_buffer <= '0';
                end if;
            -------------------------------------------------------------------
            -- START state, wait 8 clocks to transmit data
            -------------------------------------------------------------------
            when read =>
                tx <= '1';
                read_from_buffer <= '0';
                tx_data_reg <= tx_data;
                next_state <= start;
                next_bit_count <= 0;
            when start =>
                tx <= '0';
                read_from_buffer <= '0';
                tx_data_reg <= tx_data_reg;
                next_state <= data;
                next_bit_count <= 0;    
            -------------------------------------------------------------------
            -- DATA state, transmit data, 8 clock cycles per bit
            -------------------------------------------------------------------
            when data =>
                tx <= tx_data(bit_count);
                read_from_buffer <= '0';
                tx_data_reg <= tx_data_reg;
                if bit_count = 7 then
                    next_state <= stop;
                    next_bit_count <= 0;
                else
                    next_state <= data;
                    next_bit_count <= bit_count + 1;
                end if;
            -- no parity bit
            -------------------------------------------------------------------
            -- STOP state, set TX to 1 for 8 clock cycles for stop bit
            -------------------------------------------------------------------
            when stop =>
                tx <= '1';
                tx_data_reg <= tx_data_reg;
                next_state <= idle;
                next_bit_count <= 0;
                read_from_buffer <= '0';
        end case;
    end process;

end behavioral;