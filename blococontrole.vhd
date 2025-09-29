library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blococontrole is
    generic (
        G_DATA_WIDTH : integer := 32;   -- Largura em bits de cada número na memória
        G_MEM_SIZE   : integer := 100   -- Número de posições na memória
    );
    port (
        -- Entradas de controle e status
        clk                : in  std_logic;     -- Clock do sistema
        rst                : in  std_logic;     -- Reset
        start              : in  std_logic;     -- Sinal para iniciar a operação
        P                  : in  std_logic;     -- Critério de soma: 1=positivos, 0=negativos

        -- Entradas vindas do Bloco de Operadores
        i_mem_dado_signed  : in  signed(G_DATA_WIDTH - 1 downto 0);
        i_address_unsigned : in  unsigned(6 downto 0);

        -- Saídas de controle para o Bloco de Operadores
        o_en_sum_reg    : out std_logic;    -- Habilita o registrador de soma
        o_en_addr_reg   : out std_logic;    -- Habilita o registrador de endereço
        o_sel_adder_b   : out std_logic;    -- Seleciona a segunda entrada do somado
        o_clear_regs    : out std_logic;    -- Limpa os registradores
        o_done          : out std_logic     -- Sinaliza que a operação terminou
    );
end entity blococontrole;

architecture FSM of blococontrole is

    type T_STATE is (S_IDLE, S_READ_MEM, S_CALC_SUM, S_INC_ADDR, S_DONE);
    signal state_reg, next_state : T_STATE;

begin

    -- Processo 1: Registro do estado atual

    STATE_REGISTER_PROC : process(clk, rst)
    begin
        if rst = '1' then   -- Se o reset for ativado, a máquina volta para o estado inicial
            state_reg <= S_IDLE;
        elsif rising_edge(clk) then    -- Na borda de subida do clock, o estado atual recebe o próximo estado calculado
            state_reg <= next_state;
        end if;
    end process;

    -- Processo 2: Lógica de próximo estado e geração das saídas de controle

    COMBINATIONAL_LOGIC_PROC : process(state_reg, start, P, i_mem_dado_signed, i_address_unsigned)

        variable v_is_positive   : boolean;  -- Verdadeiro se o número lido for positivo
        variable v_condition_met : boolean;  -- Verdadeiro se a condição (P) for atendida

    begin

     -- Etapa 1: Definir valores padrão para todas as saídas.

        o_en_sum_reg  <= '0';
        o_en_addr_reg <= '0';
        o_sel_adder_b <= '0';
        o_clear_regs  <= '0';
        o_done        <= '0';
        next_state    <= state_reg;    -- Permanecer no mesmo estado

        -- Etapa 2: Lógica de verificação da condição

        v_is_positive   := (i_mem_dado_signed(G_DATA_WIDTH - 1) = '0');
        v_condition_met := (v_is_positive and P = '1') or (not v_is_positive and P = '0');

    -- Etapa 3: Lógica de decisão baseada no estado atual

        case state_reg is
            when S_IDLE =>
                o_clear_regs <= '1';
                if start = '1' then
                    next_state <= S_READ_MEM;
                end if;

            when S_READ_MEM =>
                next_state <= S_CALC_SUM;

            when S_CALC_SUM =>
                if v_condition_met then
                    o_sel_adder_b <= '1'; -- Usa o dado da memória na soma
                end if;
                o_en_sum_reg <= '1'; -- Habilita a atualização da soma
                
                -- Verifica se chegamos ao final da memória.
                if i_address_unsigned = (G_MEM_SIZE - 1) then
                    next_state <= S_DONE;
                else
                    -- Se não, avança para incrementar o endereço.
                    next_state <= S_INC_ADDR;
                end if;

            when S_INC_ADDR =>
                o_en_addr_reg <= '1'; -- Habilita a atualização do endereço
                next_state <= S_READ_MEM;

            when S_DONE =>
             -- Ativa o sinal 'done' para indicar que a soma terminou.
                o_done     <= '1';
            -- Permanece neste estado até que um reset ocorra.
                next_state <= S_DONE;
        end case;
    end process COMBINATIONAL_LOGIC_PROC;

end architecture FSM;