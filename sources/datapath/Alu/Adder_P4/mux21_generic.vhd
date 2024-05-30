-- Standard multiplexer 2x1, generalizzato per ingressi/uscite su N bit
-- A, B = linee di ingresso
-- Y = uscita seleziona
-- S = select


library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic




entity MUX21_GENERIC is 
	generic (NBIT : integer := 8);
	port (	A:	In	std_logic_vector(NBIT-1 downto 0);
			B:	In	std_logic_vector(NBIT-1 downto 0);
			S:	In	std_logic;
			Y:	Out	std_logic_vector(NBIT-1 downto 0));
end MUX21_GENERIC;


architecture BEHAVIORAL of MUX21_GENERIC is

begin
	with S select 
	Y <= A when '0',
	     B when '1',
		 A when others; 

end BEHAVIORAL;


