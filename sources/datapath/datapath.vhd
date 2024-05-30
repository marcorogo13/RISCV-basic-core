library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.mypackage.all;

entity datapath is

    port(
        clk                     : in std_logic;
        rst                     : in std_logic;
        instruction             : in std_logic_vector(DATA_WIDTH-1 downto 0);
        instruction_type        : in INST_TYPE;
        PC_sel_fetch            : in std_logic; ------------------ ci va? -> no, il segnale che pilota il mux del PC è il risultato dei controlli di jump/branch
        en_PC_reg               : in std_logic;
        en_PC_current_IFID      : in std_logic;
        en_instruction_IFID     : in std_logic;
        RD1_regfile             : in std_logic;
        RD2_regfile             : in std_logic;
        WR_regfile              : in std_logic;
        en_regfile              : in std_logic;
        en_wb_reg_1             : in std_logic;
        en_PC_current_IDEX      : in std_logic;
        en_rs1                  : in std_logic;
        en_rs2                  : in std_logic;
        en_imm                  : in std_logic;
        sel_A_alu               : in std_logic;
        sel_B_alu               : in std_logic;
        sel_forward_mux_A       : in STD_LOGIC_VECTOR(1 downto 0);
        sel_forward_mux_B       : in STD_LOGIC_VECTOR(1 downto 0);
        s1_alu                  : in std_logic;
        s2_alu                  : in std_logic;
        s3_alu                  : in std_logic;
        reg_pc_addr             : in std_logic;
        en_wb_reg_2             : in std_logic;
        en_PC_jump              : in std_logic;
        en_alu_result           : in std_logic;
        en_zero_exmem           : in std_logic;
        en_mem_data             : in std_logic;
        en_jump                 : in std_logic;
        en_branch               : in std_logic;
        en_wb_reg_3             : in std_logic;
        en_from_mem_memwb       : in std_logic;
        en_from_alu_memwb       : in std_logic;
        sel_wb_mux              : in std_logic;
        en_WB_delay             : in std_logic;
        sel_forward_mem         : in STD_LOGIC_VECTOR(1 downto 0);
        MEM_data_in             : in std_logic_vector(DATA_WIDTH-1 downto 0);


        -- OUTPUTS
        PC_out                  : out std_logic_vector(DATA_WIDTH-1 downto 0);
        MEM_address             : out std_logic_vector(DATA_WIDTH-1 downto 0);
        MEM_data_out            : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );

end datapath;

architecture arch1 of datapath is

    -- COMPONENTS
    component alu is
        generic (
            len:        integer := DATA_WIDTH
        );
        port (
            rst:   in std_logic;
            A:          in  std_logic_vector(len-1 downto 0);
            B:          in  std_logic_vector(len-1 downto 0);  
            S1:         in  std_logic;
            S2:         in  std_logic;
            S3:         in  std_logic;
            Y:          out std_logic_vector(len-1 downto 0);
            zero:       out std_logic
    );
    end component;

    component registerfile is
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
    end component;

    component generic_mux is
        generic(
            len:      integer := DATA_WIDTH
        );
        port(
            A:      in std_logic_vector(len-1 downto 0);
            B:      in std_logic_vector(len-1 downto 0);
            Sel:    in std_logic;
            Y:      out std_logic_vector(len-1 downto 0)
        );
    end component;

    component Single_bit_register is
        port(
            clk:        in std_logic;
            rst:        in std_logic;
            enable:     in std_logic;
            in_reg:     in std_logic;
            out_reg:    out std_logic
        );
    end component;

    component type_register is
        port(
            clk:        in std_logic;
            rst:        in std_logic;
            enable:     in std_logic;
            in_reg:     in INST_TYPE;
            out_reg:    out INST_TYPE
        );
    end component;

    component generic_Register is
        generic(
            len:    integer := DATA_WIDTH
        );
        port(
            clk:        in std_logic;
            rst:        in std_logic;
            enable:     in std_logic;
            in_reg:     in std_logic_vector(len-1 downto 0);
            out_reg:    out std_logic_vector(len-1 downto 0)
        );
    end component;

    component PCIncrementer is
        generic (len : INTEGER := DATA_WIDTH);
        port (
            A         : in  STD_LOGIC_VECTOR (len - 1 downto 0);
            addResult : out STD_LOGIC_VECTOR (len - 1 downto 0)
        );
    end component;

    component immediate_unit is
        Port ( 
            instruction     : in    STD_LOGIC_VECTOR (INSTRUCTION_LENGHT-1 downto 0);
            instr_type      : in    INST_TYPE;
            immediate       : out   STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0));
    end component;

    component forward_mux is
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
    end component;
    
    component address_adder is
        Port ( 
            PC           : in  STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
            reg_vs_pc    : in  STD_LOGIC;   --0=PC, 1=reg
            rs1          : in  STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
            offset       : in  STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0);
            target       : out  STD_LOGIC_VECTOR (DATA_WIDTH -1 downto 0)
            );
    end component;



                        -- SIGNALS

    -- FETCH (IF)
    signal next_PC_4:           std_logic_vector(DATA_WIDTH-1 downto 0);
    signal next_PC_jump:        std_logic_vector(DATA_WIDTH-1 downto 0);
    signal PC_in:               std_logic_vector(DATA_WIDTH-1 downto 0);
    signal PC_out_s:            std_logic_vector(DATA_WIDTH-1 downto 0);
    

    -- DECODE (ID)
    signal PC_propagate_1:      std_logic_vector(DATA_WIDTH-1 downto 0);
    signal instr_out:           std_logic_vector(INSTRUCTION_LENGHT-1 downto 0);
    signal instr_type_out:      INST_TYPE;
    signal rs1_id:              std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rs2_id:              std_logic_vector(DATA_WIDTH-1 downto 0);
    signal imm_id:              std_logic_vector(DATA_WIDTH-1 downto 0);

    -- EXECUTE (EX)
    signal PC_propagate_2:      std_logic_vector(DATA_WIDTH-1 downto 0);
    signal WB_propagate_1:      std_logic_vector(ADDRESS_LENGHT-1 downto 0);
    signal rs1_ex:              std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rs2_ex:              std_logic_vector(DATA_WIDTH-1 downto 0);
    signal imm_ex:              std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rs2_forwarded:       std_logic_vector(DATA_WIDTH-1 downto 0);
    signal rs1_forwarded:       std_logic_vector(DATA_WIDTH-1 downto 0);
    signal alu_A:               std_logic_vector(DATA_WIDTH-1 downto 0);
    signal alu_B:               std_logic_vector(DATA_WIDTH-1 downto 0);
    signal alu_out_ex:          std_logic_vector(DATA_WIDTH-1 downto 0);
    signal zero_out_ex:         std_logic;
    signal PC_target:           std_logic_vector(DATA_WIDTH-1 downto 0);

    -- MEMORY (MEM)
    signal WB_propagate_2:      std_logic_vector(ADDRESS_LENGHT-1 downto 0);
    signal alu_out_mem:         std_logic_vector(DATA_WIDTH-1 downto 0);
    signal zero_out_mem:        std_logic;
    signal mem_data:            std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_from_mem:       std_logic_vector(DATA_WIDTH-1 downto 0);
    signal branch_taken:        std_logic;
    signal jump_taken:          std_logic;

    -- WRITE BACK (WB)
    signal WB_propagate_3:      std_logic_vector(ADDRESS_LENGHT-1 downto 0);
    signal mem_wb:              std_logic_vector(DATA_WIDTH-1 downto 0);
    signal alu_wb:              std_logic_vector(DATA_WIDTH-1 downto 0);
    signal WB_mux_out:          std_logic_vector(DATA_WIDTH-1 downto 0);
    
    --Extra write back propagate register signal
    signal WB_delay:      std_logic_vector(DATA_WIDTH-1 downto 0);
    --signal WB_delay_reg:      std_logic_vector(DATA_WIDTH-1 downto 0);


begin


    -- FETCH (IF)

    PC_in_mux: generic_mux port map(
        A => next_PC_jump, 
        B => next_PC_4,             --when jump_taken = 0
        Sel => jump_taken,
        Y => PC_in
    );

    PC_reg: generic_Register port map(
        clk => clk,
        rst => rst,
        enable => en_PC_reg,
        in_reg => PC_in,
        out_reg => PC_out_s
    );

    PC_inc: PCIncrementer port map(
        A => PC_out_s,
        addResult => next_PC_4
    );

    PC_out <= PC_out_s;

    -- IF/ID REGISTERS

    PC_current_1: generic_Register port map(
        clk => clk,
        rst => rst,
        enable => en_PC_current_IFID,
        in_reg => PC_out_s,             --bypassed
        out_reg => PC_propagate_1
    );

    instruction_reg: generic_Register
    generic map(INSTRUCTION_LENGHT)    
    port map(
        clk => clk,
        rst => rst,
        enable => en_instruction_IFID,
        in_reg => instruction,
        out_reg => instr_out
    );

    instruction_type_reg: type_register  
    port map(
        clk => clk,
        rst => rst,
        enable => en_instruction_IFID,
        in_reg => instruction_type,
        out_reg => instr_type_out
    );
    -- DECODE (ID)

    reg_file: registerfile port map(
        CLK => clk,
        RESET => rst,
        ENABLE => en_regfile,
        RD1 => RD1_regfile,
        RD2 => RD2_regfile,
        WR => WR_regfile,
        ADD_WR => WB_propagate_3,
        ADD_RD1 => instr_out(19 downto 15),
        ADD_RD2 => instr_out(24 downto 20),
        DATAIN => WB_mux_out,
        OUT1 => rs1_id,
        OUT2 => rs2_id
    );

    imm_creator: immediate_unit port map(
        instruction => instr_out,
        instr_type => instr_type_out,
        immediate => imm_id
    );

    -- ID/EX REGISTERS

    wb_reg_1: generic_Register 
    generic map(ADDRESS_LENGHT)
    port map(
        clk => clk,
        rst => rst,
        enable => en_wb_reg_1,
        in_reg => instr_out(11 downto 7),
        out_reg => wb_propagate_1
    );

    PC_current_2: generic_Register 
    generic map(DATA_WIDTH)
    port map(
        clk => clk,
        rst => rst,
        enable => en_PC_current_IFID, --en_PC_current_IDEX,
        in_reg => PC_out_s,         --bypassed
        out_reg => PC_propagate_2
    );

    RS1_reg: generic_Register 
    generic map(DATA_WIDTH)
    port map(
        clk => clk,
        rst => rst,
        enable => en_rs1,
        in_reg => rs1_id,
        out_reg => rs1_ex
    );

    RS2_reg: generic_Register 
    generic map(DATA_WIDTH)
    port map(
        clk => clk,
        rst => rst,
        enable => en_rs2,
        in_reg => rs2_id,
        out_reg => rs2_ex
    );

    imm: generic_Register 
    generic map(DATA_WIDTH)
    port map(
        clk => clk,
        rst => rst,
        enable => en_imm,
        in_reg => imm_id,
        out_reg => imm_ex
    );

    -- EXECUTE (EX)

    A_alu_mux: generic_mux
    generic map(DATA_WIDTH)
    port map(
        A => rs1_ex, --li ho invertiti
        B => PC_propagate_2,
        Sel => sel_A_alu,
        Y => rs1_forwarded
    );

    B_alu_mux: generic_mux 
    generic map(DATA_WIDTH)
    port map(
        A => rs2_ex,        
        B => imm_ex,
        Sel => sel_B_alu,
        Y => rs2_forwarded
    );

    forward_mux_A: forward_mux port map(
        Sel => sel_forward_mux_A,
        FROM_REGFILE => rs1_forwarded,
        FROM_MEM => alu_out_mem,
        FROM_WB => WB_mux_out,
        FROM_DELAY => WB_delay,
        TO_ALU => alu_A
    );

    forward_mux_B: forward_mux port map(
        Sel => sel_forward_mux_B,
        FROM_REGFILE => rs2_forwarded,
        FROM_MEM => alu_out_mem,
        FROM_WB => WB_mux_out,
        FROM_DELAY => WB_delay,
        TO_ALU => alu_B
    );

    alu_i: alu port map(
        rst => rst,
        A => alu_A,
        B => alu_B,
        S1 => s1_alu,
        S2 => s2_alu,
        S3 => s3_alu,
        Y => alu_out_ex,
        zero => zero_out_ex
    );

    address_adder_i: address_adder port map(

        PC => PC_propagate_2,
        offset => imm_ex,
        reg_vs_pc => reg_pc_addr,
        rs1 => rs1_ex,
        target => PC_target
    );

    -- EX/MEM REGISTERS

    wb_reg_2: generic_Register
    generic map(ADDRESS_LENGHT)
    port map(
        clk => clk,
        rst => rst,
        enable => en_wb_reg_2,
        in_reg => wb_propagate_1,
        out_reg => wb_propagate_2
    );

    PC_jump: generic_Register
    generic map(DATA_WIDTH)
    port map(
        clk => clk,
        rst => rst,
        enable => en_PC_jump,
        in_reg => PC_target,
        out_reg => next_PC_jump
    );

    alu_result: generic_Register  
    generic map(DATA_WIDTH)
    port map(
        clk => clk,
        rst => rst,
        enable => en_alu_result,
        in_reg => alu_out_ex,
        out_reg => alu_out_mem
    );

    zero: Single_bit_register
    port map(
        clk => clk,
        rst => rst,
        enable => en_zero_exmem, 
        in_reg => zero_out_ex,
        out_reg => zero_out_mem
    );

    mem_data_reg: generic_Register 
    generic map(DATA_WIDTH)    
    port map(
        clk => clk,
        rst => rst,
        enable => en_mem_data,
        in_reg => rs2_ex,       
        out_reg => mem_data
    );

    -- MEMORY (MEM)

    MEM_address <= alu_out_mem;

    data_from_mem <= MEM_data_in;

    forward_mem_mux: forward_mux port map(  --usato lo stesso mux di forward della alu, i nomi sono imprecisi
        Sel => sel_forward_mem,
        FROM_REGFILE => mem_data,
        FROM_MEM => WB_mux_out,
        FROM_WB => WB_delay,
        FROM_DELAY => (others => '0'),
        TO_ALU => MEM_data_out
    );

    branch_taken <= zero_out_mem and en_branch;
    jump_taken <= branch_taken or en_jump;

    -- MEM/WB REGISTERS

    wb_reg_3: generic_Register 
    generic map(ADDRESS_LENGHT)
    port map(
        clk => clk,
        rst => rst,
        enable => en_wb_reg_3,
        in_reg => WB_propagate_2,
        out_reg => WB_propagate_3
    );

    data_from_mem_reg: generic_Register 
    generic map(DATA_WIDTH)
    port map(
        clk => clk,
        rst => rst,
        enable => en_from_mem_memwb,
        in_reg => data_from_mem,
        out_reg => mem_wb
    );

    data_from_alu: generic_Register 
    generic map(DATA_WIDTH)
    port map(
        clk => clk,
        rst => rst,
        enable => en_from_alu_memwb,
        in_reg => alu_out_mem,
        out_reg => alu_wb
    );

    -- WB (WB)

    wb_mux: generic_mux 
    generic map(DATA_WIDTH)
    port map(
        A => mem_wb,    
        B => alu_wb,
        Sel => sel_wb_mux,
        Y => WB_mux_out
    );

    -- Extra write back propagate register
    WB_delay_reg: generic_Register 
    generic map(DATA_WIDTH)
    port map(
        clk => clk,
        rst => rst,
        enable => en_WB_delay,
        in_reg => WB_mux_out,
        out_reg => WB_delay
    );




end arch1;