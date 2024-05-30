library IEEE;
use IEEE.std_logic_1164.all; --  libreria IEEE con definizione tipi standard logic
--use WORK.constants.all; -- libreria WORK user-defined
use IEEE.math_real.all; --Ã¨ giusto come libreria matematica?

entity Carry_LookAhead is
    generic (N : integer := 32;
            C : integer := 4);
    port(
        A, B: in std_logic_vector(N downto 1);
        C_in: in std_logic;      --NB: L'USO DI C_in NON E' STATO IMPLEMETATO
        C_out: out std_logic_vector((N/C) downto 1)        
    );
end Carry_LookAhead;



architecture STRUCT1 of Carry_LookAhead is

    constant FIRST_BLOCK:  integer := integer(ceil(log2(real(C))));
    constant SECOND_BLOCK: integer := integer(ceil(log2(real(N)))) - FIRST_BLOCK;
    constant DIST_BWT_BLOCKS: integer := C;
    constant n_of_rows: integer := integer(ceil(log2(real(N))));

    --array dei segnali
    --                N e non N-1 perchÃ¨ c'Ã¨ anche il segnale per la rete p-g (0)
    --                          \/
    type SignalVector is array (n_of_rows downto 0) of std_logic_vector(N downto 1);
    signal p_matrix: SignalVector;
    signal g_matrix: SignalVector;
    signal Z: std_logic_vector(N downto 1);




    component p_g
        port(
            a, b: in std_logic;
            p, g: out std_logic
        );
    end component;

    component G
        port(
            P_i_k, G_i_k: in std_logic;
            G_k_j: in std_logic;
            G_i_j: out std_logic
        );
    end component;

    component PG
        port(
            P_i_k, G_i_k: in std_logic;
            P_k_j, G_k_j: in std_logic;
            P_i_j, G_i_j: out std_logic
        );
    end component;



    begin
            xor_generate : for i in 1 to N generate

                Z(i) <= C_in xor B(i);

            end generate xor_generate; 
                   
            --i segnali di uscita dalla rete p-g sono asseganti al livello 0 delle reciproche matrici di segnali
            --in questo modo, quando nel primo blocco si useranno i segnali della riga riga_attuale-1, la prima riga
            --userÃ  automaticamente i seganli dalla rete p-g

            pg_generate: for i in 1 to N generate     --generating p-g network
                first_block: if (i = 1) generate
                    --p <= a xor b 
                    --g <= a and b;
                    --                              g1 + (p1 and C_in)
                    g_matrix(0)(1) <= ((A(1) and Z(1)) or ((A(1) xor Z(1)) and C_in));
                end generate first_block;
                not_first_block: if(i /= 1) generate
                    pg_i : p_g port map(
                        a => A(i), b => Z(i), p => p_matrix(0)(i), g => g_matrix(0)(i) 
                    );
                end generate not_first_block;
            end generate pg_generate;

            --first block: le prime x righe, dove x = log2(carry) +1, hanno un comportamento diverso, quindi vwngono generate separatamente
            --ogni blocco e' formato dall'unione di due blocchi appartenenti alla linea superiore, contigui fra loro
            --solo il primo blocco e' un blocco G, gli altri sono PG
            --per identificare il primo blocco, si verifica se l'indice è esattamente il valore esponente di 2 della riga (2^i)
            --la contiguita' e' una distanza tra un blocco e il suo precedente di esattamente distance unita' ; quindi serve una variabile distanza precdente
            --perche' quando mi servono i segnali dei due genitori, sono alla riga seguente (distanza aumentata); il figlio usa il segnale del padre "di sinistra"
            --(che appartiene alla sua stessa colonna) e il segnale del padre di destra, che e' distante quanto la distanza della riga precedente dal padre di sinistra

            
            fb: for i in 1 to FIRST_BLOCK generate

                row_generate: for j in 1 to N generate
                    
                        
                    dist_if: if (j mod 2 ** i) = 0 generate
                        g_if: if j = (2**i) generate --crea blocco G
                                G_block: G port map(
                                P_i_k => p_matrix(i-1)(j), G_i_k => g_matrix(i-1)(j), G_k_j => g_matrix(i-1)(j-2 ** (i-1)), G_i_j => g_matrix(i)(j)
                                --                 /\                         /\                                    /\
                                --tutti i genitori appartengono alla riga precedente = i-1      il padre di destra, Ã¨ distante distance_pre dalla colnna attuale
                            );    
                        end generate;
                        pg_if: if j /= (2**i) generate
                            PG_block: PG port map(
                                P_i_k => p_matrix(i-1)(j), G_i_k => g_matrix(i-1)(j), P_k_j => p_matrix(i-1)(j-2 ** (i-1)), G_k_j => g_matrix(i-1)(j-2 ** (i-1)), P_i_j => p_matrix(i)(j), G_i_j => g_matrix(i)(j)
                            );
                            
                        end generate;
                    end generate;
                    propagate_sgn: if (((j mod 2 ** i) /= 0) and (j mod C) = 0) generate
                        --se la colonna Ã¨ un multilpo del carry (quindi dovrÃ  essere propagat, ad un certo punto) e non Ã¨ stato creato alcun nodo in questa riga, comunque il suo segnale viene propagato alla linea successiva
                        --in queto modo, l'accesso "verticale" del secondo blocco avviene sempre sulla linea subito superiore
                        p_matrix(i)(j) <= p_matrix(i-1)(j) when (j mod C) = 0;
                        g_matrix(i)(j) <= g_matrix(i-1)(j) when (j mod C) = 0;

                    end generate;

                end generate ;

            end generate fb;
            
            --second block: gli elementi ora sono presenti a gruppi, abbiamo nuove variabili: il numero di elementi per gruppo, la distanza tra gli elementi del gruppo, la distanza tra gruppi
	        --	-numero di elementi per gruppo: raddoppia ad ogni riga, quindi 2^riga; il primo blocco ï¿½ costituito da tutti G
            --	-distanza tra i blocchi nel gruppo: SEMPRE LA STESSA: carry/2 [NB: carry/2 se parliamo di numero di blocchi, altrimenti come numero di bit ï¿½ esattamente = carry]
            --	-distanza tra gruppi: (ï¿½ anche la distanza del primo blocco dall'inizio): 2^(n_elem_primo_blocco + indice di riga - 1) + distanza tra i blocchi (fa riferimenti così all'ultimo dei blocchi della riga
            --                          precedente, al quale si aggiunge un distanza)
            --	              
            --serve comunque la finestra: 	|			finestra		|
            --								|-blocchi-| + |: distanza :|
            --l'ampiezza della finestra ï¿½ 2^L con L = riga complessiva, primo + secondo blocco

            --l'indice del padre destro è calcolato come indice di colonna mod primo blocco G padre della riga, diviso per il carry (in realtà il diviso per il carry si può togliere, dal momento che le unità di distanza vanno moltiplicate per il carry, ovvero la distazna tra i nodi): 
            --questo da le "unità di distanza" del figlio dal padre, e può esere calcolato in linea
            --unica eccezione, che deve essere verificata prima del generate, l'ultimo nodo: è sempre esattamente divisibile per il carry, quindi il suo modulo darà come risultato 0;
            --questa condizione va verificata prima di generare il nodo: se il modulo è zero, allora la distanza dal padre è massima
            	
            
            sb: for i in 1 to SECOND_BLOCK generate
                --window := 2 ** (FIRST_BLOCK + i);       -- finestra alla riga, tiene conto delle righe del primo blocco
                --flagG := 0;                           --al posto di usare flagG, verifichiamo se l'indice è minore di 2^ riga totale; se è così, il blocco da creare è G
                --distance := 2 ** (FIRST_BLOCK + i - 1) + DIST_BWT_BLOCKS; 
                --elem_x_block := 2 ** i;
                --counter := 0;

                row_generate: for j in 1 to N generate
                    --      questo per verificare ultimo elemento             questo per verificare gli elementi dopo il vuoto
                    --                      \/                                                                 \/
                    pos_check: if ( ((j mod (2 ** (FIRST_BLOCK + i)) = 0) or (j mod (2 ** (FIRST_BLOCK + i) )) >= (2 ** (FIRST_BLOCK + i - 1) + DIST_BWT_BLOCKS)) and ((j mod C) = 0 )) generate         

                        g_if_2: if (j <= (2 ** (FIRST_BLOCK + i))) generate 
                            last_g: if (j mod 2 ** (FIRST_BLOCK + i - 1) = 0) generate --ultimo elemento del blocco, il padre destro è alla distanza massima
                                G_block: G port map( --                                                                                                               distanza massima
                                    P_i_k => p_matrix(FIRST_BLOCK + i-1)(j), G_i_k => g_matrix(FIRST_BLOCK + i-1)(j), G_k_j => g_matrix(FIRST_BLOCK + i-1)(j- ( 2 ** (FIRST_BLOCK + i - 1) ) ), G_i_j => g_matrix(FIRST_BLOCK + i)(j)
                                ); 
                            end generate;
                            other_g: if (j mod 2 ** (FIRST_BLOCK + i - 1) /= 0) generate
                                G_block: G port map( --                                                                                            j = indice di colonna   mod   2^ riga precedente
                                    P_i_k => p_matrix(FIRST_BLOCK + i-1)(j), G_i_k => g_matrix(FIRST_BLOCK + i-1)(j), G_k_j => g_matrix(FIRST_BLOCK + i-1)(j- (j mod 2 ** (FIRST_BLOCK + i - 1) ) ), G_i_j => g_matrix(FIRST_BLOCK + i)(j)
                                );                            
                            end generate ;
                        end generate;
                        pg_if_2: if (j > (2 ** (FIRST_BLOCK + i))) generate 
                           last_pg: if (j mod 2 ** (FIRST_BLOCK + i - 1) = 0) generate --ultimo elemento del blocco, il padre destro è alla distanza massima
                                PG_block: PG port map(--                                                                                                          distanza massima                                                          di nuovo distanza massima
                                    P_i_k => p_matrix(FIRST_BLOCK + i-1)(j), G_i_k => g_matrix(FIRST_BLOCK + i-1)(j), P_k_j => p_matrix(FIRST_BLOCK + i-1)(j- (2 ** (FIRST_BLOCK + i - 1)) ), G_k_j => g_matrix(FIRST_BLOCK + i-1)(j- (2 ** (FIRST_BLOCK + i - 1)) ), P_i_j => p_matrix(FIRST_BLOCK + i)(j), G_i_j => g_matrix(FIRST_BLOCK + i)(j)
                                );
                            end generate;
                            other_pg: if (j mod 2 ** (FIRST_BLOCK + i - 1) /= 0) generate
                                PG_block: PG port map(
                                    P_i_k => p_matrix(FIRST_BLOCK + i-1)(j), G_i_k => g_matrix(FIRST_BLOCK + i-1)(j), P_k_j => p_matrix(FIRST_BLOCK + i-1)(j- (j mod 2 ** (FIRST_BLOCK + i - 1) ) ), G_k_j => g_matrix(FIRST_BLOCK + i-1)(j- (j mod 2 ** (FIRST_BLOCK + i - 1) ) ), P_i_j => p_matrix(FIRST_BLOCK + i)(j), G_i_j => g_matrix(FIRST_BLOCK + i)(j)
                                );
                            end generate;

                        end generate ;

                    end generate;
                    propagate_sgn_2: if ((j mod (2 ** (FIRST_BLOCK + i)) /= 0) and (j mod (2 ** (FIRST_BLOCK + i) )) < (2 ** (FIRST_BLOCK + i - 1) + DIST_BWT_BLOCKS) and ((j mod C) = 0 )) generate
                    
                        --stesso discorso del primo blocco, propago le linee multiple del carry
                        
                         p_matrix(i+FIRST_BLOCK)(j) <= p_matrix(i+FIRST_BLOCK-1)(j) when (j mod C) = 0;
                         g_matrix(i+FIRST_BLOCK)(j) <= g_matrix(i+FIRST_BLOCK-1)(j) when (j mod C) = 0;
                        

                    end generate ;
                
                end generate row_generate;

            end generate;

    
        c_out_assign : for i in 1 to N/C generate
            --dal momento che tutti i multipli di Carry sono stati propagati verso il basso, saranno tutti alla linea finale
                            C_out(i) <= g_matrix(n_of_rows)(C * i);
            end generate;


end STRUCT1;