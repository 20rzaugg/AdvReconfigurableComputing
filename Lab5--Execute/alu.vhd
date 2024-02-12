library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.ALL;
library work;
use work.dlxlib.all;

entity ALU is
    port (
        clk : in std_logic;
        rst_l : in std_logic;
        in1 : in std_logic_vector(DATA_WIDTH downto 0);
        in2 : in std_logic_vector(DATA_WIDTH downto 0);
        opcode : in std_logic_vector(5 downto 0);
        out1 : out std_logic_vector(DATA_WIDTH downto 0) := (others => '0')
    );
end ALU;

architecture Behavioral of ALU is

    signal next_out1 : std_logic_vector(DATA_WIDTH downto 0);

begin

    process(clk, rst_l) begin
        if rst_l = '0' then
            next_out1 <= (others => '0');
        elsif rising_edge(clk) then
            out1 <= next_out1;
        end if;
    end process;

    process(opcode, in1, in2) begin
        case opcode is
            when ADD =>
                next_out1 <= std_logic_vector(signed(in1) + signed(in2));
            when ADDI =>
                next_out1 <= std_logic_vector(signed(in1) + signed(in2));
            when ADDU =>
                next_out1 <= std_logic_vector(unsigned(in1) + unsigned(in2));
            when ADDUI =>
                next_out1 <= std_logic_vector(unsigned(in1) + unsigned(in2));
            when SUB =>
                next_out1 <= std_logic_vector(signed(in1) - signed(in2));
            when SUBI =>
                next_out1 <= std_logic_vector(signed(in1) - signed(in2));
            when SUBU =>
                next_out1 <= std_logic_vector(unsigned(in1) - unsigned(in2));
            when SUBUI =>
                next_out1 <= std_logic_vector(unsigned(in1) - unsigned(in2));
            when AND_ =>
                next_out1 <= in1 and in2;
            when ANDI =>
                next_out1 <= in1 and in2;
            when OR_ =>
                next_out1 <= in1 or in2;
            when ORI =>
                next_out1 <= in1 or in2;
            when XOR_ =>
                next_out1 <= in1 xor in2;
            when XORI =>
                next_out1 <= in1 xor in2;
            when SLL_ =>
                next_out1 <= std_logic_vector(shift_left(unsigned(in1), to_integer(unsigned(in2))));
            when SLLI =>
                next_out1 <= std_logic_vector(shift_left(unsigned(in1), to_integer(unsigned(in2))));
            when SRL_ =>
                next_out1 <= std_logic_vector(shift_right(unsigned(in1), to_integer(unsigned(in2))));
            when SRLI =>
                next_out1 <= std_logic_vector(shift_right(unsigned(in1), to_integer(unsigned(in2))));
            when SRA_ =>
                next_out1 <= std_logic_vector(shift_right(signed(in1), to_integer(unsigned(in2))));
            when SRAI =>
                next_out1 <= std_logic_vector(shift_right(signed(in1), to_integer(unsigned(in2))));
            when SLT =>
                next_out1 <= std_logic_vector(signed(in1) < signed(in2));
            when SLTI =>
                next_out1 <= std_logic_vector(signed(in1) < signed(in2));
            when SLTU =>
                next_out1 <= std_logic_vector(unsigned(in1) < unsigned(in2));
            when SLTUI =>
                next_out1 <= std_logic_vector(unsigned(in1) < unsigned(in2));
            when others =>
                next_out1 <= (others => '0');
        end case;
    end process;
end Behavioral;