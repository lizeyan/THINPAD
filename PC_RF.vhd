----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    09:22:47 11/19/2016 
-- Design Name: 
-- Module Name:    PC_RF - Behavioral 
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
-- 00 PDTPC
-- 01 IDPC
-- 10 NOT WE ²»ÄÜÐ´
-- 11 IF_RF_PC_ORIGIN
entity PC_RF is
    Port ( clk : in STD_LOGIC;
           PC_RFOp : in STD_LOGIC_VECTOR(1 downto 0);  -- 00 for PDTPC, 01 for IDPC, 10 for WE_down, 11 for NOP
                      
           IDPC : in STD_LOGIC_VECTOR(15 downto 0);
			  IF_RD_PC_ORIGIN: in STD_LOGIC_VECTOR (15 downto 0);
           PDTPC : in STD_LOGIC_VECTOR(15 downto 0);
           RF_PC_Out : out STD_LOGIC_VECTOR(15 downto 0));
end PC_RF;

architecture Behavioral of PC_RF is

begin


end Behavioral;
