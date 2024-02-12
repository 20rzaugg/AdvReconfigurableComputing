library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use work.dlxlib.all;

entity TBdecode is
end TBdecode;

architecture testbench of TBdecode is
    
    component DLXpipeline is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            addr_selector : in std_logic;
            branch_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0);
            writeback_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
            writeback_reg : in std_logic_vector(4 downto 0);
            writeback_en : in std_logic;
            rs1_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
            rs2_data : out std_logic_vector(DATA_WIDTH-1 downto 0);
            immediate : out std_logic_vector(DATA_WIDTH-1 downto 0);
            instr_out : out std_logic_vector(INSTR_WIDTH-1 downto 0);
            addr_out : out std_logic_vector(ADDR_WIDTH-1 downto 0)
        );
    end component;

    type addr_type is array (0 to 71) of std_logic_vector(ADDR_WIDTH-1 downto 0);
    signal expected_PC : addr_type := (
        "0000000001",
        "0000000010",
        "0000000011",
        "0000000100",
        "0000000101",
        "0000000110",
        "0000000111",
        "0000001000",
        "0000001001",
        "0000001010",
        "0000001011",
        "0000001100",
        "0000001101",
        "0000001110",
        "0000001111",
        "0000010000",
        "0000010001",
        "0000001011",
        "0000001100",
        "0000001101",
        "0000001110",
        "0000001111",
        "0000010000",
        "0000010001",
        "0000001011",
        "0000001100",
        "0000001101",
        "0000001110",
        "0000010000",
        "0000010001",
        "0000010010",
        "0000001001",
        "0000001010",
        "0000001011",
        "0000001100",
        "0000000100",
        "0000000101",
        "0000000110",
        "0000000111",
        "0000001000",
        "0000001001",
        "0000001010",
        "0000001011",
        "0000001100",
        "0000001101",
        "0000001110",
        "0000001111",
        "0000010000",
        "0000010001",
        "0000001011",
        "0000001100",
        "0000001101",
        "0000001110",
        "0000010000",
        "0000010001",
        "0000010010",
        "0000001001",
        "0000001010",
        "0000001011",
        "0000001100",
        "0000000100",
        "0000000101",
        "0000000110",
        "0000000111",
        "0000010011",
        "0000010010",
        "0000010011",
        "0000010100",
        "0000010010",
        "0000010011",
        "0000010100",
        "0000010010"
    );

    type mem_type is array (0 to 71) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal expected_instr : mem_type := (
        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
        x"04200000",
        x"10400000",
        x"10600000",
        x"05400000",
        x"816A0001",
        x"B1600011",
        x"10610000",
        x"204A0001",
        x"BC00000B",
        x"214A0001",
        x"B4000004",
        x"81620001",
        x"B1600010",
        x"0C211800",
        x"20420001",
        x"B400000B",
        x"BBE00000",
        x"08000401",
        x"81620001",
        x"B1600010",
        x"0C211800",
        x"20420001",
        x"B400000B",
        x"BBE00000",
        x"08000401",
        x"81620001",
        x"B1600010",
        x"0C211800",
        x"20420001",
        x"BBE00000",
        x"08000401",
        x"B4000012",
        x"214A0001",
        x"B4000004",
        x"81620001",
        x"B1600010",
        x"816A0001",
        x"B1600011",
        x"10610000",
        x"204A0001",
        x"BC00000B",
        x"214A0001",
        x"B4000004",
        x"81620001",
        x"B1600010",
        x"0C211800",
        x"20420001",
        x"B400000B",
        x"BBE00000",
        x"08000401",
        x"81620001",
        x"B1600010",
        x"0C211800",
        x"20420001",
        x"BBE00000",
        x"08000401",
        x"B4000012",
        x"214A0001",
        x"B4000004",
        x"81620001",
        x"B1600010",
        x"816A0001",
        x"B1600011",
        x"10610000",
        x"204A0001",
        x"08000401",
        x"B4000012",
        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
        x"B4000012",
        "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
    );

    signal clk : std_logic := '0';
    signal rst_l : std_logic := '1';
    signal addr_selector : std_logic := '0';
    signal branch_addr : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');
    signal writeback_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal writeback_reg : std_logic_vector(4 downto 0) := (others => '0');
    signal writeback_en : std_logic := '0';
    signal rs1_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal rs2_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal immediate : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal instr_out : std_logic_vector(INSTR_WIDTH-1 downto 0) := (others => '0');
    signal addr_out : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');

    signal index : integer := 0;
    signal next_index : integer := 0;

    signal next_addr_selector : std_logic := '0';
    signal next_branch_addr : std_logic_vector(ADDR_WIDTH-1 downto 0) := (others => '0');

    signal next_writeback_reg : std_logic_vector(4 downto 0) := (others => '0');
    signal next_writeback_data : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
    signal next_writeback_en : std_logic := '0';

begin
    DUT : DLXpipeline
        port map (
            clk => clk,
            rst_l => rst_l,
            addr_selector => addr_selector,
            branch_addr => branch_addr,
            writeback_data => writeback_data,
            writeback_reg => writeback_reg,
            writeback_en => writeback_en,
            rs1_data => rs1_data,
            rs2_data => rs2_data,
            immediate => immediate,
            instr_out => instr_out,
            addr_out => addr_out
        );

        process
        begin
            wait for 5 ns;
            clk <= not clk;
        end process;

        process (clk) begin
            if rising_edge(clk) then
                index <= next_index;
                addr_selector <= next_addr_selector;
                branch_addr <= next_branch_addr;
                writeback_reg <= next_writeback_reg;
                writeback_data <= next_writeback_data;
                writeback_en <= next_writeback_en;
            --else
            --    assert next_pc = expected_PC(index) report "PC is not correct" severity error;
            --    assert instr = expected_instr(index) report "Instruction is not correct" severity error;
            end if;
        end process;

        process (index, next_index, addr_selector, next_addr_selector, branch_addr, next_branch_addr) begin
            if index > 71 then
                assert false report "Simulation finished" severity failure;
            end if;
            next_index <= index + 1;
            next_addr_selector <= '1';
            case index is
                when 9 => --
                    next_branch_addr <= "0000001011";
                when 16 => --
                    next_branch_addr <= "0000001011";
                when 23 => --
                    next_branch_addr <= "0000001011";
                when 27 => --
                    next_branch_addr <= "0000010000";
                when 30 => --
                    next_branch_addr <= "0000001001";
                when 34 => --
                    next_branch_addr <= "0000000100";
                when 41 => --
                    next_branch_addr <= "0000001011";
                when 48 => --
                    next_branch_addr <= "0000001011";
                when 52 => --
                    next_branch_addr <= "0000010000";
                when 55 => --
                    next_branch_addr <= "0000001001";
                when 59 =>
                    next_branch_addr <= "0000000100";
                when 63 =>
                    next_branch_addr <= "0000010001";
                when 67 =>
                    next_branch_addr <= "0000010010";
                when 70 =>
                    next_branch_addr <= "0000010010";
                when others =>
                    next_addr_selector <= '0';
                    next_branch_addr <= (others => '0');
            end case;
        end process;

        process (index , next_index, writeback_reg, next_writeback_reg, writeback_data, next_writeback_data, writeback_en, next_writeback_en) begin
            next_writeback_en <= '1';
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
