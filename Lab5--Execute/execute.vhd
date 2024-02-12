library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.dlxlib.all;

entity dlx_execute is
    port (
        clk : in std_logic;
        rst_l : in std_logic;
        next_pc : in std_logic_vector(ADDR_WIDTH downto 0);
        reg_in1 : in std_logic_vector(DATA_WIDTH downto 0);
        reg_in2 : in std_logic_vector(DATA_WIDTH downto 0);
        immediate_in : in std_logic_vector(DATA_WIDTH downto 0);
        instr_in : in std_logic_vector(INSTR_WIDTH downto 0);
        alu_result : out std_logic_vector(DATA_WIDTH downto 0);

    )
end dlx_execute;

architecture hierarchial of dlx_execute is

    component ALU is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            in1 : in std_logic_vector(DATA_WIDTH downto 0);
            in2 : in std_logic_vector(DATA_WIDTH downto 0);
            opcode : in std_logic_vector(5 downto 0);
            out1 : out std_logic_vector(DATA_WIDTH downto 0)
        );
    end component ALU;
    
    component MUX2_1 is
        parameter MUX_WIDTH : integer := 32;
        port (
            sel : in std_logic;
            in0 : in std_logic_vector(MUX_WIDTH-1 downto 0);
            in1 : in std_logic_vector(MUX_WIDTH-1 downto 0);
            out0 : out std_logic_vector(MUX_WIDTH-1 downto 0)
        );
    end component mux2_1;

    signal mux1_sel : std_logic;
    signal mux2_sel : std_logic;

    signal alu_in1 : std_logic_vector(DATA_WIDTH downto 0);
    signal alu_in2 : std_logic_vector(DATA_WIDTH downto 0);

    signal opcode : std_logic_vector(5 downto 0);

begin

    opcode <= instr_in(31 downto 26);

    muxinput1 : MUX2_1
        parameter MUX_WIDTH => DATA_WIDTH;
        port map (
            sel => mux1_sel,
            in0 => next_pc,
            in1 => reg_in1,
            out0 => alu_in1
        );

    muxinput2 : MUX2_1
        parameter MUX_WIDTH => DATA_WIDTH;
        port map (
            sel => mux2_sel,
            in0 => reg_in2,
            in1 => immediate_in,
            out0 => alu_in2
        );

    alu_inst : ALU
        port map (
            clk => clk,
            rst_l => rst_l,
            in1 => alu_in1,
            in2 => alu_in2,
            opcode => opcode
            out1 => alu_result
        );

end hierarchial;