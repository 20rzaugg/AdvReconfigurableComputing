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
        op : in std_logic_vector(7 downto 0);
        out1 : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0')
    );
end ALU;

architecture Behavioral of ALU is

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

    signal signed_result : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal unsigned_result : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal next_out1 : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    mux_inst : mux2_1
    generic map (
        MUX_WIDTH => DATA_WIDTH
    )
    port map (
        sel => op(1),
        in0 => signed_result,
        in1 => unsigned_result,
        out0 => next_out1
    );

    process(clk, rst_l) begin
        if rst_l = '0' then
            out1 <= (others => '0');
        elsif rising_edge(clk) then
            out1 <= next_out1;
        end if;
    end process;

    process(op, in1, in2) is
        variable k : std_logic_vector(7 downto 0);
    begin
        signed_result <= (others => '0');
        unsigned_result <= (others => '0');
        k := op and X"FC";
        case k is
            when SW =>
                signed_result <= std_logic_vector(unsigned(in1) + unsigned(in2));
            when LW =>
                signed_result <= std_logic_vector(unsigned(in1) + unsigned(in2));
            when ADDx =>
                signed_result <= std_logic_vector(signed(in1) + signed(in2));
                unsigned_result <= std_logic_vector(unsigned(in1) + unsigned(in2));
            when SUBx =>
                signed_result <= std_logic_vector(signed(in1) - signed(in2));
                unsigned_result <= std_logic_vector(unsigned(in1) - unsigned(in2));
            when ANDx =>
                signed_result <= in1 and in2;
            when ORx =>
                signed_result <= in1 or in2;
            when XORx =>
                signed_result <= in1 xor in2;
            when SLLx =>
                signed_result <= std_logic_vector(shift_left(unsigned(in1), to_integer(unsigned(in2))));
            when SRLx =>
                signed_result <= std_logic_vector(shift_right(unsigned(in1), to_integer(unsigned(in2))));
            when SRAx =>
                signed_result <= arithmetic_right_shift(in1, to_integer(signed(in2)));
            when SLT =>
                if signed(in1) < signed(in2) then
                    signed_result <= x"0000000000000001";
                end if;
                if unsigned(in1) < unsigned(in2) then
                    unsigned_result <= x"0000000000000001";
                end if;
            when SGT =>
                if signed(in1) > signed(in2) then
                    signed_result <= x"0000000000000001";
                end if;
                if unsigned(in1) > unsigned(in2) then
                    unsigned_result <= x"0000000000000001";
                end if;
            when SLE => 
                if signed(in1) <= signed(in2) then
                    signed_result <= x"0000000000000001";
                end if;
                if unsigned(in1) <= unsigned(in2) then
                    unsigned_result <= x"0000000000000001";
                end if;
            when SGE => 
                if signed(in1) >= signed(in2) then
                    signed_result <= x"0000000000000001";
                end if;
                if unsigned(in1) >= unsigned(in2) then
                    unsigned_result <= x"0000000000000001";
                end if;
            when SEQ =>
                if in1 = in2 then
                    signed_result <= x"0000000000000001";
                    unsigned_result <= x"0000000000000001";
                end if;
            when SNE =>
                if in1 /= in2 then
                    signed_result <= x"0000000000000001";
                    unsigned_result <= x"0000000000000001";
                end if;
            when JAL =>
                signed_result <= in1;
            when others =>
        end case;
    end process;
end Behavioral;