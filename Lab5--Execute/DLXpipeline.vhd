library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.dlxlib.all;

entity DLXpipeline is
    port (
        clk : in std_logic;
        rst_l : in std_logic;
        writeback_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
        writeback_reg : in std_logic_vector(4 downto 0);
        writeback_en : in std_logic;
        alu_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
        execute_next_pc : out std_logic_vector(ADDR_WIDTH-1 downto 0);
        instr_out : out std_logic_vector(INSTR_WIDTH-1 downto 0);
        reg2_out: out std_logic_vector(DATA_WIDTH-1 downto 0)
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

    component dlx_execute is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            addr_in : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            reg_in1 : in std_logic_vector(DATA_WIDTH-1 downto 0);
            reg_in2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
            immediate_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
            instr_in : in std_logic_vector(INSTR_WIDTH-1 downto 0);
            alu_result : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
            branch_taken : out std_logic := '0';
            addr_out : out std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
            instr_out : out std_logic_vector(INSTR_WIDTH-1 downto 0) := (others => '0');
            reg2_out : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0')
        );
    end component;

    signal fetch_next_pc : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal fetch_next_instr : std_logic_vector(INSTR_WIDTH-1 downto 0);

    signal decode_next_pc : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal decode_next_instr : std_logic_vector(INSTR_WIDTH-1 downto 0);

    signal addr_selector : std_logic;

    signal alu_result : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal immediate : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal rs1_data : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rs2_data : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    alu_out <= alu_result;

    fetch : dlx_fetch
        port map (
            clk => clk,
            rst_l => rst_l,
            addr_selector => addr_selector,
            branch_addr => alu_result(ADDR_WIDTH-1 downto 0),
            next_pc => fetch_next_pc,
            instr => fetch_next_instr
        );

    decode : dlx_decode
        port map (
            clk => clk,
            rst_l => rst_l,
            addr_in => fetch_next_pc,
            instr_in => fetch_next_instr,
            writeback_data => writeback_data,
            writeback_reg => writeback_reg,
            writeback_en => writeback_en,
            rs1_data => rs1_data,
            rs2_data => rs2_data,
            immediate => immediate,
            instr_out => decode_next_instr,
            addr_out => decode_next_pc
        );

    execute : dlx_execute
        port map (
            clk => clk,
            rst_l => rst_l,
            addr_in => decode_next_pc,
            reg_in1 => rs1_data,
            reg_in2 => rs2_data,
            immediate_in => immediate,
            instr_in => decode_next_instr,
            alu_result => alu_result,
            branch_taken => addr_selector,
            addr_out => execute_next_pc,
            instr_out => instr_out,
            reg2_out => reg2_out
        );

end behavioral;
