library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity digit_stack is
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
end digit_stack;

architecture behavioral of digit_stack is
    type stack_type is array (0 to 31) of std_logic_vector(7 downto 0);
    signal stack : stack_type;
    signal top : integer range 0 to 31 := 0;
begin
    process(clk, rst_l)
    begin
        if rst_l = '0' then
            top <= 0;
        elsif rising_edge(clk) then
            if push = '1' then
                if top < 31 then
                    stack(top) <= data_in;
                    top <= top + 1;
                end if;
            elsif pop = '1' then
                if top > 0 then
                    top <= top - 1;
                end if;
            end if;
        end if;
    end process;

    top_value <= stack(top-1) when top > 0 else (others => '0');
    empty <= '1' when top = 0 else '0';
    full <= '1' when top = 10 else '0';
end behavioral;