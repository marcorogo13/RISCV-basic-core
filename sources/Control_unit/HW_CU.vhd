library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mypackage.all;


entity HW_CU is
    port (
            -- INPUTS
            instr           :   in  INST;        
            clk             :   in  std_logic;
            rst             :   in  std_logic;
            stall_hazard    :   in  std_logic;
            stall_mem       :   in  std_logic;
            stall_fetch     :   in  std_logic;
            -- OUTPUTS
            
                -- FETCH
            PC_sel_fetch            : out std_logic; ---------------- ci va??
            en_PC_reg               : out std_logic;

                --IF/ID
            en_PC_current_IFID      : out std_logic;
            en_instruction_IFID     : out std_logic;

                --DECODE
            RD1_regfile             : out std_logic;
            RD2_regfile             : out std_logic;
            en_regfile              : out std_logic;

                --ID/EX
            en_wb_reg_1             : out std_logic;
            en_PC_current_IDEX      : out std_logic;
            en_rs1                  : out std_logic;
            en_rs2                  : out std_logic;
            en_imm                  : out std_logic;

                --EXECUTE
            sel_A_alu               : out std_logic;
            sel_B_alu               : out std_logic;
            s1_alu                  : out std_logic;
            s2_alu                  : out std_logic;
            s3_alu                  : out std_logic;
            reg_pc_addr             : out std_logic;

                --EX/MEM
            en_wb_reg_2             : out std_logic;
            en_PC_jump              : out std_logic;
            en_alu_result           : out std_logic;
            en_zero_exmem           : out std_logic;
            en_mem_data             : out std_logic;

            --MEM
            read_write              : out std_logic;
            en_jump                 : out std_logic;
            en_branch               : out std_logic;

                --MEM/WB
            en_wb_reg_3             : out std_logic;
            en_from_mem_memwb       : out std_logic;
            en_from_alu_memwb       : out std_logic;

                --WRITE BACK
            sel_wb_mux              : out std_logic;
            WR_regfile              : out std_logic;

                --EXTRA WRITE BACK
            en_WB_delay             : out std_logic

            );                 
end HW_CU;


architecture Beh of HW_CU is

    
    signal cw              : std_logic_vector(CW_SIZE - 1 downto 0);
    signal cw_DECODE       : std_logic_vector(CW_SIZE - 1 - FETCH_STAGE  downto 0);
    signal cw_EXECUTE      : std_logic_vector(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE downto 0);
    signal cw_MEM          : std_logic_vector(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - EXECUTE_STAGE downto 0);
    signal cw_WB           : std_logic_vector(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - EXECUTE_STAGE - MEM_STAGE downto 0);
    signal cw_EXTRA        : std_logic;

    signal flag_A, flag_B  : std_logic;
    
    
    begin
    -- First stage : Fetch
    --en_PC_reg               <= '1';

    --IF/ID
    en_PC_current_IFID      <= cw(CW_SIZE - 1);
    en_instruction_IFID     <= cw(CW_SIZE - 2);

        --DECODE
    RD1_regfile             <= cw_DECODE(CW_SIZE - 1 - FETCH_STAGE);
    RD2_regfile             <= cw_DECODE(CW_SIZE - 1 - FETCH_STAGE - 1);
    en_regfile              <= '1';  --cw_DECODE(CW_SIZE - 1 - FETCH_STAGE - 2);

        --ID/EX
    en_wb_reg_1             <= cw_DECODE(CW_SIZE - 1 - FETCH_STAGE - 3);
    en_PC_current_IDEX      <= cw_DECODE(CW_SIZE - 1 - FETCH_STAGE - 4);
    en_rs1                  <= cw_DECODE(CW_SIZE - 1 - FETCH_STAGE - 5);
    en_rs2                  <= cw_DECODE(CW_SIZE - 1 - FETCH_STAGE - 6);
    en_imm                  <= cw_DECODE(CW_SIZE - 1 - FETCH_STAGE - 7);

        --EXECUTE
    sel_A_alu               <= cw_EXECUTE(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE );
    sel_B_alu               <= cw_EXECUTE(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - 1);
    s1_alu                  <= cw_EXECUTE(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - 2);
    s2_alu                  <= cw_EXECUTE(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - 3);
    s3_alu                  <= cw_EXECUTE(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - 4);
    reg_pc_addr             <= cw_EXECUTE(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - 5); -- 31-16 = 15

        --EX/MEM
    en_wb_reg_2             <= cw_EXECUTE(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - 6); -- 31-16 = 15
    en_PC_jump              <= cw_EXECUTE(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - 7);
    en_alu_result           <= cw_EXECUTE(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - 8);
    en_zero_exmem           <= cw_EXECUTE(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - 9);
    en_mem_data             <= cw_EXECUTE(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - 10);
        
        --MEM
    read_write              <= cw_MEM(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - EXECUTE_STAGE);
    en_jump                 <= cw_MEM(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - EXECUTE_STAGE - 1);
    en_branch               <= cw_MEM(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - EXECUTE_STAGE - 2);

        --MEM/WB
    en_wb_reg_3             <= cw_MEM(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - EXECUTE_STAGE - 3);
    en_from_mem_memwb       <= cw_MEM(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - EXECUTE_STAGE - 4);
    en_from_alu_memwb       <= cw_MEM(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - EXECUTE_STAGE - 5);

        --WRITE BACK
    sel_wb_mux              <= cw_WB(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - EXECUTE_STAGE - MEM_STAGE);
    WR_regfile              <= cw_WB(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - EXECUTE_STAGE - MEM_STAGE - 1);

        --EXTRA WRITE BACK
    en_WB_delay             <= cw_EXTRA;




opcode_func_check: process (instr, Rst, stall_hazard, stall_mem, flag_B)
begin
    if (Rst = '1') then
        cw  <= (others => '0'); 
        en_PC_reg <= '1';
        cw(CW_SIZE - 1) <= '1'; -- en_PC_current_IFID
        cw(CW_SIZE - 2) <= '1'; -- en_instruction_IFID
        flag_A <= '0';
    else 
        if (stall_hazard = '1') then
            en_PC_reg <= '0';
            flag_A <= '1';
        else
            en_PC_reg <= '1';
            flag_A <= '0';
        end if;
        if (flag_B = '0' ) then
            case instr is
                when BGE    => cw <= "111110111111010001010001000000";   -- "11111011101101000101010000000" --ble
                when BLTU   => cw <= "111110111111011001010001000000";   -- "11111011101101100101010000000" 
                when JAL    => cw <= "110011100100101011100010101010";   -- "11001110010010101011100101010" 
                when JALR   => cw <= "111011110100101111100010101010";   -- "11101111010010101011100101010" 
                when ADD    => cw <= "011111011011000010100000101011";   -- "01111101101100000010100101011" 
                when SUB    => cw <= "011111011011001010100000101011";   -- "01111101101100100010100101011" 
                when ADDI   => cw <= "011011010110000010100000101011";   -- "01101101011000000010100101011" 
                when LW     => cw <= "011011010110000010100000110111";   -- "01101101011000000010100110111" 
                when LUI    => cw <= "010011000110100010100000101011";   -- "01001100011010000010100101011" 
                when AUIPC  => cw <= "110011100100000010100000101011";   -- "11001110010000000010100101011" 
                when SW     => cw <= "011110011110000000101100000000";   -- old: "01101001011000010000101000000" || "01111001111000010000101000000"                  
                when others => cw <= (others => '0');
            end case;
        else
            cw <= (others => '0');
        end if;

    end if;
end process opcode_func_check;



Comb: process( Clk, Rst)
    begin
        if (Rst = '1') then

            cw_DECODE   <= (others => '0');
            cw_EXECUTE  <= (others => '0');
            cw_MEM      <= (others => '0');
            cw_WB       <= (others => '0');
            cw_EXTRA    <= '0';
            flag_B      <= '0';

        elsif (rising_edge(Clk)) then

            cw_DECODE   <= cw(CW_SIZE - 1 - FETCH_STAGE downto 0 );
            cw_EXECUTE  <= cw_DECODE(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE downto 0);
            cw_MEM      <= cw_EXECUTE(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - EXECUTE_STAGE downto 0);
            cw_WB       <= cw_MEM(CW_SIZE - 1 - FETCH_STAGE - DECODE_STAGE - EXECUTE_STAGE - MEM_STAGE downto 0);
            cw_EXTRA    <= cw_WB(0);
            flag_B      <= flag_A;

        end if;

    end process Comb;



end Beh;


