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
        result : inout unsigned(ADDR_WIDTH-1 downto 0) := (others => '0');
        bubble : in std_logic
    );
end entity addr_adder;

architecture rtl of addr_adder is
begin
    process(addr, offset, bubble) begin
        if bubble = '0' then
            result <= addr + offset;
        else
            result <= result;
        end if;
    end process;
end architecture rtl;
