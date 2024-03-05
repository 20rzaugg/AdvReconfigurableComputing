library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.dlxlib.all;

entity dlx_decode is
    Port ( 
        clk : in  STD_LOGIC;
        rst_l : in  STD_LOGIC := '0';
        decode_pc : in STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
        decode_instr : in STD_LOGIC_VECTOR (INSTR_WIDTH-1 downto 0);
        writeback_data : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        writeback_reg : in STD_LOGIC_VECTOR (4 downto 0);
        writeback_en : in STD_LOGIC;
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
end dlx_decode;

architecture hierarchial of dlx_decode is

    signal opcode : STD_LOGIC_VECTOR (5 downto 0);
    signal rs1 : STD_LOGIC_VECTOR (4 downto 0);
    signal rs2 : STD_LOGIC_VECTOR (4 downto 0);
    signal imm16 : STD_LOGIC_VECTOR (15 downto 0);

    component register_mem
        port (
            clk : in std_logic;
            read_addr1 : in std_logic_vector(4 downto 0);
            read_addr2 : in std_logic_vector(4 downto 0);
            write_addr : in std_logic_vector(4 downto 0);
            write_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
            write_en : in std_logic := '0';
            read_q1 : out std_logic_vector(DATA_WIDTH-1 downto 0);
            read_q2 : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    component signExtend
        port ( 
            input : in  STD_LOGIC_VECTOR (15 downto 0);
            us : in STD_LOGIC;
            output : out  STD_LOGIC_VECTOR (31 downto 0)
        );
    end component;

    signal next_immediate : STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);

begin

    opcode <= decode_instr(31 downto 26);
    rs1 <= decode_instr(20 downto 16);
    imm16 <= decode_instr(15 downto 0);


    process(opcode) begin
        if opcode = SW then
            rs2 <= decode_instr(25 downto 21);
        else
            rs2 <= decode_instr(15 downto 11);
        end if;
    end process;

    register_inst : register_mem
        port map (
            clk => clk,
            read_addr1 => rs1,
            read_addr2 => rs2,
            write_addr => writeback_reg,
            write_data => writeback_data,
            write_en => writeback_en,
            read_q1 => rs1_data,
            read_q2 => rs2_data
        );

    signExtend_inst : signExtend
        port map (
            input => imm16,
            us => is_unsigned(opcode),
            output => next_immediate
        );


    process(clk, rst_l) begin
        if rising_edge(clk) then
            if bubble = '0' then
                execute_instr <= decode_instr;
                execute_pc <= decode_pc;
                immediate <= next_immediate;
            else then
                execute_instr <= (others => '0');
                execute_pc <= (others => '0');
                immediate <= (others => '0');
            end if;
        end if;
    end process;

    -- add output data hazard detection

    process(decode_instr, execute_instr, memory_instr, rs1, rs2) begin
        bubble <= '0'
        -- check for data hazards in src1
        if rs1 = execute_instr(25 downto 21) and execute_instr(31 downto 26) = LW then
            bubble <= '1';
        elsif rs1 = execute_instr(25 downto 21) and has_writeback(execute_instr(31 downto 26) = '1') then
            top_data_hazard <= RBW_EXMEM;
        elsif rs1 = memory_instr(25 downto 21) and memory_instr(31 downto 26) = LW then
            top_data_hazard <= RBW_MEMWB_MEM;
        elsif rs1 = memory_instr(25 downto 21) and has_writeback(memory_instr(31 downto 26) = '1') then
            top_data_hazard <= RBW_MEMWB_ALU;
        else then
            top_data_hazard <= NO_HAZARD;
        end if;

        -- check for data hazards in src2
        if rs2 = execute_instr(25 downto 21) and execute_instr(31 downto 26) = LW and is_immediate(opcode) = '0' then
            bubble <= '1';
        elsif rs2 = execute_instr(25 downto 21) and has_writeback(execute_instr(31 downto 26) = '1') and is_immediate(opcode) = '0' then
            bottom_data_hazard <= RBW_EXMEM;
        elsif rs2 = memory_instr(25 downto 21) and memory_instr(31 downto 26) = LW and is_immediate(opcode) = '0' then
            bottom_data_hazard <= RBW_MEMWB_MEM;
        elsif rs2 = memory_instr(25 downto 21) and has_writeback(memory_instr(31 downto 26) = '1') and is_immediate(opcode) = '0' then
            bottom_data_hazard <= RBW_MEMWB_ALU;
        else then
            bottom_data_hazard <= NO_HAZARD;
        end if;  
    end process;

end hierarchial;
