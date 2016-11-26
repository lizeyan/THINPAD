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
           
           RF_RamRWOp_In : in std_logic;
           RF_RegWrbOp_In : in std_logic_vector(1 downto 0);
			  RF_swsrcop_in : in std_logic;
			  RF_SWMUXOP_in : in std_logic_vector (2 downto 0);
           
           RF_Flags_Out : out STD_LOGIC_VECTOR(3 downto 0);
           RF_PC_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_Rd_Out : out STD_LOGIC_VECTOR(3 downto 0);
           RF_Res_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_Rx_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_Ry_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_St_Out : out STD_LOGIC_VECTOR(15 downto 0);
           
           RF_RamRWOp_Out : out std_logic;
           RF_RegWrbOp_Out : out std_logic_vector(1 downto 0);
			  RF_SWMUXOP_out : out std_logic_vector (2 downto 0);
			  RF_swsrcop_out : out std_logic);
end EXE_RF;

 architecture Behavioral of EXE_RF is
    signal ramrw,swsrcop : std_logic := '1';
    signal regwrb: std_logic_vector(1 downto 0) := "11";
	 signal swmuxop : std_logic_vector (2 downto 0) := "111";
	signal flags, rd : STD_LOGIC_VECTOR (3 downto 0) := "1111"; --ozsc
	signal pc, res, rx, ry, st: STD_LOGIC_VECTOR (15 downto 0) := "1111111111111111";
begin
	rf_flags_out <= flags;
	rf_pc_out <= pc;
	rf_rd_out <= rd;
	rf_res_out <= res;
	rf_rx_out <= rx;
	rf_ry_out <= ry;
	rf_st_out <= st;
    
    RF_RamRWOp_Out <= ramrw;
    RF_RegWrbOp_Out <= regwrb;
	rf_swsrcop_out <= swsrcop;
    RF_SWMUXOP_out <= swmuxop;
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
				  ramrw <= RF_RamRWOp_In;
				  regwrb <= RF_RegWrbOp_In;
              swsrcop <= rf_swsrcop_in;
				  swmuxop <= RF_SWMUXOP_in;
                    
			elsif exe_rfop = "11" then
					flags <= "0000";
					pc <= "0000000000000000"; -- ?
					rd <= "1111";
					res <= "0000000000000000";
					rx <= "0000000000000000";
					ry <= "0000000000000000";
					st <= "0000100000000000";
				   ramrw <= '1';
				   regwrb <= "11";
            else
                null;
			end if;
		end if;
	end process;
end Behavioral;
