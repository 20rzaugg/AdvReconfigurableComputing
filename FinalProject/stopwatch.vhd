library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity stopwatch is 
    port (
        clk : in std_logic;
        rst_l : in std_logic; --hw reset
        t_start : in std_logic;
        t_stop : in std_logic;
        rst : in std_logic; --sw reset
        HEX0 : out unsigned(7 downto 0);
        HEX1 : out unsigned(7 downto 0);
        HEX2 : out unsigned(7 downto 0);
        HEX3 : out unsigned(7 downto 0);
        HEX4 : out unsigned(7 downto 0);
        HEX5 : out unsigned(7 downto 0)
    );
end stopwatch;

architecture behavioral of stopwatch is

    signal tenmin : unsigned(7 downto 0) := X"00";
    signal onemin : unsigned(7 downto 0) := X"00";
    signal tensec : unsigned(7 downto 0) := X"00";
    signal onesec : unsigned(7 downto 0) := X"00";
    signal hunms : unsigned(7 downto 0) := X"00";
    signal tenms : unsigned(7 downto 0) := X"00";

    signal counter : integer range 0 to 100000  := 0;

    signal go : std_logic := '0';

    type sevysegy is array (0 to 9) of unsigned(7 downto 0);
    constant sev_seg : sevysegy := (X"C0", X"F9", X"A4", X"B0", X"99", X"92", X"82", X"F8", X"80", X"90");

begin

    HEX0 <= sev_seg(to_integer(tenms));
    HEX1 <= sev_seg(to_integer(hunms));
    HEX2 <= sev_seg(to_integer(onesec)) and X"7F";
    HEX3 <= sev_seg(to_integer(tensec));
    HEX4 <= sev_seg(to_integer(onemin)) and X"7F";
    HEX5 <= sev_seg(to_integer(tenmin));

    process(clk, rst_l) begin
        if rst_l = '0' or rst = '1' then
            tenmin <= X"00";
            onemin <= X"00";
            tensec <= X"00";
            onesec <= X"00";
            hunms <= X"00";
            tenms <= X"00";
            counter <= 0;
            go <= '0';
        elsif rising_edge(clk) then
            if t_start = '1' then
                go <= '1';
            elsif t_stop = '1' then
                go <= '0';
            end if;
            tenms <= tenms;
			hunms <= hunms;
            onesec <= onesec;
            tensec <= tensec;
            onemin <= onemin;
            tenmin <= tenmin;
            if go = '1' then
                if counter >= 99999 then --set up for 10 Mhz clock
                    counter <= 0;
                    if tenms = X"09" then
                        tenms <= (others => '0');
                        if hunms = X"09" then
                            hunms <= (others => '0');
                            if onesec = X"09" then
                                onesec <= (others => '0');
                                if tensec = X"05" then
                                    tensec <= (others => '0');
                                    if onemin = X"09" then
                                        onemin <= (others => '0');
                                        tenmin <= tenmin + 1;
                                    else
                                        onemin <= onemin + 1;
                                    end if;
                                else
                                    tensec <= tensec + 1;
                                end if;
                            else
                                onesec <= onesec + 1;
                            end if;
                        else
                            hunms <= hunms + 1;
                        end if;
                    else
                        tenms <= tenms + 1;
                    end if;
                else
                    counter <= counter + 1;
                end if;
            end if;
        end if;
    end process;

end behavioral;