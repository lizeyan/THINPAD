----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    09:22:47 11/19/2016 
-- Design Name: 
-- Module Name:    PC_RF - Behavioral 
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

-- 000 PDTPC
-- 001 IDPC
-- 010 异常处理地址
-- 011 EXE_RES_PC
-- 100 不能写
entity PC_RF is
    Port ( clk : in std_logic;
           rst: in std_logic;
           int : in STD_LOGIC;
           PC_RFOp : in std_logic_vector(2 downto 0);
           PC_RFWE: in std_logic;
           IDPC : in std_logic_vector(15 downto 0);
           EXE_RES_PC : in std_logic_vector(15 downto 0);
           PDTPC : in std_logic_vector(15 downto 0);
           
           RF_PC_Out : out std_logic_vector(15 downto 0));
end PC_RF;

architecture Behavioral of PC_RF is
    signal pc : std_logic_vector(15 downto 0) := (others => '0');
begin
    RF_PC_Out <= pc;

    process(clk, rst)
    begin
        if rst = '0' then
            pc <= "0000000000000000";
        elsif clk'event and clk='1' and pc_rfwe = '1' then
            if int = '1' then
                pc <= "0000000000000101";
            else
                case PC_RFOp is
                    when "000" => 
                        pc <= PDTPC;
                    when "001" => 
                        pc <= IDPC;
                    when "010" => 
                        pc <= "0000000000000101";
                    when "011" => 
                        pc <= EXE_RES_PC;
                    when others => 
                        null;
                end case;
            end if;
        end if;
    end process;
end Behavioral;
