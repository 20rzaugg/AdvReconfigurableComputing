library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.dlxlib.all;

entity dlx_execute is
    port (
        clk : in std_logic;
        rst_l : in std_logic;
        addr_in : in std_logic_vector(ADDR_WIDTH-1 downto 0);
        reg_in1 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        reg_in2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
        immediate_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
        instr_in : in std_logic_vector(INSTR_WIDTH-1 downto 0);
        alu_result : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
        branch_taken : out std_logic := '0';
        instr_out : out std_logic_vector(INSTR_WIDTH-1 downto 0);
        reg2_out : out std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0')
    );
end dlx_execute;

architecture hierarchial of dlx_execute is

    component ALU is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            in1 : in std_logic_vector(DATA_WIDTH-1 downto 0);
            in2 : in std_logic_vector(DATA_WIDTH-1 downto 0);
            opcode : in std_logic_vector(5 downto 0);
            out1 : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component ALU;
    
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

    signal mux1_sel : std_logic;
    signal mux2_sel : std_logic;

    signal alu_in1 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal alu_in2 : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal opcode : std_logic_vector(5 downto 0);

    signal next_branch_taken : std_logic;

    signal expanded_address : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    opcode <= instr_in(31 downto 26);
    expanded_address <= "0000000000000000000000" & addr_in;

    muxinput1 : MUX2_1
        generic map (
            MUX_WIDTH => DATA_WIDTH
        )
        port map (
            sel => mux1_sel,
            in0 => expanded_address,
            in1 => reg_in1,
            out0 => alu_in1
        );

    muxinput2 : MUX2_1
        generic map (
            MUX_WIDTH => DATA_WIDTH
        )
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
            opcode => opcode,
            out1 => alu_result
        );
    
    
    mux1_sel <= is_link(opcode);
    mux2_sel <= is_immediate(opcode);

    
    process (clk, rst_l) is
    begin
        if (rst_l = '0') then
            branch_taken <= '0';
            instr_out <= (others => '0');
        elsif (rising_edge(clk)) then
            branch_taken <= next_branch_taken;
            instr_out <= instr_in;
            reg2_out <= reg_in2;            
        end if;
    end process;

    process (opcode, reg_in1) is
    begin
        if (opcode = BEQZ and reg_in1 = x"00000000") or (opcode = BNEZ and reg_in1 /= x"00000000") or opcode = J or opcode = JR or opcode = JAL or opcode = JALR then
            next_branch_taken <= '1';
        else
            next_branch_taken <= '0';
        end if;
    end process;

end hierarchial;