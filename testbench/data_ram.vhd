library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use work.mypackage.all;


library std;
use std.textio.all;

entity data_ram is 
    generic(
        DRAMSize: integer := 256;
        DataSize: integer := DATA_WIDTH;
        AddrSize: integer := DATA_WIDTH  
    );
    port(
        clk     : in std_logic;
        rst     : in std_logic;
        addr    : in std_logic_vector(AddrSize -1 downto 0);
        WE      : in std_logic;
        DataIn  : in std_logic_vector(DataSize - 1  downto 0);
        DataOut : out std_logic_vector(DataSize - 1 downto 0)
    );
    
end data_ram;


architecture beh of data_ram is 

--type DRamType is array (0 to (2**AddrSize) -1) of std_logic_vector(DataSize -1 downto 0);
type DRamType is array (0 to DRAMSize-1) of std_logic_vector(DataSize -1 downto 0);
signal DRam : DRamType;
signal flag : std_logic := '0';

begin
    

    WrProcess: process(clk,rst)
        file mem_fp: text;
        variable file_line : line;
        variable index : integer := 0;
        variable tmp_data_u : std_logic_vector(DataSize-1 downto 0);
        variable internal_address_w : std_logic_vector(DataSize -1 downto 0);
    begin
        if (rst = '1' and flag /= '1') then
            DRam  <=(others =>(others => '0'));
            -- file_open(mem_fp,"data_mem.txt",READ_MODE);
            -- while (not endfile(mem_fp)) loop
            --     readline(mem_fp,file_line);
            --     hread(file_line,tmp_data_u);
            --     DRam(index)   <= tmp_data_u;
            --     -- print read content    
            --     -- report "Ram: " & to_hstring(tmp_data_u) & "h";
            --     index := index + 1;                                             --increment by 4 as the PC
            -- end loop;

            -- flag <= '1';
            -- file_close(mem_fp);
        else
            if (clk'event and clk='1') then
                internal_address_w := "00" & Addr(DataSize - 1 downto 2);
            -- loop over the data and report it 
                -- for i in 0 to DRAMSize-1 loop
                --     report "Ram: " & to_hstring(DRam(i)) & "h";
                -- end loop;
                if (WE = '1') then
                        DRam (to_integer(unsigned(internal_address_w))) <= DataIn;
                end if;
            end if;
        end if;
    end process;

    RdProcess: process (addr, Dram, WE) 
        -- variable to store internal address
        variable internal_address_r : std_logic_vector(DataSize -1 downto 0);
    begin 
        internal_address_r := "00" & Addr(DataSize - 1 downto 2);
        if (WE = '0') then
                DataOut <= DRam (to_integer(unsigned(internal_address_r)));
        end if;
    end process;



end beh;