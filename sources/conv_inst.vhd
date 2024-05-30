library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.mypackage.all;

entity conv_inst is 
    port(
        rst : in std_logic;
        instruction_in : in std_logic_vector(INSTRUCTION_LENGHT -1 downto 0);
        instruction_out : out INST;
        instruction_type : out INST_TYPE
    );
end conv_inst;

architecture Behavioral of conv_inst is

    signal OPCODE : std_logic_vector(OPCODE_WIDTH -1 downto 0);
    signal FUNCT3 : std_logic_vector(FUNCT3_WIDTH -1 downto 0);
    signal FUNCT7 : std_logic_vector(FUNCT7_WIDTH -1 downto 0);

begin

    OPCODE <= instruction_in(6 downto 0);
    FUNCT3 <= instruction_in(14 downto 12);
    FUNCT7 <= instruction_in(31 downto 25);
    
    process(instruction_in, FUNCT3, FUNCT7, OPCODE, rst)
    --PAGINA 130 DEL MANUALE RISCV
    
    begin
        if rst = '1' then
            instruction_out <= ADDI;
            instruction_type <= R;
        else
            case OPCODE is
                when "0110111" =>                       -- LUI
                    instruction_out <= LUI;
                    instruction_type <= U;
                when "0010111" =>                       -- AUIPC
                    instruction_out <= AUIPC;
                    instruction_type <= U;
                when "1101111" =>                       -- JAL
                    instruction_out <= JAL;
                    instruction_type <= Uj;
                when "1100111" => 
                    instruction_out <= JALR;            -- JALR
                    instruction_type <= I;
                when "1100011" =>
                    case FUNCT3 is
                        when "101" =>                   -- BGE      --VERIFICARE CHE IL COMPILER SOSTITUISCA CORRETTAMENTE LA BLE
                            instruction_out <= BGE;
                            instruction_type <= SB;
                        when "110" =>                   -- BLTU
                            instruction_out <= BLTU;
                            instruction_type <= SB;
                        when others => 
                            instruction_out <= ADDI;--(others => '0');   
                            instruction_type <= I;  
                    end case;
                when "0000011" =>
                    instruction_out <= LW;              --LW
                    instruction_type <= I;
                when "0100011" =>
                    instruction_out <= SW;              --SW
                    instruction_type <= S;
                when "0010011" =>
                    instruction_out <= ADDI;            --ADDI    
                    instruction_type <= I;
                when "0110011" =>
                    case FUNCT7 is
                        when "0000000" =>
                            instruction_out <= ADD;     --ADD 
                            instruction_type <= R;  
                        when "0100000" =>
                            instruction_out <= SUB;     --SUB  
                            instruction_type <= R; 
                        when others => 
                            instruction_out <= ADDI;--(others => '0');     
                            instruction_type <= R;  
                    end case;
                when others => 
                    instruction_out <= ADDI;--(others => '0');       
                    instruction_type <= R;
            end case;
        end if;
        
    end process;

end Behavioral;
               
                    
            