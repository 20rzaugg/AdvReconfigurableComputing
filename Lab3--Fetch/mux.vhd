use IEEE.STD_LOGIC_1164.ALL;
use dlxlib.all;

entity mux2_1 is
    Port (
        sel : in std_logic;
        in0  : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        in1  : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        out0 : out std_logic_vector(ADDR_WIDTH-1 downto 0)
    );
end mux;

architecture Behavioral of mux is
begin
    process(sel, in0, in1) begin
        if sel = '0' then
            out0 <= in0;
        else
            out0 <= in1;
        end if;
    end process;
end Behavioral;
