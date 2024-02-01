library IEEE;
library work;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use work.dlxlib.all;

entity addr_adder is
    port (
        addr : in unsigned(ADDR_WIDTH-1 downto 0);
        offset : in unsigned(ADDR_WIDTH-1 downto 0);
        result : out unsigned(ADDR_WIDTH-1 downto 0) := (others => '0')
    );
end entity addr_adder;

architecture rtl of addr_adder is
begin
    result <= addr + offset;
end architecture rtl;
