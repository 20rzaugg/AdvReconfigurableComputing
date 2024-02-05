library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package dlxlib is
    constant ADDR_WIDTH : integer := 10;
    constant DATA_WIDTH : integer := 32;
    constant INSTR_WIDTH : integer := 32;
    constant MEM_SIZE : integer := 2**ADDR_WIDTH;

    function is_unsigned(opcode : std_logic_vector(5 downto 0)) return boolean;

end package dlxlib;

package body dlxlib is
    function is_unsigned(opcode : std_logic_vector(5 downto 0)) return boolean is
    begin
        if opcode = "000101" or opcode = "000110" or opcode = "001001" or opcode = "001010" or 
           opcode = "011001" or opcode = "011010" or opcode = "011101" or opcode = "011110" or
           opcode = "100001" or opcode = "100010" or opcode = "100101" or opcode = "100110" then
            return 1;
        else
            return 0;
        end if;
    end function;
end package body;
