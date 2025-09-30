library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity somador is
    generic (
        G_WIDTH : integer := 32 -- Largura dos dados
    );
    port (
        entrada1 : in  signed(G_WIDTH - 1 downto 0);
        entrada2 : in  signed(G_WIDTH - 1 downto 0);
        saida : out signed(G_WIDTH - 1 downto 0)
    );
end entity somador;

architecture Behavioral of somador is
begin
    saida <= entrada1 + entrada2;   -- A soma é atribuída a saída
end architecture Behavioral;