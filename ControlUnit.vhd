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
           ExDigitsOp : out STD_LOGIC_VECTOR(2 downto 0); --���䵽ExtendModule
           ExSignOp : out STD_LOGIC;
           PC_SRCOP : out STD_LOGIC_VECTOR(1 DOWNTO 0); -- --���͵�PC�Ĵ���
           -- ID
           AluOp : out STD_LOGIC_VECTOR(3 downto 0); -- ���浽ID_RF
           AMuxOp : out STD_LOGIC_VECTOR(3 downto 0); --
           BMuxOp : out STD_LOGIC_VECTOR(2 downto 0); --
           DirOp : out STD_LOGIC_VECTOR(2 downto 0); -- ���䵽DirectionModule
           IDPCOp : out STD_LOGIC_VECTOR(1 downto 0); 
           
           RegWrbOp : out STD_LOGIC_VECTOR(1 downto 0); -- �Ĵ���д�����ݵ�ѡ�� -- ���浽ID_RF
           RXTOp : out STD_LOGIC_VECTOR(1 downto 0);
           SWSrc : out STD_LOGIC; -- 0 rx, 1 ry --���浽ID_RF
           RamRWOp : out STD_LOGIC; -- 0 read, 1 write --���浽ID_RF
           BTBOP : out STD_LOGIC; -- is jumping ins(1) or not(0)
                -- ENABLE  complex
           EXE_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           ID_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           IF_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           MEM_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           PC_RFOp : out STD_LOGIC_VECTOR(2 downto 0);
           -- EXE
           IF_EN : out STD_LOGIC; -- put it in pc_rf. !!! NOT COMPLETED
           
			  -- ��IF�θոմ��ڴ���ȡ�������ʵ�ָ��
			  PC_RF_PC: in STD_LOGIC_VECTOR (15 downto 0);
           IF_Ins : in STD_LOGIC_VECTOR(15 downto 0);
           IF_RF_OP : in STD_LOGIC_VECTOR(4 downto 0);
			  IF_RF_ST: in STD_LOGIC_VECTOR (15 downto 0); -- IF�μĴ����б���ģ�ָ������ݡ���Ϊ�е�ָ����Ҫ�ж�funct�ֶ�
			  IDPC: in STD_LOGIC_VECTOR (15 downto 0); -- IDPCRXT������IDPC
           ID_RF_OP : in STD_LOGIC_VECTOR(4 downto 0); 
           ID_RF_Rd : in STD_LOGIC_VECTOR(3 downto 0);
           EXE_RF_OP : in STD_LOGIC_VECTOR(4 downto 0);
           EXE_RF_Rd : in STD_LOGIC_VECTOR(3 downto 0);
           MEM_RF_OP : in STD_LOGIC_VECTOR(4 downto 0);
           MEM_RF_Rd : in STD_LOGIC_VECTOR(3 downto 0)
           );
end ControlUnit;

architecture Behavioral of ControlUnit is
	---------------------------------------------------------------------------------------------
    function last_lw_rd (signal x: STD_LOGIC_VECTOR (3 downto 0)) 
		return boolean is
	 begin
		return ((ID_RF_RD = x) and (ID_RF_OP = "10010" or ID_RF_OP = "10011"));
	 end last_lw_rd;
	 -----------------------------------------------------------------------------------------------
	 -- 111�Ƿ�����ʾNone
	 signal PC_SRC_IF, PC_SRC_ID, PC_SRC_EXE, PC_SRC_MEM, PC_SRC_WB: STD_LOGIC_VECTOR (2 downto 0) := "000";
begin
	-- ����MEM_RFOP

	-- ����EXE_RFOP

	-- ����ID_RFOP

	-- ����IF_RFOP
	process (if_rf_st)
	begin
		case if_rf_st(15 downto 11) is
            when "01001" => -- addiu
					if last_lw_rd ('0' & if_rf_st(10 downto 8)) then
						if_rfop <= "10";
					else
						if_rfop <= "00";
					end if;
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
						when "00000" => 
							if if_rf_st(7 downto 5) = "0000" then --jr
							elsif if_rf_st(7 downto 5) = "0100" then --mfpc
							else
							end if;
						when others =>
					end case;
				when "11110" => --mfih and mtih
            when others =>
			end case;
	end process;

	-- ����RXTOP��Ȼ�󴫸�IDPCRXTʹ�ã�������
	-- ʹ��IF�μĴ����е�ָ���ֶ�
	-- TODO
	process (if_rf_st)
		-- 00 x
		-- 10 exe_rf_res
		-- 11 mem_rf_lw
		-- 01 mem_rf_res
		function look_ahead_more (signal x: STD_LOGIC_VECTOR(3 downto 0))
			return STD_LOGIC_VECTOR is
				variable rxtop: STD_LOGIC_VECTOR (1 downto 0);
		begin
			if id_rf_rd = x then --��Ҫ�ȴ�һ�غϣ���������ѡ���ﲢ���ؼ�
				rxtop := "00";
			else
				if exe_rf_rd = x then --�������lwָ���ô����ȷ������ǵĻ���������Ҫ�ȴ�һ�غϣ����Բ����ؼ�
					rxtop := "10";
				else
					if mem_rf_rd = x then
						if mem_rf_op = "10011" or mem_rf_op = "10010" then
							rxtop := "11";
						else
							rxtop := "01";
						end if;
					else
						rxtop := "00";
					end if;
				end if;
			end if;
			return rxtop;
		end look_ahead_more;
		
		variable looked_ahead: STD_LOGIC_VECTOR(1 downto 0) := "00";
	begin
		if if_rf_st(15 downto 11) = "00010" then --b
			rxtop <= "ZZ";
		elsif if_rf_st(15 downto 11) = "00100" then --beqz
			looked_ahead := look_ahead_more ('0' & if_rf_st(10 downto 8)); 
		elsif if_rf_st(15 downto 11) = "00101" then --bnez
			looked_ahead := look_ahead_more ('0' & if_rf_st(10 downto 8));
		elsif if_rf_st(15 downto 8) = "01100000" then --bteqz
			looked_ahead := look_ahead_more ("1010");
		elsif if_rf_st(15 downto 11) = "11101" and if_rf_st(7 downto 0) = "00000000" then --jr
			looked_ahead := look_ahead_more ('0' & if_rf_st(10 downto 8));
		else
			rxtop <= "ZZ";
		end if;
	end process;
	-- ����IDPCOP��Ȼ�󴫸�IDPCRXTʹ�ã�������
	-- ʹ��IF�μĴ����е�ָ���ֶ�
	process (if_rf_st)
	begin
		if if_rf_st(15 downto 11) = "00010" then --b
			idpcop <= "10";
		elsif if_rf_st(15 downto 11) = "00100" then --beqz
			idpcop <= "00";
		elsif if_rf_st(15 downto 11) = "00101" then --bnez
			idpcop <= "01";
		elsif if_rf_st(15 downto 8) = "01100000" then --bteqz
			idpcop <= "00";
		elsif if_rf_st(15 downto 11) = "11101" and if_rf_st(7 downto 0) = "00000000" then --jr
			idpcop <= "11";
		else
			idpcop <= "ZZ";
		end if;
	end process;
	--------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------
	-- ����PC_RFOP
	-- pc_src_if
	-- ����INTӦ�õ��쳣�����ַ����Ķ�Ӧ�õ�Ԥ���ַ
	process (if_ins)
	begin
		if if_ins(15 downto 11) = "11111" then --intָ��
			pc_src_if <= "010";
		else
			pc_src_if <= "000";
		end if;
	end process;
	-- pc_src_id
	-- ����תָ���PDT
	-- ��תָ��Ƚ�Ŀ���PC_RF_PC����ͬ����PDT���������IDPC
	process (if_rf_st)
	begin
		if idpc = pc_rf_pc then
			pc_src_id <= "000";
		else
			pc_src_id <= "001";
		end if;
	end process;
	-- pc_src_exe
	pc_src_exe <= "111";
	-- pc_src_mem
	pc_src_mem <= "111";
	-- pc_src_wb
	pc_src_wb <= "111";
	--�ۺ�
	process (pc_src_if, pc_src_id, pc_src_exe, pc_src_mem, pc_src_wb)
	begin
		if pc_src_wb = "111" then
			if pc_src_mem = "111" then
				if pc_src_exe = "111" then
					if pc_src_id = "111" then
						pc_rfop <= pc_src_if;
					else
						pc_rfop <= pc_src_id;
					end if;
				else
					pc_rfop <= pc_src_exe;
				end if;
			else
				pc_rfop <= pc_src_mem;
			end if;
		else
			pc_rfop <= pc_src_wb;
		end if;
	end process;
	--------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------
	--------------------------------------------------------------------------------------------

	-- ����regwrbop, ��֮����Ҫ���䱣�浽ID_RF
	-- ����ramrwop��֮����Ҫ���䱣�浽ID_RF
	-- ����mem_sw_srcop��֮����Ҫ���䱣�浽ID_RF
	-- ����Ŀ��Ĵ���ѡ��Ŀ����룬֮����Ҫ���䴫�䵽DirectionModule
	-- ����ALU�����룬֮����Ҫ���䱣�浽ID_RF
	-- ʹ��ID�εõ���IF_RD_OP
	process (IF_RF_ST)
		variable op: STD_LOGIC_VECTOR (4 downto 0);
		variable dir: STD_LOGIC_VECTOR (2 downto 0); -- 
	begin
		op := if_rf_st (15 downto 11);
		case op is
            when "01001" => -- addiu
					aluop <= "0000";
					dir := "000";
					regwrbop <= "00";
					ramrwop <= '0';
					swsrc <= '0';
            when "01000" => -- addiu3
					aluop <= "0000";
					dir := "001";
					regwrbop <= "00";
					ramrwop <= '0';
					swsrc <= '0';
            when "01100" => --addsp, bteqz, mtsp
					ramrwop <= '0';
					swsrc <= '0';
					case if_rf_st (10 downto 8) is
						when "011" => -- addsp
							aluop <= "0000";
							dir := "010";
							regwrbop <= "00";
						when "000" => --btnez
							aluop <= "0110";
							dir := "111";
							regwrbop <= "11";
						when "100" => --mtsp
							aluop <= "0011";
							dir := "010";
							regwrbop <= "00";
						when others =>
							aluop <= "1111";
							dir := "111";
							regwrbop <= "11";
					end case;
            when "00000" => --addsp3
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0000";
					dir := "000";
					regwrbop <= "00";
            when "00010" => -- b
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0000";
					dir := "111";
					regwrbop <= "11";
            when "00100" => -- beqz
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0110";
					dir := "111";
					regwrbop <= "11";
            when "00101" => -- bnez
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0110";
					dir := "111";
					regwrbop <= "11";
            when "01110" => -- cmpi
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0110";
					dir := "100";
					regwrbop <= "10";
            when "01101" => -- li
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0011";
					dir := "000";
					regwrbop <= "00";
            when "10011" => -- lw
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0000";
					dir := "001";
					regwrbop <= "01";
            when "10010" => -- lw_sp
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0000";
					dir := "000";
					regwrbop <= "01";
            when "00110" => 
					ramrwop <= '0';
					swsrc <= '0';
					case if_rf_st(1 downto 0) is
					when "00" => --sll
						aluop <= "0111";
						dir := "000";
						regwrbop <= "00";
					when "11" =>
						aluop <= "0100"; --sra
						dir := "000";
						regwrbop <= "00";
					when others =>
						aluop <= "1111";
						dir := "111";
					end case;
            when "01010" => -- slti
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0001";
					dir := "100";
					regwrbop <= "00";
				when "01111" => --move
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0011";
					dir := "000";
					regwrbop <= "00";
            when "11011" => -- sw
					aluop <= "0000";
					dir := "111";
					ramrwop <= '1';
					swsrc <= '1';
					regwrbop <= "11";
            when "11010" => -- swsp
					aluop <= "0000";
					dir := "111";
					ramrwop <= '1';
					swsrc <= '0';
					regwrbop <= "11";
				when "11100" => 
					ramrwop <= '0';
					swsrc <= '0';
					case if_rf_st(1 downto 0) is
						when "01" => --addu
							aluop <= "0000";
							dir := "011";
							regwrbop <= "00";
						when "11" => --subu
							aluop <= "0001";
							regwrbop <= "00";
							dir := "011";
						when others =>
							aluop <= "1111";
							dir := "111";
					end case;
				when "11101" =>
					ramrwop <= '0';
					swsrc <= '0';
					case if_rf_st(4 downto 0) is
						when "01100" => -- and
							aluop <= "0011";
							dir := "000";
							regwrbop <= "00";
						when "01010" => --cmp
							aluop <= "0110";
							dir := "100";
							regwrbop <= "10";
						when "11101" => --or
							aluop <= "0010";
							dir := "000";
							regwrbop <= "00";
						when "00100" => -- sllv
							aluop <= "0101";
							dir := "001";
							regwrbop <= "00";
						when "00000" => --mfpc
							aluop <= "0010";
							dir := "000";
							regwrbop <= "00";
						when others =>
							aluop <= "1111";
							dir := "111";
							regwrbop <= "11";
					end case;
				when "11110" =>
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0010";
					case if_rf_st(0) is
						when '0' => -- mfih
							dir := "000";
							regwrbop <= "00";
						when '1' => -- mtih
							dir := "110";
							regwrbop <= "00";
						when others =>
							dir := "111";
							regwrbop <= "11";
					end case;
            when others =>
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "1111";
					dir := "111";
					regwrbop <= "11";
			end case;
			dirop <= dir;
	end process;

	-- ������������չ�Ŀ����ź�
	-- ʹ��IF�εĵõ���IF_INS
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
						when "00000" => 
							if if_rf_st(7 downto 5) = "0000" then --jr
							elsif if_rf_st(7 downto 5) = "0100" then --mfpc
							else
							end if;
						when others =>
					end case;
				when "11110" => --mfih and mtih
            when others =>
			end case;
	end process;
end Behavioral;
