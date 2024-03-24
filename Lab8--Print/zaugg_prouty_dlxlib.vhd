library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package dlxlib is
    constant ADDR_WIDTH : integer := 10;
    constant DATA_WIDTH : integer := 32;
    constant INSTR_WIDTH : integer := 32;
    constant MEM_SIZE : integer := 2**ADDR_WIDTH;

    constant NOOP : std_logic_vector(5 downto 0) := "000000";
    constant LW : std_logic_vector(5 downto 0) := "000001";
    constant SW : std_logic_vector(5 downto 0) := "000010";
    constant ADDx : std_logic_vector(5 downto 0) := "000011";
    constant ADDI : std_logic_vector(5 downto 0) := "000100";
    constant ADDU : std_logic_vector(5 downto 0) := "000101";
    constant ADDUI : std_logic_vector(5 downto 0) := "000110";
    constant SUBx : std_logic_vector(5 downto 0) := "000111";
    constant SUBI : std_logic_vector(5 downto 0) := "001000";
    constant SUBU : std_logic_vector(5 downto 0) := "001001";
    constant SUBUI : std_logic_vector(5 downto 0) := "001010";
    constant ANDx : std_logic_vector(5 downto 0) := "001011";
    constant ANDI : std_logic_vector(5 downto 0) := "001100";
    constant ORx : std_logic_vector(5 downto 0) := "001101";
    constant ORI : std_logic_vector(5 downto 0) := "001110";
    constant XORx : std_logic_vector(5 downto 0) := "001111";
    constant XORI : std_logic_vector(5 downto 0) := "010000";
    constant SLLx : std_logic_vector(5 downto 0) := "010001";
    constant SLLI : std_logic_vector(5 downto 0) := "010010";
    constant SRLx : std_logic_vector(5 downto 0) := "010011";
    constant SRLI : std_logic_vector(5 downto 0) := "010100";
    constant SRAx : std_logic_vector(5 downto 0) := "010101";
    constant SRAI : std_logic_vector(5 downto 0) := "010110";
    constant SLT : std_logic_vector(5 downto 0) := "010111";
    constant SLTI : std_logic_vector(5 downto 0) := "011000";
    constant SLTU : std_logic_vector(5 downto 0) := "011001";
    constant SLTUI : std_logic_vector(5 downto 0) := "011010";
    constant SGT : std_logic_vector(5 downto 0) := "011011";
    constant SGTI : std_logic_vector(5 downto 0) := "011100";
    constant SGTU : std_logic_vector(5 downto 0) := "011101";
    constant SGTUI : std_logic_vector(5 downto 0) := "011110";
    constant SLE : std_logic_vector(5 downto 0) := "011111";
    constant SLEI : std_logic_vector(5 downto 0) := "100000";
    constant SLEU : std_logic_vector(5 downto 0) := "100001";
    constant SLEUI : std_logic_vector(5 downto 0) := "100010";
    constant SGE : std_logic_vector(5 downto 0) := "100011";
    constant SGEI : std_logic_vector(5 downto 0) := "100100";
    constant SGEU : std_logic_vector(5 downto 0) := "100101";
    constant SGEUI : std_logic_vector(5 downto 0) := "100110";
    constant SEQ : std_logic_vector(5 downto 0) := "100111";
    constant SEQI : std_logic_vector(5 downto 0) := "101000";
    constant SNE : std_logic_vector(5 downto 0) := "101001";
    constant SNEI : std_logic_vector(5 downto 0) := "101010";
    constant BEQZ : std_logic_vector(5 downto 0) := "101011";
    constant BNEZ : std_logic_vector(5 downto 0) := "101100";
    constant J : std_logic_vector(5 downto 0) := "101101";
    constant JR : std_logic_vector(5 downto 0) := "101110";
    constant JAL : std_logic_vector(5 downto 0) := "101111";
    constant JALR : std_logic_vector(5 downto 0) := "110000";
    constant PCH : std_logic_vector(5 downto 0) := "110001";
    constant PD : std_logic_vector(5 downto 0) := "110010";
    constant PDU : std_logic_vector(5 downto 0) := "110011";
    constant GD : std_logic_vector(5 downto 0) := "110100";
    constant GDU : std_logic_vector(5 downto 0) := "110101";
    constant LWP : std_logic_vector(5 downto 0) := "110110";
    constant SWP : std_logic_vector(5 downto 0) := "110111";

    constant NO_HAZARD : std_logic_vector(1 downto 0) := "00";
    constant RBW_EXMEM : std_logic_vector(1 downto 0) := "01";
    constant RBW_MEMWB_ALU : std_logic_vector(1 downto 0) := "10";
    constant RBW_MEMWB_MEM : std_logic_vector(1 downto 0) := "11";

    function is_unsigned(opcode : std_logic_vector(5 downto 0)) return std_logic;
    function is_immediate(opcode : std_logic_vector(5 downto 0)) return std_logic;
    function is_link(opcode : std_logic_vector(5 downto 0)) return std_logic;
    function arithmetic_right_shift(
        input_data : in std_logic_vector;
        shift_amt : in integer range 0 to DATA_WIDTH-1)
        return std_logic_vector;
    function has_writeback(opcode : std_logic_vector(5 downto 0)) return std_logic;

end package dlxlib;

package body dlxlib is
    function is_unsigned(opcode : std_logic_vector(5 downto 0)) return std_logic is
    begin
        if opcode = ADDU or opcode = ADDUI or opcode = SUBU or opcode = SUBUI or opcode = SLTU or
           opcode = SLTUI or opcode = SGTU or opcode = SGTUI or opcode = SLEU or opcode = SLEUI or
           opcode = SGEU or opcode = SGEUI then 
            return '1';
        else
            return '0';
        end if;
    end function;

    function is_immediate(opcode : std_logic_vector(5 downto 0)) return std_logic is
    begin
        if opcode = ADDI or opcode = ADDUI or opcode = SUBI or opcode = SUBUI or opcode = ANDI or
           opcode = ORI or opcode = XORI or opcode = SLLI or opcode = SRLI or opcode = SRAI or
           opcode = SLTI or opcode = SLTUI or opcode = SGTI or opcode = SGTUI or opcode = SLEI or
           opcode = SLEUI or opcode = SGEI or opcode = SGEUI or opcode = SEQI or opcode = SNEI or
           opcode = BEQZ or opcode = BNEZ or opcode = J or opcode = JAL or opcode = LW or opcode = SW then 
            return '1';
        else
            return '0';
        end if;
    end function;

    function is_link(opcode : std_logic_vector(5 downto 0)) return std_logic is
    begin
        if opcode = JAL or opcode = JALR then
            return '0';
        else
            return '1';
        end if;
    end;

    function arithmetic_right_shift(
        input_data : in std_logic_vector;
        shift_amt : in integer range 0 to DATA_WIDTH-1)
        return std_logic_vector is
        variable temp : std_logic_vector(DATA_WIDTH-1 downto 0);
        variable k : std_logic;
    begin
        -- Perform arithmetic right shift
        if shift_amt > 0 then
            temp := input_data;
            for i in 0 to DATA_WIDTH-1 loop
					if i <= shift_amt-1 then
						k := temp(temp'high); -- Preserve sign bit
						temp := temp(0) & temp(temp'high downto 1);
					end if;
            end loop;
            return temp;
        else
            return input_data; -- No shift if shift_amt is negative
        end if;
    end arithmetic_right_shift;

    function has_writeback(opcode : std_logic_vector(5 downto 0)) return std_logic is
    begin
        if opcode = ADDx or opcode = ADDU or opcode = ADDI or opcode = ADDUI or opcode = SUBx or
           opcode = SUBU or opcode = SUBI or opcode = SUBUI or opcode = ANDx or opcode = ANDI or
           opcode = ORx or opcode = ORI or opcode = XORx or opcode = XORI or opcode = SLLx or
           opcode = SLLI or opcode = SRLx or opcode = SRLI or opcode = SRAx or opcode = SRAI or
           opcode = SLT or opcode = SLTI or opcode = SLTU or opcode = SLTUI or opcode = SGT or
           opcode = SGTI or opcode = SGTU or opcode = SGTUI or opcode = SLE or opcode = SLEI or
           opcode = SLEU or opcode = SLEUI or opcode = SGE or opcode = SGEI or opcode = SGEU or
           opcode = SGEUI or opcode = SEQ or opcode = SEQI or opcode = SNE or opcode = SNEI or
           opcode = JAL or opcode = JALR or opcode = LW or opcode = LWP then
            return '1';
        else
            return '0';
        end if;
    end function;
end package body;
