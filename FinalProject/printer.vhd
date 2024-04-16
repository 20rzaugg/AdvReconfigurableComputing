library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.dlxlib.all;

entity printer is
    port ( 
        clk : in  std_logic;
        tx_clk : in std_logic;
        rst_l : in  std_logic;
        instr_in : in std_logic_vector(INSTR_WIDTH-1 downto 0);
        data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
        instr_queue_full : out std_logic;
        tx : out std_logic
    );
end printer;

architecture behavioral of printer is

    component print_instr_queue is
        port (
            clock : IN STD_LOGIC ;
		    data : IN STD_LOGIC_VECTOR (71 DOWNTO 0);
		    rdreq : IN STD_LOGIC ;
		    sclr : IN STD_LOGIC ;
		    wrreq : IN STD_LOGIC ;
		    empty : OUT STD_LOGIC ;
		    full : OUT STD_LOGIC ;
		    q : OUT STD_LOGIC_VECTOR (71 DOWNTO 0)
        );
    end component;

    component digit_stack is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            push : in std_logic;
            pop : in std_logic;
            data_in : in std_logic_vector(7 downto 0);
            top_value : out std_logic_vector(7 downto 0);
            empty : out std_logic;
            full : out std_logic
        );
    end component;

    component ip_divider_signed is
        port (
            denom : in std_logic_vector (3 downto 0);
            numer : in std_logic_vector (63 downto 0);
            quotient : out std_logic_vector (63 downto 0);
            remain : out std_logic_vector (3 downto 0)
        );
    end component;

    component ip_divider_unsigned is
        port (
            denom : in std_logic_vector (3 downto 0);
            numer : in std_logic_vector (63 downto 0);
            quotient : out std_logic_vector (63 downto 0);
            remain : out std_logic_vector (3 downto 0)
        );
    end component;

    component dcfifo1 is
        port (
            data : in std_logic_vector(7 downto 0);
            rdclk : in std_logic;
            rdreq : in std_logic;
            wrclk : in std_logic;
            wrreq : in std_logic;
            q : out std_logic_vector(7 downto 0);
            rdempty : out std_logic;
            wrfull : out std_logic
        );
    end component;

    component UART_tx is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            tx_data : in std_logic_vector(7 downto 0);
            tx_write : in std_logic;
            tx : out std_logic;
            read_from_buffer : out std_logic
        );
	 end component;
	 
    signal instr_read : std_logic := '0';
    signal instr_write : std_logic := '0';
    signal instr_queue_empty : std_logic;
    signal instr_queue_out : std_logic_vector(71 downto 0);

    signal digit_push : std_logic := '0';
    signal digit_pop : std_logic := '0';
    signal digit_empty : std_logic;
    signal digit_full : std_logic;
    signal digit_in : std_logic_vector(7 downto 0);
    signal digit_top : std_logic_vector(7 downto 0);

    type stateType is (IDLE, READQ, PCHAR, DIVIDEx, STORE, NEGATIVE, UNSTACK);
    signal state : stateType := IDLE;
    signal next_state : stateType := IDLE;

    signal fifo_char : std_logic_vector(7 downto 0);

    signal uart_tx_buffer_read : std_logic;
    signal write_char : std_logic;
    signal uart_queue_empty : std_logic;
    signal uart_char : std_logic_vector(7 downto 0);
    signal uart_queue_full : std_logic;
    
    signal numerator : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal next_numerator : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal signed_quotient : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal signed_remainder : std_logic_vector(3 downto 0);
    signal unsigned_quotient : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal unsigned_remainder : std_logic_vector(3 downto 0); 

    signal n_rst_l : std_logic;
    signal n_uart_queue_empty : std_logic;
    signal queue_data_in : std_logic_vector(71 downto 0);

begin

    n_rst_l <= not rst_l;
    n_uart_queue_empty <= not uart_queue_empty;
    queue_data_in <= opcode(instr_in) & data_in(63 downto 0);

    print_instr_queue_inst : print_instr_queue
        port map (
            clock => clk,
            data => queue_data_in,
            rdreq => instr_read,
            sclr => n_rst_l, -- check if correct
            wrreq => instr_write,
            empty => instr_queue_empty,
            full => instr_queue_full,
            q => instr_queue_out
        );

    digit_stack_inst : digit_stack
        port map (
            clk => clk,
            rst_l => rst_l,
            push => digit_push,
            pop => digit_pop,
            data_in => digit_in,
            top_value => digit_top,
            empty => digit_empty,
            full => digit_full
        );

    ip_divider_signed_inst : ip_divider_signed
        port map (
            denom => "1010",
            numer => numerator,
            quotient => signed_quotient,
            remain => signed_remainder
        );

    ip_divider_unsigned_inst : ip_divider_unsigned
        port map (
            denom => "1010",
            numer => numerator,
            quotient => unsigned_quotient,
            remain => unsigned_remainder
        );
    
    dcfifo1_inst : dcfifo1
        port map (
            data => fifo_char,
            rdclk => tx_clk,
            rdreq => uart_tx_buffer_read,
            wrclk => clk,
            wrreq => write_char,
            q => uart_char,
            rdempty => uart_queue_empty,
            wrfull => uart_queue_full
        );

    UART_tx_inst : UART_tx
        port map (
            clk => tx_clk,
            rst_l => rst_l,
            tx_data => uart_char,
            tx_write => n_uart_queue_empty,
            tx => tx,
            read_from_buffer => uart_tx_buffer_read
        );

    process(clk, rst_l) is begin
        if rst_l = '0' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
            numerator <= next_numerator;
        end if;
    end process;

    process(state, instr_queue_out, instr_queue_empty, digit_empty, digit_top, signed_quotient, unsigned_quotient, signed_remainder, unsigned_remainder, numerator) is begin
        next_numerator <= numerator;
        write_char <= '0';
        digit_pop <= '0';
        digit_push <= '0';
        instr_read <= '0';
        fifo_char <= (others => '0');
        case state is
            when IDLE =>
                if instr_queue_empty = '0' then
                    next_state <= READQ;
                    instr_read <= '1';
                else
                    next_state <= IDLE;
                end if;
            when READQ =>
                if op_cmp(instr_queue_out(71 downto 64), PCH) then
                    next_state <= PCHAR;
                elsif op_cmp(instr_queue_out(71 downto 64), PD) then
                    next_state <= DIVIDEx;
                    next_numerator <= instr_queue_out(63 downto 0);
                else
                    next_state <= IDLE;
                end if;
            when PCHAR =>
                next_state <= IDLE;
                fifo_char <= instr_queue_out(7 downto 0);
                write_char <= '1';
            when DIVIDEx =>
                next_state <= STORE;
            when STORE =>
                digit_push <= '1';
                if is_unsigned(instr_queue_out(71 downto 64)) = '0' then
                    digit_in <= std_logic_vector(unsigned("0000" & signed_remainder) + 48);
                    if signed_quotient = x"0000000000000000" then
                        next_state <= NEGATIVE;
                    else
                        next_state <= DIVIDEx;
                        next_numerator <= signed_quotient;
                    end if;
                elsif is_unsigned(instr_queue_out(71 downto 64)) = '1' then
                    digit_in <= std_logic_vector(unsigned("0000" & unsigned_remainder) + 48);
                    if unsigned_quotient = x"0000000000000000" then
                        next_state <= UNSTACK;
                    else
                        next_state <= DIVIDEx;
                        next_numerator <= unsigned_quotient;
                    end if;
                else
                    next_state <= IDLE;
                end if;
            when NEGATIVE =>
                digit_pop <= '0';
                next_state <= UNSTACK;
                if is_unsigned(instr_queue_out(71 downto 64)) = '0' and instr_queue_out(63) = '1' then
                    digit_in <= "00101101"; -- '-'?
                    digit_push <= '1';
                else
                    digit_in <= (others => '0');
                    digit_push <= '0';
					 end if;
            when UNSTACK =>
                if digit_empty = '0' then
                    next_state <= UNSTACK;
                    fifo_char <= digit_top;
                    write_char <= '1';
                    digit_pop <= '1';
                else
                    next_state <= IDLE;
                    digit_pop <= '0';
                end if;
            when others =>
                next_state <= IDLE;
        end case;
	 end process;

    instr_write <= '1' when op_cmp(opcode(instr_in), PCH) or op_cmp(opcode(instr_in), PD) else '0';

end behavioral;