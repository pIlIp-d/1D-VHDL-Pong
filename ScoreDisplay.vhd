library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity score_display is
    Port (
        clk      : in STD_LOGIC;  -- Input clock
        display0 : in std_logic_vector(3 downto 0);
        display1 : in std_logic_vector(3 downto 0);
        display2 : in std_logic_vector(3 downto 0);
        display3 : in std_logic_vector(3 downto 0);
        segment  : out std_logic_vector(6 downto 0); -- 7-segment output
        anode    : out std_logic_vector(3 downto 0)  -- Anode control
    );
end score_display;

architecture Behavioral of score_display is

    component display_7seg is 
        port (
            num : in STD_LOGIC_VECTOR(3 downto 0);
            seg : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    signal clk_div : std_logic_vector(19 downto 0) := (others => '0'); -- Clock divider
    signal slow_clk : std_logic := '0'; -- Slow clock
    signal counter : std_logic_vector(1 downto 0) := "00"; -- 2-bit counter
    signal display_value : std_logic_vector(3 downto 0); -- Current digit to display
    signal anode_temp : std_logic_vector(3 downto 0); -- Temporary anode signal

begin
    -- Clock Divider Process
    process(clk)
    begin
        if rising_edge(clk) then
            clk_div <= clk_div + 1;
            slow_clk <= clk_div(17); -- Use MSB as slow clock
        end if;
    end process;

    -- Multiplexing Process
    process(slow_clk)
    begin
        if rising_edge(slow_clk) then
            counter <= counter + 1;
            case counter is
                when "00" =>
                    anode_temp <= "1110";
                    display_value <= display0;
                when "01" =>
                    anode_temp <= "1101";
                    display_value <= display1;
                when "10" =>
                    anode_temp <= "1011";
                    display_value <= display2;
                when "11" =>
                    anode_temp <= "0111";
                    display_value <= display3;
                when others =>
                    anode_temp <= "1111"; -- All off
            end case;
        end if;
    end process;

    -- Instantiate the 7-segment decoder
    display_a: display_7seg port map(
        num => display_value, 
        seg => segment
    );

    -- Assign anode signals
    anode <= anode_temp;

end Behavioral;

