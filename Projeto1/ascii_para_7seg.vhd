-- conversor.vhd (Versão final corrigida)
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ascii_para_7seg is
    Port (
        caractere_ascii : in  std_logic_vector(7 downto 0);
        saida_seg       : out std_logic_vector(6 downto 0)
    );
end ascii_para_7seg;

architecture Behavioral of ascii_para_7seg is
begin
    process(caractere_ascii)
    begin
        case caractere_ascii is
            when x"30" => saida_seg <= "0000001"; -- '0'
            when x"31" => saida_seg <= "1001111"; -- '1'
            when x"32" => saida_seg <= "0010010"; -- '2'
            when x"33" => saida_seg <= "0000110"; -- '3'
            when x"34" => saida_seg <= "1001100"; -- '4'
            when x"35" => saida_seg <= "0100100"; -- '5'
            when x"36" => saida_seg <= "0100000"; -- '6'
            when x"37" => saida_seg <= "0001111"; -- '7'
            when x"38" => saida_seg <= "0000000"; -- '8'
            when x"39" => saida_seg <= "0000100"; -- '9'
            when x"41" => saida_seg <= "0001000"; -- 'A'
            when x"42" => saida_seg <= "1100000"; -- 'B'
            when x"43" => saida_seg <= "0110001"; -- 'C'
            when x"44" => saida_seg <= "1000010"; -- 'D'
            when x"45" => saida_seg <= "0110000"; -- 'E'
            when x"46" => saida_seg <= "0111000"; -- 'F'
            when x"2D" => saida_seg <= "1111101"; -- '-'
            when others => saida_seg <= "1111111";
        end case;
    end process;
end Behavioral;