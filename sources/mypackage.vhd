library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;

package mypackage is
    constant DATA_WIDTH                 : integer := 32;
    constant INSTRUCTION_LENGHT         : integer := 32;
    constant ADDRESS_LENGHT             : integer := 5;
    constant OPCODE_WIDTH               : integer := 7;
    constant FUNCT3_WIDTH               : integer := 3;
    constant FUNCT7_WIDTH               : integer := 7;
    constant CW_SIZE                    : integer := 30;
    constant FETCH_STAGE                : integer := 2;
    constant DECODE_STAGE               : integer := 8;
    constant EXECUTE_STAGE              : integer := 11;
    constant MEM_STAGE                  : integer := 6;
    constant WRITE_BACK_STAGE           : integer := 2;
    constant EXTRA_STAGE                : integer := 1;
    type INST is (ADD, SUB, ADDI, LUI, AUIPC, BGE, BLTU, LW, SW, JAL, JALR, BLE, VOID); -- NOP ADDI
    type INST_TYPE is (R, I, U, S, SB, UJ);
end package mypackage;