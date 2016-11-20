----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: 
-- 
-- Create Date:    10:25:45 11/18/2016 
-- Design Name: 
-- Module Name:    Digit7Light - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity Digit7Light is
    Port ( Data : in STD_LOGIC_VECTOR(3 downto 0);
           Output : out STD_LOGIC_VECTOR(6 downto 0));
end Digit7Light;

architecture Behavioral of Digit7Light is
begin
    process(Data)
    begin
        case Data is
            when "0000" => 
                Output <= "1111110";  -- 0
            when "0001" => 
                Output <= "0110000";  -- 1
            when "0010" => 
                Output <= "1101101";  -- 2
            when "0011" => 
                Output <= "1111001";  -- 3
            when "0100" => 
                Output <= "0110011";  -- 4
            when "0101" => 
                Output <= "1011011";  -- 5
            when "0110" => 
                Output <= "1011111";  -- 6
            when "0111" => 
                Output <= "1110000";  -- 7
            when "1000" => 
                Output <= "1111111";  -- 8
            when "1001" => 
                Output <= "1111011";  -- 9
            when "1010" => 
                Output <= "1110111";  -- A
            when "1011" => 
                Output <= "0011111";  -- b
            when "1100" => 
                Output <= "0001101";  -- c
            when "1101" => 
                Output <= "0111101";  -- d
            when "1110" => 
                Output <= "1001111";  -- E
            when "1111" => 
                Output <= "1000111";  -- F
            when others => 
                Output <= "0000000";  -- empty
        end case;
    end process;
end Behavioral;
