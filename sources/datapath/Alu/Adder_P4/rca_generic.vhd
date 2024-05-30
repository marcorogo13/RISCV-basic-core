library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity rca_generic is
    generic(
        N : integer := 8
    );
    port(
        A : in std_logic_vector(N-1 downto 0);
        B : in std_logic_vector(N-1 downto 0);
        C : in std_logic;
        S : out std_logic_vector(N-1 downto 0);
        Cout : out std_logic
    );
end rca_generic;

architecture Structural of rca_generic is

    component full_adder is
        Port ( a : in  STD_LOGIC;
               b : in  STD_LOGIC;
               c : in  STD_LOGIC;
               sum : out  STD_LOGIC;
               carry : out  STD_LOGIC);
    end component;

    signal S_carry : std_logic_vector(N-1 downto 0);

    begin

    FA0 : full_adder port map(
        a =>A(0), b =>B(0), c =>C, sum =>S(0), carry => S_carry(0)
    );

    FA_loop : for i in 1 to N-1 generate
        FAi : full_adder port map(
            a =>A(i), b =>B(i), c =>S_carry(i-1), sum =>S(i), carry => S_carry(i)
        );
    end generate FA_loop;

    Cout <= S_carry(N-1);

end Structural;