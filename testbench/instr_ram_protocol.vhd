library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.mypackage.all;


entity instr_ram is
  generic (
    filePath: string;
    RAM_DEPTH : integer := 128
    );
  port (
    CLK  : in  std_logic;
    RSTn  : in  std_logic;
    PROC_REQ : in  std_logic;
    MEM_RDY : out  std_logic;
    ADDR : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    WE : in  std_logic;
    WDATA : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    RDATA : out  std_logic_vector(DATA_WIDTH-1 downto 0);
    VALID : out  std_logic
    );

end instr_ram;

architecture instr_ram_beh of instr_ram is
  -- memory "width" is 1 byte
  type RAMtype is array (0 to RAM_DEPTH - 1) of std_logic_vector(7 downto 0);-- std_logic_vector(DATA_WIDTH - 1 downto 0);

  signal IRAM_mem : RAMtype;

begin  -- IRam_Bhe
  -- PC works on bytes so instructions have to be divided from a single 32 bit word into 4 8 bits 
--  Dout <= conv_std_logic_vector(IRAM_mem(conv_integer(unsigned(Addr))),DATA_WIDTH);



-- state machine to model the behaviour of the memory

state_machine: process  (CLK, RSTn)
    type state_type is (IDLE, WRITE, READ);
    variable state : state_type := IDLE;

  begin  -- process state_machine
    if (RSTn = '0') then
      state := IDLE;
      MEM_RDY <= '0';
      VALID <= '0';
    elsif (CLK'event and CLK = '1') then
      case state is
        when IDLE =>
          if (PROC_REQ = '1') then
            if (WE = '1') then
              state := WRITE;
              MEM_RDY <= '0';
              VALID <= '0';
            else
              state := READ;
              MEM_RDY <= '1';
              VALID <= '0';
            end if;
          else
            state := IDLE;
            MEM_RDY <= '0';
            VALID <= '0';
          end if;
        when WRITE =>
            state := IDLE;
            --NOTHING TO DO HERE
        when READ =>
            state := IDLE;
            RDATA(DATA_WIDTH - 1 downto DATA_WIDTH - 8)    <= IRAM_mem(to_integer(unsigned(Addr)));
            RDATA(DATA_WIDTH - 9 downto DATA_WIDTH - 16)   <= IRAM_mem(to_integer(unsigned(Addr))+1);
            RDATA(DATA_WIDTH - 17 downto DATA_WIDTH - 24)  <= IRAM_mem(to_integer(unsigned(Addr))+2);
            RDATA(DATA_WIDTH - 25 downto DATA_WIDTH - 32)  <= IRAM_mem(to_integer(unsigned(Addr))+3);
            MEM_RDY <= '0';
            VALID <= '1';
        when others =>
          state := IDLE;
          MEM_RDY <= '0';
          VALID <= '0';
      end case;
    end if;
  end process state_machine;













  -- purpose: This process is in charge of filling the Instruction RAM with the firmware
  -- type   : combinational
  -- inputs : Rst
  -- outputs: IRAM_mem

  FILL_MEM_P: process (RSTn)
    file mem_fp: text;
    variable file_line : line;
    variable index : integer := 0;
    variable tmp_data_u : std_logic_vector(DATA_WIDTH-1 downto 0);
  begin  -- process FILL_MEM_P
    if (RSTn = '1') then
      file_open(mem_fp,filePath,READ_MODE);
      while (not endfile(mem_fp)) loop
        readline(mem_fp,file_line);
        hread(file_line,tmp_data_u);
        IRAM_mem(index)   <= tmp_data_u(DATA_WIDTH-1 downto DATA_WIDTH-8);      --MSB       
        IRAM_mem(index+1) <= tmp_data_u(DATA_WIDTH-9 downto DATA_WIDTH-16);       
        IRAM_mem(index+2) <= tmp_data_u(DATA_WIDTH-17 downto DATA_WIDTH-24);       
        IRAM_mem(index+3) <= tmp_data_u(DATA_WIDTH-25 downto DATA_WIDTH-32);    --LSB   
        index := index + 4;                                             --increment by 4 as the PC
      end loop;
    end if;
  end process FILL_MEM_P;

end instr_ram_beh;
        