library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity GAME is
    port(
        clk : in std_logic;
        btn_player1: in std_logic;
        btn_player2: in std_logic;
        RST: in std_logic;
        seg:out std_logic_vector(6 downto 0);
        an: out std_logic_vector(3 downto 0);
        led : out std_logic_vector(15 downto 0)
    );
end GAME;

architecture GAME_arch of GAME is
    component LED_Loop
        port (
            Clock : in std_logic;
            divider: in std_logic_vector(7 downto 0);
            CLK_out : out std_logic
        );
    end component;
    component GameLogicLED
        port (
            RST : in std_logic;
            Clock : in std_logic;
            dir: in std_logic;
            pos : out std_logic_vector(3 downto 0);
            player_1_point: out std_logic_vector(3 downto 0);
            player_2_point: out std_logic_vector(3 downto 0);
            reset_speed: out std_logic
        );
    end component;

    component score_display port (
            clk      : in STD_LOGIC;  -- Input clock
            display0 : in std_logic_vector(3 downto 0);
            display1 : in std_logic_vector(3 downto 0);
            display2 : in std_logic_vector(3 downto 0);
            display3 : in std_logic_vector(3 downto 0);
            segment  : out std_logic_vector(6 downto 0); -- 7-segment output
            anode    : out std_logic_vector(3 downto 0)  -- Anode contro
        );
    end component;

    signal divider : std_logic_vector(7 downto 0) := "11111111";

    signal CLK_out : std_logic := '0';

    signal reset_speed: std_logic := '0';
    signal current_dir: std_logic := '1';
    signal add_player_1_point: std_logic := '0';

    signal add_player_2_point: std_logic := '0';
    signal led_states: std_logic_vector(3 downto 0) := "1000";

    signal score_player1 : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal score_player2 : STD_LOGIC_VECTOR(3 downto 0) := "0000";


begin
    gameLoop: LED_Loop port map (
            Clock => clk,
            divider => divider,
            CLK_out => CLK_out
        );
    gameLogic : GameLogicLED port map (
            RST => RST,
            Clock => CLK_out,
            dir => current_dir,
            pos => led_states,
            player_1_point => score_player1,
            player_2_point => score_player2,
            reset_speed => reset_speed
        );


    score_DISP: score_display port map (
            clk      => clk,
            display0 => score_player2, -- Muestra el puntaje del jugador 1
            display1 => "0000", -- Muestra el puntaje del jugador 2
            display2 => score_player1,        -- Opcional, dependiendo de la lógica del juego
            display3 => "0000",        -- Opcional, dependiendo de la lógica del juego
            segment  => seg,
            anode    => an
        );

    process (clk , btn_player1, btn_player2)
    begin
        if clk'event and clk = '1' then
            if current_dir = '1' and btn_player2 = '1' and led_states >= "1000" then
                current_dir <= not current_dir;
                
                case led_states is
                    when "1111" => divider <= "00111111";
                    when "1110" => divider <= "01111111";
                    when "1101" => divider <= "01111111";
                    when "1100" => divider <= "10111111";
                    when "1011" => divider <= "10111111";
                    when "1010" => divider <= "10111111";
                    when "1001" => divider <= "11111111";
                    when "1000" => divider <= "11111111";
                    when "0111" => divider <= "11111111";
                    when others => divider <= "11111111";
                end case;
            elsif (current_dir = '0') and btn_player1 = '1' and led_states <= "1000" then
                current_dir <= not current_dir;

                case led_states is
                    when "0000" => divider <= "00111111";
                    when "0001" => divider <= "01111111";
                    when "0010" => divider <= "01111111";
                    when "0011" => divider <= "10111111";
                    when "0100" => divider <= "10111111";
                    when "0101" => divider <= "10111111";
                    when "0110" => divider <= "11111111";
                    when "0111" => divider <= "11111111";
                    when "1000" => divider <= "11111111";
                    when others => divider <= "11111111";
                end case;
            end if;

            if (reset_speed = '1') then
                divider <= "11111111"; -- reset to minimum speed/max divider
            end if;
        end if;

    end process;

    process (led_states)
    begin
        case led_states is
            when "0000" => led <= "1000000000000000";
            when "0001" => led <= "0100000000000000";
            when "0010" => led <= "0010000000000000";
            when "0011" => led <= "0001000000000000";
            when "0100" => led <= "0000100000000000";
            when "0101" => led <= "0000010000000000";
            when "0110" => led <= "0000001000000000";
            when "0111" => led <= "0000000100000000";
            when "1000" => led <= "0000000010000000";
            when "1001" => led <= "0000000001000000";
            when "1010" => led <= "0000000000100000";
            when "1011" => led <= "0000000000010000";
            when "1100" => led <= "0000000000001000";
            when "1101" => led <= "0000000000000100";
            when "1110" => led <= "0000000000000010";
            when "1111" => led <= "0000000000000001";
            when others => led <= "1111111111111111";
        end case;
    end process;

end GAME_arch;