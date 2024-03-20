library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.dlxlib.ALL;

entity dlx_processor is
    port (
        ADC_CLK_10 : in std_logic;
        MAX10_CLK1_50 : in std_logic;
        MAX10_CLK2_50 : in std_logic;
        KEY : in std_logic_vector(1 downto 0);
        RX : in std_logic;
        TX : out std_logic;
        LEDR : out std_logic_vector(9 downto 0)
    );
end dlx_processor;

architecture behavioral of dlx_processor is
    component DLXpipeline is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            tx : out std_logic
        );
    end component;
begin

    pipeline : DLXpipeline
        port map (
            clk => MAX10_CLK1_50,
            rst_l => KEY(0),
            tx => TX
        );

end behavioral;
