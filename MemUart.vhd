----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    10:29:06 11/19/2016 
-- Design Name: 
-- Module Name:    MemUart - Behavioral 
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

entity MemUart is
    Port ( clk : in STD_LOGIC; --这里需要高速时钟
           rst : in STD_LOGIC; -- 刷新状态机 rst='0'重置State为00
           
           -- IF
			  -- 根据PC进行取指
           PC_RF_PC : in STD_LOGIC_VECTOR(15 downto 0); --取指令的地址
           IF_Ins : out STD_LOGIC_VECTOR(15 downto 0); --指令输出
           
           -- MEM
			  -- 0写入rx,1写入ry。
			  -- 地址是exe_rf_res.
			  MEM_SW_SrcOP: in STD_LOGIC;
           EXE_RF_Res : in STD_LOGIC_VECTOR(15 downto 0);
           EXE_RF_Rx : in STD_LOGIC_VECTOR(15 downto 0);
           EXE_RF_Ry : in STD_LOGIC_VECTOR(15 downto 0);
           MEM_LW : out STD_LOGIC_VECTOR(15 downto 0);
           
           -- IF & MEM
           RamEN: in STD_LOGIC_VECTOR(1 downto 0); --第1位ram1， 第0位ram2
           RamRWOp : in STD_LOGIC_VECTOR(1 downto 0);  -- (1) for Ram1, (0) for Ram2; 0 for R, 1 for W
           
           Addr1 : out STD_LOGIC_VECTOR(15 downto 0);
           Addr2 : out STD_LOGIC_VECTOR(15 downto 0);
           Data1 : inout STD_LOGIC_VECTOR(15 downto 0);  -- low 8 digits for Uart
           Data2 : inout STD_LOGIC_VECTOR(15 downto 0);
           Ram1EN : out STD_LOGIC;
           Ram1OE : out STD_LOGIC;
           Ram1WE : out STD_LOGIC;
           Ram2EN : out STD_LOGIC;
           Ram2OE : out STD_LOGIC;
           Ram2WE : out STD_LOGIC;
           UartRdn : out STD_LOGIC;
           UartWrn : out STD_LOGIC;
           DataReady : in STD_LOGIC;
           Tbre : in STD_LOGIC;
           Tsre : in STD_LOGIC);
end MemUart;

architecture Behavioral of MemUart is
	signal state: STD_LOGIC_VECTOR (1 downto 0) := "00";
begin
	-- 更新状态机
	process (clk, rst)
	begin
		if rst = '0' then
			state <= "00";
		else
			if clk'event then
				state <= state + 1;
			end if;
		end if;
	end process;

	-- ram2
	process (clk, rst)   
end Behavioral;
