library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity LED_Loop is
    port(
        Clock : in std_logic;
        divider: in std_logic_vector(7 downto 0);
        CLK_out : out std_logic
    );
end LED_Loop;

architecture arch_LED_Loop of LED_Loop is
    signal divider_multiplicator : std_logic_vector(15 downto 0) := "0111111111111111";
    signal multiplicator_counter: std_logic_vector(15 downto 0) := "0000000000000000";

    signal counter: std_logic_vector(7 downto 0) := "00000000";
    signal old_divider: std_logic_vector(7 downto 0) := "00000000";

begin

    process (Clock, divider)
    begin
        -- Uses counter to only ouput every 8th, 16th (divider - lower is faster) Clock signal
        -- 'Clock signal divider'
        CLK_out <= '0';
        if (counter >= divider) then
            if not (old_divider = divider) then
                old_divider <= divider;
            end if;
            counter <= "00000000";
            multiplicator_counter <= multiplicator_counter + 1;
            if (multiplicator_counter = divider_multiplicator) then
                CLK_out <= '1';
                multiplicator_counter <= "0000000000000000";
            end if;
        elsif (Clock'event and Clock = '1') then
            counter <= counter + 1;
            ---> CLK_out <= '0';
        end if;
    end process;
end arch_LED_Loop;
