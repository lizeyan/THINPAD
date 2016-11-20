----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    10:46:00 11/19/2016 
-- Design Name: 
-- Module Name:    IF_RF - Behavioral 
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

entity IF_RF is
    Port ( clk : in STD_LOGIC;
           IF_RFOp : in STD_LOGIC_VECTOR(1 downto 0);  -- 10 for WE_N, 11 for NOP, 0- for WE
           
           RF_PC_In : STD_LOGIC_VECTOR(15 downto 0);
           RF_Ins_In : STD_LOGIC_VECTOR(15 downto 0);
           
           RF_PC_Out : STD_LOGIC_VECTOR(15 downto 0);
           RF_Ins_Out : STD_LOGIC_VECTOR(15 downto 0));
end IF_RF;

architecture Behavioral of IF_RF is

begin


end Behavioral;
