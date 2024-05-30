library IEEE;
use IEEE.std_logic_1164.all;


entity carry_select_block is 
	generic (NBIT : integer := 8);
	Port (	A: In std_logic_vector(NBIT - 1 DOWNTO 0);
          	B: In std_logic_vector(NBIT - 1 DOWNTO 0);
          	Ci: In std_logic;
          	S: Out std_logic_vector(NBIT - 1 DOWNTO 0)
          	);
end carry_select_block; 

architecture ARCH1 of carry_select_block is

	component rca_generic is
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
	end component; 
	
	COMPONENT MUX21_GENERIC is 
		generic (NBIT : integer := 8);
		port (A: In std_logic_vector(NBIT-1 downto 0);
		      B: In std_logic_vector(NBIT-1 downto 0);
		      S: In std_logic;
		      Y: Out std_logic_vector(NBIT-1 downto 0));
	end COMPONENT;
	
	SIGNAL Y0, Y1: std_logic_vector(NBIT-1 downto 0);
	SIGNAL carry_0, carry_1: std_logic;
	
begin
	RCA_0 : RCA_GENERIC GENERIC MAP (NBIT)PORT MAP (A => A, B => B, C => '0', S => Y0, Cout => carry_0);
	RCA_1 : RCA_GENERIC GENERIC MAP (NBIT)PORT MAP (A => A, B => B, C => '1', S => Y1, Cout => carry_1);
	MUX: MUX21_GENERIC GENERIC MAP (NBIT)PORT MAP (A => Y0, B => Y1, S => Ci, Y => S);

end ARCH1;
