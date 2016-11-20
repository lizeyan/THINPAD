----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    14:01:47 11/19/2016 
-- Design Name: 
-- Module Name:    RegWrbModule - Behavioral 
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

entity RegWrbModule is
    Port ( RegWrbOp : in STD_LOGIC_VECTOR(1 downto 0);
           RegWrbOut : out STD_LOGIC_VECTOR(15 downto 0);
           
           MEM_RF_FlagSign : in STD_LOGIC;
           MEM_RF_LW : in STD_LOGIC_VECTOR(15 downto 0);
           MEM_RF_Res : in STD_LOGIC_VECTOR(15 downto 0));
end RegWrbModule;

architecture Behavioral of RegWrbModule is

begin


end Behavioral;
