library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
library work;
use work.dlxlib.all;

entity ALU is
    port (
        clk : in std_logic;
        rst_l : in std_logic;
        in1 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        in2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        opcode : in std_logic_vector(5 downto 0);
        out1 : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0')
    );
end ALU;

architecture Behavioral of ALU is

    signal next_out1 : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    process(clk, rst_l) begin
        if rst_l = '0' then
            out1 <= (others => '0');
        elsif rising_edge(clk) then
            out1 <= next_out1;
        end if;
    end process;

    process(opcode, in1, in2) begin
        case opcode is
            when NOOP =>
                next_out1 <= (others => '0');
            when SW =>
                next_out1 <= std_logic_vector(unsigned(in1) + unsigned(in2));
            when LW =>
                next_out1 <= std_logic_vector(unsigned(in1) + unsigned(in2));
            when ADDx =>
                next_out1 <= std_logic_vector(signed(in1) + signed(in2));
            when ADDI =>
                next_out1 <= std_logic_vector(signed(in1) + signed(in2));
            when ADDU =>
                next_out1 <= std_logic_vector(unsigned(in1) + unsigned(in2));
            when ADDUI =>
                next_out1 <= std_logic_vector(unsigned(in1) + unsigned(in2));
            when SUBx =>
                next_out1 <= std_logic_vector(signed(in1) - signed(in2));
            when SUBI =>
                next_out1 <= std_logic_vector(signed(in1) - signed(in2));
            when SUBU =>
                next_out1 <= std_logic_vector(unsigned(in1) - unsigned(in2));
            when SUBUI =>
                next_out1 <= std_logic_vector(unsigned(in1) - unsigned(in2));
            when ANDx =>
                next_out1 <= in1 and in2;
            when ANDI =>
                next_out1 <= in1 and in2;
            when ORx =>
                next_out1 <= in1 or in2;
            when ORI =>
                next_out1 <= in1 or in2;
            when XORx =>
                next_out1 <= in1 xor in2;
            when XORI =>
                next_out1 <= in1 xor in2;
            when SLLx =>
                next_out1 <= std_logic_vector(shift_left(unsigned(in1), to_integer(unsigned(in2))));
            when SLLI =>
                next_out1 <= std_logic_vector(shift_left(unsigned(in1), to_integer(unsigned(in2))));
            when SRLx =>
                next_out1 <= std_logic_vector(shift_right(unsigned(in1), to_integer(unsigned(in2))));
            when SRLI =>
                next_out1 <= std_logic_vector(shift_right(unsigned(in1), to_integer(unsigned(in2))));
            when SRAx =>
                next_out1 <= arithmetic_right_shift(in1, to_integer(signed(in2)));
            when SRAI =>
                next_out1 <= arithmetic_right_shift(in1, to_integer(signed(in2)));
            when SLT =>
                if signed(in1) < signed(in2) then
                    next_out1 <= x"00000001";
                else
                    next_out1 <= (others => '0');
                end if;
            when SLTI =>
                if signed(in1) < signed(in2) then
                    next_out1 <= x"00000001";
                else
                    next_out1 <= (others => '0');
                end if;
            when SLTU =>
                if unsigned(in1) < unsigned(in2) then
                    next_out1 <= x"00000001";
                else
                    next_out1 <=(others => '0');
                end if;
            when SLTUI =>
                if unsigned(in1) < unsigned(in2) then
                    next_out1 <= x"00000001";
                else
                    next_out1 <=(others => '0');
                end if;
            when SGT =>
                if signed(in1) > signed(in2) then
                    next_out1 <= x"00000001";
                else
                    next_out1 <=(others => '0');
                end if;
            when SGTI =>
                if signed(in1) > signed(in2) then
                    next_out1 <= x"00000001";
                else
                    next_out1 <=(others => '0');
                end if;
            when SGTU =>
                if unsigned(in1) > unsigned(in2) then
                    next_out1 <= x"00000001";
                else
                    next_out1 <=(others => '0');
                end if;
            when SGTUI =>
                if unsigned(in1) > unsigned(in2) then
                    next_out1 <= x"00000001";
                else
                    next_out1 <=(others => '0');
                end if;
            when SLE => 
                if signed(in1) <= signed(in2) then
                    next_out1 <= x"00000001";
                else
                    next_out1 <=(others => '0');
                end if;
            when SLEI => 
                if signed(in1) <= signed(in2) then
                    next_out1 <= x"00000001";
                else
                    next_out1 <=(others => '0');
                end if;
            when SLEU => 
                if unsigned(in1) <= unsigned(in2) then
                    next_out1 <= x"00000001";
                else
                    next_out1 <=(others => '0');
                end if;
            when SLEUI => 
                if unsigned(in1) <= unsigned(in2) then
                    next_out1 <= x"00000001";
                else
                    next_out1 <=(others => '0');
                end if;
            when SGE => 
                if signed(in1) >= signed(in2) then
                    next_out1 <= x"00000001";
                else
                    next_out1 <=(others => '0');
                end if;
            when SGEI => 
                if signed(in1) >= signed(in2) then
                    next_out1 <= x"00000001";
                else
                    next_out1 <=(others => '0');
                end if;
            when SGEU => 
                if unsigned(in1) >= unsigned(in2) then
                    next_out1 <= x"00000001";
                else
                    next_out1 <=(others => '0');
                end if;
            when SGEUI => 
                if unsigned(in1) >= unsigned(in2) then
                    next_out1 <= x"00000001";
                else
                    next_out1 <=(others => '0');
                end if;
            when BEQZ =>
                next_out1 <= in2;
            when BNEZ =>
                next_out1 <= in2;
            when J =>
                next_out1 <= in2;
            when JR =>
                next_out1 <= in1;
            when JAL =>
                next_out1 <= in2;
            when JALR =>
                next_out1 <= in1;
            when others =>
                next_out1 <= (others => '0');
        end case;
    end process;
end Behavioral;