----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    10:46:00 11/19/2016 
-- Design Name: 
-- Module Name:    IF_RF - Behavioral 
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

entity IF_RF is
    Port ( clk : in STD_LOGIC;
           IF_RFOp : in STD_LOGIC_VECTOR(1 downto 0);  -- 10 for WE_N, 11 for NOP, 0- for WE
           
           RF_PC_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_Ins_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_Imm_In : in std_logic_vector(15 downto 0);
           
           RF_PC_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_Ins_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_Imm_Out : out std_logic_vector(15 downto 0));
end IF_RF;

architecture Behavioral of IF_RF is
    signal pc, ins, imm : std_logic_vector(15 downto 0);
begin
    process(clk)
    begin
        RF_PC_OUT <= pc;
        RF_INS_OUT <= ins;
        RF_Imm_Out <= imm;
        if(clk'event and clk='1') then
            if(IF_RFOp = "11") then
                ins <= "0000100000000000";
                imm <= "0000000000000000";
                pc <= RF_PC_In;
            elsif(IF_RFOp(1) = '0') then
                ins<= RF_Ins_In;
                pc <= RF_PC_In;
                imm <= RF_Imm_In;
            end if;
        end if;
        
    end process;
end Behavioral;
