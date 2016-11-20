----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    13:48:52 11/19/2016 
-- Design Name: 
-- Module Name:    IF_PCAdder - Behavioral 
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

entity IF_PCAdder is
    Port ( PC_RF_PC : in STD_LOGIC_VECTOR(15 downto 0);
           IF_Res : out STD_LOGIC_VECTOR(15 downto 0));
end IF_PCAdder;

architecture Behavioral of IF_PCAdder is
begin
    IF_Res <= PC_RF_PC + 1;
end Behavioral;
