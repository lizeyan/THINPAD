----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    11:00:31 11/18/2016 
-- Design Name: 
-- Module Name:    BMux - Behavioral 
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

-- BMuxOp
-- 000 | EXE_RF_Res
-- 001 | ID_RF_Imm
-- 010 | ID_RF_Ry
-- 011 | MEM_RF_LW
-- 100 | MEM_RF_Res
-- 101 | one
-- 110 | all zeros

entity BMux is
    Port ( BMuxOp : in STD_LOGIC_VECTOR(2 downto 0);
           BSrc : out STD_LOGIC_VECTOR(15 downto 0);
           
           EXE_RF_Res : in STD_LOGIC_VECTOR(15 downto 0);
           ID_RF_Imm : in STD_LOGIC_VECTOR(15 downto 0);
           ID_RF_Ry : in STD_LOGIC_VECTOR(15 downto 0);
           MEM_RF_LW : in STD_LOGIC_VECTOR(15 downto 0);
           MEM_RF_Res : in STD_LOGIC_VECTOR(15 downto 0));
end BMux;

architecture Behavioral of BMux is
begin
    process(BMuxOp, EXE_RF_Res, ID_RF_Imm, ID_RF_Ry, MEM_RF_LW, MEM_RF_Res)
    begin
        case BMuxOp is
            when "000" => 
                BSrc <= EXE_RF_Res;
            when "001" => 
                BSrc <= ID_RF_Imm;
            when "010" => 
                BSrc <= ID_RF_Ry;
            when "011" => 
                BSrc <= MEM_RF_LW;
            when "100" => 
                BSrc <= MEM_RF_Res;
				when "101" =>
					bsrc <= "0000000000000001";
				when "110" =>
					bsrc <= "0000000000000000";
                when others => 
                    BSrc <= (others => '1');
        end case;
    end process;
end Behavioral;
