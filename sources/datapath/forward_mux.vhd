library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.mypackage.all;

entity forward_mux is
    generic(
        DATA_WIDTH : integer := DATA_WIDTH
    );
    Port(
        Sel               : in STD_LOGIC_VECTOR(1 downto 0);
        FROM_REGFILE      : in STD_LOGIC_VECTOR(DATA_WIDTH -1 downto 0);
        FROM_MEM          : in  STD_LOGIC_VECTOR(DATA_WIDTH -1 downto 0);
        FROM_WB           : in  STD_LOGIC_VECTOR(DATA_WIDTH -1 downto 0);
        FROM_DELAY        : in  STD_LOGIC_VECTOR(DATA_WIDTH -1 downto 0);
        TO_ALU            : out STD_LOGIC_VECTOR(DATA_WIDTH -1 downto 0)
    );
end forward_mux;


architecture Behavioral of forward_mux is
begin
    process(Sel, FROM_REGFILE, FROM_MEM, FROM_WB, FROM_DELAY)
    begin
        case Sel is
            when "00" => TO_ALU <= FROM_REGFILE;
            when "01" => TO_ALU <= FROM_MEM;
            when "10" => TO_ALU <= FROM_WB;
            when "11" => TO_ALU <= FROM_DELAY;
            when others => TO_ALU <= (others => '0');
        end case;        
    end process;
end Behavioral;

