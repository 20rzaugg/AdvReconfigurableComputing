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
        fast_track_mw_mem : in std_logic_vector(DATA_WIDTH-1 downto 0);
        alu_in1 : inout std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end dlx_execute;

architecture hierarchial of dlx_execute is

    component ALU is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            in1 : in std_logic_vector(DATA_WIDTH-1 downto 0);
            in2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
            opcode : in std_logic_vector(5 downto 0);
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

    signal mux1_sel : std_logic;
    signal mux2_sel : std_logic;

    signal alu_in2 : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal opcode : std_logic_vector(5 downto 0);

    signal next_branch_target : std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal next_branch_taken : std_logic;

    signal expanded_address : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal reg1_ff : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal reg2_ff : std_logic_vector(DATA_WIDTH-1 downto 0);


begin

    opcode <= execute_instr(31 downto 26);
    expanded_address <= "0000000000000000000000" & execute_pc;

    muxinput1_1 : MUX4_1
        generic map (
            MUX_WIDTH => DATA_WIDTH
        )
        port map (
            sel => top_data_hazard,
            in0 => reg_in1,
            in1 => alu_result,
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
            sel => bottom_data_hazard,
            in0 => reg_in2,
            in1 => alu_result,
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
    
    alu_inst : ALU
        port map (
            clk => clk,
            rst_l => rst_l,
            in1 => alu_in1,
            in2 => alu_in2,
            opcode => opcode,
            out1 => alu_result
        );

    mux1_sel <= is_link(opcode);
    mux2_sel <= is_immediate(opcode);

    process (clk, rst_l) is
    begin
        if (rst_l = '0') then
            --branch_taken <= '0';
            memory_instr <= (others => '0');
        elsif (rising_edge(clk)) then
            --branch_target <= next_branch_target;
            --branch_taken <= next_branch_taken;
            memory_instr <= execute_instr;
            reg2_out <= reg_in2;            
        end if;
    end process;

    process (opcode, reg1_ff) is
    begin
        if opcode = BEQZ or opcode = BNEZ or opcode = J or opcode = JAL then
            branch_target <= immediate_in(ADDR_WIDTH-1 downto 0);
        elsif opcode = JR or opcode = JALR then
            branch_target <= reg1_ff(ADDR_WIDTH-1 downto 0);
        else
            branch_target <= (others => '0');
        end if;
        if (opcode = BEQZ and reg1_ff = x"00000000") or (opcode = BNEZ and reg1_ff /= x"00000000") or opcode = J or opcode = JR or opcode = JAL or opcode = JALR then
            branch_taken <= '1';
        else
            branch_taken <= '0';
        end if;
    end process;

end hierarchial;