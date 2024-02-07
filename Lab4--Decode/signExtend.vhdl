library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.dlxlib.all;

entity signExtend is
    port ( 
        input : in  STD_LOGIC_VECTOR (15 downto 0);
        us : in STD_LOGIC;
        output : out  STD_LOGIC_VECTOR (31 downto 0)
    );
end signExtend;

architecture behavioral of signExtend is
begin
    process (us, input) begin
        if us = '1' or input(15) = '0' then
            output <= x"0000" & input;
        else
            output <= x"ffff" & input;
        end if;
    end process;

end behavioral;
