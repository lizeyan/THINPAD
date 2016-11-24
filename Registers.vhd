----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    10:59:27 11/19/2016 
-- Design Name: 
-- Module Name:    Registers - Behavioral 
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

entity Registers is
    Port ( clk : in STD_LOGIC;
           IF_RF_RX : in STD_LOGIC_VECTOR(2 downto 0);
           IF_RF_RY : in STD_LOGIC_VECTOR(2 downto 0);
           RegWrbAddr : in STD_LOGIC_VECTOR(3 downto 0);
           RegWrbData : in STD_LOGIC_VECTOR(15 downto 0);
           
           ID_Rx : out STD_LOGIC_VECTOR(15 downto 0);
           ID_Ry : out STD_LOGIC_VECTOR(15 downto 0);
           ID_IH : out STD_LOGIC_VECTOR(15 downto 0);
           ID_SP : out STD_LOGIC_VECTOR(15 downto 0);
           ID_T : out STD_LOGIC_VECTOR(15 downto 0);
           R0, R1, R2, R3, R4, R5, R6, R7, IH, SP, T : out STD_LOGIC_VECTOR(15 downto 0));
end Registers;

architecture Behavioral of Registers is
--0000    signal R0 : STD_LOGIC_VECTOR(15 downto 0);
--....
--0111    signal R7 : STD_LOGIC_VECTOR(15 downto 0);
--1000    signal IH : STD_LOGIC_VECTOR(15 downto 0); 8 
--1001    signal SP : STD_LOGIC_VECTOR(15 downto 0); 9
--1010    signal T : STD_LOGIC_VECTOR(15 downto 0); 10
    type regs is array(15 downto 0) of std_logic_vector(15 downto 0); --16个冗余了，但其实FPGA上产生的寄存器个数会是2的幂
    signal data : regs := (others => (others => '0'));
begin
    process(data)
    begin
        R0 <= data(0);
        R1 <= data(1);
        R2 <= data(2);
        R3 <= data(3);
        R4 <= data(4);
        R5 <= data(5);
        R6 <= data(6);
        R7 <= data(7);
        IH <= data(8);
        SP <= data(9);
        T <= data(10);
     end process;
--read
    process(data, IF_RF_RX, IF_RF_RY, RegWrbAddr, RegWrbData)
    begin
        ID_Rx <= data(conv_integer('0' & IF_RF_RX));
        ID_RY <= data(conv_integer('0' & IF_RF_RY));
        ID_IH <= data(8);
        ID_SP <= data(9);
        ID_T <= data(10);
    end process;
-- write
    process(clk, RegWrbAddr, RegWrbData)
    begin
        if(clk'event and clk='1' and RegWrbAddr<11) then
            data(conv_integer(RegWrbAddr)) <= RegWrbData;
        end if;
    end process;
end Behavioral;
