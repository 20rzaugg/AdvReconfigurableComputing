library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.dlxlib.all;

entity scanner is
    port (
        clk : in std_logic;
        rx_clk : in std_logic;
        rst_l : in std_logic;
        rx : in std_logic;
        instr_in : in std_logic_vector(INSTR_WIDTH-1 downto 0);
        input_buffer_empty : inout std_logic;
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity scanner; 

architecture behavioral of scanner is

    component UART_rx is
        port (
            clk : in  STD_LOGIC;
            rst_l : in  STD_LOGIC;
            rx : in  STD_LOGIC;
            rx_data : out  STD_LOGIC_VECTOR (7 downto 0);
            rx_done : out  STD_LOGIC
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

    component input_buffer is
        port (
            clock : in std_logic;
            data : in std_logic_vector (64 downto 0);
            rdreq : in std_logic;
            sclr : in std_logic;
            wrreq : in std_logic;
            empty : out std_logic;
            full : out std_logic;
            q : out std_logic_vector (64 downto 0)
        );
    end component;

    component multiplier_unsigned is
        port (
            dataa : in std_logic_vector(63 downto 0);
            result : out std_logic_vector(67 downto 0)
        );
    end component;

    type state_type is (IDLE, RECEIVE, DIGIT);
    signal state : state_type := IDLE;
    signal next_state : state_type := IDLE;

    type rd_state_type is (IDLE, DEQUEUE);
    signal rd_state : rd_state_type := IDLE;
    signal next_rd_state : rd_state_type := IDLE;

    signal multiplicant : std_logic_vector(63 downto 0);
    signal next_multiplicantx : std_logic_vector(63 downto 0);
    signal product : std_logic_vector(67 downto 0);

    signal total : std_logic_vector(63 downto 0) := (others => '0');
    signal next_total : std_logic_vector(63 downto 0) := (others => '0');
    signal neg_flag : std_logic := '0';
    signal next_neg_flag : std_logic := '0';

    signal rx_data : std_logic_vector(7 downto 0);
    signal rx_done : std_logic;

    signal dcfifo_out : std_logic_vector(7 downto 0);
    signal rdempty : std_logic;
    signal wrfull : std_logic;
    signal rdchar : std_logic := '0';

    signal input_buffer_wr : std_logic := '0';
    signal input_buffer_data : std_logic_vector(64 downto 0);
    signal sclr : std_logic;
    signal input_buffer_full : std_logic;
    signal input_buffer_output : std_logic_vector(64 downto 0);
    signal input_buffer_read : std_logic := '0';


begin

    input_buffer_data <= neg_flag & total;
    sclr <= not rst_l;

    UART_rx_inst : UART_rx
        port map (
            clk => rx_clk,
            rst_l => rst_l,
            rx => rx,
            rx_data => rx_data,
            rx_done => rx_done
        );

    dcfifo1_inst : dcfifo1
        port map (
            data => rx_data,
            rdclk => clk,
            rdreq => rdchar,
            wrclk => rx_clk,
            wrreq => rx_done,
            q => dcfifo_out,
            rdempty => rdempty,
            wrfull => wrfull
        );

    input_buffer_inst : input_buffer
        port map (
            clock => clk,
            data => input_buffer_data,
            rdreq => input_buffer_read,
            sclr => sclr,
            wrreq => input_buffer_wr,
            empty => input_buffer_empty,
            full => input_buffer_full,
            q => input_buffer_output
        );

    multiplier_unsigned_inst : multiplier_unsigned
        port map (
            dataa => multiplicant,
            result => product
        );

    process(clk, rst_l) begin
        if rst_l = '0' then
            state <= IDLE;
            multiplicant <= (others => '0');
            total <= (others => '0');
            neg_flag <= '0';
            rd_state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
            multiplicant <= next_multiplicantx;
            neg_flag <= next_neg_flag;
            total <= next_total;
            rd_state <= next_rd_state;
        end if;
    end process;

    process(state, dcfifo_out, rdempty, product, total, neg_flag) begin
        next_multiplicantx <= multiplicant;
        next_neg_flag <= neg_flag;
        next_total <= total;
        rdchar <= '0';
        input_buffer_wr <= '0';
        case state is
            when IDLE =>
                if rdempty = '0' then
                    rdchar <= '1';
                    next_state <= RECEIVE;
                else
                    next_state <= IDLE;
                end if;
            when RECEIVE =>
                if unsigned(total) = 0 and unsigned(dcfifo_out) = 45 then
                    next_neg_flag <= '1';
                    next_state <= IDLE;
                elsif unsigned(dcfifo_out) > 47 and unsigned(dcfifo_out) < 58 then
                    next_multiplicantx <= total;
                    next_state <= DIGIT;
                elsif unsigned(dcfifo_out) = 13 or unsigned(dcfifo_out) = 32 then --space or \r
                    next_total <= (others => '0');
                    next_neg_flag <= '0';
                    input_buffer_wr <= '1';
                    next_state <= IDLE;
                else
                    next_state <= IDLE;
                end if;
            when DIGIT =>
                next_total <= std_logic_vector(unsigned(product(63 downto 0)) + unsigned(dcfifo_out) - 48);
                next_state <= IDLE;
        end case;
    end process;

    process(rd_state, instr_in, input_buffer_output, input_buffer_empty) begin
        input_buffer_read <= '0';
        case rd_state is
            when IDLE =>
                if (op_cmp(opcode(instr_in), GD)) and input_buffer_empty = '0' then
                    next_rd_state <= DEQUEUE;
                    input_buffer_read <= '1';
                else
                    next_rd_state <= IDLE;
                end if;
            when DEQUEUE =>
                next_rd_state <= IDLE;
                if is_unsigned(opcode(instr_in)) = '0' and input_buffer_output(64) = '1' then
                    data_out <= std_logic_vector(signed(not input_buffer_output(63 downto 0)) + 1);
                else
                    data_out <= input_buffer_output(63 downto 0);
                end if;
        end case;
    end process;

end behavioral;