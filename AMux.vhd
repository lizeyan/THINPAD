----------------------------------------------------------------------------------
-- Company: Concept Computer Composition
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    10:44:18 11/18/2016 
-- Design Name: 
-- Module Name:    AMux - Behavioral 
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

-- AMuxOp
-- 0000 | EXE_RF_Res
-- 0001 | ID_RF_PC
-- 0010 | ID_RF_Rx
-- 0011 | ID_RF_Ry
-- 0100 | ID_RF_IH
-- 0101 | ID_RF_SP
-- 0110 | ID_RF_T
-- 0111 | MEM_RF_LW
-- 1000 | MEM_RF_Res
-- 1001 | all ones
-- 1010 | all zeros

entity AMux is
    Port ( AMuxOp : in STD_LOGIC_VECTOR(3 downto 0);
           ASrc : out STD_LOGIC_VECTOR(15 downto 0);
           
           EXE_RF_Res : in STD_LOGIC_VECTOR(15 downto 0);
           ID_RF_PC : in STD_LOGIC_VECTOR(15 downto 0);
           ID_RF_Rx : in STD_LOGIC_VECTOR(15 downto 0);
           ID_RF_Ry : in STD_LOGIC_VECTOR(15 downto 0);
           ID_RF_IH : in STD_LOGIC_VECTOR(15 downto 0);
           ID_RF_SP : in STD_LOGIC_VECTOR(15 downto 0);
           ID_RF_T : in STD_LOGIC_VECTOR(15 downto 0);
           MEM_RF_LW : in STD_LOGIC_VECTOR(15 downto 0);
           MEM_RF_Res : in STD_LOGIC_VECTOR(15 downto 0));
end AMux;

architecture Behavioral of AMux is
begin
    process(AMuxOp, EXE_RF_Res, ID_RF_PC, ID_RF_Rx, ID_RF_Ry, ID_RF_IH, ID_RF_SP, ID_RF_T, MEM_RF_LW, MEM_RF_Res)
    begin
        case AMuxOp is
            when "0000" => 
                ASrc <= EXE_RF_Res;
            when "0001" => 
                ASrc <= ID_RF_PC;
            when "0010" => 
                ASrc <= ID_RF_Rx;
            when "0011" => 
                ASrc <= ID_RF_Ry;
            when "0100" => 
                ASrc <= ID_RF_IH;
            when "0101" => 
                ASrc <= ID_RF_SP;
            when "0110" => 
                ASrc <= ID_RF_T;
            when "0111" => 
                ASrc <= MEM_RF_LW;
            when "1000" => 
                ASrc <= MEM_RF_Res;
				when "1001" =>
					ASrc <= "1111111111111111";
				when "1010" =>
					ASrc <= "0000000000000000";
            when others => 
                ASrc <= (others => '1');
        end case;
    end process;
end Behavioral;
