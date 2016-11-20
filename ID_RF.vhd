----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    11:17:05 11/19/2016 
-- Design Name: 
-- Module Name:    ID_RF - Behavioral 
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

entity ID_RF is
    Port ( clk : in STD_LOGIC;
           ID_RFOp : in STD_LOGIC_VECTOR(1 downto 0);  -- 10 for WE_N, 11 for NOP, 0- for WE
           
           RF_Imm_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_IH_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_PC_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_Res_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_Rd_In : in STD_LOGIC_VECTOR(3 downto 0);
           RF_Rx_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_Ry_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_SP_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_St_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_T_In : in STD_LOGIC_VECTOR(15 downto 0);
           
           RF_Imm_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_IH_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_PC_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_Res_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_Rd_Out : out STD_LOGIC_VECTOR(3 downto 0);
           RF_Rx_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_Ry_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_SP_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_St_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_T_Out : out STD_LOGIC_VECTOR(15 downto 0));
end ID_RF;

architecture Behavioral of ID_RF is

begin


end Behavioral;

