library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.dlxlib.all;

entity dlx_execute is
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
        stopwatch_reset : out std_logic := '0';
    );
end dlx_execute;

architecture hierarchial of dlx_execute is

    component ALU is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            in1 : in std_logic_vector(DATA_WIDTH-1 downto 0);
            in2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
            op : in std_logic_vector(7 downto 0);
            out1 : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component ALU;
    
    component MUX4_1 is
        generic (
             MUX_WIDTH : integer := DATA_WIDTH
        );
        port (
            sel : in std_logic_vector(1 downto 0);
            in0 : in std_logic_vector(MUX_WIDTH-1 downto 0);
            in1 : in std_logic_vector(MUX_WIDTH-1 downto 0);
            in2 : in std_logic_vector(MUX_WIDTH-1 downto 0);
            in3 : in std_logic_vector(MUX_WIDTH-1 downto 0);
            out0 : out std_logic_vector(MUX_WIDTH-1 downto 0)
        );
    end component mux4_1;

    component MUX2_1 is
        generic (
             MUX_WIDTH : integer := DATA_WIDTH
        );
        port (
            sel : in std_logic;
            in0 : in std_logic_vector(MUX_WIDTH-1 downto 0);
            in1 : in std_logic_vector(MUX_WIDTH-1 downto 0);
            out0 : out std_logic_vector(MUX_WIDTH-1 downto 0)
        );
    end component mux2_1;

    signal alu_result_sig : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

    signal mux1_sel : std_logic;
    signal mux2_sel : std_logic;

    signal alu_in2 : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal op : std_logic_vector(7 downto 0);

    signal next_branch_target : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal next_branch_taken : std_logic;

    signal expanded_address : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal reg1_ff : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal reg2_ff : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal reg3_ff : std_logic_vector(DATA_WIDTH-1 downto 0);


begin

    alu_result <= alu_result_sig;
    print_data <= reg1_ff;
    op <= opcode(execute_instr);
    expanded_address <= X"0000000000000" & execute_pc;

    muxinput1_1 : MUX4_1
        generic map (
            MUX_WIDTH => DATA_WIDTH
        )
        port map (
            sel => data_hazard1,
            in0 => reg_in1,
            in1 => alu_result_sig,
            in2 => fast_track_mw_alu,
            in3 => fast_track_mw_mem,
            out0 => reg1_ff
        );
    
    muxinput1_2 : MUX2_1
        generic map (
            MUX_WIDTH => DATA_WIDTH
        )
        port map (
            sel => mux1_sel,
            in0 => expanded_address,
            in1 => reg1_ff,
            out0 => alu_in1
        );

    muxinput2_1 : MUX4_1
        generic map (
            MUX_WIDTH => DATA_WIDTH
        )
        port map (
            sel => data_hazard2,
            in0 => reg_in2,
            in1 => alu_result_sig,
            in2 => fast_track_mw_alu,
            in3 => fast_track_mw_mem,
            out0 => reg2_ff
        );
    
    muxinput2_2 : MUX2_1
        generic map (
            MUX_WIDTH => DATA_WIDTH
        )
        port map (
            sel => mux2_sel,
            in0 => reg2_ff,
            in1 => immediate_in,
            out0 => alu_in2
        );
    
    muxinput3_1 : MUX4_1
        generic map (
            MUX_WIDTH => DATA_WIDTH
        )
        port map (
            sel => data_hazard3,
            in0 => reg_in3,
            in1 => alu_result_sig,
            in2 => fast_track_mw_alu,
            in3 => fast_track_mw_mem,
            out0 => reg3_ff
        );

    alu_inst : ALU
        port map (
            clk => clk,
            rst_l => rst_l,
            in1 => alu_in1,
            in2 => alu_in2,
            op => op,
            out1 => alu_result_sig
        );

    process(op) begin
        -- handle execute mux selects
        if op = JAL then
            mux1_sel <= '1';
        else
            op <= '0';
        end if;
        mux2_sel <= is_immediate(op);

        --  handle timer peripheral
        stopwatch_reset <= '0';
        stopwatch_start <= '0';
        stopwatch_stop <= '0';
        if op = TCLR then
            stopwatch_reset <= '1';
        elsif op = TSRT then
            stopwatch_start <= '1';
        elsif op = TSTP then
            stopwatch_stop <= '1';
        end if;
    end process;

    process (clk, rst_l) is
    begin
        if (rst_l = '0') then
            memory_instr <= (others => '0');
        elsif (rising_edge(clk)) then
            memory_instr <= execute_instr;
            reg3_out <= reg3_ff;            
        end if;
    end process;

    process (op, reg1_ff, alu_in2) is
    begin
        if op = BEQZ or op = BNEZ or op = J or op = JAL then
            branch_target <= alu_in_2(ADDR_WIDTH-1 downto 0)
        else
            branch_target <= (others => '0');
        end if;
        if (op = BEQZ and reg1_ff = x"0000000000000000") or (op = BNEZ and reg1_ff /= x"0000000000000000") or op = J or op = JAL then
            branch_taken <= '1';
        else
            branch_taken <= '0';
        end if;
    end process;

end hierarchial;