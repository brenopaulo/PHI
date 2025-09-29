library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_sistema_somador is
end entity tb_sistema_somador;

architecture test of tb_sistema_somador is
 
    constant C_CLK_PERIOD   : time    := 20 ns; -- Período do clock 
    constant C_DATA_WIDTH : integer := 32;
    constant C_SUM_WIDTH  : integer := 39;
    constant C_MEM_SIZE   : integer := 100;

    component sistema_somador is
        generic (
            G_DATA_WIDTH : integer;
            G_SUM_WIDTH  : integer;
            G_MEM_SIZE   : integer
        );
        port (
            clk         : in  std_logic;
            rst         : in  std_logic;
            start       : in  std_logic;
            P           : in  std_logic;
            mem_dado_in : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
            mem_end_out : out std_logic_vector(6 downto 0);
            soma_out    : out std_logic_vector(G_SUM_WIDTH - 1 downto 0);
            done        : out std_logic
        );
    end component;

    signal w_clk   : std_logic := '0';  -- Clock inicializado em '0'
    signal w_rst   : std_logic;
    signal w_start : std_logic;
    signal w_P     : std_logic;
    signal w_mem_dado : std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal w_mem_end  : std_logic_vector(6 downto 0);
    signal w_soma     : std_logic_vector(C_SUM_WIDTH - 1 downto 0);
    signal w_done     : std_logic;

    type T_MEM is array (0 to C_MEM_SIZE - 1) of std_logic_vector(C_DATA_WIDTH - 1 downto 0);
    signal fake_memory : T_MEM := (
        0      => std_logic_vector(to_signed(10, C_DATA_WIDTH)),   -- Positivo
        1      => std_logic_vector(to_signed(-5, C_DATA_WIDTH)),   -- Negativo
        2      => std_logic_vector(to_signed(20, C_DATA_WIDTH)),   -- Positivo
        3      => std_logic_vector(to_signed(-15, C_DATA_WIDTH)),  -- Negativo
        others => (others => '0')   -- O resto da memória é preenchido com zeros
    );
begin

    UUT: sistema_somador
        generic map (
            G_DATA_WIDTH => C_DATA_WIDTH,
            G_SUM_WIDTH  => C_SUM_WIDTH,
            G_MEM_SIZE   => C_MEM_SIZE
        )
        port map (
            clk         => w_clk,
            rst         => w_rst,
            start       => w_start,
            P           => w_P,
            mem_dado_in => w_mem_dado,
            mem_end_out => w_mem_end,
            soma_out    => w_soma,
            done        => w_done
        );

    -- inverte o valor de w_clk a cada meia período.
    w_clk <= not w_clk after C_CLK_PERIOD / 2;

    w_mem_dado <= fake_memory(to_integer(unsigned(w_mem_end)));

    stimulus_proc: process
    begin
        -- TESTE 1: SOMA DE NÚMEROS POSITIVOS (Resultado esperado: 10 + 20 = 30)
        report "INICIANDO TESTE DE SOMA DE POSITIVOS";
        w_rst <= '1';       -- 1. Ativa o reset
        w_start <= '0';
        w_P <= '1';        -- Configura para somar positivos
        wait for C_CLK_PERIOD * 2;
        w_rst <= '0';      -- 2. Libera o reset
        wait for C_CLK_PERIOD;
        w_start <= '1';    -- 3. Envia um pulso de 'start'
        wait for C_CLK_PERIOD;
        w_start <= '0';
        
        wait until w_done = '1';
        report "Teste de positivos finalizado. Soma = " & integer'image(to_integer(signed(w_soma)));
        wait for C_CLK_PERIOD * 5;    -- Espera um tempo extra antes do próximo teste

        -- TESTE 2: SOMA DE NÚMEROS NEGATIVOS (Resultado esperado: -5 + -15 = -20)
        report "INICIANDO TESTE DE SOMA DE NEGATIVOS";
        w_rst <= '1';       -- Repete a sequência de reset e start
        w_start <= '0';
        w_P <= '0';         -- Configura para somar negativos
        wait for C_CLK_PERIOD * 2;
        w_rst <= '0';
        wait for C_CLK_PERIOD;
        w_start <= '1';
        wait for C_CLK_PERIOD;
        w_start <= '0';

        wait until w_done = '1';
        report "Teste de negativos finalizado. Soma = " & integer'image(to_integer(signed(w_soma)));
        wait for C_CLK_PERIOD * 5;
        
        -- Fim da simulação
        report "FIM DOS TESTES";
        -- Comando para parar o simulador
        std.env.stop;
    end process;

end architecture test;