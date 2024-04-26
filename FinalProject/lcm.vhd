library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.dlxlib.all;


entity LCM is 
    port (
        clk : in std_logic;
        rst_l : in std_logic;
        vin : in std_logic_vector(DATA_WIDTH*2-1 downto 0);
        queue_in_empty : in std_logic;
        queue_in_read : out std_logic;
        queue_out_write : out std_logic := '0';
        queue_out_full : in std_logic;
        vout : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0')
    );
end LCM;

architecture Behavioral of LCM is

    type stateType is (S_IDLE, S_READ, S_ADD, S_DONE);
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

begin

vout <= std_logic_vector(vout_sig);

process(clk, rst_l) begin
    if rst_l = '0' then
        state <= S_IDLE;
        v1_locked <= (others => '0');
        v2_locked <= (others => '0');
        v1_accumulator <= (others => '0');
        v2_accumulator <= (others => '0');
        vout_sig <= (others => '0');
    elsif rising_edge(clk) then
        state <= next_state;
        v1_locked <= next_v1_locked;
        v2_locked <= next_v2_locked;
        v1_accumulator <= next_v1_accumulator;
        v2_accumulator <= next_v2_accumulator;
        vout_sig <= next_vout_sig;
    end if;
end process;

process(state, v1_locked, v2_locked, v1_accumulator, v2_accumulator, vout_sig, vin, queue_in_empty, queue_out_full) begin
    next_v1_locked <= v1_locked;
    next_v2_locked <= v2_locked;
    next_v1_accumulator <= v1_accumulator;
    next_v2_accumulator <= v2_accumulator;
    next_vout_sig <= vout_sig;
    queue_out_write <= '0';
    queue_in_read <= '0';
    case state is
        when S_IDLE =>
            if queue_in_empty = '0' then
                next_state <= S_READ;
                queue_in_read <= '1';
            else
                next_state <= S_IDLE;
            end if;
        when S_READ =>
            next_v1_locked <= unsigned(vin(DATA_WIDTH*2-1 downto DATA_WIDTH));
            next_v2_locked <= unsigned(vin(DATA_WIDTH-1 downto 0));
            next_v1_accumulator <= unsigned(vin(DATA_WIDTH*2-1 downto DATA_WIDTH));
            next_v2_accumulator <= unsigned(vin(DATA_WIDTH-1 downto 0));
            next_state <= S_ADD;
        when S_ADD =>
            if v1_accumulator = v2_accumulator then
                next_vout_sig <= v1_accumulator;
                next_state <= S_DONE;
            elsif v1_accumulator < v2_accumulator then
                if v1_accumulator + v1_locked < v1_accumulator then -- overflow protection (prevents infinite loop)
                    next_vout_sig <= (others => '1');
                    next_state <= S_DONE;
                else
                    next_state <= S_ADD;
                    if v1_accumulator + shift_left(v1_locked, 8) < v2_accumulator then
                        next_v1_accumulator <= v1_accumulator + shift_left(v1_locked, 8) + v1_locked;
                    elsif v1_accumulator + shift_left(v1_locked, 7) < v2_accumulator then
                        next_v1_accumulator <= v1_accumulator + shift_left(v1_locked, 7) + v1_locked;
                    elsif v1_accumulator + shift_left(v1_locked, 6) < v2_accumulator then
                        next_v1_accumulator <= v1_accumulator + shift_left(v1_locked, 6) + v1_locked;
                    elsif v1_accumulator + shift_left(v1_locked, 5) < v2_accumulator then
                        next_v1_accumulator <= v1_accumulator + shift_left(v1_locked, 5) + v1_locked;
                    elsif v1_accumulator + shift_left(v1_locked, 4) < v2_accumulator then
                        next_v1_accumulator <= v1_accumulator + shift_left(v1_locked, 4) + v1_locked;
                    elsif v1_accumulator + shift_left(v1_locked, 3) < v2_accumulator then
                        next_v1_accumulator <= v1_accumulator + shift_left(v1_locked, 3) + v1_locked;
                    elsif v1_accumulator + shift_left(v1_locked, 2) < v2_accumulator then
                        next_v1_accumulator <= v1_accumulator + shift_left(v1_locked, 2) + v1_locked;
                    elsif v1_accumulator + shift_left(v1_locked, 1) < v2_accumulator then
                        next_v1_accumulator <= v1_accumulator + shift_left(v1_locked, 1) + v1_locked;
                    else
                        next_v1_accumulator <= v1_accumulator + v1_locked;
                    end if;
                end if;
            else
                if v2_accumulator + v2_locked < v2_accumulator then 
                    next_vout_sig <= (others => '1');
                    next_state <= S_DONE;
                else
                    next_state <= S_ADD;
                    if v2_accumulator + shift_left(v2_locked, 8) < v1_accumulator then
                        next_v2_accumulator <= v2_accumulator + shift_left(v2_locked, 8) + v2_locked;
                    elsif v2_accumulator + shift_left(v2_locked, 7) < v1_accumulator then
                        next_v2_accumulator <= v2_accumulator + shift_left(v2_locked, 7) + v2_locked;
                    elsif v2_accumulator + shift_left(v2_locked, 6) < v1_accumulator then
                        next_v2_accumulator <= v2_accumulator + shift_left(v2_locked, 6) + v2_locked;
                    elsif v2_accumulator + shift_left(v2_locked, 5) < v1_accumulator then
                        next_v2_accumulator <= v2_accumulator + shift_left(v2_locked, 5) + v2_locked;
                    elsif v2_accumulator + shift_left(v2_locked, 4) < v1_accumulator then
                        next_v2_accumulator <= v2_accumulator + shift_left(v2_locked, 4) + v2_locked;
                    elsif v2_accumulator + shift_left(v2_locked, 3) < v1_accumulator then
                        next_v2_accumulator <= v2_accumulator + shift_left(v2_locked, 3) + v2_locked;
                    elsif v2_accumulator + shift_left(v2_locked, 2) < v1_accumulator then
                        next_v2_accumulator <= v2_accumulator + shift_left(v2_locked, 2) + v2_locked;
                    elsif v2_accumulator + shift_left(v2_locked, 1) < v1_accumulator then
                        next_v2_accumulator <= v2_accumulator + shift_left(v2_locked, 1) + v2_locked;
                    else
                        next_v2_accumulator <= v2_accumulator + v2_locked;
                    end if;
                end if;
            end if;
        when S_DONE =>
            if queue_out_full = '1' then
                next_state <= S_DONE;
            else
                queue_out_write <= '1';
                next_state <= S_IDLE;
            end if;
    end case;
end process;

end Behavioral;