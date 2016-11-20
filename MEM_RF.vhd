----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    13:28:06 11/19/2016 
-- Design Name: 
-- Module Name:    MEM_RF - Behavioral 
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
-- 10 ≤ª–¥
-- 11 –¥»Înop
--  00 or 01 –¥»Î
entity MEM_RF is
    Port ( clk : in STD_LOGIC;
           MEM_RFOp : in STD_LOGIC_VECTOR(1 downto 0);
           
           RF_Flags_In : in STD_LOGIC_VECTOR(3 downto 0);
           RF_LW_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_Rd_In : in STD_LOGIC_VECTOR(3 downto 0);
           RF_Res_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_PC_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_St_In : in STD_LOGIC_VECTOR(15 downto 0);
           
           RF_Flags_Out : out STD_LOGIC_VECTOR(3 downto 0);
           RF_LW_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_Rd_Out : out STD_LOGIC_VECTOR(3 downto 0);
           RF_Res_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_PC_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_St_Out : out STD_LOGIC_VECTOR(15 downto 0));
end MEM_RF;

architecture Behavioral of MEM_RF is
	signal flags, rd : STD_LOGIC_VECTOR (3 downto 0);
	signal lw, res, pc, st : STD_LOGIC_VECTOR (15 downto 0);
begin
	rf_flags_out <= flags;
	rf_lw_out <= lw;
	rf_rd_out <= rd;
	rf_res_out <= res;
	rf_pc_out <= pc;
	rf_st_out <= st;

	process (clk, mem_rfop, rf_flags_in, rf_lw_in, rf_rd_in, rf_res_in, rf_pc_in, rf_st_in)
	begin
		pc <= rf_pc_in;
		if mem_rfop = "00" or mem_rfop = "01" then
			flags <= rf_flags_in;
			lw <= rf_lw_in;
			rd <= rf_rd_in;
			res <= rf_Res_in;
			st <= rf_st_in;
		elsif mem_rfop = "11" then
			flags <= "0000";
			lw <= "0000000000000000";
			rd <= "1111";
			res <= "0000000000000000";
			st <= "0000100000000000";
		end if;
	end process;
end Behavioral;
