library IEEE;
use IEEE.std_logic_1164.all;


entity Single_bit_register is
    port(
        clk:        in std_logic;
        rst:        in std_logic;
        enable:     in std_logic;
        in_reg:     in std_logic;
        out_reg:    out std_logic
    );
end entity Single_bit_register;

architecture behavioral of Single_bit_register is
begin
    process(clk, rst)
    begin
        if (rst = '1') then                 --reset attivo alto e asincrono
            out_reg <= '0';
        elsif (rising_edge(clk) and enable = '1') then
                out_reg <= in_reg;
        end if ;
    end process;
end behavioral;