----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    12:11:58 11/19/2016 
-- Design Name: 
-- Module Name:    EXE_RF - Behavioral 
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

entity EXE_RF is
    Port ( clk : in STD_LOGIC;
           EXE_RFOp : in STD_LOGIC_VECTOR(1 downto 0);  -- 10 for WE_N, 11 for NOP, 0- for WE
           
           RF_Flags_In : in STD_LOGIC_VECTOR(3 downto 0);
           RF_PC_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_Rd_In : in STD_LOGIC_VECTOR(3 downto 0);
           RF_Res_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_Rx_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_Ry_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_St_In : in STD_LOGIC_VECTOR(15 downto 0);
           
           RF_Flags_Out : out STD_LOGIC_VECTOR(3 downto 0);
           RF_PC_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_Rd_Out : out STD_LOGIC_VECTOR(3 downto 0);
           RF_Res_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_Rx_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_Ry_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_St_Out : out STD_LOGIC_VECTOR(15 downto 0));
end EXE_RF;

 architecture Behavioral of EXE_RF is
	signal flags, rd : STD_LOGIC_VECTOR (3 downto 0) := "0000"; --ozsc
	signal pc, res, rx, ry, st: STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
begin
	rf_flags_out <= flags;
	rf_pc_out <= pc;
	rf_rd_out <= rd;
	rf_res_out <= res;
	rf_rx_out <= rx;
	rf_ry_out <= ry;
	rf_st_out <= st;
	
	process (clk)
	begin
		if rising_edge (clk) then
			if exe_rfOP  = "00" or exe_rfop = "01" then
					flags <= rf_flags_in;
					pc <= rf_pc_in;
					rd <= rf_rd_in;
					res <= rf_res_in;
					rx <= rf_rx_in;
					ry <= rf_ry_in;
					st <= rf_st_in;
			elsif exe_rfop = "11" then
					flags <= "0000";
					pc <= "0000000000000000"; -- ?
					rd <= "1111";
					res <= "0000000000000000";
					rx <= "0000000000000000";
					ry <= "0000000000000000";
					st <= "0000100000000000";
			end if;
		end if;
	end process;

end Behavioral;

