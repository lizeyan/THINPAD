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

-- 选择写回寄存器的数据
-- 00 res
-- 11 !flagZero
-- 01 lw
-- 10 flag_sign
entity RegWrbModule is
    Port ( RegWrbOp : in STD_LOGIC_VECTOR(1 downto 0);
           RegWrbOut : out STD_LOGIC_VECTOR(15 downto 0);
           MEM_RF_Flagzero : in STD_LOGIC;
           
           MEM_RF_FlagSign : in STD_LOGIC;
           MEM_RF_LW : in STD_LOGIC_VECTOR(15 downto 0);
           MEM_RF_Res : in STD_LOGIC_VECTOR(15 downto 0));
end RegWrbModule;

architecture Behavioral of RegWrbModule is
begin
		process (regwrbop, mem_rf_flagsign, mem_rf_lw, mem_rf_res)
		begin
			case regwrbop is
				when "00" =>
					regwrbout <= mem_rf_res;
				when "01" =>
					regwrbout <= mem_rf_lw;
				when "10" =>
					regwrbout <= "000000000000000" & mem_rf_flagsign;
				when "11" =>
                    regwrbout <= "000000000000000" & (not mem_rf_flagzero);
                when others=>
                    regwrbout <= "0000000000000000";
			end case;
		end process;

end Behavioral;
