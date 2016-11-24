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
-- 011 IF_RF_PC_ORIGIN
-- 100 不能写
entity PC_RF is
    Port ( clk : in std_logic;
           PC_RFOp : in std_logic_vector(2 downto 0);
                      
           IDPC : in std_logic_vector(15 downto 0);
           IF_RF_OPC : in std_logic_vector(15 downto 0);
           PDTPC : in std_logic_vector(15 downto 0);
           
           RF_PC_Out : out std_logic_vector(15 downto 0));
end PC_RF;

architecture Behavioral of PC_RF is
    constant DelInt : std_logic_vector(15 downto 0) := (others => '1');  -- Address of DelInt
    
    signal pc : std_logic_vector(15 downto 0) := (others => '0');
begin
    RF_PC_Out <= pc;

    process(clk)
    begin
        if clk'event and clk='1' then
            case PC_RFOp is
                when "000" => 
                    pc <= PDTPC;
                when "001" => 
                    pc <= IDPC;
                when "010" => 
                    pc <= DelInt;
                when "011" => 
                    pc <= IF_RF_OPC;
                when others => 
                    null;
            end case;
        end if;
    end process;
end Behavioral;
