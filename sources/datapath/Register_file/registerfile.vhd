library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;
use IEEE.numeric_std.all;
use WORK.all;
use work.mypackage.all;

entity registerfile is
	generic (
		addr_size: integer := ADDRESS_LENGHT;
		data_size: integer := DATA_WIDTH
	);
	port ( 
		CLK: 		IN std_logic;
		RESET: 		IN std_logic;
		ENABLE: 	IN std_logic;
		RD1: 		IN std_logic;
		RD2: 		IN std_logic;
		WR: 		IN std_logic;
		ADD_WR: 	IN std_logic_vector(addr_size - 1  downto 0);
		ADD_RD1: 	IN std_logic_vector(addr_size - 1 downto 0);
		ADD_RD2: 	IN std_logic_vector(addr_size - 1 downto 0);
		DATAIN: 	IN std_logic_vector(data_size - 1  downto 0);
		OUT1: 		OUT std_logic_vector(data_size - 1 downto 0);
		OUT2: 		OUT std_logic_vector(data_size - 1 downto 0)
		);
end registerfile;

architecture A of registerfile is
        subtype REG_ADDR is natural range 0 to 2**addr_size - 1; -- using natural type
	type REG_ARRAY is array(REG_ADDR) of std_logic_vector(data_size - 1 downto 0); 
	signal REGISTERS : REG_ARRAY; 

	
begin 



Wr_P : process(clk)		
	begin
		if (clk ='1' and clk'EVENT) then
			if RESET='1' then
				REGISTERS <= (others => (others => '0')); --synch reset all values stored to 0
			elsif (RESET = '0' and ENABLE = '1') then 
				if (WR = '1') then
					if (unsigned(ADD_WR) /= 0) then
						REGISTERS(to_integer(unsigned(ADD_WR))) <= DATAIN; 
					end if;				
				end if; 
			end if;
		end if;
end process Wr_P;




Rw_P : process(ENABLE, RESET, ADD_RD1, ADD_RD2, RD1, RD2)		
	begin
		
		if (RESET = '1') then
			OUT1 <= (others => '0');
			OUT2 <= (others => '0');
		elsif (ENABLE = '1') then 
			if (RD1 = '1') then
				OUT1 <= REGISTERS(to_integer(unsigned(ADD_RD1)));
			end if; 
			if (RD2 = '1') then
				OUT2 <= REGISTERS(to_integer(unsigned(ADD_RD2)));
			end if; 
		end if;
	
end process Rw_P;




end A;

----


configuration CFG_RF_BEH of registerfile is
  for A
  end for;
end configuration;
