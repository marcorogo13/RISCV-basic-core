library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic


entity G is
    port(
        P_i_k, G_i_k: in std_logic;
        G_k_j: in std_logic;
        G_i_j: out std_logic
    );
end G;

architecture ARCH1 of G is
begin
    G_i_j <= G_i_k or (P_i_k and G_k_j); -- G_i_j = G_i_k + P_i_k and G_(k-1)_j
end ARCH1;
    
