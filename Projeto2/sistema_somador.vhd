library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sistema_somador is
    generic (
        G_DATA_WIDTH : integer := 32;
        G_SUM_WIDTH  : integer := 39;
        G_MEM_SIZE   : integer := 100
    );
    port (
        -- Entradas e Saídas Globais
        clk         : in  std_logic;
        rst         : in  std_logic;
        start       : in  std_logic;
        P           : in  std_logic;
        mem_dado_in : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);  -- Entrada de 32 bits
        mem_end_out : out std_logic_vector(6 downto 0);     -- Saída de 7 bits
        soma_out    : out std_logic_vector(G_SUM_WIDTH - 1 downto 0);   -- Saída de 39 bits
        done        : out std_logic
    );
end entity sistema_somador;

architecture Structural of sistema_somador is

    -- Sinais de interconexão entre blococontrole e blocooperadores
    signal w_en_sum_reg       : std_logic;
    signal w_en_addr_reg      : std_logic;
    signal w_sel_adder_b      : std_logic;
    signal w_clear_regs       : std_logic;
    signal w_mem_dado_signed  : signed(G_DATA_WIDTH - 1 downto 0);
    signal w_address_unsigned : unsigned(6 downto 0);

begin

    -- Instância do Bloco de Controle
    U_BC: entity work.blococontrole(FSM)
        generic map (
            G_DATA_WIDTH => G_DATA_WIDTH,
            G_MEM_SIZE   => G_MEM_SIZE
        )
        port map (
            clk                => clk,
            rst                => rst,
            start              => start,
            P                  => P,
            i_mem_dado_signed  => w_mem_dado_signed,
            i_address_unsigned => w_address_unsigned,
            o_en_sum_reg       => w_en_sum_reg,
            o_en_addr_reg      => w_en_addr_reg,
            o_sel_adder_b      => w_sel_adder_b,
            o_clear_regs       => w_clear_regs,
            o_done             => done
        );

    -- Instância do Bloco de Operadores
    U_BO: entity work.blocooperadores(Structural)
        generic map (
            G_DATA_WIDTH => G_DATA_WIDTH,
            G_SUM_WIDTH  => G_SUM_WIDTH
        )
        port map (
            clk                => clk,
            rst                => rst,
            i_en_sum_reg       => w_en_sum_reg,
            i_en_addr_reg      => w_en_addr_reg,
            i_sel_adder_b      => w_sel_adder_b,
            i_clear_regs       => w_clear_regs,
            i_is_inc_addr      => w_is_inc_addr,
            i_mem_dado         => mem_dado_in,
            o_mem_end          => mem_end_out,
            o_soma             => soma_out,
            o_mem_dado_signed  => w_mem_dado_signed,
            o_address_unsigned => w_address_unsigned
        );

end architecture Structural;