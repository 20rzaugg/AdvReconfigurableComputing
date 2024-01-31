library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library dlxlib;
use dlxlib.all;

entity addr_adder is
    port (
        addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        offset : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        result : out std_logic_vector(ADDR_WIDTH-1 downto 0)
    );
end entity addr_adder;

architecture rtl of addr_adder is
begin
    result <= std_logic_vector(unsigned(addr) + unsigned(offset));
end architecture rtl;
