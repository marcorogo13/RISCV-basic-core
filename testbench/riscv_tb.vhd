library ieee;
use ieee.std_logic_1164.all;
use work.mypackage.all;



entity risv_tb is
end risv_tb;

architecture risv_tb_arch of risv_tb is

    component riscv is
        port (
            clk             : in std_logic;
            rst             : in std_logic;
            --mem signals to tb
                --instruction
            instr_ADDR      : out  std_logic_vector(DATA_WIDTH-1 downto 0);
            instr_WE        : out  std_logic;
            instr_WDATA     : out  std_logic_vector(DATA_WIDTH-1 downto 0);
            instr_RDATA     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
                --memory
            mem_ADDR        : out  std_logic_vector(DATA_WIDTH-1 downto 0);
            mem_WE          : out  std_logic;
            mem_WDATA       : out  std_logic_vector(DATA_WIDTH-1 downto 0);
            mem_RDATA       : in  std_logic_vector(DATA_WIDTH-1 downto 0)    
        );
    end component;
    

    component instr_ram is
        generic (
            filePath: string := "instr_mem.txt";
            RAM_DEPTH : integer := 256
            );
          port (
            clk     : in std_logic;
            rst     : in std_logic;
            Addr  : in std_logic_vector(DATA_WIDTH - 1  downto 0);
            Dout : out std_logic_vector(DATA_WIDTH - 1 downto 0)
            );
    end component;

    component data_ram is
        generic(
            DRAMSize: integer := 256
        );
        port(
            clk     : in std_logic;
            rst     : in std_logic;
            addr    : in std_logic_vector(DATA_WIDTH -1 downto 0);
            WE      : in std_logic;
            DataIn  : in std_logic_vector(DATA_WIDTH - 1  downto 0);
            DataOut : out std_logic_vector(DATA_WIDTH - 1 downto 0)
        );
    end component;


    signal clk                  : std_logic := '0';
    signal rst                  : std_logic := '0';
   -- signal instr_PROC_REQ_s     : std_logic;
   -- signal instr_MEM_RDY_s      : std_logic;
   -- signal instr_ADDR_s         : std_logic_vector(DATA_WIDTH-1 downto 0);
   -- signal instr_WE_s           : std_logic;
   -- signal instr_WDATA_s        : std_logic_vector(DATA_WIDTH-1 downto 0);
   -- signal instr_RDATA_s        : std_logic_vector(DATA_WIDTH-1 downto 0);
   -- signal instr_VALID_s        : std_logic;
   -- signal mem_PROC_REQ_s       : std_logic;
   -- signal mem_MEM_RDY_s        : std_logic;
   -- signal mem_ADDR_s           : std_logic_vector(DATA_WIDTH-1 downto 0);
   -- signal mem_WE_s             : std_logic;
   -- signal mem_WDATA_s          : std_logic_vector(DATA_WIDTH-1 downto 0);
   -- signal mem_RDATA_s          : std_logic_vector(DATA_WIDTH-1 downto 0);
   -- signal mem_VALID_s          : std_logic;

    signal instr_ADDR_s         : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal instr_WE_s           : std_logic;
    signal instr_WDATA_s        : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal instr_RDATA_s        : std_logic_vector(DATA_WIDTH-1 downto 0);

    signal mem_ADDR_s           : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mem_WE_s             : std_logic;
    signal mem_WDATA_s          : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mem_RDATA_s          : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    riscv_i : riscv
        port map (
            clk => clk,
            rst => rst,
            instr_ADDR => instr_ADDR_s,
            instr_WE => instr_WE_s,
            instr_WDATA => instr_WDATA_s,
            instr_RDATA => instr_RDATA_s,

            mem_ADDR => mem_ADDR_s,
            mem_WE => mem_WE_s,
            mem_WDATA => mem_WDATA_s,
            mem_RDATA => mem_RDATA_s
        );


    data_ram_i : data_ram 
        port map(
            clk => clk,
            rst => rst,
            addr => mem_ADDR_s,
            WE => mem_WE_s,
            DataIn => mem_WDATA_s,
            DataOut => mem_RDATA_s
        );
    
    instr_ram_i : instr_ram
            port map (
                clk => clk,
                rst => rst,
                addr => instr_ADDR_s,
                Dout => instr_RDATA_s
            );


    clk <= not clk after 5 ns;
    rst <= '1', '0' after 50 ns;



end risv_tb_arch;