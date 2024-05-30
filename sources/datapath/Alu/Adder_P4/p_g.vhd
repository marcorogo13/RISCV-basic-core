library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic


entity p_g is
    port(
        a, b: in std_logic;
        p, g: out std_logic
    );
end p_g;

architecture ARCH1 of p_g is
begin
    p <= a xor b;
    g <= a and b;
end ARCH1;
    
  