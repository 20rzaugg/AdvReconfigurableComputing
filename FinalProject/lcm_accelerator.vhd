library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
library work;
use work.dlxlib.all;

entity lcm_accelerator is
    port(
        clk_10 : in std_logic;
        clk_50 : in std_logic;
        rst_l : in std_logic;
        v1 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        v2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        start : in std_logic;
        result : out std_logic_vector(DATA_WIDTH-1 downto 0);
        done : out std_logic
    );
end lcm_accelerator;

architecture behavioral of lcm_accelerator is

    component accelerator_dcfifo is
        port(
            aclr : IN STD_LOGIC := '0';
		    data : IN STD_LOGIC_VECTOR (127 DOWNTO 0);
		    rdclk : IN STD_LOGIC;
		    rdreq : IN STD_LOGIC;
		    wrclk : IN STD_LOGIC;
		    wrreq : IN STD_LOGIC;
		    q : OUT STD_LOGIC_VECTOR (127 DOWNTO 0);
		    rdempty	: OUT STD_LOGIC;
		    wrfull : OUT STD_LOGIC 
        );
    end component;

    component accelerator_dcfifo_out is
        port (
            aclr : IN STD_LOGIC := '0';
		    data : IN STD_LOGIC_VECTOR (63 DOWNTO 0);
		    rdclk : IN STD_LOGIC;
		    rdreq : IN STD_LOGIC;
		    wrclk : IN STD_LOGIC;
		    wrreq : IN STD_LOGIC;
		    q : OUT STD_LOGIC_VECTOR (63 DOWNTO 0);
		    rdempty : OUT STD_LOGIC;
		    wrfull : OUT STD_LOGIC 
        );
    end component;

    component lcm is
        port(
            clk : in std_logic;
            rst_l : in std_logic;
            vin : in std_logic_vector(DATA_WIDTH*2-1 downto 0);
            queue_in_empty : in std_logic;
            queue_in_read : out std_logic;
            queue_out_write : out std_logic := '0';
            queue_out_full : in std_logic;
            vout : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0')
        );
    end component;

    type state_type is (S_IDLE, S_HOLD, S_READ, S_DONE);
    signal state : state_type := S_IDLE;
    signal next_state : state_type := S_IDLE;

    signal aclr : std_logic := '0';
    signal speedy_queue_in_input : std_logic_vector(127 downto 0);
    signal speedy_queue_in_output : std_logic_vector(127 downto 0);
    signal speedy_queue_out_input : std_logic_vector(63 downto 0);
    signal speedy_queue_out_output : std_logic_vector(63 downto 0);
    signal in_queue_empty : std_logic;
    signal in_queue_full : std_logic;
    signal in_queue_read : std_logic := '0';
    signal in_queue_write : std_logic := '0';
    signal out_queue_empty : std_logic;
    signal out_queue_full : std_logic;
    signal out_queue_read : std_logic := '0';
    signal out_queue_write : std_logic := '0';
    signal result_sig : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal next_result_sig : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    aclr <= not rst_l;
    speedy_queue_in_input <= v1 & v2;
    result <= result_sig;

    accelerator_dcfifo_in_inst : accelerator_dcfifo
        port map(
            aclr => aclr,
            data => speedy_queue_in_input,
            rdclk => clk_50,
            rdreq => in_queue_read,
            wrclk => clk_10,
            wrreq => in_queue_write,
            q => speedy_queue_in_output,
            rdempty => in_queue_empty,
            wrfull => in_queue_full
        );

    accelerator_dcfifo_out_inst : accelerator_dcfifo_out
        port map(
            aclr => aclr,
            data => speedy_queue_out_input,
            rdclk => clk_10,
            rdreq => out_queue_read,
            wrclk => clk_50,
            wrreq => out_queue_write,
            q => speedy_queue_out_output,
            rdempty => out_queue_empty,
            wrfull => out_queue_full
        );

    lcm_accelerator : lcm
        port map (
            clk => clk_50,
            rst_l => rst_l,
            vin => speedy_queue_in_output,
            queue_in_empty => in_queue_empty,
            queue_in_read => in_queue_read,
            queue_out_write => out_queue_write,
            queue_out_full => out_queue_full,
            vout => speedy_queue_out_input
        );

    process(clk_10, rst_l) begin
        if rst_l = '0' then
            state <= S_IDLE;
        elsif rising_edge(clk_10) then
            state <= next_state;
            result_sig <= next_result_sig;
        end if;
    end process;

    process(state, start, in_queue_full, out_queue_empty, speedy_queue_out_output, result_sig) begin
        in_queue_write <= '0';
        out_queue_read <= '0';
        next_result_sig <= result_sig;
        case state is
            when S_IDLE =>
                if start = '1' then
                    next_state <= S_HOLD;
                    in_queue_write <= '1';
                else
                    next_state <= S_IDLE;
                end if;
            when S_HOLD =>
                if out_queue_empty = '0' then
                    next_state <= S_READ;
                    out_queue_read <= '1';
                else
                    next_state <= S_HOLD;
                end if;
            when S_READ =>
                next_state <= S_DONE;
            when S_DONE =>
                next_result_sig <= speedy_queue_out_output(63 downto 0);
                next_state <= S_IDLE;
        end case;
    end process;

    done <= '1' when state = S_DONE else '0';

end behavioral;