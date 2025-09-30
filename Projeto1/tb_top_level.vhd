library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_top_level is
end tb_top_level;

architecture test of tb_top_level is
    signal A, B     : std_logic_vector(7 downto 0);
    signal sel      : std_logic;
    signal S1, S2   : std_logic_vector(6 downto 0);

    component top_level
        Port (
            A, B       : in  std_logic_vector(7 downto 0);
            sel        : in  std_logic;
            S1, S2     : out std_logic_vector(6 downto 0)
        );
    end component;

begin
    DUT: top_level port map (
        A => A,
        B => B,
        sel => sel,
        S1 => S1,
        S2 => S2
    );

    process
    begin
        -- Teste 1: swap desligado
        A <= x"34"; -- '4'
        B <= x"41"; -- 'A'
        sel <= '0';
        wait for 10 ns;

        -- Teste 2: swap ligado
        sel <= '1';
        wait for 10 ns;

        -- Teste 3: outros caracteres
        A <= x"35"; -- '5'
        B <= x"39"; -- '9'
        sel <= '0';
        wait for 10 ns;

        wait;
    end process;
end test;
