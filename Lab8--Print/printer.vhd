library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.dlxlib.all;

entity printer is
    port ( 
        clk : in  std_logic;
        rst_l : in  std_logic;
        instr_in : in std_logic_vector(INSTR_WIDTH-1 downto 0);
        data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
        instr_queue_full : out std_logic;
        tx : out std_logic
    );
end printer;

architecture behavioral of printer is

    component pll1 is
        port (
            areset : in std_logic := '0';
            inclk0 : in std_logic := '0'; -- 50.0 MHz
            c0 : out std_logic -- 19.2 kHz
        );
    end component;

    component print_instr_queue is
        port (
            clock : IN STD_LOGIC ;
		    data : IN STD_LOGIC_VECTOR (37 DOWNTO 0);
		    rdreq : IN STD_LOGIC ;
		    sclr : IN STD_LOGIC ;
		    wrreq : IN STD_LOGIC ;
		    empty : OUT STD_LOGIC ;
		    full : OUT STD_LOGIC ;
		    q : OUT STD_LOGIC_VECTOR (37 DOWNTO 0)
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
            numer : in std_logic_vector (31 downto 0);
            quotient : out std_logic_vector (31 downto 0);
            remain : out std_logic_vector (3 downto 0)
        );
    end component;

    component ip_divider_unsigned is
        port (
            denom : in std_logic_vector (3 downto 0);
            numer : in std_logic_vector (31 downto 0);
            quotient : out std_logic_vector (31 downto 0);
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
    signal instr_queue_out : std_logic_vector(37 downto 0);

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

    signal uart_tx_clk : std_logic;
    signal uart_tx_buffer_read : std_logic;
    signal write_char : std_logic;
    signal uart_queue_empty : std_logic;
    signal uart_char : std_logic_vector(7 downto 0);
    
    signal numerator : std_logic_vector(31 downto 0);
    signal signed_quotient : std_logic_vector(31 downto 0);
    signal signed_remainder : std_logic_vector(3 downto 0);
    signal unsigned_quotient : std_logic_vector(31 downto 0);
    signal unsigned_remainder : std_logic_vector(3 downto 0); 

begin

    pll_inst : pll1
        port map (
            areset => not rst_l,
            inclk0 => clk,
            c0 => uart_tx_clk
        );

    print_instr_queue_inst : print_instr_queue
        port map (
            clock => clk,
            data => instr_in(31 downto 26) & data_in(31 downto 0),
            rdreq => instr_read,
            sclr => not rst_l, -- check if correct
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
            rdclk => uart_tx_clk,
            rdreq => uart_tx_buffer_read,
            wrclk => clk,
            wrreq => write_char,
            q => uart_char,
            rdempty => uart_queue_empty,
            wrfull => instr_queue_full
        );

    UART_tx_inst : UART_tx
        port map (
            clk => uart_tx_clk,
            rst_l => rst_l,
            tx_data => uart_char,
            tx_write => not uart_queue_empty,
            tx => tx,
            read_from_buffer => uart_tx_buffer_read
        );

    process(clk, rst_l) is begin
        if rst_l = '0' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    process(state, instr_queue_out, instr_queue_empty, digit_empty, digit_top, signed_quotient, unsigned_quotient, signed_remainder, unsigned_remainder) is begin
        case state is
            when IDLE =>
                write_char <= '0';
                digit_pop <= '0';
                fifo_char <= (others => '0');
                if instr_queue_empty = '0' then
                    next_state <= READQ;
                    instr_read <= '1';
                else
                    next_state <= IDLE;
                    instr_read <= '0';
                end if;
            when READQ =>
                digit_pop <= '0';
                fifo_char <= (others => '0');
                write_char <= '0';
                instr_read <= '0';
                if instr_queue_out(37 downto 32) = PCH then
                    next_state <= PCHAR;
                elsif instr_queue_out(37 downto 32) = PD or instr_queue_out(37 downto 32) = PDU then
                    next_state <= DIVIDEx;
                    numerator <= instr_queue_out(31 downto 0);
                else
                    next_state <= IDLE;
                end if;
            when PCHAR =>
                digit_pop <= '0';
                next_state <= IDLE;
                fifo_char <= instr_queue_out(7 downto 0);
                write_char <= '1';
                instr_read <= '0';
                digit_push <= '0';
            when DIVIDEx =>
                digit_pop <= '0';
                fifo_char <= (others => '0');
                write_char <= '0';
                instr_read <= '0';
                digit_push <= '0';
                next_state <= STORE;
            when STORE =>
                digit_pop <= '0';
                write_char <= '0';
                instr_read <= '0';
                digit_push <= '1';
                if instr_queue_out(37 downto 32) = PD then
                    digit_in <= std_logic_vector(unsigned("0000" & signed_remainder) + 48);
                    if signed_quotient = x"00000000" then
                        next_state <= NEGATIVE;
                    else
                        next_state <= DIVIDEx;
                        numerator <= signed_quotient;
                    end if;
                elsif instr_queue_out(37 downto 32) = PDU then
                    digit_in <= std_logic_vector(unsigned("0000" & unsigned_remainder) + 48);
                    if unsigned_quotient = x"00000000" then
                        next_state <= UNSTACK;
                    else
                        next_state <= DIVIDEx;
                        numerator <= unsigned_quotient;
                    end if;
                else
                    next_state <= IDLE;
                end if;
            when NEGATIVE =>
                digit_pop <= '0';
                next_state <= UNSTACK;
                if instr_queue_out(37 downto 32) = PD and instr_queue_out(31) = '1' then
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

    instr_write <= '1' when instr_in(31 downto 26) = PCH or instr_in(31 downto 26) = PD or instr_in(31 downto 26) = PDU else '0';

end behavioral;