LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.mypackage.all;


entity generic_mux is
    generic(
        len:      integer := DATA_WIDTH
    );
    port(
        A:      in std_logic_vector(len-1 downto 0);
        B:      in std_logic_vector(len-1 downto 0);
        Sel:    in std_logic;
        Y:      out std_logic_vector(len-1 downto 0)
    );
end generic_mux;


architecture beh of generic_mux is
begin
    with Sel select Y <=
        B when '0',
        A when '1',
        A when others;

end beh;