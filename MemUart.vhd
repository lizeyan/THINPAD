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
           mem_en_lh : in std_logic; -- look ahead of mem_en
           -- IF
           -- 根据PC进行取指
           PC_RF_PC : in STD_LOGIC_VECTOR(15 downto 0); --取指令的地址
           IF_Ins : out STD_LOGIC_VECTOR(15 downto 0); --指令输出
           -- MEM
           -- 地址是exe_rf_res.
           MEM_SW_DATA : in STD_LOGIC_VECTOR (15 downto 0);
           EXE_RF_Res : in STD_LOGIC_VECTOR(15 downto 0);
           ALUres: in std_logic_vector (15 downto 0); --look ahead of exe_rf_res
           MEM_LW : out STD_LOGIC_VECTOR(15 downto 0);
           
           -- IF & MEM
           -- 0 read; 1 write
           RamRWOp : in std_logic; --内存读写
           ramrwop_lh : in std_logic; --look ahead of ramrwop
           
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
	signal state: STD_LOGIC := '0';
	shared variable data : std_logic_vector (15 downto 0) := "0000000000000000";
	shared variable nready : std_logic := '1';
begin
	state_out <= "000" & state;
    if_ins <= data2;
    process (exe_rf_res, mem_en, ramrwop)
    begin
        if exe_rf_res(15 downto 2) = "10111111000000" and ramrwop = '0' and exe_rf_res(0) = '0' and mem_en = '1' and state = '0' and nready = '0' then -- read uart
            mem_lw <= "00000000" & data1 (7 downto 0);
        else
            mem_lw <= data;
        end if;
    end process;
    
	process (clk, rst)
	begin
		if rst = '0' then
			state <= '0';
		elsif rising_edge (clk) then
			if (state /= '0' and exe_rf_res(15 downto 2) = "10111111000000" and ramrwop = '0' and exe_rf_res(0) = '0' and mem_en = '1')
                or (state = '0' and alures(15 downto 2) = "10111111000000" and ramrwop_lh = '0' and alures(0) = '0' and mem_en_lh = '1') then --read uart
				ram1en <= '1';		ram1we <= '1';		ram1oe <= '1';
				case state is
					when '0' =>
						nready := '1';
						data1 <= "ZZZZZZZZZZZZZZZZ";
					when '1' =>
						if dataready = '1' then
							nready := '0';
						end if;
					when others => null;
				end case;
				uartrdn <= nready;
			elsif (state /= '0' and exe_rf_res(15 downto 2) = "10111111000000" and ramrwop = '1' and exe_rf_res(0) = '0' and mem_en = '1')
                or (state = '0' and alures(15 downto 2) = "10111111000000" and ramrwop_lh = '1' and alures (0) = '0' and mem_en_lh = '1') then --write uart
				ram1en <= '1';		ram1we <= '1';		ram1oe <= '1';
				uartrdn <= '1';
                case state is
                    when '1' => 
                        if tbre = '1' and tsre = '1' then
                            uartwrn <= '0';
                            data1 (7 downto 0) <= mem_sw_data(7 downto 0);
                        end if;
                    when '0' =>
                        uartwrn <= '1';
                    when others => null;
                end case;
			elsif (state /= '0' and exe_rf_res(15 downto 2) = "10111111000000" and ramrwop = '0' and exe_rf_res(0) = '1' and mem_en = '1') 
                or (state = '0' and alures(15 downto 2) = "10111111000000" and ramrwop_lh = '0' and alures(0) = '1' and mem_en_lh = '1') then
				uartrdn <= '1';
				ram1en <= '1';
				ram1we <= '1';
				ram1oe <= '1';
				data1 <= "ZZZZZZZZZZZZZZZZ";
				data := "00000000000000" & dataready & (tbre and tsre);
			elsif (state /= '0' and exe_rf_res(15) = '1' and ramrwop = '0' and mem_en = '1')
                or (state = '0' and alures(15) = '1' and ramrwop_lh = '0' and mem_en_lh = '1') then --read ram1
				uartrdn <= '1';
				case state is
					when '0' =>
						ram1en <= '0';		ram1we <= '1';		ram1oe <= '0';
						addr1 <= alures;
						data1 <= "ZZZZZZZZZZZZZZZZ";
					when '1' =>
						data := data1;
                        ram1en <= '1';		ram1we <= '1';		ram1oe <= '1';
                        data1 <= "ZZZZZZZZZZZZZZZZ";
					when others => null;
				end case;
			elsif (state /= '0' and exe_rf_res(15) = '1' and ramrwop = '1' and mem_en = '1')
                or (state = '0' and alures(15) = '1' and ramrwop_lh = '1' and mem_en_lh = '1') then --write ram1  
				uartrdn <= '1';
				case state is
					when '0' =>
						ram1en <= '0';		ram1we <= '1';		ram1oe <= '1';
					when '1' =>
						ram1we <= '0';
						addr1 <= exe_rf_res;
						data1 <= mem_sw_data;
					when others => null;
				end case;
			elsif (state /= '0' and exe_rf_res(15) = '0' and ramrwop = '0' and mem_en = '1' ) 
                or (state = '0' and alures(15) = '0' and ramrwop_lh = '0' and mem_en_lh = '1')then --read ram2
				case state is
					when '0' =>
						ram2en <= '0';		ram2we <= '1';		ram2oe <= '0';
						addr2 <= alures;
						data2 <= "ZZZZZZZZZZZZZZZZ";
					when '1' =>
						data := data2;
                        data2 <= "ZZZZZZZZZZZZZZZZ";
					when others => null;
				end case;
			elsif (state /= '0' and exe_rf_res(15) = '0' and ramrwop = '1' and mem_en = '1' ) 
                or (state = '0' and alures(15) = '0' and ramrwop_lh = '1' and mem_en_lh = '1')then --write ram2
				case state is
					when '1' =>
						ram2we <= '0';
						addr2 <= exe_rf_res;
						data2 <= mem_sw_data;
					when others => null;
				end case;
			else
                data1 <= "ZZZZZZZZZZZZZZZZ";
                data2 <= "ZZZZZZZZZZZZZZZZ";
				uartrdn <= '1';
			end if;
			-- read ram2 for IF
			if state = '1' then
				ram2en <= '0';		ram2we <= '1';		ram2oe <= '0';
				addr2 <= pc_rf_pc;
				data2 <= "ZZZZZZZZZZZZZZZZ";
			end if;
			state <= not state;
		end if;
	end process;
end Behavioral;
