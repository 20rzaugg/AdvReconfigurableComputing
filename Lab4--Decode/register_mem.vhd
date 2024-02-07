library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.dlxlib.all;

entity register_mem is
    port
    (
        clk : in std_logic;
        read_addr1 : in std_logic_vector(4 downto 0);
        read_addr2 : in std_logic_vector(4 downto 0);
        write_addr : in std_logic_vector(4 downto 0);
        write_data : in std_logic_vector(DATA_WIDTH-1 downto 0);
        write_en : in std_logic := '0';
        read_q1 : out std_logic_vector(DATA_WIDTH-1 downto 0);
        read_q2 : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
    
end entity;

architecture rtl of register_mem is

    -- Build a 2D array type for the RAM
    type memory_t is array(0 to 31) of std_logic_vector(DATA_WIDTH-1 downto 0);
    
    -- Declare the RAM signal.
    signal ram : memory_t;
    
    -- Register to hold the address
    signal addr_reg1 : integer range 0 to 31; 
    signal addr_reg2 : integer range 0 to 31;

begin

    process(clk)
    begin
        if(rising_edge(clk)) then
            ram(0) <= (others => '0');
            if(write_en = '1' and unsigned(write_addr) > 0) then
                ram(to_integer(unsigned(write_addr))) <= write_data;
            end if;
            
            -- Register the address for reading
            addr_reg1 <= to_integer(unsigned(read_addr1));
            addr_reg2 <= to_integer(unsigned(read_addr2));
        end if;
    
    end process;
    
    read_q1 <= ram(addr_reg1);
    read_q2 <= ram(addr_reg2);
    
end rtl;
