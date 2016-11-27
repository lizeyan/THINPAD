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
           mem_en : in std_logic;
           -- IF
           -- 根据PC进行取指
           PC_RF_PC : in STD_LOGIC_VECTOR(15 downto 0); --取指令的地址
           IF_Ins : out STD_LOGIC_VECTOR(15 downto 0); --指令输出
           -- MEM
           -- 地址是exe_rf_res.
           MEM_SW_DATA : in STD_LOGIC_VECTOR (15 downto 0);
           EXE_RF_Res : in STD_LOGIC_VECTOR(15 downto 0);
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
			  -------DEBUG--------------
          state_out : out std_logic_vector (3 downto 0);
           DataReady : in STD_LOGIC;
           Tbre : in STD_LOGIC;
           Tsre : in STD_LOGIC);
end MemUart;

architecture Behavioral of MemUart is
	shared variable state: STD_LOGIC_VECTOR (1 downto 0) := "11";
    shared variable sent : boolean := false;
    signal readdata, ramdata, uartdata, readins: std_logic_vector (15 downto 0);
begin
    --update state
    process (clk, rst)
    begin
        if rst = '0' then
            state := "00";
        elsif rising_edge (clk) then
            state := state + 1;
            if state = "01" then
                ramdata <= readdata;
            elsif state = "11" then
                uartdata <= readdata;
                if_ins <= readins;
            end if;
        end if;
    end process;
    
    process (exe_rf_res, ramrwop, mem_en, ramdata, uartdata)
    begin
        if exe_rf_res(15 downto 2) = "10111111000000" and ramrwop = '0' and exe_rf_res(0) = '0' and mem_en = '1' then
            mem_lw <= "00000000" & uartdata(7 downto 0);
        elsif ramrwop = '0' and mem_en = '1' then
            mem_lw <= ramdata;
        else
            mem_lw <= "0000000000000000";
        end if;
    end process;
    
    process (exe_rf_res, mem_sw_data, data1, data2, ramrwop, mem_en, clk, rst)
    begin
        if exe_rf_res(15 downto 2) = "10111111000000" and ramrwop = '0' and exe_rf_res(0) = '0' and mem_en = '1' then
            ram1en <= '1';  ram1we <= '1';  ram1oe <= '1';
            uartwrn <= '1';
            case state is
                when "00" =>
                    uartrdn <= '1';
                    data1 <= "ZZZZZZZZZZZZZZZZ";
                when "01" =>
                    if dataready = '1' then
                        uartrdn <= '0';
                        data1 <= "ZZZZZZZZZZZZZZZZ";
                    else
                        uartrdn <= '1';
                        data1 <= "ZZZZZZZZZZZZZZZZ";
                    end if;
                when "10" =>
                    readdata <= data1;
                when "11" =>
                    uartrdn <= '1';
                    data1 <= "ZZZZZZZZZZZZZZZZ";
                when others =>
                    uartrdn <= '1';
                    data1 <= "ZZZZZZZZZZZZZZZZ";
            end case;
        elsif exe_rf_res(15 downto 2) = "10111111000000" and ramrwop = '1' and exe_rf_res(0) = '0' and mem_en = '1' then -- write uart                                                                                                                                                       
            ram1en <= '1';  ram1we <= '1';  ram1oe <= '1';  uartrdn <= '1';
            if state = "00" then
                uartwrn <= clk;
                data1 <= "00000000" & mem_sw_data (7 downto 0);
            else
                uartwrn <= '1';
                data1 <= "ZZZZZZZZZZZZZZZZ";
            end if;
--          
--            case state is
--                when "00" =>
--                    if tbre = '1' and tsre = '1' and (not sent)then
--                        uartwrn <= '0';
--                        data1 <= "00000000" & mem_sw_data (7 downto 0);
--                        sent := true;
--                    else
--                        uartwrn <= '1'; data1 <= "ZZZZZZZZZZZZZZZZ";
--                    end if;                                                
--                when others =>
--                    sent := false;
--                    uartwrn <= '1';
--                    data1 <= "ZZZZZZZZZZZZZZZZ";
--            end case;
        elsif exe_rf_res(15 downto 2) = "10111111000000" and ramrwop = '0' and exe_rf_res(0) = '1' and mem_en = '1' then
				uartrdn <= '1';
				uartwrn <= '1';
				ram1en <= '1';
				ram1we <= '1';
				ram1oe <= '1';
				data1 <= "ZZZZZZZZZZZZZZZZ";
				readdata <= "00000000000000" & dataready & (tbre and tsre);
        elsif exe_rf_res (15) = '1' and ramrwop = '0' and mem_en = '1' then
            uartwrn <= '1';	uartrdn <= '1';
            case state is
                when "00" =>
                    ram1en <= '0';		ram1we <= '1';		ram1oe <= '0';
                    addr1 <= exe_rf_res;
                    data1 <= "ZZZZZZZZZZZZZZZZ";
                    readdata <= data1;
                when "01" =>
                    ram1en <= '0';  ram1we <= '1';  ram1oe <= '0';
                    addr1 <= exe_rf_res;
                    data2 <= "ZZZZZZZZZZZZZZZZ";
                when others =>
                    ram1en <= '1';  ram1we <= '1';  ram1oe <= '1';
                    data1 <= "ZZZZZZZZZZZZZZZZ";
            end case;
        elsif exe_rf_res (15) = '1' and ramrwop = '1' and mem_en = '1' then   
            uartwrn <= '1';	uartrdn <= '1';
            case state is
                when "00" =>
                    ram1en <= '0';		ram1we <= '1';		ram1oe <= '1';
                when "01" =>
                    ram1en <= '0';		ram1we <= '0';		ram1oe <= '1';
                    addr1 <= exe_rf_res;
                    data1 <= mem_sw_data;
                when others =>
                    data1 <= "ZZZZZZZZZZZZZZZZ";
                    ram1en <= '1';		ram1we <= '1';		ram1oe <= '1';
            end case;
        elsif exe_rf_res (15) = '0' and ramrwop = '0' and mem_en = '1' then
            uartwrn <= '1';	uartrdn <= '1';
            case state is
                when "00" =>
                    ram2en <= '0';		ram2we <= '1';		ram2oe <= '0';
                    addr2 <= exe_rf_res;
                    data2 <= "ZZZZZZZZZZZZZZZZ";
                    readdata <= data2;
                when "01" =>
                    ram2en <= '0';  ram2we <= '1';  ram2oe <= '0';
                    addr2 <= exe_rf_res;
                    data2 <= "ZZZZZZZZZZZZZZZZ";
                when others =>
                    data2 <= "ZZZZZZZZZZZZZZZZ";
            end case;
        elsif exe_rf_res (15) = '0' and ramrwop = '1' and mem_en = '1' then   
            uartwrn <= '1';	uartrdn <= '1';
            case state is
                when "00" =>
                    ram2en <= '0';		ram2we <= '1';		ram2oe <= '1';
                when "01" =>
                    ram2en <= '0';		ram2we <= '0';		ram2oe <= '1';
                    addr2 <= exe_rf_res;
                    data2 <= mem_sw_data;
                when others =>
                    data2 <= "ZZZZZZZZZZZZZZZZ";
            end case;
        else
            uartwrn <= '1'; uartrdn <= '1';
            ram1en <= '1';  ram1oe <= '1';  ram1we <= '1';
            ram2en <= '1';  ram2oe <= '1';  ram2we <= '1';
            data1 <= "ZZZZZZZZZZZZZZZZ";
            data2 <= "ZZZZZZZZZZZZZZZZ";
        end if;
        
        if state = "10" then
            ram2en <= '0';		ram2we <= '1';		ram2oe <= '0';
            addr2 <= pc_rf_pc;
            data2 <= "ZZZZZZZZZZZZZZZZ";
            readins <= data2;
        else
            ram2en <= '1';		ram2we <= '1';		ram2oe <= '1';
        end if;
    end process;
    
    
    
    
	state_out <= "00" & state;
--    mem_lw <= data;
--	process (clk, rst)
--	begin
--		if rst = '0' then
--			state <= "00";
--		elsif rising_edge (clk) then
--			if exe_rf_res(15 downto 2) = "10111111000000" and ramrwop = '0' and exe_rf_res(0) = '0' and mem_en = '1'  then --read uart
--				ram1en <= '1';		ram1we <= '1';		ram1oe <= '1';
--				uartwrn <= '1';
--				case state is
--					when "00" =>
--						nready := '1';
--						data1 <= "ZZZZZZZZZZZZZZZZ";
--					when "01" =>
--						if dataready = '1' then
--							nready := '0';
--						end if;
--					when "10" =>
--						if nready = '0' then
--							data <= data1;
--							nready := '1';
--						end if;
--					when "11" =>
--						nready := '1';
--						data1 <= "ZZZZZZZZZZZZZZZZ";
--					when others => null;
--				end case;
--				uartrdn <= nready;
--			elsif exe_rf_res(15 downto 2) = "10111111000000" and ramrwop = '1' and exe_rf_res(0) = '0' and mem_en = '1'  then --write uart
--				ram1en <= '1';		ram1we <= '1';		ram1oe <= '1';
--				uartrdn <= '1';
--				case state is
--					when "00" =>
--						if tbre = '1' and tsre = '1' then
--							uartwrn <= '0';
--							data1(7 downto 0) <= mem_sw_data (7 downto 0);
--						end if;
--					when "01" =>
--						uartwrn <= '1';
--					when others => null;
--				end case;
--			elsif exe_rf_res(15 downto 2) = "10111111000000" and ramrwop = '0' and exe_rf_res(0) = '1' and mem_en = '1' then
--				uartrdn <= '1';
--				uartwrn <= '1';
--				ram1en <= '1';
--				ram1we <= '1';
--				ram1oe <= '1';
--				data1 <= "ZZZZZZZZZZZZZZZZ";
--				data <= "00000000000000" & dataready & (tbre and tsre);
--			elsif exe_rf_res(15) = '1' and ramrwop = '0' and mem_en = '1'  then --read ram1
--				uartwrn <= '1';	uartrdn <= '1';
--				case state is
--					when "00" =>
--						ram1en <= '0';		ram1we <= '1';		ram1oe <= '0';
--						addr1 <= exe_rf_res;
--						data1 <= "ZZZZZZZZZZZZZZZZ";
--					when "01" =>
--                        addr1 <= exe_rf_res;
--						data <= data1;
--					when others => null;
--				end case;
--			elsif exe_rf_res(15) = '1' and ramrwop = '1' and mem_en = '1'  then --write ram1  
--				uartwrn <= '1';	uartrdn <= '1';
--				case state is
--					when "00" =>
--						ram1en <= '0';		ram1we <= '1';		ram1oe <= '1';
--					when "01" =>
--						ram1we <= '0';
--						addr1 <= exe_rf_res;
--						data1 <= mem_sw_data;
--					when others =>
--						data1 <= "ZZZZZZZZZZZZZZZZ";
--						ram1en <= '1';		ram1we <= '1';		ram1oe <= '1';
--				end case;
--			elsif exe_rf_res(15) = '0' and ramrwop = '0' and mem_en = '1'  then --read ram2
--				case state is
--					when "00" =>
--						ram2en <= '0';		ram2we <= '1';		ram2oe <= '0';
--						addr2 <= exe_rf_res;
--						data2 <= "ZZZZZZZZZZZZZZZZ";
--					when "01" =>
--                        addr2 <= exe_rf_res;
--						data <= data2;
--					when others => null;
--				end case;
--			elsif exe_rf_res(15) = '0' and ramrwop = '1' and mem_en = '1' then --write ram2
--				case state is
--					when "00" =>
--						ram2en <= '0';		ram2we <= '1';		ram2oe <= '1';
--					when "01" =>
--						ram2we <= '0';
--						addr2 <= exe_rf_res;
--						data2 <= mem_sw_data;
--					when others => null;
--				end case;
--			else
--				uartrdn <= '1';
--                
--			end if;
--			-- read ram2 for IF
--			if state = "10" then
--				ram2en <= '0';		ram2we <= '1';		ram2oe <= '0';
--				addr2 <= pc_rf_pc;
--				data2 <= "ZZZZZZZZZZZZZZZZ";
--			elsif state = "11" then
--				if_ins <= data2;
--			end if;
--			state <= state + 1;
--		end if;
--	end process;
end Behavioral;


