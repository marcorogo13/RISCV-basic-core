library ieee;
use ieee.std_logic_1164.all;
use work.mypackage.all;

entity riscv is
    port (
        clk             : in std_logic;
        rst             : in std_logic;
        --mem signals to tb
            --instruction
        instr_ADDR      : out  std_logic_vector(DATA_WIDTH-1 downto 0);
        instr_WE        : out  std_logic;
        instr_WDATA     : out  std_logic_vector(DATA_WIDTH-1 downto 0);
        instr_RDATA     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
            --memory
        mem_ADDR        : out  std_logic_vector(DATA_WIDTH-1 downto 0);
        mem_WE          : out  std_logic;
        mem_WDATA       : out  std_logic_vector(DATA_WIDTH-1 downto 0);
        mem_RDATA       : in  std_logic_vector(DATA_WIDTH-1 downto 0)          

    );
end riscv;

architecture stru of riscv is
    component datapath is
        port (
            clk                     : in std_logic;
            rst                     : in std_logic;
            instruction             : in std_logic_vector(DATA_WIDTH-1 downto 0);
            instruction_type        : in INST_TYPE;
            PC_sel_fetch            : in std_logic;
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
            -- OUTPUTS
            PC_out                  : out std_logic_vector(DATA_WIDTH-1 downto 0);
            MEM_address             : out std_logic_vector(DATA_WIDTH-1 downto 0);
            MEM_data_in             : in std_logic_vector(DATA_WIDTH-1 downto 0);
            MEM_data_out            : out std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    component HW_CU is
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
            PC_sel_fetch            : out std_logic;
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
    end component;

    component hazard_forward_unit is
        port(
            rst             : in std_logic;
            clk             : in std_logic;
            instruction     : in std_logic_vector(INSTRUCTION_LENGHT - 1 downto 0);
            inst_type       : in INST;
            stall_in_fetch  : in std_logic;
            stall_in_mem    : in std_logic; --attivo alto
            
            stall           : out std_logic;
            forward_A       : out std_logic_vector(1 downto 0);
            forward_B       : out std_logic_vector(1 downto 0)
        );
    end component;

    component forward_mem_unit is
        port(
            rst             : in std_logic;
            clk             : in std_logic;
            instruction     : in std_logic_vector(INSTRUCTION_LENGHT - 1 downto 0);
            inst_type       : in INST;
            stall_in_fetch  : in std_logic;
            stall_in_mem    : in std_logic; --attivo alto
            
            forward         : out std_logic_vector(1 downto 0)
        );
    end component;

    component conv_inst is 
    port(
        rst : in std_logic;
        instruction_in : in std_logic_vector(INSTRUCTION_LENGHT -1 downto 0);
        instruction_out : out INST;
        instruction_type : out INST_TYPE
    );
    end component;

    component mem_unit is
        port(
            --signals for processor
            clk : in std_logic;
            rst : in std_logic;
            address : in std_logic_vector(DATA_WIDTH-1 downto 0);
            stall    : out std_logic;
            w_r      : in std_logic;
            data_out : out std_logic_vector(DATA_WIDTH-1 downto 0);
            data_in  : in std_logic_vector(DATA_WIDTH-1 downto 0);
    
            -- signals for memory
            ADDR    : out  std_logic_vector(DATA_WIDTH-1 downto 0);
            WE      : out  std_logic;
            WDATA   : out  std_logic_vector(DATA_WIDTH-1 downto 0);
            RDATA   : in  std_logic_vector(DATA_WIDTH-1 downto 0)
        );
    end component;

    component fetch_unit is
        port(
            --signals for processor
            clk             : in std_logic;
            rst             : in std_logic;
            pc              : in std_logic_vector(DATA_WIDTH-1 downto 0);
            stall           : out std_logic;
            instruction     : out std_logic_vector(INSTRUCTION_LENGHT-1 downto 0);
    
            --signals for memory
            ADDR    : out  std_logic_vector(DATA_WIDTH-1 downto 0);
            WE      : out  std_logic;
            WDATA   : out  std_logic_vector(DATA_WIDTH-1 downto 0);
            RDATA   : in  std_logic_vector(DATA_WIDTH-1 downto 0)  
        );
    end component;

    -- SIGNAL
    signal instruction_s        : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal instruction_coded_s  : INST;
    signal instruction_type_s   : INST_TYPE;
    signal PC_sel_fetch_s       : std_logic;
    signal en_PC_reg_s          : std_logic;
    signal en_PC_current_IFID_s : std_logic;
    signal en_instruction_IFID_s: std_logic;
    signal RD1_regfile_s        : std_logic;
    signal RD2_regfile_s        : std_logic;
    signal WR_regfile_s         : std_logic;
    signal en_regfile_s         : std_logic;
    signal en_wb_reg_1_s        : std_logic;
    signal en_PC_current_IDEX_s : std_logic;
    signal en_rs1_s             : std_logic;
    signal en_rs2_s             : std_logic;
    signal en_imm_s             : std_logic;
    signal sel_A_alu_s          : std_logic;
    signal sel_B_alu_s          : std_logic;
    signal sel_forward_mux_A_s  : STD_LOGIC_VECTOR(1 downto 0);
    signal sel_forward_mux_B_s  : STD_LOGIC_VECTOR(1 downto 0);
    signal s1_alu_s             : std_logic;
    signal s2_alu_s             : std_logic;
    signal s3_alu_s             : std_logic;
    signal reg_pc_addr_s        : std_logic;
    signal en_wb_reg_2_s        : std_logic;
    signal en_PC_jump_s         : std_logic;
    signal en_alu_result_s      : std_logic;
    signal en_zero_exmem_s      : std_logic;
    signal en_mem_data_s        : std_logic;
    signal en_wb_reg_3_s        : std_logic;
    signal en_from_mem_memwb_s  : std_logic;
    signal en_from_alu_memwb_s  : std_logic;
    signal sel_wb_mux_s         : std_logic;
    signal en_WB_delay_s        : std_logic;
    signal stall_hazard_s       : std_logic;
    signal stall_mem_s          : std_logic;
    signal stall_fetch_s        : std_logic;
    signal en_jump_s            : std_logic;
    signal en_branch_s          : std_logic;
    signal PC_s                 : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal sel_forward_mem_s    : STD_LOGIC_VECTOR(1 downto 0);

    signal mem_address_s        : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal w_r_s                : std_logic;
    signal data_from_mem_s      : std_logic_vector(DATA_WIDTH-1 downto 0);
    signal data_to_mem_s        : std_logic_vector(DATA_WIDTH-1 downto 0);


begin
    datapath_i: datapath
    port map (
        clk                     => clk,
        rst                     => rst,
        instruction             => instruction_s,
        instruction_type        => instruction_type_s,
        PC_sel_fetch            => PC_sel_fetch_s,
        en_PC_reg               => en_PC_reg_s,
        en_PC_current_IFID      => en_PC_current_IFID_s,
        en_instruction_IFID     => en_instruction_IFID_s,
        RD1_regfile             => RD1_regfile_s,
        RD2_regfile             => RD2_regfile_s,
        WR_regfile              => WR_regfile_s,
        en_regfile              => en_regfile_s,
        en_wb_reg_1             => en_wb_reg_1_s,
        en_PC_current_IDEX      => en_PC_current_IDEX_s,
        en_rs1                  => en_rs1_s,
        en_rs2                  => en_rs2_s,
        en_imm                  => en_imm_s,
        sel_A_alu               => sel_A_alu_s,
        sel_B_alu               => sel_B_alu_s,
        sel_forward_mux_A       => sel_forward_mux_A_s,
        sel_forward_mux_B       => sel_forward_mux_B_s,
        s1_alu                  => s1_alu_s,
        s2_alu                  => s2_alu_s,
        s3_alu                  => s3_alu_s,
        reg_pc_addr             => reg_pc_addr_s,
        en_wb_reg_2             => en_wb_reg_2_s,
        en_PC_jump              => en_PC_jump_s,
        en_alu_result           => en_alu_result_s,
        en_zero_exmem           => en_zero_exmem_s,
        en_mem_data             => en_mem_data_s,
        en_jump                 => en_jump_s,
        en_branch               => en_branch_s,
        en_wb_reg_3             => en_wb_reg_3_s,
        en_from_mem_memwb       => en_from_mem_memwb_s,
        en_from_alu_memwb       => en_from_alu_memwb_s,
        sel_wb_mux              => sel_wb_mux_s,
        en_WB_delay             => en_WB_delay_s,
        sel_forward_mem         => sel_forward_mem_s,
        PC_out                  => PC_s,
        MEM_address             => mem_address_s,
        MEM_data_in             => data_from_mem_s,
        MEM_data_out            => data_to_mem_s
    );


    control_unit_i: HW_CU 
    port map (
        instr                   => instruction_coded_s,
        clk                     => clk,
        rst                     => rst,
        stall_hazard            => stall_hazard_s,
        stall_mem               => stall_mem_s,
        stall_fetch             => stall_fetch_s,
        PC_sel_fetch            => PC_sel_fetch_s,
        en_PC_reg               => en_PC_reg_s,
        en_PC_current_IFID      => en_PC_current_IFID_s,
        en_instruction_IFID     => en_instruction_IFID_s,
        RD1_regfile             => RD1_regfile_s,
        RD2_regfile             => RD2_regfile_s,
        en_regfile              => en_regfile_s,
        en_wb_reg_1             => en_wb_reg_1_s,
        en_PC_current_IDEX      => en_PC_current_IDEX_s,
        en_rs1                  => en_rs1_s,
        en_rs2                  => en_rs2_s,
        en_imm                  => en_imm_s,
        sel_A_alu               => sel_A_alu_s,
        sel_B_alu               => sel_B_alu_s,
        s1_alu                  => s1_alu_s,
        s2_alu                  => s2_alu_s,
        s3_alu                  => s3_alu_s,
        reg_pc_addr             => reg_pc_addr_s,
        en_wb_reg_2             => en_wb_reg_2_s,
        en_PC_jump              => en_PC_jump_s,
        en_alu_result           => en_alu_result_s,
        en_zero_exmem           => en_zero_exmem_s,
        en_mem_data             => en_mem_data_s,
        read_write              => w_r_s,
        en_jump                 => en_jump_s,
        en_branch               => en_branch_s,
        en_wb_reg_3             => en_wb_reg_3_s,
        en_from_mem_memwb       => en_from_mem_memwb_s,
        en_from_alu_memwb       => en_from_alu_memwb_s,
        sel_wb_mux              => sel_wb_mux_s,
        WR_regfile              => WR_regfile_s,
        en_WB_delay             => en_WB_delay_s
        
    );

    instruction_conv_i: conv_inst 
    port map(
        rst => rst,
        instruction_in => instruction_s,
        instruction_out => instruction_coded_s,
        instruction_type => instruction_type_s
    );

    hazard_forward_unit_i: hazard_forward_unit
    port map(
        rst => rst,
        clk => clk,
        instruction => instruction_s,
        inst_type => instruction_coded_s,
        stall_in_fetch => stall_fetch_s,
        stall_in_mem => stall_mem_s,
        stall => stall_hazard_s,
        forward_A => sel_forward_mux_A_s,
        forward_B => sel_forward_mux_B_s
    );

    forward_mem_unit_i: forward_mem_unit
    port map(
        rst => rst,
        clk => clk,
        instruction => instruction_s,
        inst_type => instruction_coded_s,
        stall_in_fetch => stall_fetch_s,
        stall_in_mem => stall_mem_s,
        forward => sel_forward_mem_s
    );

    fetch_unit_i: fetch_unit 
    port map(
        clk => clk,
        rst => rst,
        pc => PC_s,
        stall => stall_fetch_s,
        instruction => instruction_s,
        ADDR => instr_ADDR,
        WE => instr_WE,
        WDATA => instr_WDATA,
        RDATA => instr_RDATA
    );

    mem_unit_i: mem_unit 
    port map(
        clk => clk,
        rst => rst,
        address => mem_address_s,
        stall => stall_mem_s,
        w_r => w_r_s,
        data_out => data_from_mem_s,
        data_in => data_to_mem_s,
        ADDR => mem_ADDR,
        WE => mem_WE,
        WDATA => mem_WDATA,
        RDATA => mem_RDATA
    );

end stru;