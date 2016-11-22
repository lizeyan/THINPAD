----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    11:15:22 11/18/2016 
-- Design Name: 
-- Module Name:    ControlUnit - Behavioral 
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

entity ControlUnit is
    Port ( 
           -- IF generate
           ExDigitsOp : out STD_LOGIC_VECTOR(2 downto 0); --传输到ExtendModule
           ExSignOp : out STD_LOGIC;
           PC_SRCOP : out STD_LOGIC_VECTOR(1 DOWNTO 0); -- --传送到PC寄存器
           -- ID
           AluOp : out STD_LOGIC_VECTOR(3 downto 0); -- 保存到ID_RF
           AMuxOp : out STD_LOGIC_VECTOR(3 downto 0); --
           BMuxOp : out STD_LOGIC_VECTOR(2 downto 0); --
           DirOp : out STD_LOGIC_VECTOR(2 downto 0); -- 传输到DirectionModule
           IDPCOp : out STD_LOGIC_VECTOR(1 downto 0); 
           
           RegWrbOp : out STD_LOGIC_VECTOR(1 downto 0);
           RXTOp : out STD_LOGIC_VECTOR(1 downto 0);
           SWSrc : out STD_LOGIC; -- 0 rx, 1 ry
           RamRWOp : out STD_LOGIC; -- 0 read, 1 write
           BTBOP : out STD_LOGIC; -- is jumping ins(1) or not(0)
                -- ENABLE  complex
           EXE_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           ID_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           IF_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           MEM_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           PC_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           -- EXE
           IF_EN : out STD_LOGIC; -- put it in pc_rf. !!! NOT COMPLETED
           
           IF_Ins : in STD_LOGIC_VECTOR(15 downto 0);
           IF_RF_OP : in STD_LOGIC_VECTOR(4 downto 0);
			  IF_RF_ST: in STD_LOGIC_VECTOR (15 downto 0); -- IF段寄存器中保存的，指令的内容。因为有的指令需要判断funct字段
           ID_RF_OP : in STD_LOGIC_VECTOR(4 downto 0); 
           ID_RF_Rd : in STD_LOGIC_VECTOR(3 downto 0);
           EXE_RF_OP : in STD_LOGIC_VECTOR(4 downto 0);
           EXE_RF_Rd : in STD_LOGIC_VECTOR(3 downto 0)
           
           
           );
end ControlUnit;

architecture Behavioral of ControlUnit is
    
begin
	-- 产生目标寄存器选项的控制码，之后需要将其传输到DirectionModule
	-- 产生ALU操作码，之后需要将其保存到ID_RF
	-- 使用ID段得到的IF_RD_OP
	process (IF_RF_OP)
		variable op: STD_LOGIC_VECTOR (4 downto 0);
		variable dir: STD_LOGIC_VECTOR (2 downto 0); -- 我太懒
	begin
		op := if_rf_st (15 downto 11);
		case op is
            when "01001" => -- addiu
					aluop <= "0000";
					dir := "000";
            when "01000" => -- addiu3
					aluop <= "0000";
					dir := "001";
            when "01100" => --addsp, bteqz, mtsp
					case if_rf_st (10 downto 8) is
						when "011" => -- addsp
							aluop <= "0000";
							dir := "010";
						when "000" => --btnez
							aluop <= "0110";
							dir := "111";
						when "100" => --mtsp
							aluop <= "0011";
							dir := "010";
						when others =>
							aluop <= "1111";
							dir := "111";
					end case;
            when "00000" => --addsp3
					aluop <= "0000";
					dir := "000";
            when "00010" => -- b
					aluop <= "0000";
					dir := "111";
            when "00100" => -- beqz
					aluop <= "0110";
					dir := "111";
            when "00101" => -- bnez
					aluop <= "0110";
					dir := "111";
            when "01110" => -- cmpi
					aluop <= "0110";
					dir := "100";
            when "01101" => -- li
					aluop <= "0011";
					dir := "000";
            when "10011" => -- lw
					aluop <= "0000";
					dir := "001";
            when "10010" => -- lw_sp
					aluop <= "0000";
					dir := "000";
            when "00110" => -- sll, sra
					case if_rf_st(1 downto 0) is
					when "00" =>
						aluop <= "0111";
						dir := "000";
					when "11" =>
						aluop <= "0100";
						dir := "000";
					when others =>
						aluop <= "1111";
						dir := "111";
					end case;
            when "01010" => -- slti
					aluop <= "0001";
					dir := "100";
				when "01111" => --move
					aluop <= "0011";
					dir := "000";
            when "11011" => -- sw
					aluop <= "0000";
					dir := "111";
            when "11010" => -- swsp
					aluop <= "0000";
					dir := "111";
				when "11100" => 
					case if_rf_st(1 downto 0) is
						when "01" => --addu
							aluop <= "0000";
							dir := "011";
						when "11" => --subu
							aluop <= "0001";
							dir := "011";
						when others =>
							aluop <= "1111";
							dir := "111";
					end case;
				when "11101" =>
					case if_rf_st(4 downto 0) is
						when "01100" => -- and
							aluop <= "0011";
							dir := "000";
						when "01010" => --cmp
							aluop <= "0110";
							dir := "100";
						when "11101" => --or
							aluop <= "0010";
							dir := "000";
						when "00100" => -- sllv
							aluop <= "0101";
							dir := "001";
						when "00000" => --mfpc
							aluop <= "0010";
							dir := "000";
						when others =>
							aluop <= "1111";
							dir := "111";
					end case;
				when "11110" =>
					aluop <= "0010";
					case if_rf_st(0) is
						when '0' => -- mfih
							dir := "000";
						when '1' => -- mtih
							dir := "110";
						when others =>
							dir := "111";
					end case;
            when others =>
					aluop <= "1111";
					dir := "111";
			end case;
			dirop <= dir;
	end process;

	-- 产生立即数扩展的控制信号
	-- 使用IF段的得到的IF_INS
    process(IF_Ins)
	-- EX Digits Op
	-- 000 10:0
	-- 001 7:0
	-- 011 4:0
	-- 010 4:2
	-- 110 3:0
	-- others Z... (ILLEGAL)
    begin
        case IF_Ins(15 downto 11) is
            when "01001" => -- addiu
            	ExDigitsOp <= "001";
           		ExSignOp <= '1';
            when "01000" => -- addiu3
            	ExDigitsOp <= "110";
           		ExSignOp <= '1';
            when "01100" => --addsp, bteqz, mtsp
            	if(IF_Ins(10 downto 8)="000" or IF_Ins(10 downto 8)="011") then
            		ExDigitsOp <= "001";
           			ExSignOp <= '1';
           		else
           		end if;
            when "00000" => --addsp3
            	ExDigitsOp <= "001";
           		ExSignOp <= '1';
            when "00010" => -- b
            	ExDigitsOp <= "000";
           		ExSignOp <= '1';
            when "00100" => -- beqz
            	ExDigitsOp <= "001";
           		ExSignOp <= '1';
            when "00101" => -- bnez
            	ExDigitsOp <= "001";
           		ExSignOp <= '1';
            when "01110" => -- cmpi
            	ExDigitsOp <= "001";
           		ExSignOp <= '1';
            when "01101" => -- li
            	ExDigitsOp <= "001";
           		ExSignOp <= '0';
            when "10011" => -- lw
            	ExDigitsOp <= "011";
           		ExSignOp <= '1';
            when "10010" => -- lw_sp
            	ExDigitsOp <= "001";
           		ExSignOp <= '1';
            when "00110" => -- sll, sra
            	ExDigitsOp <= "010";
           		ExSignOp <= '0';
            when "01010" => -- slti
            	ExDigitsOp <= "001";
           		ExSignOp <= '1';
            when "11011" => -- sw
            	ExDigitsOp <= "011";
           		ExSignOp <= '1';
            when "11010" => -- swsp
            	ExDigitsOp <= "001";
           		ExSignOp <= '1';
            when others =>
            	ExDigitsOp <= "111";
           		ExSignOp <= '1';
        end case;
    end process;
    
	 
	-- template
	process
	variable op: STD_LOGIC_VECTOR (4 downto 0);
	begin
		op := if_rf_st (15 downto 11);
		case op is
            when "01001" => -- addiu
            when "01000" => -- addiu3
            when "01100" => 
					case if_rf_st (10 downto 8) is
						when "011" => -- addsp
						when "000" => --btnez
						when "100" => --mtsp
						when others =>
					end case;
            when "00000" => --addsp3
            when "00010" => -- b
            when "00100" => -- beqz
            when "00101" => -- bnez
            when "01110" => -- cmpi
            when "01101" => -- li
            when "10011" => -- lw
            when "10010" => -- lw_sp
            when "00110" => -- sll, sra
					case if_rf_st(1 downto 0) is
						when "00" =>
						when "11" =>
						when others =>
					end case;
            when "01010" => -- slti
				when "01111" => --move
            when "11011" => -- sw
            when "11010" => -- swsp
				when "11100" => 
					case if_rf_st(1 downto 0) is
						when "01" => --addu
						when "11" => --subu
						when others =>
					end case;
				when "11101" =>
					case if_rf_st(4 downto 0) is
						when "01100" => -- add
						when "01010" => --cmp
						when "11101" => --or
						when "00100" => -- sllv
						when "00000" => --mfpc
						when others =>
					end case;
				when "11110" => --mfih and mtih
            when others =>
			end case;
	end process;
end Behavioral;
