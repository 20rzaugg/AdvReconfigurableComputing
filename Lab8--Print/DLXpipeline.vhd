library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.dlxlib.all;

entity DLXpipeline is
    port (
        clk : in std_logic;
        rst_l : in std_logic
        tx : out std_logic;
    );
end DLXpipeline;

architecture behavioral of DLXpipeline is

    component dlx_fetch is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            addr_selector : in std_logic;
            branch_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            bubble : in std_logic;
            decode_pc : out std_logic_vector(ADDR_WIDTH-1 downto 0);
            instr : out std_logic_vector(INSTR_WIDTH-1 downto 0)
        );
    end component;

    component dlx_decode is
        port (
            clk : in  STD_LOGIC;
            rst_l : in  STD_LOGIC := '0';
            decode_pc : in STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
            decode_instr : in STD_LOGIC_VECTOR (INSTR_WIDTH-1 downto 0);
            writeback_data : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
            writeback_reg : in STD_LOGIC_VECTOR (4 downto 0);
            writeback_en : in STD_LOGIC;
            branch_taken : in STD_LOGIC;
            rs1_data : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
            rs2_data : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
            immediate : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
            execute_instr : inout STD_LOGIC_VECTOR (INSTR_WIDTH-1 downto 0);
            memory_instr : in STD_LOGIC_VECTOR (INSTR_WIDTH-1 downto 0);
            execute_pc : out STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
            bubble : inout STD_LOGIC := '0';
            top_data_hazard : out STD_LOGIC_VECTOR (1 downto 0);
            bottom_data_hazard : out STD_LOGIC_VECTOR (1 downto 0)
        );
    end component;

    component dlx_execute is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            execute_pc : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            reg_in1 : in std_logic_vector(DATA_WIDTH-1 downto 0);
            reg_in2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
            immediate_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
            execute_instr : in std_logic_vector(INSTR_WIDTH-1 downto 0);
            alu_result : inout std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
            branch_target : out std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
            branch_taken : out std_logic := '0';
            memory_instr : out std_logic_vector(INSTR_WIDTH-1 downto 0) := (others => '0');
            reg2_out : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
            top_data_hazard : in STD_LOGIC_VECTOR (1 downto 0);
            bottom_data_hazard : in STD_LOGIC_VECTOR (1 downto 0);
            fast_track_mw_alu : in std_logic_vector(DATA_WIDTH-1 downto 0);
            fast_track_mw_mem : in std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    component dlx_memory is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            alu_result_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
            data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
            instr_in : in std_logic_vector(INSTR_WIDTH-1 downto 0);
            data_mem_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
            instr_out : out std_logic_vector(INSTR_WIDTH-1 downto 0);
            alu_result_out : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    component dlx_writeback is
        port ( 
            instr_in : in  std_logic_vector(INSTR_WIDTH-1 downto 0) := (others => '0');
            data_mem_in : in std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
            alu_result_in : in std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
            writeback_data_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
            writeback_address_out : out std_logic_vector(4 downto 0);
            writeback_enable_out : out std_logic
        );
    end component;

    
    signal decode_pc : std_logic_vector(ADDR_WIDTH-1 downto 0); -- fetch to decode
    signal decode_instr : std_logic_vector(INSTR_WIDTH-1 downto 0); -- fetch to decode

    signal execute_pc : std_logic_vector(ADDR_WIDTH-1 downto 0); -- decode to execute
    signal execute_instr : std_logic_vector(INSTR_WIDTH-1 downto 0); -- decode to execute

    signal memory_instr : std_logic_vector(INSTR_WIDTH-1 downto 0);

    signal writeback_instr : std_logic_vector(INSTR_WIDTH-1 downto 0);

    signal data_mem_out : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal addr_selector : std_logic;

    signal execute_alu_result : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal branch_target : std_logic_vector(ADDR_WIDTH-1 downto 0);

    signal reg2_out : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal memory_alu_result_out : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal execute_immediate : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal rs1_data : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rs2_data : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal writeback_data : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal writeback_address : std_logic_vector(4 downto 0);
    signal writeback_en : std_logic;
    signal bubble : std_logic;

    signal top_data_hazard : std_logic_vector(1 downto 0);
    signal bottom_data_hazard : std_logic_vector(1 downto 0);

begin

    fetch : dlx_fetch
        port map (
            clk => clk, --from system
            rst_l => rst_l, --from system
            addr_selector => addr_selector, --from execute
            branch_addr => branch_target, --from execute
            bubble => bubble, --from decode
            decode_pc => decode_pc, --to decode
            instr => decode_instr --to decode
        );

    decode : dlx_decode
        port map (
            clk => clk, --from system
            rst_l => rst_l, --from system
            decode_pc => decode_pc, --from fetch
            decode_instr => decode_instr, --from fetch
            writeback_data => writeback_data, --from writeback
            writeback_reg => writeback_address, --from writeback
            writeback_en => writeback_en, --from writeback
            branch_taken => addr_selector, --from execute
            rs1_data => rs1_data, --to execute
            rs2_data => rs2_data, --to execute
            immediate => execute_immediate, --to execute
            execute_instr => execute_instr, --to execute
            memory_instr => memory_instr,
            execute_pc => execute_pc, --to execute
            bubble => bubble, --to fetch
            top_data_hazard => top_data_hazard,
            bottom_data_hazard => bottom_data_hazard
        );

    execute : dlx_execute
        port map (
            clk => clk, --from system
            rst_l => rst_l, --from system
            execute_pc => execute_pc, --from decode
            reg_in1 => rs1_data, --from decode
            reg_in2 => rs2_data, --from decode
            immediate_in => execute_immediate, --from decode
            execute_instr => execute_instr, --from decode
            alu_result => execute_alu_result, --to memory and decode
            branch_target => branch_target, --to fetch
            branch_taken => addr_selector, --to fetch
            memory_instr => memory_instr, --to fetch
            reg2_out => reg2_out, --to memory
            top_data_hazard => top_data_hazard,
            bottom_data_hazard => bottom_data_hazard,
            fast_track_mw_alu => memory_alu_result_out,
            fast_track_mw_mem => data_mem_out
        );

    memory : dlx_memory
        port map (
            clk => clk, --from system
            rst_l => rst_l, --from system
            alu_result_in => execute_alu_result, --from execute
            data_in => reg2_out, --from execute
            instr_in => memory_instr, --from execute
            data_mem_out => data_mem_out, --to writeback
            instr_out => writeback_instr, --to writeback
            alu_result_out => memory_alu_result_out --to writeback
        );
    
    writeback : dlx_writeback
        port map (
            instr_in => writeback_instr, --from memory
            data_mem_in => data_mem_out, --from memory
            alu_result_in => memory_alu_result_out, --from memory
            writeback_data_out => writeback_data, --to decode
            writeback_address_out => writeback_address, --to decode
            writeback_enable_out => writeback_en --to decode
        );

end behavioral;
