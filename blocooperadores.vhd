library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity blocooperadores is
    generic (
        G_DATA_WIDTH : integer := 32;
        G_SUM_WIDTH  : integer := 39 -- 32 (dado) + 7 (para 100 somas)
    );
    port (
        -- Sinais de controle vindos do BC
        clk          : in  std_logic;   -- Clock
        rst          : in  std_logic;   -- Reset
        i_en_sum_reg   : in  std_logic; -- Habilita a escrita no registrador de soma
        i_en_addr_reg  : in  std_logic; -- Habilita a escrita no registrador de endereço
        i_sel_adder_b  : in  std_logic; -- Seleciona o operando B do somador (dado ou zero)
        i_clear_regs   : in  std_logic; -- Limpa os registradores
        i_is_inc_addr  : in  std_logic; -- Informa que a operação atual é um incremento de endereço

        -- Interface com a Memória e Saídas
        i_mem_dado : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0); -- Dado vindo da memória
        o_mem_end  : out std_logic_vector(6 downto 0);                -- Endereço enviado para a memória
        o_soma     : out std_logic_vector(G_SUM_WIDTH - 1 downto 0);  -- Resultado da soma

        -- Saídas de status para o BC
        o_mem_dado_signed  : out signed(G_DATA_WIDTH - 1 downto 0);
        o_address_unsigned : out unsigned(6 downto 0)
    );
end entity blocooperadores;

architecture Structural of blocooperadores is
    -- Registradores
    signal sum_reg     : signed(G_SUM_WIDTH - 1 downto 0);  -- Armazena a soma acumulada
    signal address_reg : unsigned(6 downto 0);              -- Armazena o endereço de memória atual

    signal adder_in_a : signed(G_SUM_WIDTH - 1 downto 0);   -- Entrada 1 do somador
    signal adder_in_b : signed(G_SUM_WIDTH - 1 downto 0);   -- Entrada 2 do somador
    signal adder_out  : signed(G_SUM_WIDTH - 1 downto 0);   -- Saída do somador
begin
    -- Instância do componente Somador
    U_ADDER: entity work.somador(Behavioral)
        generic map (
            G_WIDTH => G_SUM_WIDTH  -- O somador precisa ter a largura máxima para acomodar a soma final
        )
        port map (
            A => adder_in_a,
            B => adder_in_b,
            S => adder_out
        );

  -- Registrador para a Soma Acumulada

    SUM_REG_PROC : process(clk, rst)
    begin
        if rst = '1' then
            sum_reg <= (others => '0'); -- Zera a soma
        elsif rising_edge(clk) then
            if i_clear_regs = '1' then
                sum_reg <= (others => '0'); -- Limpa a soma no início da operação
            elsif i_en_sum_reg = '1' then
                sum_reg <= adder_out;
            end if;
        end if;
    end process;

    -- Registrador para o Endereço de Memória

    ADDR_REG_PROC : process(clk, rst)
    begin
        if rst = '1' then
            address_reg <= (others => '0'); -- Zera o endereço
        elsif rising_edge(clk) then
            if i_clear_regs = '1' then
                address_reg <= (others => '0'); -- Limpa o endereço no início da operação
            elsif i_en_addr_reg = '1' then
                address_reg <= unsigned(adder_out(address_reg'range));
            end if;
        end if;
    end process;

    adder_in_a <= resize(signed(address_reg), G_SUM_WIDTH) when i_is_inc_addr = '1' else
                  sum_reg;

    adder_in_b <= resize(signed(i_mem_dado), G_SUM_WIDTH) when i_sel_adder_b = '1' else
                  to_signed(1, G_SUM_WIDTH)              when i_is_inc_addr = '1' else
                  to_signed(0, G_SUM_WIDTH);

    -- Conexão das saídas
    o_mem_end          <= std_logic_vector(address_reg);    -- Endereço atual para a memória
    o_soma             <= std_logic_vector(sum_reg);        -- Soma final
    o_mem_dado_signed  <= signed(i_mem_dado);               -- Fornece o dado para a FSM
    o_address_unsigned <= address_reg;                      -- Fornece o endereço para a FSM

end architecture Structural;