library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use work.dlxlib.all;

entity TBexecute is
end TBexecute;

architecture testbench of TBexecute is
    
    component DLXpipeline is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            writeback_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
            writeback_reg : in std_logic_vector(4 downto 0);
            writeback_en : in std_logic;
            alu_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
            instr_out : out std_logic_vector(INSTR_WIDTH-1 downto 0);
            reg2_out: out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    signal clk : std_logic := '0';
    signal rst_l : std_logic := '1';
    signal writeback_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal writeback_reg : std_logic_vector(4 downto 0) := (others => '0');
    signal writeback_en : std_logic := '0';

    signal reg2_out : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal alu_result : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal instr_out : std_logic_vector(INSTR_WIDTH-1 downto 0) := (others => '0');

    signal index : integer := 0;
    signal next_index : integer := 0;

    signal next_writeback_reg : std_logic_vector(4 downto 0) := (others => '0');
    signal next_writeback_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal next_writeback_en : std_logic := '0';

begin
    DUT : DLXpipeline
        port map (
            clk => clk,
            rst_l => rst_l,
            writeback_data => writeback_data,
            writeback_reg => writeback_reg,
            writeback_en => writeback_en,
            alu_out => alu_result,
            instr_out => instr_out,
            reg2_out => reg2_out
        );
    rst_l <= '1';

    process
    begin
        wait for 5 ns;
        clk <= not clk;
    end process;

    process (clk)
    begin
        if rising_edge(clk) then
            index <= next_index;
            writeback_reg <= next_writeback_reg;
            writeback_data <= next_writeback_data;
            writeback_en <= next_writeback_en;
        end if;
    end process;

    process (index , next_index, writeback_reg, next_writeback_reg, writeback_data, next_writeback_data, writeback_en, next_writeback_en) begin
        next_writeback_en <= '1';
        next_index <= index + 1;
        if index >= 72 then
            assert false report "Testbench finished" severity failure;
        end if;
        case index is
            when 3 =>
                next_writeback_reg <= "00001";
                next_writeback_data <= x"00000003";
            when 4 =>
                next_writeback_reg <= "00010";
                next_writeback_data <= x"00000000";
            when 5 =>
                next_writeback_reg <= "00011";
                next_writeback_data <= x"00000000";
            when 6 =>
                next_writeback_reg <= "01010";
                next_writeback_data <= x"00000003";
            when 7 =>
                next_writeback_reg <= "01011";
                next_writeback_data <= x"00000000";
            when 9 =>
                next_writeback_reg <= "00011";
                next_writeback_data <= x"00000003";
            when 10 =>
                next_writeback_reg <= "00010";
                next_writeback_data <= x"00000002";
            when 14 =>
                next_writeback_reg <= "01011";
                next_writeback_data <= x"00000002";
            when 16 =>
                next_writeback_reg <= "00001";
                next_writeback_data <= x"00000002";
            when 17 =>
                next_writeback_reg <= "00010";
                next_writeback_data <= x"00000002";
            when others =>
                next_writeback_en <= '0';
                next_writeback_reg <= "00000";
                next_writeback_data <= x"00000000";
        end case;
    end process;
end architecture;
