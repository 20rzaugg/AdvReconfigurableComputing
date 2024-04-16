library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.dlxlib.all;

entity TBpipelineTBcopy is
end TBpipelineTBcopy;

architecture testbench of TBpipelineTBcopy is
    
    component DLXpipelineTBcopy is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            tx : out std_logic;
            LEDR : out std_logic_vector(9 downto 0);
            HEX0 : out unsigned(7 downto 0);
            HEX1 : out unsigned(7 downto 0);
            HEX2 : out unsigned(7 downto 0);
            HEX3 : out unsigned(7 downto 0);
            HEX4 : out unsigned(7 downto 0);
            HEX5 : out unsigned(7 downto 0);
            rx_data : in std_logic_vector(7 downto 0);
            rx_done : in std_logic
        );
    end component;

    signal clk : std_logic := '0';
    signal rst_l : std_logic := '1';
    signal index : integer := 0;
    signal next_index : integer := 0;
    signal tx : std_logic;
    signal rx_data : std_logic_vector(7 downto 0) := (others => '0');
    signal rx_done : std_logic := '0';
    signal LEDR : std_logic_vector(9 downto 0);
    signal HEX0 : unsigned(7 downto 0);
    signal HEX1 : unsigned(7 downto 0);
    signal HEX2 : unsigned(7 downto 0);
    signal HEX3 : unsigned(7 downto 0);
    signal HEX4 : unsigned(7 downto 0);
    signal HEX5 : unsigned(7 downto 0);

begin
    DUT : DLXpipelineTBcopy
        port map (
            clk => clk,
            rst_l => rst_l,
            tx => tx,
            LEDR => LEDR,
            HEX0 => HEX0,
            HEX1 => HEX1,
            HEX2 => HEX2,
            HEX3 => HEX3,
            HEX4 => HEX4,
            HEX5 => HEX5,
            rx_data => rx_data,
            rx_done => rx_done
        );

    process
    begin
        wait for 10 ns;
        clk <= not clk;
    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            index <= next_index;
        end if;
    end process;

    process (index) begin
        rst_l <= '1';
        if index > 40000 then
            report "Simulation finished" severity failure;
        else
            next_index <= index + 1;
        end if;
    end process;

    process(index) is begin
        case index is
            -- 11
            when 685 =>
                rx_data <= x"31";
                rx_done <= '1';
            when 686 =>
                rx_done <= '0';
            when 688 =>
                rx_data <= x"31";
                rx_done <= '1';
            when 689 =>
                rx_done <= '0';
            when 692 =>
                rx_data <= x"20";
                rx_done <= '1';
            when 693 =>
                rx_done <= '0';
            -- 7
            when 714 =>
                rx_data <= x"37";
                rx_done <= '1';
            when 715 =>
                rx_done <= '0';
            when 718 =>
                rx_data <= x"20";
                rx_done <= '1';
            when 719 =>
                rx_done <= '0';
            -- 3
            when 751 =>
                rx_data <= x"33";
                rx_done <= '1';
            when 752 =>
                rx_done <= '0';
            when 755 =>
                rx_data <= x"20";
                rx_done <= '1';
            when 756 =>
                rx_done <= '0';
            -- 17
            when 799 =>
                rx_data <= x"31";
                rx_done <= '1';
            when 800 =>
                rx_done <= '0';
            when 802 =>
                rx_data <= x"37";
                rx_done <= '1';
            when 803 =>
                rx_done <= '0';
            when 806 =>
                rx_data <= x"20";
                rx_done <= '1';
            when 807 =>
                rx_done <= '0';
            -- 2
            when 832 =>
                rx_data <= x"32";
                rx_done <= '1';
            when 833 =>
                rx_done <= '0';
            when 836 =>
                rx_data <= x"20";
                rx_done <= '1';
            when 837 =>
                rx_done <= '0';
            -- 29
            when 902 =>
                rx_data <= x"32";
                rx_done <= '1';
            when 903 =>
                rx_done <= '0';
            when 906 =>
                rx_data <= x"39";
                rx_done <= '1';
            when 907 =>
                rx_done <= '0';
            when 910 =>
                rx_data <= x"20";
                rx_done <= '1';
            when 911 =>
                rx_done <= '0';
            -- 15
            when 934 =>
                rx_data <= x"31";
                rx_done <= '1';
            when 935 =>
                rx_done <= '0';
            when 937 =>
                rx_data <= x"35";
                rx_done <= '1';
            when 938 =>
                rx_done <= '0';
            when 941 =>
                rx_data <= x"20";
                rx_done <= '1';
            when 942 =>
                rx_done <= '0';
            -- 23
            when 989 =>
                rx_data <= x"32";
                rx_done <= '1';
            when 990 =>
                rx_done <= '0';
            when 993 =>
                rx_data <= x"33";
                rx_done <= '1';
            when 994 =>
                rx_done <= '0';
            when 997 =>
                rx_data <= x"20";
                rx_done <= '1';
            when 998 =>
                rx_done <= '0';
            -- 5
            when 1045 =>
                rx_data <= x"35";
                rx_done <= '1';
            when 1046 =>
                rx_done <= '0';
            when 1049 =>
                rx_data <= x"20";
                rx_done <= '1';
            when 1050 =>
                rx_done <= '0';
            -- 13
            when 1142 =>
                rx_data <= x"31";
                rx_done <= '1';
            when 1143 =>
                rx_done <= '0';
            when 1145 =>
                rx_data <= x"33";
                rx_done <= '1';
            when 1146 =>
                rx_done <= '0';
            when 1149 =>
                rx_data <= x"20";
                rx_done <= '1';
            when 1150 =>
                rx_done <= '0';
            -- 27
            when 1218 =>
                rx_data <= x"32";
                rx_done <= '1';
            when 1219 =>
                rx_done <= '0';
            when 1222 =>
                rx_data <= x"37";
                rx_done <= '1';
            when 1223 =>
                rx_done <= '0';
            when 1226 =>
                rx_data <= x"20";
                rx_done <= '1';
            when 1227 =>
                rx_done <= '0';
            -- 19
            when 1260 =>
                rx_data <= x"31";
                rx_done <= '1';
            when 1261 =>
                rx_done <= '0';
            when 1263 =>
                rx_data <= x"39";
                rx_done <= '1';
            when 1264 =>
                rx_done <= '0';
            when 1267 =>
                rx_data <= x"20";
                rx_done <= '1';
            when 1268 =>
                rx_done <= '0';
            when others =>
                null;
        end case;
    end process;

end testbench;
