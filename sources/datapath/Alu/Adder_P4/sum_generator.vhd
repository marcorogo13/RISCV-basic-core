library IEEE;
use IEEE.std_logic_1164.all;

entity sum_generator is 
	generic (NBIT_PER_BLOCK : integer := 4;
           	 NBLOCKS : integer := 8);
	Port (	A: In std_logic_vector(NBIT_PER_BLOCK*NBLOCKS - 1 DOWNTO 0);
          	B: In std_logic_vector(NBIT_PER_BLOCK*NBLOCKS - 1 DOWNTO 0);
          	Ci: In std_logic_vector(NBLOCKS - 1 DOWNTO 0);
          	S: Out std_logic_vector(NBIT_PER_BLOCK*NBLOCKS - 1 DOWNTO 0)
          	);
end sum_generator; 

ARCHITECTURE STRUCTURAL_1 OF sum_generator IS

	COMPONENT carry_select_block is 
		generic (NBIT : integer := 8);
		Port (	A: In std_logic_vector(NBIT - 1 DOWNTO 0);
		  	B: In std_logic_vector(NBIT - 1 DOWNTO 0);
		  	Ci: In std_logic;
		  	S: Out std_logic_vector(NBIT - 1 DOWNTO 0)
		  	);
	end COMPONENT; 

	signal Z: std_logic_vector(NBIT_PER_BLOCK*NBLOCKS - 1 DOWNTO 0);

BEGIN
	xor_generate : for i in 0 to NBIT_PER_BLOCK*NBLOCKS -1 generate
		Z(i) <= Ci(0) xor B(i);
	end generate xor_generate;

	ADDER: FOR I IN 1 TO NBLOCKS GENERATE
		CSI: carry_select_block 
			GENERIC MAP (NBIT => NBIT_PER_BLOCK) 
			PORT MAP (A => A( NBIT_PER_BLOCK*I - 1 DOWNTO NBIT_PER_BLOCK*I - NBIT_PER_BLOCK), B => Z( NBIT_PER_BLOCK*I - 1 DOWNTO NBIT_PER_BLOCK*I - NBIT_PER_BLOCK),
							Ci => Ci(I-1), S => S(NBIT_PER_BLOCK*I - 1 DOWNTO NBIT_PER_BLOCK*I - NBIT_PER_BLOCK));
	END GENERATE;


END STRUCTURAL_1;
