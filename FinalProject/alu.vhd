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

    process(op, in1, in2) begin
        case op(7 downto 2) is
            when SW(7 downto 2) =>
                signed_result <= std_logic_vector(unsigned(in1) + unsigned(in2));
                unsigned_result <= (others => 'X');
            when LW(7 downto 2) =>
                signed_result <= std_logic_vector(unsigned(in1) + unsigned(in2));
                unsigned_result <= (others => 'X');
            when ADDx(7 downto 2) =>
                signed_result <= std_logic_vector(signed(in1) + signed(in2));
                unsigned_result <= std_logic_vector(unsigned(in1) + unsigned(in2));
            when SUBx(7 downto 2) =>
                signed_result <= std_logic_vector(signed(in1) - signed(in2));
                unsigned_result <= std_logic_vector(unsigned(in1) - unsigned(in2));
            when ANDx(7 downto 2) =>
                signed_result <= in1 and in2;
                unsigned_result <= (others => 'X');
            when ORx(7 downto 2) =>
                signed_result <= in1 or in2;
                unsigned_result <= (others => 'X');
            when XORx(7 downto 2) =>
                signed_result <= in1 xor in2;
                unsigned_result <= (others => 'X');
            when SLLx(7 downto 2) =>
                signed_result <= std_logic_vector(shift_left(unsigned(in1), to_integer(unsigned(in2))));
                unsigned_result <= (others => 'X');
            when SRLx(7 downto 2) =>
                signed_result <= std_logic_vector(shift_right(unsigned(in1), to_integer(unsigned(in2))));
                unsigned_result <= (others => 'X');
            when SRAx(7 downto 2) =>
                signed_result <= arithmetic_right_shift(in1, to_integer(signed(in2)));
                unsigned_result <= (others => 'X');
            when SLT(7 downto 2) =>
                if signed(in1) < signed(in2) then
                    signed_result <= x"0000000000000001";
                else
                    signed_result <= (others => '0');
                end if;
                if unsigned(in1) < unsigned(in2) then
                    unsigned_result <= x"0000000000000001";
                else
                    unsigned_result <= (others => '0');
                end if;
            when SGT(7 downto 2) =>
                if signed(in1) > signed(in2) then
                    signed_result <= x"0000000000000001";
                else
                    signed_result <= (others => '0');
                end if;
                if unsigned(in1) > unsigned(in2) then
                    unsigned_result <= x"0000000000000001";
                else
                    unsigned_result <= (others => '0');
                end if;
            when SLE(7 downto 2) => 
                if signed(in1) <= signed(in2) then
                    signed_result <= x"0000000000000001";
                else
                    signed_result <= (others => '0');
                end if;
                if unsigned(in1) <= unsigned(in2) then
                    unsigned_result <= x"0000000000000001";
                else
                    unsigned_result <= (others => '0');
                end if;
            when SGE(7 downto 2) => 
                if signed(in1) >= signed(in2) then
                    signed_result <= x"0000000000000001";
                else
                    signed_result <= (others => '0');
                end if;
                if unsigned(in1) >= unsigned(in2) then
                    unsigned_result <= x"0000000000000001";
                else
                    unsigned_result <= (others => '0');
                end if;
            when JAL(7 downto 2) =>
                signed_result <= in1;
                unsigned_result <= (others => 'X');
            when others =>
                signed_result <= (others => 'X');
                unsigned_result <= (others => 'X');
        end case;
    end process;
end Behavioral;