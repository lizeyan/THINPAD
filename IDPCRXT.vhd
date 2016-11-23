----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    09:41:08 11/19/2016 
-- Design Name: 
-- Module Name:    IDPCRXT - Behavioral 
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

-- 生成IDPC，是这条跳转指令的目标地址
entity IDPCRXT is
    Port ( IDPC : out STD_LOGIC_VECTOR(15 downto 0);
           IDPCOp : in STD_LOGIC_VECTOR(1 downto 0);
           RXTOp : in STD_LOGIC_VECTOR(2 downto 0);
           
           ID_Res : in STD_LOGIC_VECTOR(15 downto 0);
           ID_Rx : in STD_LOGIC_VECTOR(15 downto 0);
           ID_T : in STD_LOGIC_VECTOR(15 downto 0);
           IF_RF_PC : in STD_LOGIC_VECTOR(15 downto 0);
           EXE_RF_Res : in STD_LOGIC_VECTOR(15 downto 0);
           MEM_RF_LW : in STD_LOGIC_VECTOR(15 downto 0);
           MEM_RF_Res : in STD_LOGIC_VECTOR(15 downto 0);
           PC_RF_PC : in STD_LOGIC_VECTOR(15 downto 0));
end IDPCRXT;

architecture Behavioral of IDPCRXT is
    signal RXTRes : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal EQ : STD_LOGIC := '0';
begin
    -- Find the correct Rx and T regs between ID, EXE, and MEM. 
    process(RXTOp, ID_Rx, ID_T, EXE_RF_Res, MEM_RF_LW, MEM_RF_Res)
    begin
        case RXTOp is
            when "000" =>
                RXTRes <= ID_Rx;
            when "001" => 
                RXTRes <= ID_T;
            when "010" => 
                RXTRes <= EXE_RF_Res;
            when "011" => 
                RXTRes <= MEM_RF_LW;
            when "100" => 
                RXTRes <= MEM_RF_Res;
            when others =>
                RXTRes <= "ZZZZZZZZZZZZZZZZ";
        end case;
    end process;
    
    -- Check whether Rx or T is zero. 
    process(RXTRes)
    begin
        if RXTRes = "0000000000000000" then
            EQ <= '1';
        else
            EQ <= '0';
        end if;
    end process;
    
    -- Select IDPC
    process(IDPCOp, EQ, EXE_RF_Res, PC_RF_PC, RXTRes)
    begin
        case IDPCOp is
            when "00" =>  -- BEQZ, BTEQZ
                if EQ='1' then
                    IDPC <= EXE_RF_Res;
                else
                    IDPC <= PC_RF_PC;
                end if;
            when "01" =>  -- BNEZ
                if EQ='0' then
                    IDPC <= EXE_RF_Res;
                else
                    IDPC <= PC_RF_PC;
                end if;
            when "10" =>  -- B
                IDPC <= EXE_RF_Res;
            when "11" =>  -- JR
                IDPC <= RXTRes;
            when others =>
                IDPC <= "ZZZZZZZZZZZZZZZZ";
        end case;
    end process;
end Behavioral;
