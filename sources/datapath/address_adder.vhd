library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.mypackage.all;


entity address_adder is
    Port ( 
        PC           : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        reg_vs_pc    : in  STD_LOGIC;   --0=PC, 1=reg
        rs1          : in  STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
        offset       : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
        target       : out  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0)
        );
end address_adder;

architecture Behavioral of address_adder is
    
    signal offset_shifted : std_logic_vector(DATA_WIDTH-1 downto 0);

begin

    --per ora non viene fatto lo shift, perchè non so perchè?
        --pechè l'immediate per il jump è moltipliocato x2= shift
    --probabilmente volendo si può implementare un adder migliore
    --offset_shifted <= offset(DATA_WIDTH-2 downto 0) & "0";
    --target <= std_logic_vector(unsigned(PC) + unsigned(offset)); --rimesso shifted shifted

    comb: process(PC, reg_vs_pc, rs1, offset)
    begin
        if (reg_vs_pc = '1') then
            target <= std_logic_vector(unsigned(rs1) + unsigned(offset));
        else
            target <= std_logic_vector(unsigned(PC) + unsigned(offset));
        end if;
    end process comb;

end Behavioral;