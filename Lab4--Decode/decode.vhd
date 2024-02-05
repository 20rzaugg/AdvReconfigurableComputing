library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.dlxlib.all;

entity dlx_decode is
    Port ( 
        clk : in  STD_LOGIC;
        rst_l : in  STD_LOGIC := '0';
        addr_in : in STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
        instr_in : in STD_LOGIC_VECTOR (INSTR_WIDTH-1 downto 0);
        writeback_data : in STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        writeback_reg : in STD_LOGIC_VECTOR (4 downto 0);
        writeback_en : in STD_LOGIC;
        rs1_data : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        rs2_data : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        immediate : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        instr_out : out STD_LOGIC_VECTOR (INSTR_WIDTH-1 downto 0);
        addr_out : out STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
    );
end dlx_decode;

architecture hierarchial of dlx_decode is

    signal opcode : STD_LOGIC_VECTOR (5 downto 0);
    signal rs1 : STD_LOGIC_VECTOR (4 downto 0);
    signal rs2 : STD_LOGIC_VECTOR (4 downto 0);
    signal imm16 : STD_LOGIC_VECTOR (15 downto 0);

    component register_mem
        port (
            clk : in std_logic;
            read_addr1 : in std_logic_vector(4 downto 0);
            read_addr2 : in std_logic_vector(4 downto 0);
            write_addr : in std_logic_vector(4 downto 0);
            write_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
            write_en : in std_logic := '0';
            read_q1 : out std_logic_vector(DATA_WIDTH-1 downto 0);
            read_q2 : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

begin

    rs1 <= instr_in(20 downto 16);
    rs2 <= instr_in(15 downto 11);
    imm16 <= instr_in(15 downto 0);

    registers : register_mem
        port map (
            clk => clk,
            read_addr1 => rs1,
            read_addr2 => rs2,
            write_addr => writeback_reg,
            write_data => writeback_data,
            write_en => writeback_en,
            read_q1 => rs1_data,
            read_q2 => rs2_data
        );

    process(clk, rst_l) begin
        if rising_edge(clk) then
            instr_out <= instr_in;
            addr_out <= addr_in;
        end if;
    end

end hierarchial;
