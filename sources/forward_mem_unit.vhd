library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.mypackage.all;

entity forward_mem_unit is
    port(
        rst             : in std_logic;
        clk             : in std_logic;
        instruction     : in std_logic_vector(INSTRUCTION_LENGHT - 1 downto 0);
        inst_type       : in INST;
        stall_in_fetch  : in std_logic;
        stall_in_mem    : in std_logic; --attivo alto
        
        forward         : out std_logic_vector(1 downto 0)
    );
end forward_mem_unit;



architecture Behavioral of forward_mem_unit is

    signal previus_dest_reg_1:      std_logic_vector(5 downto 0);
    signal previus_dest_reg_2:      std_logic_vector(5 downto 0);

    signal current_dest_reg:        std_logic_vector(5 downto 0); 
    signal current_source_reg:      std_logic_vector(5 downto 0); 

    signal forward_comb:            std_logic_vector(1 downto 0);
    signal forward_delay_1:         std_logic_vector(1 downto 0);
    signal forward_delay_2:         std_logic_vector(1 downto 0);



begin


    startup: process(rst, instruction)
    begin
        if (Rst = '1') then
           
            current_dest_reg <= (others => '0');       --Spostate qua le assegnazioni iniziali
            current_source_reg <= (others => '0');
        else                   
            current_dest_reg <= '0' & instruction(11 downto 7);
            current_source_reg <= '0' & instruction(24 downto 20);
        end if;
    end process startup;
                


    forward_p: process(clk, current_source_reg, current_dest_reg)
    begin
        forward_comb <= "00";

        if (inst_type = SW) then

            if ( previus_dest_reg_2 = current_source_reg and current_source_reg /= "000000" ) then
                forward_comb <= "10";
            end if;

            if ( previus_dest_reg_1 = current_source_reg and current_source_reg /= "000000" ) then
                forward_comb <= "01";
            end if;
        end if;
    end process forward_p;


    sequential_forwarding: process(rst, clk)
    begin
        if (Rst = '1') then
            forward <= "00";
            forward_delay_1 <= "00";
            forward_delay_2 <= "00";
        elsif (rising_edge(Clk)) then
            forward_delay_1 <= forward_comb;
            forward_delay_2 <= forward_delay_1;
            forward <= forward_delay_2;
        end if;
    end process sequential_forwarding;


    Propagation : process(rst, clk, inst_type)
    begin
        if (rst = '1') then
            previus_dest_reg_1 <= (others => '1');
            previus_dest_reg_2 <= (others => '1');
        elsif (rising_edge(clk)) then
            if (inst_type /= Sw and inst_type /= BLE and inst_type /= BLTU) then
                previus_dest_reg_2 <= previus_dest_reg_1;
                previus_dest_reg_1 <= current_dest_reg;
            else
                previus_dest_reg_2 <= previus_dest_reg_1;
                previus_dest_reg_1 <= (others => '1');
            end if;
        end if;
    end process Propagation;

end Behavioral;