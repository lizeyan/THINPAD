----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    11:15:22 11/18/2016 
-- Design Name: 
-- Module Name:    ControlUnit - Behavioral 
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

entity ControlUnit is
    Port ( AluOp : out STD_LOGIC_VECTOR(3 downto 0);
           AMuxOp : out STD_LOGIC_VECTOR(3 downto 0);
           BMuxOp : out STD_LOGIC_VECTOR(2 downto 0);
           DirOp : out STD_LOGIC_VECTOR(2 downto 0);
           ExDigitsOp : out STD_LOGIC_VECTOR(2 downto 0);
           ExSignOp : out STD_LOGIC;
           IDPCOp : out STD_LOGIC_VECTOR(1 downto 0);
           RamEn: out STD_LOGIC_VECTOR(1 downto 0);
           RamRWOp : out STD_LOGIC_VECTOR(1 downto 0);
			  MEM_SW_SRCop: out STD_LOGIC; --MEM段访存写入的是rx还是ry，在ID段根据指令决定。
           RegWrbOp : out STD_LOGIC_VECTOR(1 downto 0);
           RXTOp : out STD_LOGIC_VECTOR(1 downto 0);
           
           EXE_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           ID_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           IF_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           MEM_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           PC_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           
           IF_RF_OP : in STD_LOGIC_VECTOR(4 downto 0);
           ID_RF_OP : in STD_LOGIC_VECTOR(4 downto 0);
           ID_RF_Rd : in STD_LOGIC_VECTOR(3 downto 0);
           EXE_RF_OP : in STD_LOGIC_VECTOR(4 downto 0);
           EXE_RF_Rd : in STD_LOGIC_VECTOR(3 downto 0)
           
           
           );
end ControlUnit;

architecture Behavioral of ControlUnit is

begin

end Behavioral;
