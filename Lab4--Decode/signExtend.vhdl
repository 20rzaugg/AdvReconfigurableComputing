library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.dlxlib.all;

entity signExtend is
    port ( 
        input : in  STD_LOGIC_VECTOR (15 downto 0);
        us : in STD_LOGIC;
        output : out  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0)
    );
    
    process() begin
        if us = '1' or input(15) = '0' then
            output <= (others => '0') & input;
        else
            output <= (others => '1') & input;
        end if;
    end process;

end signExtend;