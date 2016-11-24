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
           IF_ENOP: in STD_LOGIC; --是否取值
           PC_RF_PC : in STD_LOGIC_VECTOR(15 downto 0); --取指令的地址
           IF_Ins : out STD_LOGIC_VECTOR(15 downto 0); --指令输出
           
           -- MEM
           -- 0写入rx,1写入ry。
           -- 地址是exe_rf_res.
           MEM_SW_SrcOp : in STD_LOGIC;
           EXE_RF_Res : in STD_LOGIC_VECTOR(15 downto 0);
           EXE_RF_Rx : in STD_LOGIC_VECTOR(15 downto 0);
           EXE_RF_Ry : in STD_LOGIC_VECTOR(15 downto 0);
           MEM_LW : out STD_LOGIC_VECTOR(15 downto 0);
           
           -- IF & MEM
           -- 0 read; 1 write
           RamRWOp : in std_logic; --内存读写
           
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
			if clk'event and (clk='0' or clk='1') then
				state <= state + 1;
			end if;
		end if;
	end process;
	
	--uart
	process (state)
	begin
		if exe_rf_res(15 downto 2) = "10111111000000" then --首先保证访问的是uart
			if exe_rf_res(0) = '0' then
				case state is
					when "00" =>
						uartwrn <= '1';
						uartrdn <= '1';
					when "01" =>
						if ramrwop = '0' then
							uartrdn <= '1';
							data1 <= "ZZZZZZZZZZZZZZZZ";
						elsif ramrwop = '1' then
							if mem_sw_srcop = '0' then
								data1 <= exe_rf_rx;
							elsif mem_sw_srcop = '1' then
								data1 <= exe_rf_ry;
							end if;
							uartwrn <= '0';
						end if;
					when "10" =>
						if ramrwop = '0' then
							uartrdn <= '0';
						elsif ramrwop = '1' then
							uartwrn <= '1';
						end if;
					when "11" =>
						if ramrwop = '0' then
							mem_lw <= data1;
						elsif ramrwop = '1' then
						end if;
					when others =>
						uartwrn <= '1';
						uartrdn <= '1';
				end case;
			elsif exe_rf_res(0) = '1' then
				if ramrwop = '0' then
					mem_lw <= "00000000000000" & dataready & (tbre and tsre);
				end if;
			end if;
		else
			uartwrn <= '1';
			uartrdn <= '1';
		end if;
	end process;
	
	--ram1
	process (state)
	begin
		if exe_rf_res(15) = '1' and not (exe_rf_res(15 downto 2) = "10111111000000")then
			case state is
				when "00" => --mem段读写准备
					if ramrwop = '0' then --读
						ram1en <= '0';
						ram1we <= '1';
						ram1oe <= '0';
						addr1 <= exe_rf_res;
						data1 <= "ZZZZZZZZZZZZZZZZ";
					elsif ramrwop = '1' then --写
						ram1en <= '0';
						ram1we <= '1';
						ram1oe <= '1';
					else
						ram1en <= '1';
						ram1oe <= '1';
						ram1we <= '1';
					end if;
				when "01" => --mem段读写数据
						if ramrwop = '0' then --读
							mem_lw <= data1;
						elsif ramrwop = '1' then --写
							if mem_sw_srcop = '1' then
								data1 <= exe_rf_rx;
							else
								data1 <= exe_rf_ry;
							end if;
							addr1 <= exe_rf_res;
							ram1we <= '0';
						else
							ram1en <= '1';
							ram1oe <= '1';
							ram1we <= '1';
						end if;
				when others =>
					ram1en <= '1';
					ram1oe <= '1';
					ram1we <= '1';
			end case;
		else
			ram1en <= '1';
			ram1oe <= '1';
			ram1we <= '1';
		end if;
	end process;

	-- ram2
	process (state)
	begin
		case state is
			when "00" => --mem段读写准备
				if exe_rf_res(15) = '0' then --如果访问的是ram2
					if ramrwop = '0' then --读
						ram2en <= '0';
						ram2we <= '1';
						ram2oe <= '0';
						addr2 <= exe_rf_res;
						data2 <= "ZZZZZZZZZZZZZZZZ";
					elsif ramrwop = '1' then --写
						ram2en <= '0';
						ram2we <= '1';
						ram2oe <= '1';
					else
						ram2en <= '1';
						ram2oe <= '1';
						ram2we <= '1';
					end if;
				else --否则关闭ram2
					ram2en <= '1';
					ram2oe <= '1';
					ram2we <= '1';
				end if;
			when "01" => --mem段读写数据
				if exe_rf_res(15) = '0' then --如果访问的是ram2
					if ramrwop = '0' then --读
						mem_lw <= data2;
					elsif ramrwop = '1' then --写
						if mem_sw_srcop = '1' then
							data2 <= exe_rf_rx;
						else
							data2 <= exe_rf_ry;
						end if;
						addr2 <= exe_rf_res;
						ram2we <= '0';
					else
						ram2en <= '1';
						ram2oe <= '1';
						ram2we <= '1';
					end if;
				else --否则关闭ram2
					ram2en <= '1';
					ram2oe <= '1';
					ram2we <= '1';
				end if;
			when "10" => --if段取值准备
				ram2en <= '0';
				ram2we <= '1';
				ram2oe <= '0';
				addr2 <= pc_rf_pc;
				data2 <= "ZZZZZZZZZZZZZZZZ";
			when "11" => --取指令
				if_ins <= data2;
			when others =>
				ram2en <= '1';
				ram2oe <= '1';
				ram2we <= '1';
		end case;
	end process;
end Behavioral;
