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
    Port ( clk : in std_logic;
           IF_RFOp : in std_logic_vector(1 downto 0);  -- 10 for WE_N, 11 for NOP, 0- for WE
           INT      : in STD_LOGIC;
           RF_Imm_In : in std_logic_vector(15 downto 0);
           RF_Ins_In : in std_logic_vector(15 downto 0);
           RF_PC_In : in std_logic_vector(15 downto 0);
           RF_OPC_In : in std_logic_vector(15 downto 0);
           
           RF_Imm_Out : out std_logic_vector(15 downto 0);
           RF_Ins_Out : out std_logic_vector(15 downto 0);
           RF_PC_Out : out std_logic_vector(15 downto 0);
           RF_OPC_Out : out std_logic_vector(15 downto 0));
end IF_RF;

architecture Behavioral of IF_RF is
    signal imm : std_logic_vector(15 downto 0);
    signal ins : std_logic_vector(15 downto 0);
    signal pc : std_logic_vector(15 downto 0);
    signal opc : std_logic_vector(15 downto 0);
begin
    RF_Imm_Out <= imm;
    RF_INS_Out <= ins;
    RF_PC_Out <= pc;
    RF_OPC_Out <= opc;
    
    process(clk)
    begin
        if clk'event and clk='1' then
            if int = '1' then
                imm <= pc;
                ins <= "1111100000010000";
            elsif IF_RFOp="11" then
                imm <= "0000000000000000";
                ins <= "0000100000000000";
                pc <= RF_PC_In;
                opc <= RF_OPC_In;
            elsif IF_RFOp(1)='0' then
                imm <= RF_Imm_In;
                ins<= RF_Ins_In;
                pc <= RF_PC_In;
                opc <= RF_OPC_In;
            else
                null;
            end if;
        end if;
    end process;
end Behavioral;
