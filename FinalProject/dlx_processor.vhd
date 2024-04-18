library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library work;
use work.dlxlib.ALL;

entity dlx_processor is
    port (
        ADC_CLK_10 : in std_logic;
        MAX10_CLK1_50 : in std_logic;
        MAX10_CLK2_50 : in std_logic;
        HEX0 : out unsigned(7 downto 0);
        HEX1 : out unsigned(7 downto 0);
        HEX2 : out unsigned(7 downto 0);
        HEX3 : out unsigned(7 downto 0);
        HEX4 : out unsigned(7 downto 0);
        HEX5 : out unsigned(7 downto 0);
        KEY : in std_logic_vector(1 downto 0);
        LEDR : out std_logic_vector(9 downto 0);
        RX : in std_logic;
        TX : out std_logic
    );
end dlx_processor;

architecture behavioral of dlx_processor is
    component DLXpipeline is
        port (
            clk : in std_logic;
            clk_50 : in std_logic;
            rst_l : in std_logic;
            tx : out std_logic;
            rx : in std_logic;
            LEDR : out std_logic_vector(9 downto 0);
            HEX0 : out unsigned(7 downto 0);
            HEX1 : out unsigned(7 downto 0);
            HEX2 : out unsigned(7 downto 0);
            HEX3 : out unsigned(7 downto 0);
            HEX4 : out unsigned(7 downto 0);
            HEX5 : out unsigned(7 downto 0)
        );
    end component;
begin

    pipeline : DLXpipeline
        port map (
            clk => ADC_CLK_10,
            clk_50 => MAX10_CLK1_50,
            rst_l => KEY(0),
            tx => TX,
            rx => RX,
            LEDR => LEDR,
            HEX0 => HEX0,
            HEX1 => HEX1,
            HEX2 => HEX2,
            HEX3 => HEX3,
            HEX4 => HEX4,
            HEX5 => HEX5
        );

end behavioral;
