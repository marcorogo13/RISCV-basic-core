library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.mypackage.all;

entity hazard_forward_unit is
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
end hazard_forward_unit;


architecture Behavioral of hazard_forward_unit is

    --comportamento base:
        --in caso di jump o branch (BGE, BLTU, JAL, JALR), si stalla sempre
        --in caso di operazioni con destinazione, si valuta il forwarding; se non è possibile, si stalla
        --le operazioni con destinazione sono: ADD, SUB, ADDI, LUI, LW); 
        --lo stallo avviene nel caso di LW, con uso immediatamente successivo del dato
        --da valutare l'istruzione auipc: scrive nel Program Counter, come si gestisce?

    signal previus_dest_reg_1:      std_logic_vector(5 downto 0);
    signal previus_inst_type_1:     INST;
    signal previus_dest_reg_2:      std_logic_vector(5 downto 0);
    signal previus_inst_type_2:     INST;
    signal previus_dest_reg_3:      std_logic_vector(5 downto 0);
    signal previus_inst_type_3:     INST;

    --forse i tipi di istruzioni precedenti oltre a quella prima non servono

    signal current_dest_reg:      std_logic_vector(5 downto 0); 
    signal current_source_reg_1:  std_logic_vector(5 downto 0); 
    signal current_source_reg_2:  std_logic_vector(5 downto 0); 


    -- combinational to sequential signals
    signal forward_A_comb:       std_logic_vector(1 downto 0);
    signal forward_B_comb:       std_logic_vector(1 downto 0);
    signal forward_A_delayed:    std_logic_vector(1 downto 0);
    signal forward_B_delayed:    std_logic_vector(1 downto 0);

    -- flush after stall for branch
    signal flush:                std_logic;


begin

    startup: process(rst, instruction)
        begin
            if (Rst = '1') then
               
                current_dest_reg <= (others => '0');       --Spostate qua le assegnazioni iniziali
                current_source_reg_1 <= (others => '0');
                current_source_reg_2 <= (others => '0');
            else
                current_dest_reg <= '0' & instruction(11 downto 7);       --Spostate qua le assegnazioni iniziali
                current_source_reg_1 <= '0' & instruction(19 downto 15);
                current_source_reg_2 <= '0' & instruction(24 downto 20);
            end if;
    end process startup;
                    
    

    Hazard_evaluation: process(rst, current_dest_reg, current_source_reg_1, current_source_reg_2, inst_type, previus_dest_reg_1, previus_inst_type_1, previus_dest_reg_2, previus_inst_type_2, previus_dest_reg_3, previus_inst_type_3 )
        begin
            
            forward_A_comb <= "00";
            forward_B_comb <= "00";
            stall <= '0';
            flush <= '0';

            --per la gestione degli stalli a causa di branch/jump: si continua a stallare per 3 cicli di clock dopo aver rilevato (verificare che sia il numero di clock giusto)
            --la cosa è ottenuta semplicemente verificando se le istruzioni precedenti sono branch/jump, nel caso, si continua a stallare
            if (inst_type = BGE or inst_type = BLTU or inst_type = JAL or inst_type = JALR) then
                stall <= '1';
            end if;
            if (previus_inst_type_3 = BGE or previus_inst_type_3 = BLTU or previus_inst_type_3 = JAL or previus_inst_type_3 = JALR) then
                stall <= '0';
                flush <= '1';
            end if;

            --penso che siano sufficenti come clock, dovrebbero essere 3 clock di stallo, non dovrebbe servire controllare anche la successiva

            --fine gestione stalli per branch/jump, inizio gestione forwarding
                --MODIFICA: LE ISTRUZIONI DI TIPO I NON DEVONO GUARDARE IL SOURCE REG 2, PERFCHÈ CONTIENE PARTE DELL'IMMEDIATO, NON UN REGISTRO
        
            if (inst_type = ADD or inst_type = SUB or inst_type = LUI or inst_type = BGE or inst_type = JAL or inst_type = JALR or inst_type = BLTU or inst_type = BLE) then
                --i controlli vanno fatti dall'istruzione più indietro alla più avanti, in modo che un hazard più vicino abbia la precedenza di forward 
                
                --forwording da 3 istruzioni fa
                if ( previus_dest_reg_3 = current_source_reg_1 and current_source_reg_1 /= "000000" ) then
                    forward_A_comb <= "11";
                end if;
                if (previus_dest_reg_3 = current_source_reg_2 and current_source_reg_2 /= "000000") then
                    forward_B_comb <= "11";
                end if;

                --forwording da 2 istruzioni fa
                if ( previus_dest_reg_2 = current_source_reg_1 and current_source_reg_1 /= "000000") then
                    forward_A_comb <= "10";
                end if;
                if ( previus_dest_reg_2 = current_source_reg_2 and current_source_reg_2 /= "000000") then
                    forward_B_comb <= "10";
                end if;
                
                --forwording da 1 istruzione fa, necessario controllare se l'istruzione precedente è una load
                if ( previus_inst_type_1 /= LW ) then                       --istruzione precedente non load, possibile fare forward
                    if ( previus_dest_reg_1 = current_source_reg_1 and current_source_reg_1 /= "000000") then
                        forward_A_comb <= "01";
                    end if;
                    if ( previus_dest_reg_1 = current_source_reg_2 and current_source_reg_2 /= "000000") then
                        forward_B_comb <= "01";
                    end if;
                --se è una load, non posso fare forward, devo verificare, se sono usati gli stessi registri è necessario stallare
                elsif ((current_source_reg_1 = previus_dest_reg_1 and current_source_reg_1 /= "000000") or (current_source_reg_2 = previus_dest_reg_1 and current_source_reg_2 /= "000000")) then --istruzione precedente load, rischio di stallo
                    stall <= '1';
                end if; 

                --gestione tipo I: esattamente come sopra, ma senza guardare il source reg 2

            elsif (inst_type = ADDI or inst_type = LW) then
                --forwording da 3 istruzioni fa
                if ( previus_dest_reg_3 = current_source_reg_1 and current_source_reg_1 /= "000000") then
                    forward_A_comb <= "11";
                end if;

                --forwording da 2 istruzioni fa
                if ( previus_dest_reg_2 = current_source_reg_1 and current_source_reg_1 /= "000000") then
                    forward_A_comb <= "10";
                end if;
                
                --forwording da 1 istruzione fa, necessario controllare se l'istruzione precedente è una load
                if ( previus_inst_type_1 /= LW ) then                       --istruzione precedente non load, possibile fare forward
                    if ( previus_dest_reg_1 = current_source_reg_1 and current_source_reg_1 /= "000000") then
                        forward_A_comb <= "01";
                    end if;
                --se è una load, non posso fare forward, devo verificare, se sono usati gli stessi registri è necessario stallare
                elsif (current_source_reg_1 = previus_dest_reg_1 and current_source_reg_1 /= "000000") then --istruzione precedente load, rischio di stallo
                    stall <= '1';
                end if;                   
            end if;


    end process Hazard_evaluation;


    sequential_forwarding: process(rst, clk)
        begin
            if (Rst = '1') then
                forward_A <= "00";
                forward_B <= "00";
                forward_A_delayed <= "00";
                forward_B_delayed <= "00";
            elsif (rising_edge(Clk)) then
                forward_A_delayed <= forward_A_comb;
                forward_B_delayed <= forward_B_comb;
                forward_A <= forward_A_delayed;
                forward_B <= forward_B_delayed;
            end if;
    end process sequential_forwarding;


    Propagation: process( clk, rst, stall_in_fetch, stall_in_mem )
        begin
            if (Rst = '1') then

                previus_dest_reg_1 <= (others => '1');
                previus_inst_type_1 <= VOID;
                previus_dest_reg_2 <= (others => '1');
                previus_inst_type_2 <= VOID;
                previus_dest_reg_3 <= (others => '1');
                previus_inst_type_3 <= VOID;
            elsif (rising_edge(Clk) and stall_in_fetch = '0' ) then
                if (flush = '0') then --and stall_in_mem = '0'
                    previus_dest_reg_1 <= current_dest_reg;
                    previus_inst_type_1 <= inst_type;
                    previus_dest_reg_2 <= previus_dest_reg_1;
                    previus_inst_type_2 <= previus_inst_type_1;
                    previus_dest_reg_3 <= previus_dest_reg_2;
                    previus_inst_type_3 <= previus_inst_type_2;
                else
                    previus_dest_reg_1 <= (others => '1');
                    previus_inst_type_1 <= VOID;
                    previus_dest_reg_2 <= (others => '1');
                    previus_inst_type_2 <= VOID;
                    previus_dest_reg_3 <= (others => '1');
                    previus_inst_type_3 <= VOID;
                end if;
            end if;

    end process Propagation;





end Behavioral;