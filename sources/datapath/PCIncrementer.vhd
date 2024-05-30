LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.mypackage.all;

ENTITY PCIncrementer IS
	GENERIC (len : INTEGER := DATA_WIDTH);
	PORT (
		A         : IN  STD_LOGIC_VECTOR (len - 1 DOWNTO 0);
		addResult : OUT STD_LOGIC_VECTOR (len - 1 DOWNTO 0)
	);
END ENTITY PCIncrementer;
--
ARCHITECTURE behavioral OF PCIncrementer IS
BEGIN
	addResult <= std_logic_vector(unsigned(A) + to_unsigned(4, A'length));
END ARCHITECTURE behavioral;