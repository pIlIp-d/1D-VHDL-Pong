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
### **LED_Loop**
Code for [src/LED_Loop.vhd](./LED_Loop)
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
### **GameLogicLED**
Code for [src/GameLoopLED.vhd](./GameLoopLED)
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
If it has not reached the end, keeps adding to the position. 
Makes similar logic for player 2.
