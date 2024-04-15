library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.dlxlib.all;


entity LCM is 
    port (
        clk : in std_logic;
        rst_l : in std_logic;
        v1 : in unsigned(DATA_WIDTH-1 downto 0);
        v2 : in unsigned(DATA_WIDTH-1 downto 0);
        start : in std_logic;
        done : out std_logic := '0';
        vout : out unsigned(DATA_WIDTH-1 downto 0) := (others => '0');
        err : out std_logic := '0'
    );
end LCM;

architecture Behavioral of LCM is

    type stateType is (S_IDLE, S_ADD, S_DONE, S_ERROR);
    signal state : stateType := S_IDLE;
    signal next_state : stateType := S_IDLE;
    signal v1_locked : unsigned(DATA_WIDTH-1 downto 0);
    signal next_v1_locked : unsigned(DATA_WIDTH-1 downto 0);
    signal v2_locked : unsigned(DATA_WIDTH-1 downto 0);
    signal next_v2_locked : unsigned(DATA_WIDTH-1 downto 0);
    signal v1_accumulator : unsigned(DATA_WIDTH-1 downto 0);
    signal next_v1_accumulator : unsigned(DATA_WIDTH-1 downto 0);
    signal v2_accumulator : unsigned(DATA_WIDTH-1 downto 0);
    signal next_v2_accumulator : unsigned(DATA_WIDTH-1 downto 0);
    signal vout_sig : unsigned(DATA_WIDTH-1 downto 0);
    signal next_vout_sig : unsigned(DATA_WIDTH-1 downto 0);
    signal next_err : std_logic := '0';
    signal done_sig : std_logic := '0';
    signal next_done_sig : std_logic := '0';

begin

vout <= vout_sig;
done <= done_sig;

process(clk, rst_l) begin
    if rst_l = '0' then
        state <= S_IDLE;
        v1_locked <= (others => '0');
        v2_locked <= (others => '0');
        v1_accumulator <= (others => '0');
        v2_accumulator <= (others => '0');
        vout_sig <= (others => '0');
        err <= '0';
        done <= '0';
    elsif rising_edge(clk) then
        state <= next_state;
        v1_locked <= next_v1_locked;
        v2_locked <= next_v2_locked;
        v1_accumulator <= next_v1_accumulator;
        v2_accumulator <= next_v2_accumulator;
        vout_sig <= next_vout_sig;
        err <= next_err;
        done <= next_done_sig;
    end if;
end process;

process(state, v1_locked, v2_locked, v1_accumulator, v2_accumulator, done_sig, vout_sig, v1, v2, start) begin
    next_v1_locked <= v1_locked;
    next_v2_locked <= v2_locked;
    next_v1_accumulator <= v1_accumulator;
    next_v2_accumulator <= v2_accumulator;
    next_vout_sig <= vout_sig;
    next_done_sig <= done_sig;
    case state is
        when S_IDLE =>
            if start = '1' then
                next_done_sig <= '0';
                next_v1_locked <= v1;
                next_v2_locked <= v2;
                next_v1_accumulator <= v1;
                next_v2_accumulator <= v2;
                next_state <= S_ADD;
            else
                next_state <= S_IDLE;
            end if;
        when S_ADD =>
            if v1_accumulator = v2_accumulator then
                next_done_sig <= '1';
                next_vout_sig <= v1_accumulator;
                next_state <= S_DONE;
            elsif v1_accumulator < v2_accumulator then
                if v1_accumulator + v1_locked < v1_accumulator then -- overflow protection (prevents infinite loop)
                    next_err <= '1';
                    next_state <= S_ERROR;
                else
                    next_v1_accumulator <= v1_accumulator + v1_locked;
                    next_state <= S_ADD;
                end if;
            else
                if v2_accumulator + v2_locked < v2_accumulator then 
                    next_err <= '1';
                    next_state <= S_ERROR;
                else
                    next_v2_accumulator <= v2_accumulator + v2_locked;
                    next_state <= S_ADD;
                end if;
            end if;
        when S_DONE =>
            if start = '1' then
                next_state <= S_DONE;
            else
                next_state <= S_IDLE;
            end if;
        when S_ERROR =>
            next_state <= S_ERROR;
            next_err <= '1';
    end case;
end process;

end Behavioral;