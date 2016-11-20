----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    11:10:53 11/18/2016 
-- Design Name: 
-- Module Name:    ExtendModule - Behavioral 
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

entity ExtendModule is
    Port ( ExSrc : in STD_LOGIC_VECTOR(10 downto 0);
           ExImm : out STD_LOGIC_VECTOR(15 downto 0);
           
           ExDigitsOp : in STD_LOGIC_VECTOR(2 downto 0);
           ExSignOp : in STD_LOGIC);
end ExtendModule;

architecture Behavioral of ExtendModule is

begin


end Behavioral;
