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
			  boot_finish_out: out boolean;
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
           vga_en: out std_logic_vector(0 downto 0);
           vga_data : out std_logic_vector (15 downto 0);
           vga_addr : out std_logic_vector (12 downto 0);
           -- IF & MEM
           -- 0 read; 1 write
           RamRWOp : in std_logic; --内存读写
           ramrwop_lh : in std_logic; --look ahead of ramrwop
           
           Addr1 : out STD_LOGIC_VECTOR(15 downto 0);
           Addr2 : out STD_LOGIC_VECTOR(15 downto 0);
           Data1 : inout STD_LOGIC_VECTOR(15 downto 0);  -- low 8 digits for Uart
			  data2 : inout STD_LOGIC_VECTOR(15 downto 0);
           Ram1EN : out STD_LOGIC;
           Ram1OE : out STD_LOGIC;
           Ram1WE : out STD_LOGIC;
           Ram2EN : out STD_LOGIC;
           Ram2OE : out STD_LOGIC;
           Ram2WE : out STD_LOGIC;
           UartRdn : out STD_LOGIC;
           UartWrn : out STD_LOGIC;
			  ------FLASH----------------
			  flash_byte : out std_logic;
           flash_vpen : out std_logic;
           flash_ce : out std_logic;
           flash_oe : out std_logic;
           flash_we : out std_logic;
           flash_rp : out std_logic;
           flash_addr : out std_logic_vector(22 downto 1) := (others => '0');
           flash_data : inout std_logic_vector(15 downto 0) := (others => 'Z');
			  -------DEBUG--------------
           state_out : out std_logic_vector (3 downto 0);
           DataReady : in STD_LOGIC;
           Tbre : in STD_LOGIC;
           Tsre : in STD_LOGIC);
end MemUart;

architecture Behavioral of MemUart is
	signal state: STD_LOGIC := '0';
	signal data : std_logic_vector (15 downto 0) := "0000000000000000";
	shared variable nready : std_logic := '1';
	
	signal addr_count : std_logic_vector(15 downto 0) := (others => '0');
	signal data_temp : std_logic_vector(15 downto 0) := (others => '0');
	signal boot_finish : boolean := false;
     
	signal state_boot : std_logic_vector(3 downto 0) := "0000";
	signal boot_clock_cnt : std_logic_vector (7 downto 0) := "00000000";
begin
		flash_byte <= '1';
		flash_vpen <= '1';
		flash_ce <= '0';
		flash_rp <= '1';
		boot_finish_out <= boot_finish;
		state_out <= "000" & state;
    process (exe_rf_res, mem_en, ramrwop, data1, state, data)
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
			boot_finish <= false;
			addr_count <= (others => '0');
			state_boot <= "0000";
		elsif rising_edge (clk) then
			if boot_finish then
				if state = '0' then
						 uartwrn <= '1';
					end if;
				if (state /= '0' and exe_rf_res(15 downto 2) = "10111111000000" and ramrwop = '0' and exe_rf_res(0) = '0' and mem_en = '1')
						 or (state = '0' and alures(15 downto 2) = "10111111000000" and ramrwop_lh = '0' and alures(0) = '0' and mem_en_lh = '1') then --read uart
					ram1en <= '1';		ram1we <= '1';		ram1oe <= '1';
						 addr2 <= pc_rf_pc;
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
						 addr2 <= pc_rf_pc;
					uartrdn <= '1';
						 case state is
							  when '1' => 
									if tbre = '1' and tsre = '1' then
										 uartwrn <= '0';
										 data1 (7 downto 0) <= mem_sw_data(7 downto 0);
									end if;
							  when others =>
									uartwrn <= '1';
						 end case;
				elsif (state /= '0' and exe_rf_res(15 downto 2) = "10111111000000" and ramrwop = '0' and exe_rf_res(0) = '1' and mem_en = '1') 
						 or (state = '0' and alures(15 downto 2) = "10111111000000" and ramrwop_lh = '0' and alures(0) = '1' and mem_en_lh = '1') then
					uartrdn <= '1';
						 uartwrn <= '1';
					ram1en <= '1';
					ram1we <= '1';
					ram1oe <= '1';
						 addr2 <= pc_rf_pc;
					data1 <= "ZZZZZZZZZZZZZZZZ";
					data <= "00000000000000" & dataready & (tbre and tsre);
				elsif (state /= '0' and exe_rf_res(15) = '1' and ramrwop = '0' and mem_en = '1')
						 or (state = '0' and alures(15) = '1' and ramrwop_lh = '0' and mem_en_lh = '1') then --read ram1
					uartrdn <= '1';
						 uartwrn <= '1';
						 addr2 <= pc_rf_pc;
					case state is
						when '0' =>
							ram1en <= '0';		ram1we <= '1';		ram1oe <= '0';
							addr1 <= alures;
							data1 <= "ZZZZZZZZZZZZZZZZ";
						when '1' =>
							data <= data1;
									ram1en <= '1';		ram1we <= '1';		ram1oe <= '1';
									data1 <= "ZZZZZZZZZZZZZZZZ";
						when others => null;
					end case;
				elsif (state /= '0' and exe_rf_res(15) = '1' and ramrwop = '1' and mem_en = '1')
						 or (state = '0' and alures(15) = '1' and ramrwop_lh = '1' and mem_en_lh = '1') then --write ram1  
					uartrdn <= '1';
						 uartwrn <= '1';
						 addr2 <= pc_rf_pc;
					case state is
						when '0' =>
							ram1en <= '0';		ram1we <= '1';		ram1oe <= '1';
						when '1' =>
							ram1we <= '0';
							addr1 <= exe_rf_res;
							data1 <= mem_sw_data;
						when others => null;
					end case;
					elsif (state /= '0' and exe_rf_res(15) = '0' and ramrwop = '0' and mem_en = '1')
						 or (state = '0' and alures(15) = '0' and ramrwop_lh = '0' and mem_en_lh = '1') then --read ram2
					ram1en <= '1';		ram1we <= '1';		ram1oe <= '1';
					uartrdn <= '1';
						 uartwrn <= '1';
						 case state is
							  when '0' =>
									addr2 <= alures;
							  when '1' =>
									data <= data2;
									addr2 <= pc_rf_pc;
							  when others =>
									addr2 <= pc_rf_pc;
						 end case;
					elsif (state /= '0' and exe_rf_res(15) = '0' and ramrwop = '1' and mem_en = '1')
						 or (state = '0' and alures(15) = '0' and ramrwop_lh = '1' and mem_en_lh = '1') then --write ram2
					ram1en <= '1';		ram1we <= '1';		ram1oe <= '1';
						 case state is
							  when '0' =>
									addr2 <= alures;
							  when '1' =>
									addr2 <= pc_rf_pc;
							  when others =>
									addr2 <= pc_rf_pc;
						 end case;
				else
					ram1en <= '1';		ram1we <= '1';		ram1oe <= '1';
					uartrdn <= '1';
						 uartwrn <= '1';
						 data1 <= "ZZZZZZZZZZZZZZZZ";
					uartrdn <= '1';
						 addr2 <= pc_rf_pc;
				end if;
				state <= not state;
			else
				if addr_count < x"3FFF" then -- boot
					boot_clock_cnt <= boot_clock_cnt + 1;
					if boot_clock_cnt = "00000000" then
						boot_finish <= false;
						case state_boot is
							  when "0000" => -- read
									flash_we <= '0';
									flash_data <= x"00FF";
									state_boot <= "0001";
							  when "0001" => 
									flash_we <= '1';
									state_boot <= "0010";
							  when "0010" =>
									flash_oe <= '0';
									flash_addr <= "000000"&addr_count;
									flash_data <= (others => 'Z');
									state_boot <= "0011";
							  when "0011" =>
									data_temp <= flash_data;
									flash_oe <= '1';
									state_boot <= "0100";
							  when "0100" =>
--									ram2en <= '0';
--									ram2we <= '1';
--									ram2oe <= '1';
									state_boot <= "0101";
							  when "0101" =>
--									ram2we <= '0';
									addr2 <= addr_count;
--									data2 <= data_temp;
									state_boot <= "0110";
							  when "0110" =>
									addr_count <= addr_count + 1;
									state_boot <= "0000";
							  when others => 
									state_boot <= "0000";
						end case;
					end if;
				else -- boot finish
					boot_finish <= true;
				end if;
			end if;
		end if;
	end process;
    
    process (clk)
    begin
        if rising_edge(clk) then
            if (state = '1' and exe_rf_res(15 downto 13) = "111" and ramrwop = '1' and mem_en = '1')then --write vga
                vga_en <= "1";
                vga_addr <= exe_rf_res (12 downto 0);
                vga_data <= mem_sw_data;
            else
                vga_en <= "0";
            end if;
        end if;
    end process;
    process (state, exe_rf_res, ramrwop, mem_en, pc_rf_pc, clk, mem_sw_data, boot_finish, state_boot, data_temp)
    begin
			if boot_finish then
			  if exe_rf_res(15) = '0' and ramrwop = '0' and mem_en = '1' then --read ram2
					case state is
						 when '1' =>
							  ram2en <= '0';		ram2we <= '1';		ram2oe <= '0';
	--                    addr2 <= exe_rf_res;
							  data2 <= "ZZZZZZZZZZZZZZZZ";
						 when '0' =>
							  ram2en <= '0';		ram2we <= '1';		ram2oe <= '0';
	--                    addr2 <= pc_rf_pc;
							  data2 <= "ZZZZZZZZZZZZZZZZ";
							  if_ins <= data2;
						 when others => null;
					end case;
			  elsif exe_rf_res(15) = '0' and ramrwop = '1' and mem_en = '1' then --write ram2
					case state is
						 when '1' =>
							  ram2en <= '0';
							  ram2oe <= '1';
							  ram2we <= '0';
	--                    addr2 <= exe_rf_res;
							  data2 <= mem_sw_data;
						 when '0' =>
							  ram2en <= '0';
							  ram2oe <= '0';
							  ram2we <= '1';
							  data2 <= "ZZZZZZZZZZZZZZZZ";
	--                    addr2 <= pc_rf_pc;
							  if_ins <= data2;
						 when others =>
							  ram2en <= '1';  ram2oe <= '1';  ram2we <= '1';
					end case;
			  else
					ram2en <= '0';
					ram2oe <= '0';
					ram2we <= '1';
					data2 <= "ZZZZZZZZZZZZZZZZ";
	--            addr2 <= pc_rf_pc;
					if_ins <= data2;
			  end if;
		  else
				case state_boot is
					  when "0101" =>
							ram2en <= '0';
							ram2we <= '1';
							ram2oe <= '1';
					  when "0110" =>
							ram2we <= '0';
							data2 <= data_temp;
					  when others => null;
				end case;
		  end if;
    end process;
    
end Behavioral;
