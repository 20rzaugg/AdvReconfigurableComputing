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
    constant ADD : std_logic_vector(5 downto 0) := "000011";
    constant ADDI : std_logic_vector(5 downto 0) := "000100";
    constant ADDU : std_logic_vector(5 downto 0) := "000101";
    constant ADDUI : std_logic_vector(5 downto 0) := "000110";
    constant SUB : std_logic_vector(5 downto 0) := "000111";
    constant SUBI : std_logic_vector(5 downto 0) := "001000";
    constant SUBU : std_logic_vector(5 downto 0) := "001001";
    constant SUBUI : std_logic_vector(5 downto 0) := "001010";
    constant AND_ : std_logic_vector(5 downto 0) := "001011";
    constant ANDI : std_logic_vector(5 downto 0) := "001100";
    constant OR_ : std_logic_vector(5 downto 0) := "001101";
    constant ORI : std_logic_vector(5 downto 0) := "001110";
    constant XOR_ : std_logic_vector(5 downto 0) := "001111";
    constant XORI : std_logic_vector(5 downto 0) := "010000";
    constant SLL_ : std_logic_vector(5 downto 0) := "010001";
    constant SLLI : std_logic_vector(5 downto 0) := "010010";
    constant SRL_ : std_logic_vector(5 downto 0) := "010011";
    constant SRLI : std_logic_vector(5 downto 0) := "010100";
    constant SRA_ : std_logic_vector(5 downto 0) := "010101";
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

    function is_unsigned(opcode : std_logic_vector(5 downto 0)) return std_logic;

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
end package body;
