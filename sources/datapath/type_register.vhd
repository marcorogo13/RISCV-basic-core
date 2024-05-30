library IEEE;
use IEEE.std_logic_1164.all;
use work.mypackage.all;


entity type_register is
    port(
        clk:        in std_logic;
        rst:        in std_logic;
        enable:     in std_logic;
        in_reg:     in INST_TYPE;
        out_reg:    out INST_TYPE
    );
end entity type_register;

architecture behavioral of type_register is
begin
    process(clk, rst)
    begin
        if (rst = '1') then                 --reset attivo alto e asincrono
            out_reg <= I;
        elsif (rising_edge(clk) and enable = '1') then
                out_reg <= in_reg;
        end if ;
    end process;
end behavioral;