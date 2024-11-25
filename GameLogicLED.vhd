library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity GameLogicLED is
    port(
        RST : in std_logic;
        Clock : in std_logic;
        dir: in std_logic;
        pos : out std_logic_vector(3 downto 0);
        player_1_point: out std_logic_vector(3 downto 0);
        player_2_point: out std_logic_vector(3 downto 0);
        reset_speed: out std_logic := '0'
    );
end GameLogicLED;

architecture arch_GameLogicLED of GameLogicLED is
    signal current_pos: std_logic_vector(3 downto 0) := "1000"; -- start in the middle
    signal length : std_logic_vector(3 downto 0) := "1111";
    signal score1 : std_logic_vector(3 downto 0) := "0000";
    signal score2 : std_logic_vector(3 downto 0) := "0000";

begin
    process (Clock)
    begin
        if RST = '1' then
            score1 <= "0000";
            score2 <= "0000";
        end if;
        if (Clock'event and Clock = '1') then
            reset_speed <= '0';
            -- moves to the right
            if (dir = '1') then
                -- right border
                if (current_pos = length) then
                    reset_speed <= '1';
                    if score1 >= "1001" then
                        score1 <= "0000";
                        score2 <= "0000";
                    else
                        score1 <= score1 + 1;
                    end if;
                    current_pos <= "1000"; -- reset to middle
                else
                    current_pos <= current_pos + 1;
                end if;
            -- moves to the left
            else
                -- left border
                if (current_pos = 0) then
                    reset_speed <= '1';
                    if score2 >= "1001" then
                        score1 <= "0000";
                        score2 <= "0000";

                    else
                        score2 <= score2 + 1;
                    end if;
                    current_pos <= "1000"; -- reset to middle
                else
                    current_pos <= current_pos - 1;
                end if;
            end if;
        end if;
        -- return      
        pos <= current_pos;
        player_1_point <= score1;
        player_2_point <= score2;
    end process;

end arch_GameLogicLED;
