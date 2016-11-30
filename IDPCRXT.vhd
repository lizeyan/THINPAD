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
    Port ( BTBTOp : out std_logic;
           IDPC : out std_logic_vector(15 downto 0);
           IDPCOp : in std_logic_vector(1 downto 0); --IDPC的选择，只和指令有关
           RXTOp : in std_logic_vector(2 downto 0); --寄存器取值的数据旁路控制信号
           
           ID_Res : in std_logic_vector(15 downto 0); --IF_RF_PC加上IMM的结果，是ID_PCAdder的输出
           ID_Rx : in std_logic_vector(15 downto 0); --rx寄存器的值
           ID_T : in std_logic_vector(15 downto 0); --T寄存器的值
           IF_RF_PC : in std_logic_vector(15 downto 0);
           EXE_RF_Res : in std_logic_vector(15 downto 0);
           MEM_RF_LW : in std_logic_vector(15 downto 0);
           MEM_RF_Res : in std_logic_vector(15 downto 0));
end IDPCRXT;

architecture Behavioral of IDPCRXT is
    signal EQ : std_logic := '0';
    signal RXTRes : std_logic_vector(15 downto 0) := (others => '0');
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
                RXTRes <= "1111111111111111";
        end case;
    end process;
    
    -- Check whether Rx or T is zero. 
    process(RXTRes)
    begin
        if RXTRes="0000000000000000" then
            EQ <= '1';
        else
            EQ <= '0';
        end if;
    end process;
    
    -- Select IDPC
    process(IDPCOp, EQ, ID_Res, IF_RF_PC, RXTRes)
    begin
        case IDPCOp is
            when "00" =>  -- BEQZ, BTEQZ
                if EQ='1' then
                    IDPC <= ID_Res;
                    BTBTOp <= '1';
                else
                    IDPC <= IF_RF_PC;
                    BTBTOp <= '0';
                end if;
            when "01" =>  -- BNEZ
                if EQ='0' then
                    IDPC <= ID_Res;
                    BTBTOp <= '1';
                else
                    IDPC <= IF_RF_PC;
                    BTBTOp <= '0';
                end if;
            when "10" =>  -- B
                IDPC <= ID_Res;
                BTBTOp <= '1';
            when "11" =>  -- JR
                IDPC <= RXTRes;
                BTBTOp <= '1';
            when others =>
                IDPC <= "1111111111111111";
                BTBTOp <= '0';
        end case;
    end process;
end Behavioral;
