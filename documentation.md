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
6. [References](#references)
---

## **Introduction**  
A brief manual to the introduccion of game creation using FPGAs and self-learning of basic VHDL language. Very useful to understand how sequential and combinational logic works.
- Explain hard-to-understand block codes or the logic behind them to get the user to a better understanding of it.
- Explanation by blocks, not into a high level.
- Aimed for VHDL beginner programmers.

> This document describes the functionality and structure of the design code compiled on this repository. It's purpose is to help developers to understand key points of it and how they work together.  

---

## **Project Structure**  
Incluye una vista general de la estructura de archivos y carpetas del repositorio, con una breve explicación de su contenido.  

```plaintext
├── src/  
│   ├── Basys3.xdc  		# Constraints for Basys 3 Board  
│   ├── DisplayDecoder.vhd  # BCD to Seven segment decoder
│   ├── Game.vhd  		    # Top Entity of the design    
│   ├── GameLogicLED.vhd  	# LEDs Logic, for ball movement  
│   ├── LED_Loop.vhd  		# LEDs Loop from the Basys 3 Board
│   ├── ScoreDisplay.vhd  	# Logic for shown score on seven segment
├── README.md         # Instrucciones generales  
├── documentation.md  # Documentación detallada  
```
---
## **Description of Files and Folders**  
Explication:
- **LED_Loop**: In this file, we have the logic to control the way of turning on the LEDs of the Basys3. It uses the signal of the clock and a divider to control the speed of the movement of the LEDs. Basically the logic of this file makes sure that the LEDs state changes according to the signal of the clock and the divider.

- **GameLogicLED**: In this file, we control the states of the LEDs used for the movement of the players inside of the game. Additionally, the score system that increases the score of each player when they reach certain values is contained here. It also allows to establish the speed of the LEDs and control the flow of the positions in the game. 
  
- **Game**: This file is the top entity of the design. Here all the connections of the different parts of the game come together from the buttons of the players, the control of the LEDs and the visualization of the score. We also implement a reset to reset the game to its initial state.
  
- **DisplayDecoder**: This file is in charge of decoding the numbers that are in format BCD (decimal code coded in binary) to a compatible format for the 7-segment display of the Basys 3 by activating the correct segments according to what goes in.
  
- **Basys3**: This file, contains the restrictions of the Basys 3, it also defines how the different connections of the FPGA, to the external components like the buttons, LEDs and displays are routed. It also establishes the clock.

## **Code Explanation**  
### **LED Loop**
Code for [LED_Loop](./src/LED_Loop.vhd).

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
This file uses the clock provided by the Basys Board. It gets the divider signal from an external signal in order to slow down the LEDs movement by a certain amount.
```vhdl
        CLK_out <= '0';
        if (counter >= divider) then
            if not (old_divider = divider) then
                old_divider <= divider;
            end if;
        end if;
```
Everytime the counter is reset, the divider changes according to the stated value taken from the position.
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
Code for [GameLogicLED](./src/GameLogicLED.vhd).

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
This block handles the logic for the loop of leds. It also handles the score system adding and returning the score back to the main game.vhd.
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
Everytime it reaches the end of player 2s side, it adds a point to player 1. If player reaches 10 points it resets meaning player 1 won.
 ```vhdl
        else
            current_pos <= current_pos + 1;
        end if;
```
If it has not reached the end, it keeps adding to the position. Same logic applies for the other player.
### **7 Seg Display Decoder** 
Code for [DisplayDecoder](./src/DisplayDecoder.vhd).

**Ports declaration**
```vhdl
entity display_7seg is
    Port ( num : in STD_LOGIC_VECTOR(3 downto 0);
           seg : out STD_LOGIC_VECTOR(6 downto 0));
end display_7seg;  
```
The decoder gets a BCD number and sends a seven segment logic vector which is later connected to the Basys board. 
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
Code for [ScoreDisplay](./src/ScoreDisplay.vhd).

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
The logic uses the internal clock of the basys to coordinate the 4 digits for the display. Every display declaration is a digit.
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
Code for [Game](./src/Game.vhd).
Game is the top entity of our design, it is intended to have all the connections from the basys board and implements a hard reset which sets all to 0.

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
As stated, buttons can either be the internal basys ones, or external ones for comfort.
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
Every time the player clicks, depending on the position of the ball the bounce will have a different speed for the ball.
```vhdl
 case led_states is
            when "0000" => led <= "1000000000000000";
            ----- Other Cases
            when "1111" => led <= "0000000000000001";
            when others => led <= "1111111111111111";
        end case;
```
Led cases shows converts the position to a single led that is turned on. (Demultiplexer)
### **Constraints**
Code for [Basys 3](./src/Basys3.xdc).
```xdc
set_property PACKAGE_PIN W5 [get_ports clk]
set_property PACKAGE_PIN W5 [get_ports clk]
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]
```
Clock from the Basys. It is Necessary to check the manual of the board, to find the operating frequency. In our case it works at 10MHz frequency.
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
All the board LEDs were used to show the game loop. As we worked with vectors it is just necessary to change the index of the declared vector. Can be changed to single standard logic data.
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
The seven segment gets the 7 bit vector which corresponds to a line of the seven segment display. If you are not using the same board it is necessary to check board documentation also to know the common anode configuration.
```xdc
set_property PACKAGE_PIN J3 [get_ports {btn_player2}]
	set_property IOSTANDARD LVCMOS33 [get_ports {btn_player2}]
set_property PACKAGE_PIN M2 [get_ports {btn_player1}]
	set_property IOSTANDARD LVCMOS33 [get_ports {btn_player1}]
```
We used external buttons, so those were connected to inputs from the sides of the board. Using pull down resistors is recommended as well.
```xdc
## Configuration options
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
```
Used configuration. Not necessary to modify if working with the same board.

---
## **References**

- PensActius. (2018, February 23). Juego PONG  con tira de leds y arduino [Video].Youtube  [https://www.youtube.com/watch?v=videoID](https://www.youtube.com/watch?v=Q-6n0XncaWE)
  [Pong Game Example by PensActius]([https://www.youtube.com/watch?v=videoID](https://www.youtube.com/watch?v=Q-6n0XncaWE))


-Ingeniería Electrónica Industrial Campus Jalpa. (2020, May 19). Juego Pong IEI Juego Arduino Impresión 3D [Video].YouTube.[https://www.youtube.com/watch?v=videoID](https://www.youtube.com/watch?app=desktop&v=adN6mfCjHu4)
  [Pong Game Example byIngeniería Electrónica Industrial Campus Jalpa]([https://www.youtube.com/watch?v=videoID](https://www.youtube.com/watch?app=desktop&v=adN6mfCjHu4))


-Robot UNO. (2020, July 9). PING-PONG con ARDUINO || MINIJUEGO CON ARDUINO || PROYECTO para PRINCIPIANTES[explicado paso a paso] [Video]. YouTube.[https://www.youtube.com/watch?v=videoID](https://www.youtube.com/watch?v=ttuo--XyvzM)
   [Pong Game Example by Robot UNO]([https://www.youtube.com/watch?v=videoID](https://www.youtube.com/watch?v=ttuo--XyvzM))




