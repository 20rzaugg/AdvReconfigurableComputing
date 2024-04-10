library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
library work;
use work.dlxlib.all;

entity dlx_decode is
    Port ( 
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
end dlx_decode;

architecture hierarchial of dlx_decode is

    signal op : STD_LOGIC_VECTOR (7 downto 0);
    signal rs1 : STD_LOGIC_VECTOR (5 downto 0);
    signal rs2 : STD_LOGIC_VECTOR (5 downto 0);
    signal rs3 : STD_LOGIC_VECTOR (5 downto 0);
    signal imm32 : STD_LOGIC_VECTOR (31 downto 0);
    signal pipeline_flush : std_logic := '0';
    signal instr_queue : STD_LOGIC_VECTOR (INSTR_WIDTH-1 downto 0);

    signal after_bubble : std_logic := '0';

    component register_mem
        port (
            clk : in std_logic;
            read_addr1 : in std_logic_vector(5 downto 0);
            read_addr2 : in std_logic_vector(5 downto 0);
            read_addr3 : in std_logic_vector(5 downto 0);
            write_addr : in std_logic_vector(5 downto 0);
            write_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
            write_en : in std_logic := '0';
            read_q1 : out std_logic_vector(DATA_WIDTH-1 downto 0);
            read_q2 : out std_logic_vector(DATA_WIDTH-1 downto 0);
            read_q3 : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    component signExtend
        port ( 
            input : in  STD_LOGIC_VECTOR (31 downto 0);
            us : in STD_LOGIC;
            output : out  STD_LOGIC_VECTOR (63 downto 0)
        );
    end component;

    signal next_immediate : STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
    signal next_data_hazard1 : STD_LOGIC_VECTOR (1 downto 0);
    signal next_data_hazard2 : STD_LOGIC_VECTOR (1 downto 0);
    signal next_data_hazard3 : STD_LOGIC_VECTOR (1 downto 0);

begin

    process(op, instr_queue, decode_instr, after_bubble) begin
        if after_bubble = '1' then
            op <= opcode(instr_queue);
            rs1 <= regsrc1(instr_queue);
            rs2 <= regsrc2(instr_queue);
            rs3 <= regsrc3(instr_queue);
            imm32 <= immediate(instr_queue);
        else
            op <= opcode(decode_instr);
            rs1 <= regsrc1(decode_instr);
            rs2 <= regsrc2(decode_instr);
            rs3 <= regsrc3(decode_instr);
            imm32 <= immediate(decode_instr);
        end if;
    end process;

    register_inst : register_mem
        port map (
            clk => clk,
            read_addr1 => rs1,
            read_addr2 => rs2,
            read_addr3 => rs3,
            write_addr => writeback_reg,
            write_data => writeback_data,
            write_en => writeback_en,
            read_q1 => rs1_data,
            read_q2 => rs2_data,
            read_q3 => rs3_data
        );

    signExtend_inst : signExtend
        port map (
            input => imm32,
            us => is_unsigned(op),
            output => next_immediate
        );


    process(clk, rst_l) begin
        if rst_l = '0' then
            data_hazard1 <= (others => '0');
            data_hazard2 <= (others => '0');
            data_hazard3 <= (others => '0');
            execute_instr <= (others => '0');
            execute_pc <= (others => '0');
            imm_out <= (others => '0');
            pipeline_flush <= '0';
            after_bubble <= '0';
            instr_queue <= (others => '0');
        elsif rising_edge(clk) then
            data_hazard1 <= next_data_hazard1;
            data_hazard2 <= next_data_hazard2;
            data_hazard3 <= next_data_hazard3;
            if after_bubble = '1' or pipeline_flush = '1' or bubble = '1' or branch_taken = '1' then
                execute_instr <= (others => '0');
                execute_pc <= (others => '0');
                imm_out <= (others => '0');
                if pipeline_flush = '1' then
                    pipeline_flush <= '0';
                end if;

                if branch_taken = '1' then
                    pipeline_flush <= '1';
                end if;

                if bubble = '1' then
                    after_bubble <= '1';
                    if instr_queue = x"0000000000000000" then
                        instr_queue <= decode_instr;
                    else
                        instr_queue <= instr_queue;
                    end if;
                elsif after_bubble = '1' then
                    instr_queue <= (others => '0');
                    execute_instr <= instr_queue;
                    execute_pc <= decode_pc;
                    imm_out <= next_immediate;
                    after_bubble <= '0';
                end if; 
            else
                execute_instr <= decode_instr;
                execute_pc <= decode_pc;
                imm_out <= next_immediate;
                instr_queue <= (others => '0');
                pipeline_flush <= '0';
                after_bubble <= '0';
            end if;
        end if;
    end process;

    process(decode_instr, execute_instr, memory_instr, rs1, rs2, print_queue_full, input_buffer_empty, op, instr_queue) begin
        bubble <= '0';
        -- check for data hazards in src1
        if rs1 = regdest(execute_instr) and (opcode(execute_instr) = LW or opcode(execute_instr) = GD) then
            bubble <= '1';
        elsif rs1 = regdest(execute_instr) and has_writeback(opcode(execute_instr)) = '1' then
            next_data_hazard1 <= RBW_EXMEM;
        elsif rs1 = regdest(memory_instr) and opcode(memory_instr) = LW then
            next_data_hazard1 <= RBW_MEMWB_MEM;
        elsif rs1 = regdest(memory_instr) and has_writeback(opcode(memory_instr)) = '1' then
            next_data_hazard1 <= RBW_MEMWB_ALU;
        else
            next_data_hazard1 <= NO_HAZARD;
        end if;

        -- check for data hazards in src2
        if rs2 = regdest(execute_instr) and (opcode(execute_instr) = LW or opcode(execute_instr) = GD) then
            bubble <= '1';
        elsif rs2 = regdest(execute_instr) and has_writeback(opcode(execute_instr)) = '1' then
            next_data_hazard2 <= RBW_EXMEM;
        elsif rs2 = regdest(memory_instr) and opcode(memory_instr) = LW then
            next_data_hazard2 <= RBW_MEMWB_MEM;
        elsif rs2 = regdest(memory_instr) and has_writeback(opcode(memory_instr)) = '1' then
            next_data_hazard2 <= RBW_MEMWB_ALU;
        else
            next_data_hazard2 <= NO_HAZARD;
        end if;
        
        -- check for data hazards in src3
        if rs3 = regdest(execute_instr) and (opcode(execute_instr) = LW or opcode(execute_instr) = GD) then
            bubble <= '1';
        elsif rs3 = regdest(execute_instr) and has_writeback(opcode(execute_instr)) = '1' then
            next_data_hazard3 <= RBW_EXMEM;
        elsif rs3 = regdest(memory_instr) and opcode(memory_instr) = LW then
            next_data_hazard3 <= RBW_MEMWB_MEM;
        elsif rs3 = regdest(memory_instr) and has_writeback(opcode(memory_instr)) = '1' then
            next_data_hazard3 <= RBW_MEMWB_ALU;
        else
            next_data_hazard3 <= NO_HAZARD;
        end if;

        -- handle "print buffer full" and "scan buffer empty"
        if (input_buffer_empty = '1' and (op = GD or opcode(instr_queue) = GD)) or (print_queue_full = '1' and (opcode = PD or opcode = PCH)) then
            bubble <= '1';
        end if;
        
    end process;

end hierarchial;
