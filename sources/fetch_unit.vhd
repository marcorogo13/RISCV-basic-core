library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.mypackage.all;

entity fetch_unit is
    port(
        --signals for processor
        clk             : in std_logic;
        rst             : in std_logic;
        pc              : in std_logic_vector(DATA_WIDTH-1 downto 0);
        stall           : out std_logic;
        instruction     : out std_logic_vector(INSTRUCTION_LENGHT-1 downto 0);

        --signals for memory
        ADDR    : out  std_logic_vector(DATA_WIDTH-1 downto 0);
        WE      : out  std_logic;
        WDATA   : out  std_logic_vector(DATA_WIDTH-1 downto 0);
        RDATA   : in  std_logic_vector(DATA_WIDTH-1 downto 0)   
    );
end entity fetch_unit;

architecture beh of fetch_unit is

    -- signal to describe FSM states
    -- type state_type is (reset, request, waits, reading, received);
    -- signal state, next_state : state_type;


begin

    -- by pass to memory for tests 
    ADDR <= pc;
    WE <= '0';
    WDATA <= (others => '0');
    instruction <= RDATA;
    stall <= '0';


    -- regproc: process(clk, rst)
    -- begin
    --     if rst = '1' then
    --         state <= reset;
    --     elsif rising_edge(clk) then
    --         state <= next_state;
    --     end if;
    -- end process regproc;

    -- f_u: process(pc, MEM_RDY, RDATA, VALID, state ) 
    -- begin
    --     WE <= '0';
    --     WDATA <= (others => '0');
    --     case (state) is
    --         when reset =>
    --             PROC_REQ <= '0';
    --             ADDR <= (others => '0');
    --             WE <= '0';
    --             WDATA <= (others => '0');
    --             next_state <= request;
    --         when request =>
    --             PROC_REQ <= '1';
    --             ADDR <= pc;
    --             WE <= '0';
    --             WDATA <= (others => '0');
    --             if (MEM_RDY = '1') then
    --                 next_state <= waits;
    --             else
    --                 next_state <= request;
    --             end if;
    --         when waits =>
    --             if VALID = '1' then
    --                 instruction <= RDATA;
    --                 next_state <= reading;
    --                 stall <= '0';
    --             else
    --                 next_state <= waits;
    --                 stall <= '1';
    --             end if;
    --         when reading =>                 -- no idea su come gestire il back to back reading visto che c'è anche il segnare di ready da ricontrollare
    --             if(VALID = '1') then
    --                 instruction <= RDATA;
    --                 next_state <= request;
    --                 stall <= '0';
    --             else
    --                 next_state <= request;
    --                 stall <= '1';
    --             end if;
    --         when others =>
    --             next_state <= reset;
    --     end case;

    -- end process f_u;

end architecture beh;
