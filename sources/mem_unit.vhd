library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.mypackage.all;

entity mem_unit is
    port(
        --signals for processor
        clk : in std_logic;
        rst : in std_logic;
        address : in std_logic_vector(DATA_WIDTH-1 downto 0);
        stall    : out std_logic;
        w_r      : in std_logic;
        data_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
        data_in  : in std_logic_vector(DATA_WIDTH-1 downto 0);

        -- signals for memory
        ADDR    : out  std_logic_vector(DATA_WIDTH-1 downto 0);
        WE      : out  std_logic;
        WDATA   : out  std_logic_vector(DATA_WIDTH-1 downto 0);
        RDATA   : in  std_logic_vector(DATA_WIDTH-1 downto 0)
    );
end entity mem_unit;

architecture beh of mem_unit is

    -- signal to describe FSM states
    -- type state_type is (reset, request, write_1, read_1, write_2, read_2);
    -- signal state, next_state : state_type;


begin



    --bypass signals to memory for tests
    --ADDR <= address;
    --WE <= w_r;
    --WDATA <= data_in;
    --data_out <= RDATA;
    --stall <= '0';


    read_write_proc: process (w_r, address, data_in, RDATA, rst) is
    begin
        if rst = '1' then
            ADDR <= (others => '0');
            WDATA <= (others => '0');
            WE <= '0';
        else
            if (unsigned(address) < 255) then
                if w_r = '1' then
                    ADDR <= address;
                    WDATA <= data_in;
                    WE <= '1';
                else
                    ADDR <= address;
                    --WDATA <= (others => '0');
                    WE <= '0';
                    data_out <= RDATA;
                end if;
            end if;
        end if;
    end process read_write_proc;


    -- regproc: process(clk, rst)
    -- begin
    --     if rst = '1' then
    --         state <= reset;
    --     elsif rising_edge(clk) then
    --         state <= next_state;
    --     end if;
    -- end process regproc;



    -- --da gestire il fatto che la FSM si deve attivare solo quando una NUOVA richiesta viene fatta , non come ora che si attiva sempre stallando
    -- f_u: process(address, data_in, MEM_RDY, RDATA, VALID, state ) 
    -- begin
    --     case (state) is
    --         when reset =>
    --             PROC_REQ <= '0';
    --             ADDR <= (others => '0');
    --             WE <= '0';
    --             WDATA <= (others => '0');
    --             next_state <= request;
    --             stall <= '0';
                

    --         when request =>
    --             PROC_REQ <= '1';
    --             ADDR <= address;
    --             WE <= '0';
    --             WDATA <= (others => '0');
    --             stall <= '1';
    --             if (w_r = '1') then
    --                 next_state <= write_1;
    --                 WE <= '1';
    --             else
    --                 next_state <= read_1;
    --                 WE <= '0';
    --             end if;
    --             --if MEM_RDY = '1' then
    --             --    next_state <= writes;
    --             --else
    --             --    next_state <= request;
    --             --end if;

    --         when write_1 =>
    --             PROC_REQ <= '1';
    --             ADDR <= address;
    --             WE <= '1';
    --             WDATA <= data_in;
    --             stall <= '1';
    --             if(MEM_RDY = '1') then
    --                 next_state <= write_2;
    --                 PROC_REQ <= '0';
    --                 WE <= '0';
    --             else
    --                 next_state <= write_1;
    --                 stall <= '1';
    --             end if;

    --         when read_1 =>
    --             PROC_REQ <= '1';
    --             ADDR <= address;
    --             WE <= '0';
    --             WDATA <= (others => '0');
    --             stall <= '1';
    --             if MEM_RDY = '1' then
    --                 next_state <= read_2;
    --                 PROC_REQ <= '0';
    --             else
    --                 next_state <= read_1;
    --             end if;

    --         when write_2 => 
    --             PROC_REQ <= '0';
    --             ADDR <= (others => '0');
    --             WE <= '0';
    --             if VALID = '1' then
    --                 next_state <= request;
    --                 PROC_REQ <= '0';
    --                 WE <= '0';
    --                 stall <= '0';
    --             else
    --                 next_state <= write_2;
    --                 stall <= '1';
    --             end if;
                
    --         when read_2 =>
    --             PROC_REQ <= '0';
    --             ADDR <= (others => '0');
    --             WE <= '0';
    --             if VALID = '1' then
    --                 next_state <= request;
    --                 PROC_REQ <= '0';
    --                 WE <= '0';
    --                 stall <= '0';
    --                 data_out <= RDATA;
    --             else
    --                 next_state <= read_2;
    --                 stall <= '1';
    --             end if;

    --         when others =>
    --             PROC_REQ <= '0';
    --             ADDR <= (others => '0');
    --             WE <= '0';
    --             WDATA <= (others => '0');
    --             next_state <= request;
    --     end case;

    -- end process f_u;

end architecture beh;
