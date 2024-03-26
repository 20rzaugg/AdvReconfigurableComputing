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
        writeback_address_out : out std_logic_vector(4 downto 0);
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
            in3 => x"00000000",
            out0 => writeback_data_out
        );

    writeback_enable_out <= has_writeback(instr_in(31 downto 26));

    process(instr_in) begin
        if instr_in(31 downto 26) = LW then
            mux_selector <= "00";
        elsif instr_in(31 downto 26) = GD or instr_in(31 downto 26) = GDU then
            mux_selector <= "01";
        else
            mux_selector <= "10";
        end if;

        if instr_in(31 downto 26) = JAL or instr_in(31 downto 26) = JALR then
            writeback_address_out <= "11111"; -- link register = 31
        else
            writeback_address_out <= instr_in(25 downto 21);
        end if;
    end process;

end hierarchial;
