library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.dlxlib.all;

entity DLXpipeline is
    port (
        clk : in std_logic;
        rst_l : in std_logic;
        addr_selector : in std_logic;
        branch_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        writeback_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
        writeback_reg : in std_logic_vector(4 downto 0);
        writeback_en : in std_logic;
        rs1_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
        rs2_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
        immediate : out std_logic_vector(DATA_WIDTH-1 downto 0);
        instr_out : out std_logic_vector(INSTR_WIDTH-1 downto 0);
        addr_out : out std_logic_vector(ADDR_WIDTH-1 downto 0)
    );
end DLXpipeline;

architecture behavioral of DLXpipeline is

    component dlx_fetch is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            addr_selector : in std_logic;
            branch_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            next_pc : out std_logic_vector(ADDR_WIDTH-1 downto 0);
            instr : out std_logic_vector(INSTR_WIDTH-1 downto 0)
        );
    end component;

    component dlx_decode is
        port (
            clk : in  STD_LOGIC;
            rst_l : in  STD_LOGIC := '0';
            addr_in : in STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
            instr_in : in STD_LOGIC_VECTOR (INSTR_WIDTH-1 downto 0);
            writeback_data : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
            writeback_reg : in STD_LOGIC_VECTOR (4 downto 0);
            writeback_en : in STD_LOGIC;
            rs1_data : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
            rs2_data : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
            immediate : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
            instr_out : out STD_LOGIC_VECTOR (INSTR_WIDTH-1 downto 0);
            addr_out : out STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0)
        );
    end component;

    signal next_pc : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal instr : std_logic_vector(INSTR_WIDTH-1 downto 0);

begin

    fetch : dlx_fetch
        port map (
            clk => clk,
            rst_l => rst_l,
            addr_selector => addr_selector,
            branch_addr => branch_addr,
            next_pc => next_pc,
            instr => instr
        );

    decode : dlx_decode
        port map (
            clk => clk,
            rst_l => rst_l,
            addr_in => next_pc,
            instr_in => instr,
            writeback_data => writeback_data,
            writeback_reg => writeback_reg,
            writeback_en => writeback_en,
            rs1_data => rs1_data,
            rs2_data => rs2_data,
            immediate => immediate,
            instr_out => instr_out,
            addr_out => addr_out
        );

end behavioral;
