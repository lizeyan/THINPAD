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
    Port ( clk : in STD_LOGIC; --������Ҫ����ʱ��
           rst : in STD_LOGIC; -- ˢ��״̬�� rst='0'����StateΪ00
           
           -- IF
           -- ����PC����ȡָ
           PC_RF_PC : in STD_LOGIC_VECTOR(15 downto 0); --ȡָ��ĵ�ַ
           IF_Ins : out STD_LOGIC_VECTOR(15 downto 0); --ָ�����
           
           -- MEM
           -- 0д��rx,1д��ry��
           -- ��ַ��exe_rf_res.
           MEM_SW_SrcOp : in STD_LOGIC;
           EXE_RF_Res : in STD_LOGIC_VECTOR(15 downto 0);
           EXE_RF_Rx : in STD_LOGIC_VECTOR(15 downto 0);
           EXE_RF_Ry : in STD_LOGIC_VECTOR(15 downto 0);
           MEM_LW : out STD_LOGIC_VECTOR(15 downto 0);
           
           -- IF & MEM
           -- 0 read; 1 write
           RamRWOp : in std_logic; --�ڴ��д
           
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
	signal mem_lw_ram1, mem_lw_ram2 : std_logic_vector (15 downto 0) := "0000000000000000";
begin
	-- ����״̬��
	process (clk, rst)
	begin
		if rst = '0' then
			state <= "00";
		else
			if  rising_edge (clk) then
				state <= state + 1;
			end if;
		end if;
	end process;
	
	process (mem_lw_ram1, mem_lw_ram2, exe_rf_res)
	begin
		if exe_rf_res(15) = '1' then
			mem_lw <= mem_lw_ram1;
		else
			mem_lw <= mem_lw_ram2;
		end if;
	end process;
	
	--ram1 and uart
	process (state, exe_rf_res, ramrwop, data1, mem_sw_srcop, exe_rf_rx, exe_rf_ry, dataready)
	begin
		if exe_rf_res(15) = '1' and not (exe_rf_res(15 downto 2) = "10111111000000")then
			uartwrn <= '1';
			uartrdn <= '1';
			case state is
				when "00" => --mem�ζ�д׼��
					mem_lw_ram1 <= "0000000000000000";
					data1 <= "ZZZZZZZZZZZZZZZZ";
					if ramrwop = '0' then --��
						ram1en <= '0';
						ram1we <= '1';
						ram1oe <= '0';
						addr1 <= exe_rf_res;
					elsif ramrwop = '1' then --д
						ram1en <= '0';
						ram1we <= '1';
						ram1oe <= '1';
						addr1 <= "ZZZZZZZZZZZZZZZZ";
					else
						ram1en <= '1';
						ram1oe <= '1';
						ram1we <= '1';
						addr1 <= "ZZZZZZZZZZZZZZZZ";
					end if;
				when "01" => --mem�ζ�д����
						if ramrwop = '0' then --��
							ram1en <= '0';
							ram1we <= '1';
							ram1oe <= '0';
							addr1 <= exe_rf_res;
							mem_lw_ram1 <= data1;
						elsif ramrwop = '1' then --д
							mem_lw_ram1 <= "0000000000000000";
							if mem_sw_srcop = '1' then
								data1 <= exe_rf_rx;
							else
								data1 <= exe_rf_ry;
							end if;
							addr1 <= exe_rf_res;
							ram1we <= '0';
							ram1en <= '0';
							ram1oe <= '1';
						else
							mem_lw_ram1 <= "0000000000000000";
							ram1en <= '1';
							ram1oe <= '1';
							ram1we <= '1';
							addr1 <= "ZZZZZZZZZZZZZZZZ";
						end if;
				when others =>
					mem_lw_ram1 <= "0000000000000000";
					ram1en <= '1';
					ram1oe <= '1';
					ram1we <= '1';
					addr1 <= "ZZZZZZZZZZZZZZZZ";
			end case;
		elsif exe_rf_res(15 downto 2) = "10111111000000" then --���ȱ�֤���ʵ���uart
			ram1en <= '1';
			ram1we <= '1';
			ram1oe <= '1';
			addr1 <= "ZZZZZZZZZZZZZZZZ";
			if exe_rf_res(0) = '0' then
				case state is
					when "00" =>
						uartwrn <= '1';
						uartrdn <= '1';
						mem_lw_ram1 <= "0000000000000000";
					when "01" =>
						mem_lw_ram1 <= "0000000000000000";
						if ramrwop = '0' then
							uartrdn <= '1';
							uartwrn <= '1';
							data1 <= "ZZZZZZZZZZZZZZZZ";
						elsif ramrwop = '1' then
							if mem_sw_srcop = '0' then
								data1 <= exe_rf_rx;
							elsif mem_sw_srcop = '1' then
								data1 <= exe_rf_ry;
							end if;
							uartrdn <= '1';
							uartwrn <= '0';
						end if;
					when "10" =>
						mem_lw_ram1 <= "0000000000000000";
						if ramrwop = '0' then
							uartrdn <= '0';
							uartwrn <= '1';
						elsif ramrwop = '1' then
							uartwrn <= '1';
							uartrdn <= '1';
						end if;
					when "11" =>
						if ramrwop = '0' then
							uartrdn <= '0';
							uartwrn <= '1';
							mem_lw_ram1 <= data1;
						elsif ramrwop = '1' then
							uartwrn <= '1';
							uartrdn <= '1';
							mem_lw_ram1 <= "0000000000000000";
						else
							uartwrn <= '1';
							uartrdn <= '1';
							mem_lw_ram1 <= "0000000000000000";
						end if;
					when others =>
						uartwrn <= '1';
						uartrdn <= '1';
						mem_lw_ram1 <= "0000000000000000";
				end case;
			elsif exe_rf_res(0) = '1' then
				uartwrn <= '1';
				uartrdn <= '1';
				if ramrwop = '0' then
					mem_lw_ram1 <= "00000000000000" & dataready & (tbre and tsre);
				else
					mem_lw_ram1 <= "0000000000000000";
				end if;
			end if;
		else
			mem_lw_ram1 <= "0000000000000000";
			addr1 <= "0000000000000000";
			ram1en <= '1';
			ram1oe <= '1';
			ram1we <= '1';
			uartrdn <= '1';
			uartwrn <= '1';
		end if;
	end process;

	-- ram2
	process (state, exe_rf_res, ramrwop, data2, mem_sw_srcop, exe_rf_rx, exe_rf_ry, pc_rf_pc)
	begin
		case state is
			when "00" => --mem�ζ�д׼��
				if_ins <= "ZZZZZZZZZZZZZZZZ";
				mem_lw_ram2 <= "ZZZZZZZZZZZZZZZZ";
				data2 <= "ZZZZZZZZZZZZZZZZ";
				if exe_rf_res(15) = '0' then --������ʵ���ram2
					addr2 <= exe_rf_res;
					if ramrwop = '0' then --��
						ram2en <= '0';
						ram2we <= '1';
						ram2oe <= '0';
					elsif ramrwop = '1' then --д
						ram2en <= '0';
						ram2we <= '1';
						ram2oe <= '1';
					else
						ram2en <= '1';
						ram2oe <= '1';
						ram2we <= '1';
					end if;
				else --����ر�ram2
					addr2 <= "ZZZZZZZZZZZZZZZZ";
					ram2en <= '1';
					ram2oe <= '1';
					ram2we <= '1';
				end if;
			when "01" => --mem�ζ�д����
				if_ins <= "ZZZZZZZZZZZZZZZZ";
				if exe_rf_res(15) = '0' then --������ʵ���ram2
					if ramrwop = '0' then --��
						ram2en <= '0';
						ram2we <= '1';
						ram2oe <= '0';
						mem_lw_ram2 <= data2;
						addr2 <= exe_rf_res;
					elsif ramrwop = '1' then --д
						mem_lw_ram2 <= "ZZZZZZZZZZZZZZZZ";
						if mem_sw_srcop = '1' then
							data2 <= exe_rf_rx;
						else
							data2 <= exe_rf_ry;
						end if;
						addr2 <= exe_rf_res;
						ram2we <= '0';
						ram2en <= '0';
						ram2oe <= '1';
					else
						mem_lw_ram2 <= "ZZZZZZZZZZZZZZZZ";
						ram2en <= '1';
						ram2oe <= '1';
						ram2we <= '1';
						addr2 <= "ZZZZZZZZZZZZZZZZ";
					end if;
				else --����ر�ram2
					mem_lw_ram2 <= "ZZZZZZZZZZZZZZZZ";
					ram2en <= '1';
					ram2oe <= '1';
					ram2we <= '1';
					addr2 <= "ZZZZZZZZZZZZZZZZ";
				end if;
			when "10" => --if��ȡֵ׼��
				mem_lw_ram2 <= "ZZZZZZZZZZZZZZZZ";
				ram2en <= '0';
				ram2we <= '1';
				ram2oe <= '0';
				addr2 <= pc_rf_pc;
				data2 <= "ZZZZZZZZZZZZZZZZ";
				if_ins <= "ZZZZZZZZZZZZZZZZ";
			when "11" => --ȡָ��
				mem_lw_ram2 <= "ZZZZZZZZZZZZZZZZ";
				ram2en <= '0';
				ram2we <= '1';
				ram2oe <= '0';
				if_ins <= data2;
				addr2 <= pc_rf_pc;
			when others =>
				if_ins <= "ZZZZZZZZZZZZZZZZ";
				mem_lw_ram2 <= "ZZZZZZZZZZZZZZZZ";
				ram2en <= '1';
				ram2oe <= '1';
				ram2we <= '1';
				addr2 <= "ZZZZZZZZZZZZZZZZ";
		end case;
	end process;
end Behavioral;
