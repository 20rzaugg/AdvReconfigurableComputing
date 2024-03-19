library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library work;
use work.dlxlib.all;

entity printer is
    port ( 
        clk : in  std_logic;
        rst_l : in  std_logic;
        instr_in : in std_logic_vector(INSTR_WIDTH-1 downto 0);
        data_in : in std_logic_vector(DATA_WIDTH-1 downto 0);
        instr_queue_full : out std_logic;
    );
end printer;

architecture behavioral of printer is

    component print_instr_queue is
        port (
            clock : IN STD_LOGIC ;
		    data : IN STD_LOGIC_VECTOR (37 DOWNTO 0);
		    rdreq : IN STD_LOGIC ;
		    sclr : IN STD_LOGIC ;
		    wrreq : IN STD_LOGIC ;
		    empty : OUT STD_LOGIC ;
		    full : OUT STD_LOGIC ;
		    q : OUT STD_LOGIC_VECTOR (37 DOWNTO 0)
        );
    end component;

    component digit_stack is
        port (
            clk : in std_logic;
            rst_l : in std_logic;
            push : in std_logic;
            pop : in std_logic;
            data_in : in std_logic_vector(7 downto 0);
            top_value : out std_logic_vector(7 downto 0);
            empty : out std_logic;
            full : out std_logic
        );
    end component;

    component ip_divider_signed is
        port (
            denom : in std_logic_vector (3 downto 0);
            numer : in std_logic_vector (31 downto 0);
            quotient : out std_logic_vector (31 downto 0);
            remain : out std_logic_vector (3 downto 0)
        );
    end component;

    component ip_divider_unsigned is
        port (
            denom : in std_logic_vector (3 downto 0);
            numer : in std_logic_vector (31 downto 0);
            quotient : out std_logic_vector (31 downto 0);
            remain : out std_logic_vector (3 downto 0)
        );
    end component;

    component dcfifo1 is
        port (
            data : in std_logic_vector(7 downto 0);
            rdclk : in std_logic;
            rdreq : in std_logic;
            wrclk : in std_logic;
            wrreq : in std_logic;
            q : out std_logic_vector(7 downto 0);
            rdempty : out std_logic;
            wrfull : out std_logic
        );
    end component;

    signal instr_read : std_logic := '0';
    signal instr_write : std_logic := '0';
    signal instr_queue_empty : std_logic;
    signal instr_queue_out : std_logic_vector(37 downto 0);

    signal digit_push : std_logic := '0';
    signal digit_pop : std_logic := '0';
    signal digit_empty : std_logic;
    signal digit_full : std_logic;
    signal digit_top : std_logic_vector(7 downto 0);

    type stateType is (IDLE, PCH, PD, DIVIDE, DIVIDE_DELAY, STACK_POPULATE, STACK_REMOVE);
    signal state : stateType := IDLE;
    signal next_state : stateType := IDLE;

    signal instr : std_logic_vector(5 downto 0);
    signal next_instr : std_logic_vector(5 downto 0);
    signal data : std_logic_vector(31 downto 0);
    signal next_data : std_logic_vector(31 downto 0);

begin

    print_instr_queue_inst : print_instr_queue
        port map (
            clock => clk,
            data => instr_in(31 downto 26) & data_in(31 downto 0),
            rdreq => instr_read,
            sclr => not rst_l, -- check if correct
            wrreq => instr_write,
            empty => instr_queue_empty,
            full => instr_queue_full,
            q => instr_queue_out
        );

    digit_stack_inst : digit_stack
        port map (
            clk => clk,
            rst_l => rst_l,
            push => digit_push,
            pop => digit_pop,
            data_in => data_in(7 downto 0),
            top_value => open,
            empty => digit_empty,
            full => digit_full
        );

    ip_divider_signed_inst : ip_divider_signed
        port map (
            denom => "1010",
            numer => 
        );

    process(clk, rst_l) is begin
        if rst_l = '0' then
    end process;

    instr_write <= '1' when instr_in(31 downto 26) = PCH or instr_in(31 downto 26) = PD or instr_in(31 downto 26) = PDU else '0';

end behavioral;