library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use work.dlxlib.all;

entity mux4_1 is
    generic (
         MUX_WIDTH : integer
    );
    port (
        sel : in std_logic_vector(1 downto 0);
        in0  : in std_logic_vector(MUX_WIDTH-1 downto 0);
        in1  : in std_logic_vector(MUX_WIDTH-1 downto 0);
        in2  : in std_logic_vector(MUX_WIDTH-1 downto 0);
        in3  : in std_logic_vector(MUX_WIDTH-1 downto 0);
        out0 : out std_logic_vector(MUX_WIDTH-1 downto 0)
    );
end mux4_1;

architecture Behavioral of mux4_1 is
begin
    process(sel, in0, in1, in2, in3) begin
        case sel is
            when "00" =>
                out0 <= in0;
            when "01" =>
                out0 <= in1;
            when "10" =>
                out0 <= in2;
            when "11" =>
                out0 <= in3;
        end case;
    end process;
end Behavioral;