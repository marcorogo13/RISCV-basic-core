library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.mypackage.all;

entity immediate_unit is
    Port ( 
        instruction     : in    STD_LOGIC_VECTOR (INSTRUCTION_LENGHT-1 downto 0);
        instr_type      : in    INST_TYPE;
        immediate       : out   STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0));
end immediate_unit;


architecture Behavioral of immediate_unit is

begin

    with instr_type select immediate <=
        (DATA_WIDTH-1 downto 12 => instruction(31)) & instruction(31 downto 20) when I,
        (DATA_WIDTH-1 downto 12 => instruction(31)) & instruction(31 downto 25) & instruction(11 downto 7) when S,
        (DATA_WIDTH-1 downto 13 => instruction(31)) & instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) & '0' when SB,
        (DATA_WIDTH-1 downto 21 => instruction(31)) & instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) & '0' when UJ,
        instruction(DATA_WIDTH-1 downto 12) & "000000000000" when U,
        (others => '0') when others;

end Behavioral;