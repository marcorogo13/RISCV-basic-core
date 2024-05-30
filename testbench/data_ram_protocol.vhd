library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.mypackage.all;


entity data_ram is
  generic (
    RAM_DEPTH: integer := 4000
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

end data_ram;

architecture data_ram_beh of data_ram is
  -- memory "width" is 1 byte
  --type DRamType is array (0 to (2**AddrSize) -1) of std_logic_vector(DataSize -1 downto 0);
  type DRamType is array (0 to RAM_DEPTH - 1) of std_logic_vector(7 downto 0);-- std_logic_vector(DATA_WIDTH - 1 downto 0);
  signal DRam : DRamType;

begin  -- IRam_Bhe
  -- PC works on bytes so instructions have to be divided from a single 32 bit word into 4 8 bits 
--  Dout <= conv_std_logic_vector(IRAM_mem(conv_integer(unsigned(Addr))),DATA_WIDTH);


--  Dout(DATA_WIDTH - 1 downto DATA_WIDTH - 8)    <= IRAM_mem(to_integer(unsigned(Addr)));
--  Dout(DATA_WIDTH - 9 downto DATA_WIDTH - 16)   <= IRAM_mem(to_integer(unsigned(Addr))+1);
--  Dout(DATA_WIDTH - 17 downto DATA_WIDTH - 24)  <= IRAM_mem(to_integer(unsigned(Addr))+2);
--  Dout(DATA_WIDTH - 25 downto DATA_WIDTH - 32)  <= IRAM_mem(to_integer(unsigned(Addr))+3);




-- state machine to model the behaviour of the memory

state_machine : process (CLK, RSTn)
    type state_type is (IDLE, WRITE, READ);
    variable state : state_type := IDLE;

  begin  -- process state_machine
    if (RSTn = '0') then
      state := IDLE;
      MEM_RDY <= '0';
      VALID <= '0';
      DRam  <=(others =>(others => '0'));
    elsif (CLK'event and CLK = '1') then
      case state is
        when IDLE =>
          if (PROC_REQ = '1') then
            if (WE = '1') then
              state := WRITE;
              MEM_RDY <= '1';
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
            VALID <= '1';
            MEM_RDY <= '0';
            DRam(to_integer(unsigned(Addr))) <= WDATA(DATA_WIDTH - 1 downto DATA_WIDTH - 8);
            DRam(to_integer(unsigned(Addr))+1) <= WDATA(DATA_WIDTH - 9 downto DATA_WIDTH - 16);
            DRam(to_integer(unsigned(Addr))+2) <= WDATA(DATA_WIDTH - 17 downto DATA_WIDTH - 24);
            DRam(to_integer(unsigned(Addr))+3) <= WDATA(DATA_WIDTH - 25 downto DATA_WIDTH - 32);
        when READ =>
            state := IDLE;
            RDATA(DATA_WIDTH - 1 downto DATA_WIDTH - 8)    <= DRam(to_integer(unsigned(Addr)));
            RDATA(DATA_WIDTH - 9 downto DATA_WIDTH - 16)   <= DRam(to_integer(unsigned(Addr))+1);
            RDATA(DATA_WIDTH - 17 downto DATA_WIDTH - 24)  <= DRam(to_integer(unsigned(Addr))+2);
            RDATA(DATA_WIDTH - 25 downto DATA_WIDTH - 32)  <= DRam(to_integer(unsigned(Addr))+3);
            MEM_RDY <= '0';
            VALID <= '1';
        when others =>
          state := IDLE;
          MEM_RDY <= '0';
          VALID <= '0';
      end case;
    end if;
  end process state_machine;










end data_ram_beh;
        