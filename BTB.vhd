----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    09:35:51 11/19/2016 
-- Design Name: 
-- Module Name:    BTB - Behavioral 
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

entity BTB is
    Port ( clk : in STD_LOGIC;
           PDTPC : out STD_LOGIC_VECTOR(15 downto 0);
           
           IDPC : in STD_LOGIC_VECTOR(15 downto 0);
           IF_Res : in STD_LOGIC_VECTOR(15 downto 0);
           IF_RF_OP : in STD_LOGIC_VECTOR(4 downto 0);
           IF_RF_PC : in STD_LOGIC_VECTOR(15 downto 0);
           PC_RF_PC : in STD_LOGIC_VECTOR(15 downto 0));
end BTB;

architecture Behavioral of BTB is
    type btbr_type is array(255 downto 0) of STD_LOGIC_VECTOR(25 downto 0);  -- 8 HPC + 2 buf + 16 Target
    signal BTBTable : btbr_type;
begin


end Behavioral;
