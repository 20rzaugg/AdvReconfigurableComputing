library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.dlxlib.all;

entity signExtend is
    port ( 
        input : in  STD_LOGIC_VECTOR (31 downto 0);
        us : in STD_LOGIC;
        output : out  STD_LOGIC_VECTOR (63 downto 0)
    );
end signExtend;

architecture behavioral of signExtend is
begin
    process (us, input) begin
        if us = '1' or input(31) = '0' then
            output <= x"00000000" & input;
        else
            output <= x"ffffffff" & input;
        end if;
    end process;

end behavioral;
