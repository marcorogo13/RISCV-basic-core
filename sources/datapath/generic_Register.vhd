library IEEE;
use IEEE.std_logic_1164.all;
use work.mypackage.all;


entity generic_Register is
    generic(
        len:    integer := DATA_WIDTH
    );
    port(
        clk:        in std_logic;
        rst:        in std_logic;
        enable:     in std_logic;
        in_reg:     in std_logic_vector(len-1 downto 0);
        out_reg:    out std_logic_vector(len-1 downto 0)
    );
end entity generic_Register;

architecture behavioral of generic_Register is
    
begin
    process(clk, rst)
    begin
        if (rst = '1') then                 --reset attivo alto e asincrono
            out_reg <= (others => '0');
        elsif (rising_edge(clk) and enable = '1') then
            out_reg <= in_reg;
        end if ;
    end process;
end behavioral;


