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
           
           RegWrbOp : out STD_LOGIC_VECTOR(1 downto 0); -- 寄存器写回数据的选择 -- 保存到ID_RF
           RXTOp : out STD_LOGIC_VECTOR(2 downto 0);
           SWSrc : out STD_LOGIC; -- 0 rx, 1 ry --保存到ID_RF
           RamRWOp : out STD_LOGIC; -- 0 read, 1 write --保存到ID_RF
           BTBOP : out STD_LOGIC; -- is jumping ins(1) or not(0)
                -- ENABLE  complex
           EXE_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           ID_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           IF_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           MEM_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           PC_RFOp : out STD_LOGIC_VECTOR(2 downto 0);
           -- EXE
           IF_EN : out STD_LOGIC; -- put it in pc_rf. !!! NOT COMPLETED
           
			  -- 在IF段刚刚从内存中取出的新鲜的指令
			  PC_RF_PC: in STD_LOGIC_VECTOR (15 downto 0);
           IF_Ins : in STD_LOGIC_VECTOR(15 downto 0);
           IF_RF_OP : in STD_LOGIC_VECTOR(4 downto 0);
			  IF_RF_ST: in STD_LOGIC_VECTOR (15 downto 0); -- IF段寄存器中保存的，指令的内容。因为有的指令需要判断funct字段
			  IDPC: in STD_LOGIC_VECTOR (15 downto 0); -- IDPCRXT产生的IDPC
           ID_RF_OP : in STD_LOGIC_VECTOR(4 downto 0); 
           ID_RF_Rd : in STD_LOGIC_VECTOR(3 downto 0);
           EXE_RF_OP : in STD_LOGIC_VECTOR(4 downto 0);
           EXE_RF_Rd : in STD_LOGIC_VECTOR(3 downto 0);
			  EXE_Fout : in STD_LOGIC_VECTOR (15 downto 0); -- ALU的即时输出
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
	 -- 111非法，表示None
	 signal PC_SRC_IF, PC_SRC_ID, PC_SRC_EXE, PC_SRC_MEM, PC_SRC_WB: STD_LOGIC_VECTOR (2 downto 0) := "000";
begin
	-- 产生MEM_RFOP

	-- 产生EXE_RFOP

	-- 产生ID_RFOP

	-- 产生IF_RFOP
	
	process (if_rf_st, pc_rf_pc, idpc, id_rf_op, id_rf_rd, exe_rf_op, exe_rf_rd)
		variable target_failed : boolean := false; --跳转指令发现预测失败
		variable last_lw_rd, last_last_lw_rd, last_rd : boolean := false; --发现数据冲突
		variable written_st: boolean := false; --发现之后有sw指令在写入该指令的地址
		--------------------------------------------------------------------------------------------------
		procedure data_conflict (x: in std_logic_vector(3 downto 0);
--														signal id_rf_rd, exe_rf_rd: in std_logic_vector (3 downto 0);
--														signal id_rf_op, exe_rf_op: in std_logic_vector (4 downto 0);
													  last_rd, last_lw_rd, last_last_lw_rd: out boolean) is
		begin
			last_rd := id_rf_rd = x;
			last_lw_rd := (id_rf_rd = x) and (id_rf_op = "10011" or id_rf_op = "10010");
			last_last_lw_rd := (exe_rf_op = "10011" or exe_rf_op = "10010") and exe_rf_rd = x;
		end data_conflict;
		procedure data_conflict (x, y: in std_logic_vector(3 downto 0);
--														signal id_rf_rd, exe_rf_rd: in std_logic_vector (3 downto 0);
--														signal id_rf_op, exe_rf_op: in std_logic_vector (4 downto 0);
													  last_rd, last_lw_rd, last_last_lw_rd: out boolean) is
		begin
			last_rd := id_rf_rd = x or id_rf_rd = y;
			last_lw_rd := (id_rf_rd = x or id_rf_rd = y) and (id_rf_op = "10011" or id_rf_op = "10010");
			last_last_lw_rd := (exe_rf_op = "10011" or exe_rf_op = "10010") and (exe_rf_rd = x or exe_rf_rd = y);
		end data_conflict;
		
		procedure normal_ins(last_rd, last_lw_rd, last_last_lw_rd, written_st, taregt_failed: in boolean) is
		begin
				if written_st then
					if_rfop <= "11";
				elsif last_lw_rd then
					if_rfop <= "10";
				else
					if_rfop <= "00";
				end if;
		end normal_ins;
		
		procedure branch_ins(last_rd, last_lw_rd, last_last_lw_rd, written_st, taregt_failed: in boolean) is
		begin
			if written_st or (target_failed and not (last_rd or last_last_lw_rd)) then
				if_rfop <= "11";
			elsif last_rd or last_last_lw_rd then
				if_rfop <= "10";
			else
				if_rfop <= "00";
			end if;
		end normal_ins;
	begin
		target_failed := idpc /= pc_rf_pc;
		---------------------------------------------------------------------------------
		written_st := (id_rf_op = "11011" or id_rf_op = "11010") and exe_fout = pc_rf_pc;
		---------------------------------------------------------------------------------
		case if_rf_st(15 downto 11) is
			when "01001" => -- addiu
				data_conflict (x => '0' & if_rf_st(10 downto 8), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
				if written_st then
					if_rfop <= "11";
				elsif last_lw_rd then
					if_rfop <= "10";
				else
					if_rfop <= "00";
				end if;
			when "01000" => -- addiu3
				data_conflict (x => '0' & if_rf_st(10 downto 8), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
			when "01100" => 
				case if_rf_st (10 downto 8) is
					when "011" => -- addsp
						data_conflict (x => "1001", last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
					when "000" => --btnez
						data_conflict (x => "1010", last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
					when "100" => --mtsp
							data_conflict (x => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
					when others =>
				end case;
			when "00000" => --addsp3
				data_conflict (x => "1001", last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
			when "00010" => -- b
			when "00100" => -- beqz
				data_conflict (x => '0' & if_rf_st(10 downto 8), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
			when "00101" => -- bnez
				data_conflict (x => '0' & if_rf_st(10 downto 8), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
			when "01110" => -- cmpi
				data_conflict (x => '0' & if_rf_st(10 downto 8), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
			when "01101" => -- li
			when "10011" => -- lw
				data_conflict (x => '0' & if_rf_st(10 downto 8), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
			when "10010" => -- lw_sp
				data_conflict (x => "1001", last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
			when "00110" => -- sll, sra
				case if_rf_st(1 downto 0) is
					when "00" =>
						data_conflict (x => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
					when "11" =>
						data_conflict (x => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
					when others =>
				end case;
			when "01010" => -- slti
				data_conflict (x => '0' & if_rf_st(10 downto 8), y => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
			when "01111" => --move
				data_conflict (x => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
			when "11011" => -- sw
				data_conflict (x => '0' & if_rf_st(10 downto 8), y => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
			when "11010" => -- swsp
				data_conflict (x => '0' & if_rf_st(10 downto 8), y => "1001", last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
			when "11100" => 
				case if_rf_st(1 downto 0) is
					when "01" => --addu
						data_conflict (x => '0' & if_rf_st(10 downto 8), y => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
					when "11" => --subu
						data_conflict (x => '0' & if_rf_st(10 downto 8), y => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
					when others =>
				end case;
			when "11101" =>
				case if_rf_st(4 downto 0) is
					when "01100" => -- add
					when "01010" => --cmp
						data_conflict (x => '0' & if_rf_st(10 downto 8), y => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
					when "11101" => --or
						data_conflict (x => '0' & if_rf_st(10 downto 8), y => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
					when "00100" => -- sllv
						data_conflict (x => '0' & if_rf_st(10 downto 8), y => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
					when "00000" => 
						if if_rf_st(7 downto 5) = "0000" then --jr
							data_conflict (x => '0' & if_rf_st(10 downto 8), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
						elsif if_rf_st(7 downto 5) = "0100" then --mfpc
						else
						end if;
					when others =>
				end case;
			when "11110" => --mfih and mtih
				case if_rf_st(0) is
						when '0' => -- mfih
						when '1' => -- mtih
							data_conflict (x => '0' & if_rf_st(10 downto 8), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
						when others =>
					end case;
			when others =>
		end case;
	end process;

	-- 产生RXTOP，然后传给IDPCRXT使用，不保存
	-- 使用IF段寄存器中的指令字段
	process (if_rf_st)
		-- 00 x
		-- 10 exe_rf_res
		-- 11 mem_rf_lw
		-- 01 mem_rf_res
		variable x : STD_LOGIC_VECTOR (3 downto 0) := "1111"; --这条指令需要的寄存器的地址
	begin
		-- 确认这条跳转指令需要的寄存器地址
		if if_rf_st(15 downto 11) = "00010" then --b
			x := "1111";
		elsif if_rf_st(15 downto 11) = "00100" then --beqz
			x := '0' & if_rf_st (10 downto 8);
		elsif if_rf_st(15 downto 11) = "00101" then --bnez
			x := '0' & if_rf_st (10 downto 8);
		elsif if_rf_st(15 downto 8) = "01100000" then --bteqz
			x := "1010";
		elsif if_rf_st(15 downto 11) = "11101" and if_rf_st(7 downto 0) = "00000000" then --jr
			x := '0' & if_rf_st (10 downto 8);
		else
			x := "1111";
		end if;
		-- 如果有必要取寄存器的值
		if x /= "1111" then --就查看之前指令的情况并使用数据旁路
			if id_rf_rd = x then --如果上一条指令地址相同，需要等待一回合，所以这里选这里并不关键
				rxtop <= "000"; -- useless
			else
				if exe_rf_rd = x then --如果上上条指令不是lw指令，那么就正确。如果是的话，这里需要等待一回合，所以并不关键
					rxtop <= "010";
				else
					if mem_rf_rd = x then
						if mem_rf_op = "10011" or mem_rf_op = "10010" then
							rxtop <= "011";
						else
							rxtop <= "100";
						end if;
					else
						if x = "1010" then
							rxtop <= "001";
						else
							rxtop <= "000";
						end if;
					end if;
				end if;
			end if;
		else --如果没必要
			rxtop <= "111"; --就给出非法控制信号
		end if;
	end process;
	-- 产生IDPCOP，然后传给IDPCRXT使用，不保存
	-- 使用IF段寄存器中的指令字段
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
	-- 产生PC_RFOP
	-- pc_src_if
	-- 除了INT应该到异常处理地址，别的都应该到预测地址
	process (if_ins)
	begin
		if if_ins(15 downto 11) = "11111" then --int指令
			pc_src_if <= "010";
		else
			pc_src_if <= "000";
		end if;
	end process;
	-- pc_src_id
	-- 非跳转指令都是PDT
	-- 跳转指令比较目标和PC_RF_PC，相同就是PDT，否则就是IDPC
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
	--综合
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

	-- 产生regwrbop, ，之后需要将其保存到ID_RF
	-- 产生ramrwop，之后需要将其保存到ID_RF
	-- 产生mem_sw_srcop，之后需要将其保存到ID_RF
	-- 产生目标寄存器选项的控制码，之后需要将其传输到DirectionModule
	-- 产生ALU操作码，之后需要将其保存到ID_RF
	-- 使用ID段得到的IF_RD_OP
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
