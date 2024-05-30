library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.math_real.all;
use IEEE.numeric_std.all;
use work.mypackage.all;


entity alu is
    generic (
        len:        integer := DATA_WIDTH
    );
    port (
        rst:        in std_logic;
        A:          in  std_logic_vector(len-1 downto 0);
        B:          in  std_logic_vector(len-1 downto 0);  
        S1:         in  std_logic;
        S2:         in  std_logic;
        S3:         in  std_logic;
        Y:          out std_logic_vector(len-1 downto 0);
        zero:       out std_logic
    );
end alu;

--Alu da modificare per fare solo le operazioni che servono (due bit dovrebbero essere suffcenti, deve fare somme, sottrazioni e comparison 
-- S1 = 0, S2 = 0 S3 = 0 -> sum
-- S1 = 0, S2 = 0 S3 = 1 -> sub
-- S1 = 0, S2 = 1 S3 = 0 -> ble
-- S1 = 0, S2 = 1 S3 = 1 -> bltu
-- S1 = 1, S2 = 0 S3 = 0 -> lui
-- S1 = 1, S2 = 0 S3 = 1 -> a + 4 (for PC storing for jal and jalr)

architecture alu of alu is

constant bit_per_block: integer := 4;

signal Cout:            std_logic;
signal Cin:             std_logic;
signal AdderOut:        std_logic_vector(len-1 downto 0);
signal ShiftOut:        std_logic_vector(len -1 downto 0);



component P4_ADDER is
	generic (
		NBIT :		        integer := DATA_WIDTH;
		NBIT_PER_BLOCK :    integer := 4
		);
	port (
		A :		in	std_logic_vector(NBIT-1 downto 0);
		B :		in	std_logic_vector(NBIT-1 downto 0);
		Cin :	in	std_logic;
		S :		out	std_logic_vector(NBIT-1 downto 0);
		Cout :	out	std_logic);
end component;


begin
    
    --vengono usati i segnali s4 e s3 al posto di cin e shift_direction poichè hanno lo stesso comportamento logico
    adder : P4_ADDER    
        generic map (len, bit_per_block)
        port map(A, B, Cin, AdderOut, Cout);

    compute: process(S1, S2, S3, A, B, AdderOut, ShiftOut) --aggiunto adderout, testing
    begin
        zero <= '0';
        Y <= (others => '0');
        
        --modifica: un potenziale problema potrebbe essere la contemporanea assegnazione di Cin e di Adder out
        --in quanto il valore di AdderOut dipende da Cin
        --sostiruisco cin con il valore di S4: si comporta esattamene come Cin, ma si evita una assegnazione in più


        if (S1 = '0' and S2 = '0' and S3 = '0') then     --sum
            Cin <= '0';--cin = 0 sum
            Y <= AdderOut;

        elsif (S1 = '0' and S2 = '0' and S3 = '1') then  --sub
            Cin <= '1';--cin = 1 sub
            Y <= AdderOut;
        
        elsif (S1 = '0' and S2 = '1' and S3 = '0') then  --ble
            --dobbiamo adottare qualche metodo speciale, o facciamo una semplice comparazione?
            if (signed(A) >= signed(B)) then
                zero <= '1';               
            end if ;

        elsif (S1 = '0' and S2 = '1' and S3 = '1') then  --bltu            
            if (unsigned(A) < unsigned(B)) then
                zero <= '1';               
            end if ;
        
        elsif (S1 = '1' and S2 = '0' and S3 = '0') then  --lui
            Y <= B;

        elsif (S1 = '1' and S2 = '0' and S3 = '1') then  --add 4 (to PC)
            Y <= std_logic_vector(unsigned(A) + to_unsigned(4, DATA_WIDTH));

        end if ;

    end process;

end alu;
