----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    13:57:56 11/19/2016 
-- Design Name: 
-- Module Name:    ID_PCAdder - Behavioral 
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

entity ID_PCAdder is
    Port ( IF_RF_PC : in STD_LOGIC_VECTOR(15 downto 0);
           ID_Imm : in STD_LOGIC_VECTOR(15 downto 0);
           ID_Res : out STD_LOGIC_VECTOR(15 downto 0));
end ID_PCAdder;

architecture Behavioral of ID_PCAdder is
begin
    ID_Res <= IF_RF_PC + ID_Imm;
end Behavioral;
