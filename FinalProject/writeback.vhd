library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library work;
use work.dlxlib.all;

entity dlx_writeback is
    Port ( 
        instr_in : in  std_logic_vector(INSTR_WIDTH-1 downto 0) := (others => '0');
        data_mem_in : in std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
        alu_result_in : in std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
        writeback_data_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
        writeback_address_out : out std_logic_vector(5 downto 0);
        writeback_enable_out : out std_logic;
        input_buffer_output : in std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end dlx_writeback;

architecture hierarchial of dlx_writeback is
    
    component MUX4_1 is
        generic (
             MUX_WIDTH : integer := DATA_WIDTH
        );
        port (
            sel : in std_logic_vector (1 downto 0);
            in0 : in std_logic_vector(MUX_WIDTH-1 downto 0);
            in1 : in std_logic_vector(MUX_WIDTH-1 downto 0);
            in2 : in std_logic_vector(MUX_WIDTH-1 downto 0);
            in3 : in std_logic_vector(MUX_WIDTH-1 downto 0);
            out0 : out std_logic_vector(MUX_WIDTH-1 downto 0)
        );
    end component mux4_1;

    signal mux_selector : std_logic_vector(1 downto 0) := "00";

begin

    mux_inst : MUX4_1
        generic map (
            MUX_WIDTH => DATA_WIDTH
        )
        port map (
            sel => mux_selector,
            in0 => data_mem_in,
            in1 => input_buffer_output,
            in2 => alu_result_in,
            in3 => x"0000000000000000",
            out0 => writeback_data_out
        );

    writeback_enable_out <= instr_in(63);

    
    process(instr_in) begin
        -- Select writeback source (memory, scanner, or ALU)
        if op_cmp(opcode(instr_in), LW) then
            mux_selector <= "00";
        elsif op_cmp(opcode(instr_in), GD) then
            mux_selector <= "01";
        else
            mux_selector <= "10";
        end if;

        -- Select target register for write
        if op_cmp(opcode(instr_in), JAL) then
            writeback_address_out <= "111111"; -- link register = 63
            --Note to self: we can remove this logic if we hardcode all JAL instructions to have dest reg 63
        else
            writeback_address_out <= regdest(instr_in);
        end if;
    end process;

end hierarchial;
