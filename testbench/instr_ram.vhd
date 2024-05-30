library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.mypackage.all;


entity instr_ram is
  generic (
    filePath: string := "PROGPATH";
    RAM_DEPTH : integer := 256;
    I_SIZE : integer := INSTRUCTION_LENGHT
    );
  port (
    clk  : in std_logic;
    Rst  : in  std_logic;
    Addr : in  std_logic_vector(I_SIZE - 1 downto 0);
    Dout : out std_logic_vector(I_SIZE - 1 downto 0)
    );

end instr_ram;

architecture beh of instr_ram is
  
  --type RAMtype is array (0 to RAM_DEPTH - 1) of std_logic_vector(7 downto 0);-- std_logic_vector(I_SIZE - 1 downto 0);
  type RAMtype is array (0 to RAM_DEPTH - 1) of std_logic_vector(I_SIZE-1 downto 0);
  signal IRAM_mem : RAMtype;
  signal internal_address : std_logic_vector(I_SIZE -1 downto 0);

begin  -- IRam_Bhe
  -- PC works on bytes so instructions have to be divided from a single 32 bit word into 4 8 bits 
--  Dout <= conv_std_logic_vector(IRAM_mem(conv_integer(unsigned(Addr))),I_SIZE);


  -- Dout(I_SIZE - 1 downto I_SIZE - 8)    <= IRAM_mem(to_integer(unsigned(Addr)));
  -- Dout(I_SIZE - 9 downto I_SIZE - 16)   <= IRAM_mem(to_integer(unsigned(Addr))+1);
  -- Dout(I_SIZE - 17 downto I_SIZE - 24)  <= IRAM_mem(to_integer(unsigned(Addr))+2);
  -- Dout(I_SIZE - 25 downto I_SIZE - 32)  <= IRAM_mem(to_integer(unsigned(Addr))+3);
  internal_address <= "00" & Addr(I_SIZE - 1 downto 2);
  Dout <= IRAM_mem(to_integer(unsigned(internal_address)));


  
  
  FILL_MEM_P: process (Rst)
    file mem_fp: text;
    variable file_line : line;
    variable index : integer := 0;
    variable tmp_data_u : std_logic_vector(I_SIZE-1 downto 0);
  begin  -- process FILL_MEM_P
    if (Rst = '1') then
      file_open(mem_fp,filePath,READ_MODE);
      while (not endfile(mem_fp)) loop
        readline(mem_fp,file_line);
        hread(file_line,tmp_data_u);
        IRAM_mem(index)   <= tmp_data_u(I_SIZE-1 downto 0);         
        -- IRAM_mem(index+1) <= tmp_data_u(I_SIZE-9 downto I_SIZE-16);       
        -- IRAM_mem(index+2) <= tmp_data_u(I_SIZE-17 downto I_SIZE-24);       
        -- IRAM_mem(index+3) <= tmp_data_u(I_SIZE-25 downto I_SIZE-32);    --LSB   
        index := index + 1;                                             --increment by 4 as the PC
      end loop;
      file_close(mem_fp);
    end if;
  end process FILL_MEM_P;

end beh;
        