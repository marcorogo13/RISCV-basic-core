library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.mypackage.all;

entity P4_ADDER is
	generic (
		NBIT :		integer := DATA_WIDTH;
		NBIT_PER_BLOCK : integer := 4
		);
	port (
		A :		in	std_logic_vector(NBIT-1 downto 0);
		B :		in	std_logic_vector(NBIT-1 downto 0);
		Cin :	in	std_logic;
		S :		out	std_logic_vector(NBIT-1 downto 0);
		Cout :	out	std_logic);
end P4_ADDER;

architecture STRUCT of P4_ADDER is
	

	-- Carry generator declaration	
	component Carry_lookahead is
		generic (N : integer := 32;
		        C : integer := 4);
		port(
		    A, B: in std_logic_vector(N-1 downto 0);
		    C_in: in std_logic;      --NB: L'USO DI C_in NON E' STATO IMPLEMETATO
		    C_out: out std_logic_vector((N/C) - 1 downto 0)        
		);
	end component;	

	-- sum_generator component declaration
	component sum_generator is
		generic (NBIT_PER_BLOCK : integer := 4;
		       	 NBLOCKS : integer := 8);
		Port (	A: In std_logic_vector(NBIT_PER_BLOCK*NBLOCKS - 1 DOWNTO 0);
		      	B: In std_logic_vector(NBIT_PER_BLOCK*NBLOCKS - 1 DOWNTO 0);
		      	Ci: In std_logic_vector(NBLOCKS - 1 DOWNTO 0);
		      	S: Out std_logic_vector(NBIT_PER_BLOCK*NBLOCKS - 1 DOWNTO 0)
		      	);
	end component;


	signal C_out_s : std_logic_vector ((NBIT/NBIT_PER_BLOCK) - 1 downto 0);
	signal C_in_s : std_logic_vector ((NBIT/NBIT_PER_BLOCK) - 1 downto 0);
	
begin


	c_loo : Carry_lookahead 
		generic map (NBIT, NBIT_PER_BLOCK)
		port map(A => A, B => B, C_in => Cin, C_out => C_out_s);

	C_in_s <= C_out_s(NBIT/NBIT_PER_BLOCK -2 downto 0) & Cin;
	Cout <= C_out_s(NBIT/NBIT_PER_BLOCK -1);

	s_gen : sum_generator
	generic map (NBIT_PER_BLOCK, NBIT/NBIT_PER_BLOCK)
	port map(A, B, C_in_s, S);

	
end STRUCT;

