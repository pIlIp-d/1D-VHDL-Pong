library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity display_7seg is
    Port ( num : in STD_LOGIC_VECTOR(3 downto 0);
           seg : out STD_LOGIC_VECTOR(6 downto 0));
end display_7seg;

architecture Behavioral of display_7seg is
begin
    process(num)
    begin
        case num is
            when "0000" => seg <= "1000000"; 
            when "0001" => seg <= "1111001"; 
            when "0010" => seg <= "0100100"; 
            when "0011" => seg <= "0110000"; 
            when "0100" => seg <= "0011001"; 
            when "0101" => seg <= "0010010"; 
            when "0110" => seg <= "0000010"; 
            when "0111" => seg <= "1111000"; -- 7
            when "1000" => seg <= "0000000"; -- 8
            when "1001" => seg <= "0010000"; -- 9
            when others => seg <= "1111111"; -- Display off
        end case;
    end process;
end Behavioral;