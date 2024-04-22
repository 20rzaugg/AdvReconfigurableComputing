library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
library work;
use work.dlxlib.all;

entity LCM_GCD is 
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
end LCM_GCD;

architecture Behavioral of LCM_GCD is

    component lcm_multiplier is
        port (
            clock : IN std_logic;
		    dataa : IN std_logic_vector (63 downto 0);
		    datab : IN std_logic_vector (63 downto 0);
		    result : OUT std_logic_vector (127 downto 0)
        );
    end component;

    component lcm_divider is
        port (
            clock : in std_logic;
            denom : in std_logic_vector(63 downto 0);
            numer : in std_logic_vector(63 downto 0);
            quotient : out std_logic_vector(63 downto 0);
            remain : out std_logic_vector(63 downto 0)
        );
    end component;

    type stateType is (S_IDLE, S_READ, S_EVEN, S_GCD, S_DIVIDE, S_DIVIDE2, S_DIVIDE3, S_DIVIDE4, S_DIVIDE5, S_DIVIDE6, S_MULTIPLY, S_MULTIPLY2, S_MULTIPLY3, S_DONE);
    signal state : stateType := S_IDLE;
    signal next_state : stateType := S_IDLE;
    signal v1_locked : unsigned(DATA_WIDTH-1 downto 0);
    signal next_v1_locked : unsigned(DATA_WIDTH-1 downto 0);
    signal v2_locked : unsigned(DATA_WIDTH-1 downto 0);
    signal next_v2_locked : unsigned(DATA_WIDTH-1 downto 0);

    signal gcd_v1 : unsigned(DATA_WIDTH-1 downto 0);
    signal next_gcd_v1 : unsigned(DATA_WIDTH-1 downto 0);
    signal gcd_v2 : unsigned(DATA_WIDTH-1 downto 0);
    signal next_gcd_v2 : unsigned(DATA_WIDTH-1 downto 0);
    signal gcd_d : integer range 0 to 63 := 0;
    signal next_gcd_d : integer range 0 to 63 := 0;

    signal multiplier_a : std_logic_vector(63 downto 0);
    signal next_multiplier_a : std_logic_vector(63 downto 0);
    signal multiplier_b : std_logic_vector(63 downto 0);
    signal next_multiplier_b : std_logic_vector(63 downto 0);
    signal multiplier_product : std_logic_vector(127 downto 0);

    signal divider_numerator : std_logic_vector(63 downto 0);
    signal next_divider_numerator : std_logic_vector(63 downto 0);
    signal divider_denominator : std_logic_vector(63 downto 0);
    signal next_divider_denominator : std_logic_vector(63 downto 0);
    signal divider_quotient : std_logic_vector(63 downto 0);
    signal divider_remainder : std_logic_vector(63 downto 0);
    
    signal vout_sig : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal next_vout_sig : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    divider : lcm_divider port map (
        clock => clk,
        denom => divider_denominator,
        numer => divider_numerator,
        quotient => divider_quotient,
        remain => divider_remainder
    );

    multiplier : lcm_multiplier port map (
        clock => clk,
        dataa => multiplier_a,
        datab => multiplier_b,
        result => multiplier_product
    );

vout <= vout_sig;

process(clk, rst_l) begin
    if rst_l = '0' then
        state <= S_IDLE;
        v1_locked <= (others => '0');
        v2_locked <= (others => '0');
        gcd_v1 <= (others => '0');
        gcd_v2 <= (others => '0');
        gcd_d <= 0;
        multiplier_a <= (others => '0');
        multiplier_b <= (others => '0');
        divider_numerator <= (others => '0');
        divider_denominator <= (others => '0');
        vout_sig <= (others => '0');
        
    elsif rising_edge(clk) then
        state <= next_state;
        v1_locked <= next_v1_locked;
        v2_locked <= next_v2_locked;
        gcd_v1 <= next_gcd_v1;
        gcd_v2 <= next_gcd_v2;
        gcd_d <= next_gcd_d;
        multiplier_a <= next_multiplier_a;
        multiplier_b <= next_multiplier_b;
        divider_numerator <= next_divider_numerator;
        divider_denominator <= next_divider_denominator;
        vout_sig <= next_vout_sig;
    end if;
end process;

process(state, v1_locked, v2_locked, gcd_v1, gcd_v2, gcd_d, multiplier_a, multiplier_b, divider_denominator, divider_numerator, vout_sig, vin, queue_in_empty, queue_out_full) begin
    next_v1_locked <= v1_locked;
    next_v2_locked <= v2_locked;
    next_gcd_v1 <= gcd_v1;
    next_gcd_v2 <= gcd_v2;
    next_gcd_d <= gcd_d;
    next_multiplier_a <= multiplier_a;
    next_multiplier_b <= multiplier_b;
    next_divider_numerator <= divider_numerator;
    next_divider_denominator <= divider_denominator;
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
        --read inputs from the DC FIFO
        when S_READ =>
            next_v1_locked <= unsigned(vin(DATA_WIDTH*2-1 downto DATA_WIDTH));
            next_v2_locked <= unsigned(vin(DATA_WIDTH-1 downto 0));
            next_gcd_v1 <= unsigned(vin(DATA_WIDTH*2-1 downto DATA_WIDTH));
            next_gcd_v2 <= unsigned(vin(DATA_WIDTH-1 downto 0));
            next_gcd_d <= 0;
            next_state <= S_EVEN;
        --implements Binary Euclid's algorithm for GCD
        --divides both numbers by 2 until they are both odd
        when S_EVEN =>
            next_state <= S_EVEN;
            if gcd_v1(0) = '0' and gcd_v2(0) = '0' then
                next_gcd_v1 <= gcd_v1 srl 1;
                next_gcd_v2 <= gcd_v2 srl 1;
                next_gcd_d <= gcd_d + 1;
            elsif gcd_v1(0) = '0' and gcd_v2(0) = '1' then
                next_gcd_v1 <= gcd_v1 srl 1;
            elsif gcd_v1(0) = '1' and gcd_v2(0) = '0' then
                next_gcd_v2 <= gcd_v2 srl 1;
            else
                next_state <= S_GCD;
            end if;
        --subtract v1 from v2 or v2 from v1 depending on which is greater
        when S_GCD =>
            if gcd_v1 = gcd_v2 then
                next_divider_denominator <= std_logic_vector(gcd_v1 sll gcd_d);
                next_divider_numerator <= std_logic_vector(v1_locked);
                next_state <= S_DIVIDE;
            else
                next_state <= S_EVEN;
                if gcd_v1 > gcd_v2 then
                    next_gcd_v1 <= gcd_v1 - gcd_v2;
                else
                    next_gcd_v2 <= gcd_v2 - gcd_v1;
                end if;
            end if;
        --divide V1 by the GCD
        when S_DIVIDE =>
            next_state <= S_DIVIDE2;
        when S_DIVIDE2 =>
            next_state <= S_DIVIDE3;
        when S_DIVIDE3 => 
            next_state <= S_DIVIDE4;
        when S_DIVIDE4 =>
            next_state <= S_DIVIDE5;
        when S_DIVIDE5 =>
            next_state <= S_DIVIDE6;
        when S_DIVIDE6 =>
            next_multiplier_a <= divider_quotient;
            next_multiplier_b <= std_logic_vector(v2_locked);
            next_state <= S_MULTIPLY;
        --multiply the quotient by V2
        when S_MULTIPLY =>
            next_state <= S_MULTIPLY2;
        when S_MULTIPLY2 =>
            next_state <= S_MULTIPLY3;
        when S_MULTIPLY3 =>
            next_vout_sig <= multiplier_product(DATA_WIDTH-1 downto 0);
            next_state <= S_DONE;
        --return the LCM to the DC FIFO
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