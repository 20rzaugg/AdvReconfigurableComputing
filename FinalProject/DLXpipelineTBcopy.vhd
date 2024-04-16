library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
library work;
use work.dlxlib.all;

entity DLXpipelineTBcopy is
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
end DLXpipelineTBcopy;

architecture behavioral of DLXpipelineTBcopy is

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
            writeback_reg : in STD_LOGIC_VECTOR (5 downto 0);
            writeback_en : in STD_LOGIC;
            branch_taken : in STD_LOGIC;
            rs1_data : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
            rs2_data : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
            rs3_data : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
            imm_out : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
            execute_instr : inout STD_LOGIC_VECTOR (INSTR_WIDTH-1 downto 0) := (others => '0');
            memory_instr : in STD_LOGIC_VECTOR (INSTR_WIDTH-1 downto 0);
            execute_pc : out STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0) := (others => '0');
            bubble : inout STD_LOGIC := '0';
            data_hazard1 : out STD_LOGIC_VECTOR (1 downto 0);
            data_hazard2 : out STD_LOGIC_VECTOR (1 downto 0);
            data_hazard3 : out STD_LOGIC_VECTOR (1 downto 0);
            print_queue_full : in STD_LOGIC;
            input_buffer_empty : in STD_LOGIC
        );
    end component;

    component dlx_execute is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            execute_pc : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            reg_in1 : in std_logic_vector(DATA_WIDTH-1 downto 0);
            reg_in2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
            reg_in3 : in std_logic_vector(DATA_WIDTH-1 downto 0);
            immediate_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
            execute_instr : in std_logic_vector(INSTR_WIDTH-1 downto 0);
            alu_result : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
            branch_target : out std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
            branch_taken : out std_logic := '0';
            memory_instr : out std_logic_vector(INSTR_WIDTH-1 downto 0) := (others => '0');
            reg3_out : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
            data_hazard1 : in STD_LOGIC_VECTOR(1 downto 0);
            data_hazard2 : in STD_LOGIC_VECTOR(1 downto 0);
            data_hazard3 : in STD_LOGIC_VECTOR(1 downto 0);
            fast_track_mw_alu : in std_logic_vector(DATA_WIDTH-1 downto 0);
            fast_track_mw_mem : in std_logic_vector(DATA_WIDTH-1 downto 0);
            print_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
            stopwatch_start : out std_logic := '0';
            stopwatch_stop : out std_logic := '0';
            stopwatch_reset : out std_logic := '0'
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
            writeback_address_out : out std_logic_vector(5 downto 0);
            writeback_enable_out : out std_logic;
            input_buffer_output : in std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    component printer is
        port ( 
            clk : in  std_logic;
            tx_clk : in std_logic;
            rst_l : in  std_logic;
            instr_in : in std_logic_vector(INSTR_WIDTH-1 downto 0);
            data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
            instr_queue_full : out std_logic;
            tx : out std_logic
        );
    end component;

    component scannerTBcopy is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            instr_in : in std_logic_vector(INSTR_WIDTH-1 downto 0);
            input_buffer_empty : inout std_logic;
            data_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
            rx_data : in std_logic_vector(7 downto 0);
            rx_done : in std_logic
        );
    end component;

    component stopwatch is
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

    signal reg3_out : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal memory_alu_result_out : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal execute_immediate : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal rs1_data : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rs2_data : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rs3_data : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal writeback_data : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal writeback_address : std_logic_vector(5 downto 0);
    signal writeback_en : std_logic;
    signal bubble : std_logic;

    signal data_hazard1 : std_logic_vector(1 downto 0);
    signal data_hazard2 : std_logic_vector(1 downto 0);
    signal data_hazard3 : std_logic_vector(1 downto 0);

    signal instr_queue_full : std_logic;

    signal print_data_in : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal rx_clk : std_logic;
    signal tx_clk : std_logic;
    signal areset : std_logic;

    signal input_buffer_empty : std_logic;
    signal input_buffer_data : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal tim_clk : std_logic;
    signal t_start : std_logic;
    signal t_stop : std_logic;
    signal t_rst : std_logic;


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
            rs3_data => rs3_data, --to execute
            imm_out => execute_immediate, --to execute
            execute_instr => execute_instr, --to execute
            memory_instr => memory_instr,
            execute_pc => execute_pc, --to execute
            bubble => bubble, --to fetch
            data_hazard1 => data_hazard1, --to execute
            data_hazard2 => data_hazard2, --to execute
            data_hazard3 => data_hazard3, --to execute
            print_queue_full => instr_queue_full, --from printer
            input_buffer_empty => input_buffer_empty --from scanner
        );

    execute : dlx_execute
        port map (
            clk => clk, --from system
            rst_l => rst_l, --from system
            execute_pc => execute_pc, --from decode
            reg_in1 => rs1_data, --from decode
            reg_in2 => rs2_data, --from decode
            reg_in3 => rs3_data, --from decode
            immediate_in => execute_immediate, --from decode
            execute_instr => execute_instr, --from decode
            alu_result => execute_alu_result, --to memory and decode
            branch_target => branch_target, --to fetch
            branch_taken => addr_selector, --to fetch
            memory_instr => memory_instr, --to fetch
            reg3_out => reg3_out, --to memory
            data_hazard1 => data_hazard1, --from decode
            data_hazard2 => data_hazard2, --from decode
            data_hazard3 => data_hazard3, --from decode
            fast_track_mw_alu => memory_alu_result_out,
            fast_track_mw_mem => data_mem_out,
            print_data => print_data_in, --to printer
            stopwatch_start => t_start, --to stopwatch
            stopwatch_stop => t_stop, --to stopwatch
            stopwatch_reset => t_rst --to stopwatch
        );

    memory : dlx_memory
        port map (
            clk => clk, --from system
            rst_l => rst_l, --from system
            alu_result_in => execute_alu_result, --from execute
            data_in => reg3_out, --from execute
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
            writeback_enable_out => writeback_en, --to decode
            input_buffer_output => input_buffer_data
        );

    printer1 : printer
        port map (
            clk => clk, --from system
            tx_clk => clk,
            rst_l => rst_l, --from system
            instr_in => execute_instr, --from decode
            data_in => print_data_in, --from decode
            instr_queue_full => instr_queue_full, --to decode
            tx => tx --to system
        );

    scanner1 : scannerTBcopy
        port map (
            clk => clk, --from system
            rst_l => rst_l, --from system
            instr_in => execute_instr, --from execute
            input_buffer_empty => input_buffer_empty, --to decode
            data_out => input_buffer_data, --to writeback
            rx_data => rx_data, --from system
            rx_done => rx_done --from system
        );

    stopwatch1 : stopwatch
        port map (
            clk => clk, --from system
            rst_l => rst_l, --from system
            t_start => t_start, --from execute
            t_stop => t_stop, --from execute
            rst => t_rst, --from execute
            HEX0 => HEX0, --to system
            HEX1 => HEX1, --to system
            HEX2 => HEX2, --to system
            HEX3 => HEX3, --to system
            HEX4 => HEX4, --to system
            HEX5 => HEX5 --to system
        );

end behavioral;
