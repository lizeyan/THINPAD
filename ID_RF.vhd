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
    Port ( clk : in std_logic;
           ID_RFOp : in std_logic_vector(1 downto 0);  -- 10 for WE_N, 11 for NOP, 0- for WE
           
           RF_Imm_In : in std_logic_vector(15 downto 0);
           RF_IH_In : in std_logic_vector(15 downto 0);
           RF_PC_In : in std_logic_vector(15 downto 0);
           RF_Res_In : in std_logic_vector(15 downto 0);
           RF_Rd_In : in std_logic_vector(3 downto 0);
           RF_Rx_In : in std_logic_vector(15 downto 0);
           RF_Ry_In : in std_logic_vector(15 downto 0);
           RF_SP_In : in std_logic_vector(15 downto 0);
           RF_St_In : in std_logic_vector(15 downto 0);
           RF_T_In : in std_logic_vector(15 downto 0);
           
           -- control signal
           RF_AluOp_In : in std_logic_vector(3 downto 0);
           RF_AmuxOp_In : in std_logic_vector(3 downto 0);
           RF_BmuxOp_In : in std_logic_vector(2 downto 0);
           RF_RamRWOp_In : in std_logic;
           RF_RegWrbOp_In : in std_logic_vector(1 downto 0);
			  RF_swsrcop_in : in std_logic;
           
           RF_Imm_Out : out std_logic_vector(15 downto 0);
           RF_IH_Out : out std_logic_vector(15 downto 0);
           RF_PC_Out : out std_logic_vector(15 downto 0);
           RF_Res_Out : out std_logic_vector(15 downto 0);
           RF_Rd_Out : out std_logic_vector(3 downto 0);
           RF_Rx_Out : out std_logic_vector(15 downto 0);
           RF_Ry_Out : out std_logic_vector(15 downto 0);
           RF_SP_Out : out std_logic_vector(15 downto 0);
           RF_St_Out : out std_logic_vector(15 downto 0);
           RF_T_Out : out std_logic_vector(15 downto 0);
           
           RF_AluOp_Out : out std_logic_vector(3 downto 0);
           RF_AmuxOp_Out : out std_logic_vector(3 downto 0);
           RF_BmuxOp_Out : out std_logic_vector(2 downto 0);
           RF_RamRWOp_Out : out std_logic;
           RF_RegWrbOp_Out : out std_logic_vector(1 downto 0);
			  RF_swsrcop_out : out std_logic);
end ID_RF;

architecture Behavioral of ID_RF is
    signal ramrw, swsrcop : std_logic := '1';
    signal regwrb : std_logic_vector(1 downto 0) := "11";
    signal bmux : std_logic_vector(2 downto 0) := "111";
    signal rd, alu, amux : std_logic_vector(3 downto 0) := "1111";
    signal imm, ih, pc, res, rx, ry, sp, st, t : std_logic_vector(15 downto 0) := "1111111111111111";
begin
    RF_Imm_Out <= imm;
    RF_IH_Out <= ih;
    RF_PC_Out <= pc;
    RF_Res_Out <= res;
    RF_Rd_Out <= rd;
    RF_Rx_Out <= rx;
    RF_Ry_Out <= ry;
    RF_SP_Out <= sp;
    RF_St_out <= st;
    RF_T_Out <= t;
	 rf_swsrcop_out <= swsrcop;
    
    RF_AluOp_Out <= alu;
    RF_AmuxOp_Out <= amux;
    RF_BmuxOp_Out <= bmux;
    RF_RamRWOp_Out <= ramrw;
    RF_RegWrbOp_Out <= regwrb;
    
    process(clk)
    begin
        if clk'event and clk='1' then 
            if ID_RFOp="11" then -- nop
                imm <= "0000000000000000";
                res <= "0000000000000000";
                rd <= "1111";
                rx <= "0000000000000000";
                ry <= "0000000000000000";
                st <= "0000100000000000";
                
                ih <= RF_IH_IN;
                pc <= RF_PC_IN;
                sp <= RF_SP_IN;
                t <= RF_T_IN;
                
                alu <= "1111"; --illegal
                amux <= "1111"; --illegal
                bmux <= "111"; --illegal
                ramrw <= '1';
                regwrb <= "11";
            elsif ID_RFOp="00" or ID_RFOp="01" then
                imm <= RF_Imm_IN;
                res <= RF_Res_IN;
                rd <= RF_Rd_IN;
                rx <= RF_RX_IN;
                ry <= RF_RY_IN;
                st <= RF_ST_IN;
                
                ih <= RF_IH_IN;
                pc <= RF_PC_IN;
                sp <= RF_SP_IN;
                t <= RF_T_IN;
                
                alu <= RF_AluOp_In;
                amux <= RF_AmuxOp_In;
                bmux <= RF_BmuxOp_In;
                ramrw <= RF_RamRWOp_In;
                regwrb <= RF_RegWrbOp_In;
					 swsrcop <= rf_swsrcop_in;
            else
                null;
            end if;
        end if;
    end process;
end Behavioral;
