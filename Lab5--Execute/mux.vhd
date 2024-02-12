library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use work.dlxlib.all;

entity mux2_1 is
    parameter MUX_WIDTH : integer := 32
    Port (
        sel : in std_logic;
        in0  : in std_logic_vector(MUX_WIDTH downto 0);
        in1  : in std_logic_vector(MUX_WIDTH downto 0);
        out0 : out std_logic_vector(MUX_WIDTH downto 0)
    );
end mux2_1;

architecture Behavioral of mux2_1 is
begin
    process(sel, in0, in1) begin
        if sel = '0' then
            out0 <= in0;
        else
            out0 <= in1;
        end if;
    end process;
end Behavioral;
