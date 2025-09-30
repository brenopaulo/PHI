-- top_level.vhd
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level is
    Port (
        A, B       : in  std_logic_vector(7 downto 0);
        sel        : in  std_logic; -- 0 = A→S1, B→S2; 1 = B→S1, A→S2
        S1, S2     : out std_logic_vector(6 downto 0)
    );
end top_level;

architecture Structural of top_level is
    signal a_mux, b_mux : std_logic_vector(7 downto 0);

    component ascii_para_7seg
        Port (
            caractere_ascii : in std_logic_vector(7 downto 0);
            saida_seg       : out std_logic_vector(6 downto 0)
        );
    end component;

begin
    -- MUX para inverter entradas baseado em sel
    a_mux <= A when sel = '0' else B;
    b_mux <= B when sel = '0' else A;

    -- Instância 1
    conv1: ascii_para_7seg port map (
        caractere_ascii => a_mux,
        saida_seg       => S1
    );

    -- Instância 2
    conv2: ascii_para_7seg port map (
        caractere_ascii => b_mux,
        saida_seg       => S2
    );

end Structural;