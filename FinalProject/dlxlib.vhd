library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package dlxlib is
    constant ADDR_WIDTH : integer := 10;
    constant DATA_WIDTH : integer := 64;
    constant INSTR_WIDTH : integer := 64;
    constant MEM_SIZE : integer := 2**ADDR_WIDTH;

    constant NOOP  : std_logic_vector(7 downto 0) := "00000000";

    constant LW    : std_logic_vector(7 downto 0) := "10000000";
    constant SW    : std_logic_vector(7 downto 0) := "00000100";

    constant ADDx  : std_logic_vector(7 downto 0) := "10000100";
    constant SUBx  : std_logic_vector(7 downto 0) := "10001000";
    constant ANDx  : std_logic_vector(7 downto 0) := "10001100";
    constant ORx   : std_logic_vector(7 downto 0) := "10010000";
    constant XORx  : std_logic_vector(7 downto 0) := "10010100";
    constant SLLx  : std_logic_vector(7 downto 0) := "10011000";
    constant SRLx  : std_logic_vector(7 downto 0) := "10011100";
    constant SRAx  : std_logic_vector(7 downto 0) := "10100000";

    constant SGT   : std_logic_vector(7 downto 0) := "10100100";
    constant SGE   : std_logic_vector(7 downto 0) := "10101000";
    constant SLT   : std_logic_vector(7 downto 0) := "10101100";
    constant SLE   : std_logic_vector(7 downto 0) := "10110000";
    constant SEQ   : std_logic_vector(7 downto 0) := "10110100";
    constant SNE   : std_logic_vector(7 downto 0) := "10111000";
    constant J     : std_logic_vector(7 downto 0) := "00111100";
    constant JAL   : std_logic_vector(7 downto 0) := "10111100";
    constant BEQZ  : std_logic_vector(7 downto 0) := "00110100";
    constant BNEZ  : std_logic_vector(7 downto 0) := "00111000";

    constant PCH   : std_logic_vector(7 downto 0) := "01000000";
    constant PD    : std_logic_vector(7 downto 0) := "01000100";
    constant GD    : std_logic_vector(7 downto 0) := "11000000";
    constant TCLR  : std_logic_vector(7 downto 0) := "01100000";
    constant TSRT  : std_logic_vector(7 downto 0) := "01100100";
    constant TSTP  : std_logic_vector(7 downto 0) := "01101000";
    constant LCM   : std_logic_vector(7 downto 0) := "11100000";

    constant NO_HAZARD : std_logic_vector(1 downto 0) := "00";
    constant RBW_EXMEM : std_logic_vector(1 downto 0) := "01";
    constant RBW_MEMWB_ALU : std_logic_vector(1 downto 0) := "10";
    constant RBW_MEMWB_MEM : std_logic_vector(1 downto 0) := "11";

    function arithmetic_right_shift(
        input_data : in std_logic_vector;
        shift_amt : in integer range 0 to DATA_WIDTH-1)
        return std_logic_vector;
    function opcode(instr : std_logic_vector(INSTR_WIDTH-1 downto 0)) return std_logic_vector;
    function regdest(instr : std_logic_vector(INSTR_WIDTH-1 downto 0)) return std_logic_vector;
    function regsrc1(instr : std_logic_vector(INSTR_WIDTH-1 downto 0)) return std_logic_vector;
    function regsrc2(instr : std_logic_vector(INSTR_WIDTH-1 downto 0)) return std_logic_vector;
    function regsrc3(instr : std_logic_vector(INSTR_WIDTH-1 downto 0)) return std_logic_vector;
    function immediate(instr : std_logic_vector(INSTR_WIDTH-1 downto 0)) return std_logic_vector;

    function has_writeback(op : std_logic_vector(7 downto 0)) return std_logic;
    function is_unsigned(op : std_logic_vector(7 downto 0)) return std_logic;
    function is_immediate(op : std_logic_vector(7 downto 0)) return std_logic;

    function op_cmp(op1 : std_logic_vector(7 downto 0); op2 : std_logic_vector(7 downto 0)) return boolean;

end package dlxlib;

package body dlxlib is

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

    function opcode(instr : in std_logic_vector(INSTR_WIDTH-1 downto 0)) return std_logic_vector is begin
        return instr(63 downto 56);
    end opcode;

    function regdest(instr : in std_logic_vector(INSTR_WIDTH-1 downto 0)) return std_logic_vector is begin
        return instr(55 downto 50);
    end regdest;

    function regsrc1(instr : std_logic_vector(INSTR_WIDTH-1 downto 0)) return std_logic_vector is begin
        return instr(49 downto 44);
    end regsrc1;
    
    function regsrc2(instr : std_logic_vector(INSTR_WIDTH-1 downto 0)) return std_logic_vector is begin
        return instr(43 downto 38);
    end regsrc2;
    
    function regsrc3(instr : std_logic_vector(INSTR_WIDTH-1 downto 0)) return std_logic_vector is begin
        return instr(37 downto 32);
    end regsrc3;
    
    function immediate(instr : std_logic_vector(INSTR_WIDTH-1 downto 0)) return std_logic_vector is begin
        return instr(31 downto 0);
    end immediate;

    function has_writeback(op : std_logic_vector(7 downto 0)) return std_logic is begin
        return op(7);
    end has_writeback;
        
    function is_unsigned(op : std_logic_vector(7 downto 0)) return std_logic is begin
        return op(1);
    end is_unsigned;

    function is_immediate(op : std_logic_vector(7 downto 0)) return std_logic is begin
        return op(0);
    end is_immediate;

    function op_cmp(op1 : std_logic_vector(7 downto 0); op2 : std_logic_vector(7 downto 0)) return boolean is begin
        return (op1 and X"FC") = op2;
    end op_cmp;
end package body;
