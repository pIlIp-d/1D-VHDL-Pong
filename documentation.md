# **Project Documentation**  

## **Index**  
1. [Introduction](#introduction)  
2. [Project Structure](#project-structure)  
3. [Description of Files and Folders](#description-of-files-and-folders)  
4. [Code Explanation](#code-explanation)  
   - [Ports declaration](#Ports-declaration)  
   - [LED_Loop](#LED_Loop)
   - [GameLogicLED](#GameLogicLED)
   - [Game](#Game)
   - [DisplayDecoder](#DisplayDecoder)
   - [Basys3](#Basys3)
5. [Evidence](#evidence)  
6. [References](#references)
---

## **Introduction**  
Proporciona un resumen general del propósito de este documento.  
- ¿Qué busca explicar?  
- ¿Qué nivel de detalle se proporciona?  
- ¿A quién está dirigido (desarrolladores, usuarios finales, etc.)?  

> Este documento describe la funcionalidad y estructura del código fuente incluido en este repositorio. Su objetivo es ayudar a los desarrolladores a entender las partes clave del proyecto y cómo estas interactúan entre sí.  

---

## **Project Structure**  
Incluye una vista general de la estructura de archivos y carpetas del repositorio, con una breve explicación de su contenido.  

```plaintext
├── carpeta1/  
│   ├── archivo1.py  # Breve descripción  
│   ├── archivo2.py  # Breve descripción  
├── carpeta2/  
│   ├── archivo3.py  # Breve descripción  
├── README.md         # Instrucciones generales  
├── documentation.md  # Documentación detallada  
---
```
## **Description of Files and Folders**  
Explication:
- **Ports declaration**:
- **LED_Loop**:
- **GameLogicLED**:
- **Game**:
- **DisplayDecoder**:
- **Basys3**:

## **Code Explanation**  
### **LED Loop**
Code for [LED_Loop](./src/LED_Loop.vhd)
**Ports declaration**
```vhdl
entity LED_Loop is
    port(
        Clock : in std_logic;
        divider: in std_logic_vector(7 downto 0);
        CLK_out : out std_logic
    );
end LED_Loop;
```
This file uses the clock provided from the Basys Board. Gets the divider signal from an external signal in order to slow down on a certain amount the LEDs movement.
**Signals**
```vhdl
        CLK_out <= '0';
        if (counter >= divider) then
            if not (old_divider = divider) then
                old_divider <= divider;
            end if;
        end if;
```
Everytime counter is reset, divider changes according to the stated value took from the position.
```vhdl
            multiplicator_counter <= multiplicator_counter + 1;
            if (multiplicator_counter = divider_multiplicator) then
                CLK_out <= '1';
                multiplicator_counter <= "0000000000000000";
            end if;
        elsif (Clock'event and Clock = '1') then
            counter <= counter + 1;
```
The counter is adding every time there is a rising edge. Meaning it will be slowed down or sped up according to divider.
### **LED Loop Logic**
Code for [GameLogicLED](./src/GameLogicLED.vhd)
**Ports declaration**
```vhdl
port(
        RST : in std_logic;
        Clock : in std_logic;
        dir: in std_logic;
        pos : out std_logic_vector(3 downto 0);
        player_1_point: out std_logic_vector(3 downto 0);
        player_2_point: out std_logic_vector(3 downto 0);
        reset_speed: out std_logic := '0'
    );
```
This block is intended to work as the logic for the loop of leds, it gives a puntuation system using the adding points vectors. Also gives control to the Loop from the last file.
 ```vhdl
        if (current_pos = length) then
            reset_speed <= '1';
                if score1 >= "1001" then
                    score1 <= "0000";
                    score2 <= "0000";
                else
                    score1 <= score1 + 1;
                end if;
                current_pos <= "1000"; 
```
Everytime it reaches the end of player 2, adds up a point to player 1. If player reaches 10 points it resets meaning player 1 won.
 ```vhdl
        else
            current_pos <= current_pos + 1;
        end if;
```
If it has not reached the end, keeps adding to the position. Makes similar logic for player 2.
### **7 Seg Display Decoder** 
Code for [DisplayDecoder](./src/DisplayDecoder.vhd)
**Ports declaration**
```vhdl
entity display_7seg is
    Port ( num : in STD_LOGIC_VECTOR(3 downto 0);
           seg : out STD_LOGIC_VECTOR(6 downto 0));
end display_7seg;  
```
Decoder gets a BCD number and sends a seven segment logic vector which is later connected to the Basys board. 
```vhdl
            when "0000" => seg <= "1000000"; -- 0
            when "0001" => seg <= "1111001"; -- 1
            when "0010" => seg <= "0100100"; -- 2
            when "0011" => seg <= "0110000"; -- 3
            when "0100" => seg <= "0011001"; -- 4
            when "0101" => seg <= "0010010"; -- 5
            when "0110" => seg <= "0000010"; -- 6
            when "0111" => seg <= "1111000"; -- 7
            when "1000" => seg <= "0000000"; -- 8
            when "1001" => seg <= "0010000"; -- 9
```
Every 0 of the vector is an active LED of the seven segment, in this case we had common anode segments. It can be changed to the preference of the developer. 
### **Display Logic**  
Code for [ScoreDisplay](./src/ScoreDisplay.vhd)
**Ports declaration**
```vhdl
 Port (
        clk      : in STD_LOGIC;  
        display0 : in std_logic_vector(3 downto 0);
        display1 : in std_logic_vector(3 downto 0);
        display2 : in std_logic_vector(3 downto 0);
        display3 : in std_logic_vector(3 downto 0);
        segment  : out std_logic_vector(6 downto 0); 
        anode    : out std_logic_vector(3 downto 0) 
    );
```
The logic uses the internal clock of the basys to coordinate the 4 digits to display. Every display declaration is a digit.
```vhdl
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
```
A case is used to count and coordinate the anode with it is corresponding digit. When it reaches 3, goes back to 0.
```vhdl
display_a: display_7seg port map(
        num => display_value, 
        seg => segment
    );
    anode <= anode_temp;
```
The decoder from [DisplayDecoder](./src/DisplayDecoder.vhd) is used to decode the BCD vector into seven segment logic. Later the anode signal is connected to anode output.
### **Game Top Entity**
Code for [Game](./src/Game.vhd)
Game is the top entity of our design, it is intended to have all the conections from the basys and implements a hard reset which sets all to 0. Commented line codes are not intended to be used.
**Ports declaration**
```vhdl
    port(
        clk : in std_logic;
        btn_player1: in std_logic;
        btn_player2: in std_logic;
        RST: in std_logic;
        seg:out std_logic_vector(6 downto 0);
        an: out std_logic_vector(3 downto 0);
        led : out std_logic_vector(15 downto 0)
    );
```
Buttons as said, can be used from the basys. For comfort we used external buttons.
```vhdl
      if clk'event and clk = '1' then
            if current_dir = '1' and btn_player2 = '1' and led_states >= "1000" then
                current_dir <= not current_dir;
                case led_states is
                    when "1111" => divider <= "00111111";
                    -----Other cases
                    when others => divider <= "11111111";
                end case;
```
Every time the player clicks, depending on the position it will have a different speed declared inside divider. Similar case for the other player. Having 3 different conditions allows to avoids bugs of double clicking from the same player.
```vhdl
 case led_states is
            when "0000" => led <= "1000000000000000";
            ----- Other Cases
            when "1111" => led <= "0000000000000001";
            when others => led <= "1111111111111111";
        end case;
```
Led cases shows the position on the basys LED array. Basically decodes from BCD to vectorial position.
### **Constraints**  
Code for [Basys 3](./src/Basys3.xdc)
```xdc
set_property PACKAGE_PIN W5 [get_ports clk]
set_property PACKAGE_PIN W5 [get_ports clk]
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
```
Clock from the Basys. Necessary to check for the manual of the board. In our case it works at 10MHz frequency.
```xdc
set_property PACKAGE_PIN R2 [get_ports {RST}]
	set_property IOSTANDARD LVCMOS33 [get_ports {RST}]
```
Reset is an input used to hard reset the game itself.
```xdc
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {led[0]}]
#14 more constraints
set_property PACKAGE_PIN L1 [get_ports {led[15]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {led[15]}]
```
All the board LEDs were used to show the game loop. As we worked with vectors it is just neccesary to change the index of the declared vector. Can be changed to single standar logic data.
```xdc
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
#5 more Constraints
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]
	
set_property PACKAGE_PIN U2 [get_ports {an[0]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
#2 more Constraints
set_property PACKAGE_PIN W4 [get_ports {an[3]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]
```
The seven segment gets the 7 bit vector which corresponds to a line of the seven segment display. If not using the same board it is necessary to check board documentation also to know the common anodes configuration.
```xdc
set_property PACKAGE_PIN J3 [get_ports {btn_player2}]
	set_property IOSTANDARD LVCMOS33 [get_ports {btn_player2}]
set_property PACKAGE_PIN M2 [get_ports {btn_player1}]
	set_property IOSTANDARD LVCMOS33 [get_ports {btn_player1}]
```
We used external buttons so those were connected to inputs from the sides of the board. Using pull downs resistors is recommendated to connect into the voltage supply of the board.
```xdc
## Configuration options
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
```
Used configuration. Not neccesary to modify if working with the same board.
