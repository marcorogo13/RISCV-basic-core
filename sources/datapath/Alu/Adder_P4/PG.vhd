library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic

entity PG is
    port(
        P_i_k, G_i_k: in std_logic;
        P_k_j, G_k_j: in std_logic;
        P_i_j, G_i_j: out std_logic
    );
end PG;

architecture ARCH1 of PG is
begin
    P_i_j <= P_i_k and P_k_j;               --P_i_j = P_i_k and P_(k-1)_j
    G_i_j <= G_i_k or (P_i_k and G_k_j);    -- G_i_j = G_i_k + P_i_k and G_(k-1)_j
end ARCH1;
    
    