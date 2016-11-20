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

entity IDPCRXT is
    Port ( RXTOp : in STD_LOGIC_VECTOR(1 downto 0);
           IDPCOp : in STD_LOGIC_VECTOR(1 downto 0);
           IDPC : out STD_LOGIC_VECTOR(15 downto 0);
           
           ID_Res : in STD_LOGIC_VECTOR(15 downto 0);
           ID_Rx : in STD_LOGIC_VECTOR(15 downto 0);
           ID_T : in STD_LOGIC_VECTOR(15 downto 0);
           IF_RF_PC : in STD_LOGIC_VECTOR(15 downto 0);
           EXE_RF_Res : in STD_LOGIC_VECTOR(15 downto 0);
           MEM_RF_LW : in STD_LOGIC_VECTOR(15 downto 0);
           PC_RF_PC : in STD_LOGIC_VECTOR(15 downto 0));
end IDPCRXT;

architecture Behavioral of IDPCRXT is
    signal RXTRes : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    signal EQ : STD_LOGIC := '0';
begin
    process(RXTOp, ID_Rx, ID_T, EXE_RF_Res, MEM_RF_LW)
    begin
        case RXTOp is
            when "00" =>
                RXTRes <= ID_Rx;
            when "01" => 
                RXTRes <= ID_T;
            when "10" => 
                RXTRes <= EXE_RF_Res;
            when "11" => 
                RXTRes <= MEM_RF_LW;
        end case;
    end process;
    
    process(RXTRes)
    begin
        if RXTRes=(others => '0') then
            EQ <= '1';
        else
            EQ <= '0';
        end if;
    end process;
    
    process(IDPCOp, EQ, EXE_RF_Res, PC_RF_PC, RXTRes)
    begin
        case IDPCOp is
            when "00" => 
                if EQ='1' then
                    IDPC <= EXE_RF_Res;
                else
                    IDPC <= PC_RF_PC;
                end if;
            when "01" => 
                if EQ='0' then
                    IDPC <= EXE_RF_Res;
                else
                    IDPC <= PC_RF_PC;
                end if;
            when "10" => 
                IDPC <= EXE_RF_Res;
            when "11" => 
                IDPC <= RXTRes;
        end case;
    end process;
end Behavioral;
