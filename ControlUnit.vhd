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
           
           -- ID
           AluOp : out STD_LOGIC_VECTOR(3 downto 0); -- 保存到ID_RF
           AMuxOp : out STD_LOGIC_VECTOR(3 downto 0); --
           BMuxOp : out STD_LOGIC_VECTOR(2 downto 0); --
           DirOp : out STD_LOGIC_VECTOR(2 downto 0); -- 传输到DirectionModule
           IDPCOp : out STD_LOGIC_VECTOR(1 downto 0); 
           
           RegWrbOp : out STD_LOGIC_VECTOR(1 downto 0); -- 寄存器写回数据的选择 -- 保存到ID_RF
           RXTOp : out STD_LOGIC_VECTOR(2 downto 0);
           SWSrc : out STD_LOGIC; -- 0 rx, 1 ry --保存到ID_RF
			  SWMUXOP : out STD_LOGIC_VECTOR (2 downto 0);
           RamRWOp : out STD_LOGIC; -- 0 read, 1 write --保存到ID_RF
           memen : out std_logic;
           BTBOP : out STD_LOGIC; -- is jumping ins(1) or not(0)
           
           -- ENABLE  complex
           EXE_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           ID_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           IF_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           MEM_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
           PC_RFOp : out STD_LOGIC_VECTOR(2 downto 0);
			  PC_RFWE: out STD_LOGIC;
           
           -- 在IF段刚刚从内存中取出的新鲜的指令
           PC_RF_PC: in STD_LOGIC_VECTOR (15 downto 0);
           IF_Ins : in STD_LOGIC_VECTOR(15 downto 0);
           
           IF_RF_OP : in STD_LOGIC_VECTOR(4 downto 0);
           IF_RF_ST: in STD_LOGIC_VECTOR (15 downto 0); -- IF段寄存器中保存的，指令的内容。因为有的指令需要判断funct字段
           IF_RF_OPC : in STD_LOGIC_VECTOR (15 downto 0);
           IDPC: in STD_LOGIC_VECTOR (15 downto 0); -- IDPCRXT产生的IDPC
           ID_RF_OP : in STD_LOGIC_VECTOR(4 downto 0); 
           ID_RF_Rd : in STD_LOGIC_VECTOR(3 downto 0);
           EXE_RF_OP : in STD_LOGIC_VECTOR(4 downto 0);
           EXE_RF_Rd : in STD_LOGIC_VECTOR(3 downto 0);
           EXE_Res : in STD_LOGIC_VECTOR (15 downto 0); -- ALU的即时输出
           MEM_RF_OP : in STD_LOGIC_VECTOR(4 downto 0);
           MEM_RF_Rd : in STD_LOGIC_VECTOR(3 downto 0)
           );
end ControlUnit;

architecture Behavioral of ControlUnit is
	---------------------------------------------------------------------------------------------
    impure function last_lw_rd (signal x: STD_LOGIC_VECTOR (3 downto 0)) 
		return boolean is
			variable ret : boolean := false;
	 begin
		ret := ((ID_RF_RD = x) and (ID_RF_OP = "10010" or ID_RF_OP = "10011"));
		return ret;
	 end last_lw_rd;
	 -----------------------------------------------------------------------------------------------
	 -- 111非法，表示None
	 signal PC_SRC_IF, PC_SRC_ID, PC_SRC_EXE, PC_SRC_MEM, PC_SRC_WB: STD_LOGIC_VECTOR (2 downto 0) := "000";
begin
	-- SWMUXOP
	process (if_rf_st, id_rf_op, id_rf_rd, exe_rf_op, exe_rf_rd)
		variable target : std_logic_vector (3 downto 0) := "1111";
	begin
		if if_rf_st(15 downto 11) = "11011" then
			target := '0' & if_rf_st (7 downto 5);
		elsif if_rf_st (15 downto 11) = "11010" then
			target := '0' & if_rf_st (10 downto 8);
		else
			target := "1111";
		end if;
		if id_rf_rd = target and id_rf_rd /= "1111" then
			if id_rf_op = "10011" or id_rf_op = "10010" then
				swmuxop <= "010";
			else
				swmuxop <= "011";
			end if;
		elsif exe_rf_rd = target and exe_rf_rd /= "1111" then
			if exe_rf_op = "10011" or exe_rf_op = "10010" then
				swmuxop <= "000";
			else
				swmuxop <= "001";
			end if;
		else
			swmuxop <= "111";
		end if;
	end process;
	--BMUXOP
	process (if_rf_st, id_rf_op, id_rf_rd, exe_rf_op, exe_rf_rd)
    -- BMuxOp
    -- 000 | EXE_RF_Res
    -- 001 | ID_RF_Imm
    -- 010 | ID_RF_Ry
    -- 011 | MEM_RF_LW
    -- 100 | MEM_RF_Res
    -- 101 | all ones
    -- 110 | all zeros
		procedure look_ahead (x: in std_logic_vector(3 downto 0);
													side: out boolean;
													muxop : out std_logic_vector(2 downto 0)) is
		begin
			if id_rf_rd = x then --反正如果是lw就会等的，所以直接取alu的输出
				muxop := "000";
				side := true;
			else
				if exe_rf_rd = x then
					if exe_rf_op = "10011" or exe_rf_op = "10010" then
						muxop := "011";
						side := true;
					else
						muxop := "100";
						side := true;
					end if;
				else
					muxop := "111";
					side := false;
				end if;
			end if;
		end look_ahead;
		procedure look_ahead_ry is
			variable side: boolean := false;
			variable sidemuxop : std_logic_vector (2 downto 0) := "000";
		begin
			look_ahead (x => '0' & if_rf_st(7 downto 5), side => side, muxop => sidemuxop);
			if side then
				bmuxop <= sidemuxop;
			else
				bmuxop <= "010";
			end if;
		end look_ahead_ry;
	begin
		case if_rf_st (15 downto 11) is
			when "01001" => -- addiu
				bmuxop <= "001";
			when "01000" => -- addiu3
				bmuxop <= "001";
			when "01100" => 
				case if_rf_st (10 downto 8) is
					when "011" => -- addsp
						bmuxop <= "001";
					when "000" => --btnez
						bmuxop <= "111";
					when "100" => --mtsp
						look_ahead_ry;
					when others =>
						bmuxop <= "111";
				end case;
			when "00000" => --addsp3
				bmuxop <= "001";
			when "00010" => -- b
				bmuxop <= "111";
			when "00100" => -- beqz
				bmuxop <= "111";
			when "00101" => -- bnez
				bmuxop <= "111";
			when "01110" => -- cmpi
				bmuxop <= "001";
			when "01101" => -- li
				bmuxop <= "001";
			when "10011" => -- lw
				bmuxop <= "001";
			when "10010" => -- lw_sp
				bmuxop <= "001";
			when "00110" => 
				case if_rf_st(1 downto 0) is
					when "00" => -- sll
						bmuxop <= "001";
					when "11" => -- sra
						bmuxop <= "001";
					when others =>
						bmuxop <= "111";
				end case;
			when "01010" => -- slti
				bmuxop <= "001";	
			when "01111" => --move
				look_ahead_ry;
			when "11011" => -- sw
				bmuxop <= "001";
			when "11010" => -- swsp
				bmuxop <= "001";
			when "11100" => 
				case if_rf_st(1 downto 0) is
					when "01" => --addu
						look_ahead_ry;
					when "11" => --subu
						look_ahead_ry;
					when others =>
						bmuxop <= "111";
				end case;
			when "11101" =>
				case if_rf_st(4 downto 0) is
					when "01100" => -- and
						look_ahead_ry;
					when "01010" => --cmp
						look_ahead_ry;
					when "01101" => --or
						look_ahead_ry;
					when "00100" => -- sllv
						look_ahead_ry;
					when "00000" => 
						if if_rf_st(7 downto 5) = "000" then --jr
							bmuxop <= "111";
						elsif if_rf_st(7 downto 5) = "010" then --mfpc
							bmuxop <= "110";
						else
							bmuxop <= "111";
						end if;
					when others =>
						bmuxop <= "111";
				end case;
			when "11110" => --mfih and mtih
				case if_rf_st(0) is
					when '0' => -- mfih
						bmuxop <= "110";
					when '1' => -- mtih
						bmuxop <= "110";
					when others =>
						bmuxop <= "111";
				end case;
			when others =>
				bmuxop <= "111";
		end case;
	end process;
	-- AMUXOP
	process (if_rf_st, id_rf_op, id_rf_rd, exe_rf_op, exe_rf_rd)
    -- AMuxOp
    -- 0000 | EXE_RF_Res
    -- 0001 | ID_RF_PC
    -- 0010 | ID_RF_Rx
    -- 0011 | ID_RF_Ry
    -- 0100 | ID_RF_IH
    -- 0101 | ID_RF_SP
    -- 0110 | ID_RF_T
    -- 0111 | MEM_RF_LW
    -- 1000 | MEM_RF_Res
    -- 1001 | all ones
    -- 1010 | all zeros  
		procedure look_ahead (x: in std_logic_vector(3 downto 0);
													side: out boolean;
													muxop : out std_logic_vector(3 downto 0)) is
		begin
			if id_rf_rd = x then --反正如果是lw就会等的，所以直接取alu的输出
				muxop := "0000";
				side := true;
			else
				if exe_rf_rd = x then
					if exe_rf_op = "10011" or exe_rf_op = "10010" then
						muxop := "0111";
						side := true;
					else
						muxop := "1000";
						side := true;
					end if;
				else
					muxop := "1111";
					side := false;
				end if;
			end if;
		end look_ahead;
		procedure look_ahead_rx is
			variable side: boolean := false;
			variable sidemuxop : std_logic_vector (3 downto 0) := "0000";
		begin
			look_ahead (x => '0' & if_rf_st(10 downto 8), side => side, muxop => sidemuxop);
			if side then
				amuxop <= sidemuxop;
			else
				amuxop <= "0010";
			end if;
		end look_ahead_rx;
		procedure look_ahead_ry is
			variable side: boolean := false;
			variable sidemuxop : std_logic_vector (3 downto 0) := "0000";
		begin
			look_ahead (x => '0' & if_rf_st(7 downto 5), side => side, muxop => sidemuxop);
			if side then
				amuxop <= sidemuxop;
			else
				amuxop <= "0011";
			end if;
		end look_ahead_ry;
		procedure look_ahead_sp is
			variable side: boolean := false;
			variable sidemuxop : std_logic_vector (3 downto 0) := "0000";
		begin
			look_ahead (x => "1001", side => side, muxop => sidemuxop);
			if side then
				amuxop <= sidemuxop;
			else
				amuxop <= "0101";
			end if;
		end look_ahead_sp;
		procedure look_ahead_ih is
			variable side: boolean := false;
			variable sidemuxop : std_logic_vector (3 downto 0) := "0000";
		begin
			look_ahead (x => "1000", side => side, muxop => sidemuxop);
			if side then
				amuxop <= sidemuxop;
			else
				amuxop <= "0100";
			end if;
		end look_ahead_ih;
	begin
		case if_rf_st (15 downto 11) is
			when "01001" => -- addiu
				look_ahead_rx;
			when "01000" => -- addiu3
				look_ahead_rx;
			when "01100" => 
				case if_rf_st (10 downto 8) is
					when "011" => -- addsp
						look_ahead_sp;
					when "000" => --btnez
						amuxop <= "1111";
					when "100" => --mtsp
						amuxop <= "1001";
					when others =>
						amuxop <= "1111";
				end case;
			when "00000" => --addsp3
				look_ahead_sp;
			when "00010" => -- b
				amuxop <= "1111";
			when "00100" => -- beqz
				amuxop <= "1111";
			when "00101" => -- bnez
				amuxop <= "1111";
			when "01110" => -- cmpi
				look_ahead_rx;
			when "01101" => -- li
				amuxop <= "1001";
			when "10011" => -- lw
				look_ahead_rx;
			when "10010" => -- lw_sp
				look_ahead_sp;
			when "00110" => 
				case if_rf_st(1 downto 0) is
					when "00" => -- sll
						look_ahead_ry;
					when "11" => --sra
						look_ahead_ry;
					when others =>
						amuxop <= "1111";
				end case;
			when "01010" => -- slti
				look_ahead_rx;
			when "01111" => --move
				amuxop <= "1001";
			when "11011" => -- sw
				look_ahead_rx;
			when "11010" => -- swsp
				look_ahead_sp;
			when "11100" => 
				case if_rf_st(1 downto 0) is
					when "01" => --addu
						look_ahead_rx;
					when "11" => --subu
						look_ahead_rx;
					when others =>
						amuxop <= "1111";
				end case;
			when "11101" =>
				case if_rf_st(4 downto 0) is
					when "01100" => -- and
						look_ahead_rx;
					when "01010" => --cmp
						look_ahead_rx;
					when "01101" => --or
						look_ahead_rx;
					when "00100" => -- sllv
						look_ahead_rx;
					when "00000" => 
						if if_rf_st(7 downto 5) = "000" then --jr
							amuxop <= "1111";
						elsif if_rf_st(7 downto 5) = "010" then --mfpc
							amuxop <= "0001";
						else
							amuxop <= "1111";
						end if;
					when others =>
						amuxop <= "1111";
				end case;
			when "11110" => --mfih and mtih
				case if_rf_st(0) is
					when '0' => -- mfih
						look_ahead_ih;
					when '1' => -- mtih
						look_ahead_rx;
					when others =>
						amuxop <= "1111";
				end case;
			when others =>
				amuxop <= "1111";
		end case;
	end process;
    
	-- 产生MEM_RFOP
	mem_rfop <= "00";
	
	-- 产生EXE_RFOP
	exe_rfop <= "00";

    -- generate btbop signal
    process(if_rf_st)
        variable op : std_logic_vector(4 downto 0) := "00000";
    begin
			op := if_rf_st (15 downto 11);
        if(op="00010" or op="00100" or op="00101") then -- b, beqz, bnez
            btbop <= '1';
        elsif(if_rf_st(15 downto 8)="01100000") then -- bteqz
            btbop <= '1';
        elsif(op="11101" and if_rf_st="00000") then -- jr
            btbop <= '1';
        else
            btbop <= '0';
        end if;
    end process;
    
    process(id_rf_op, exe_res, pc_rf_pc, if_rf_opc)
        variable nn_written_st : boolean := false;
        variable n_written_st : boolean := false; 
    begin
        nn_written_st := (id_rf_op = "11011" or id_rf_op = "11010") and exe_res = pc_rf_pc;
        n_written_st := (id_rf_op = "11011" or id_rf_op = "11010") and exe_res = if_rf_opc;
        if(nn_written_st or n_written_st) then 
            pc_src_exe <= "011";
        else
            pc_src_exe <= "111";
        end if;
    end process;
	--下面这俩判断条件差不多，所以我写在一个process里面，太懒，少写一点代码
	-- 如果性能不足，可以拆开成两个process分别产生
	-- 产生ID_RFOP
	-- 产生IF_RFOP
	process (if_rf_st, pc_rf_pc, idpc, id_rf_op, id_rf_rd, exe_rf_op, exe_rf_rd, exe_res, if_rf_opc)
		variable target_failed : boolean := false; --跳转指令发现预测失败
		variable last_lw_rd, last_last_lw_rd, last_rd : boolean := false; --发现数据冲突
		variable n_written_st, nn_written_st: boolean := false; --发现之后有sw指令在写入该指令的地址
		--------------------------------------------------------------------------------------------------
		procedure data_conflict (x: in std_logic_vector(3 downto 0);
--														signal id_rf_rd, exe_rf_rd: in std_logic_vector (3 downto 0);
--														signal id_rf_op, exe_rf_op: in std_logic_vector (4 downto 0);
													  last_rd, last_lw_rd, last_last_lw_rd: out boolean) is
		begin
			last_rd := (id_rf_rd = x);
			last_lw_rd := ( (id_rf_rd = x) and (id_rf_op = "10011" or id_rf_op = "10010") );
			last_last_lw_rd := ( (exe_rf_op = "10011" or exe_rf_op = "10010") and exe_rf_rd = x );
		end data_conflict;
		procedure data_conflict (x, y: in std_logic_vector(3 downto 0);
--														signal id_rf_rd, exe_rf_rd: in std_logic_vector (3 downto 0);
--														signal id_rf_op, exe_rf_op: in std_logic_vector (4 downto 0);
													  last_rd, last_lw_rd, last_last_lw_rd: out boolean) is
		begin
			last_rd := ((id_rf_rd = x) or (id_rf_rd = y));
			last_lw_rd := (id_rf_rd = x or id_rf_rd = y) and (id_rf_op = "10011" or id_rf_op = "10010");
			last_last_lw_rd := (exe_rf_op = "10011" or exe_rf_op = "10010") and (exe_rf_rd = x or exe_rf_rd = y);
		end data_conflict;
		procedure normal_ins(last_rd, last_lw_rd, last_last_lw_rd, nn_written_st, n_written_st, target_failed: in boolean) is
		begin
				if n_written_st then -- conflict with ins in ID
					if_rfop <= "11";
					id_rfop <= "11";
					pc_rfwe <= '1';
			   elsif nn_written_st then -- conflict with ins in IF
				  if_rfop <= "11";
				  id_rfop <= "00";
					pc_rfwe <= '1';
				elsif last_lw_rd then
					if_rfop <= "10";
					id_rfop <= "11";
					pc_rfwe <= '0';
				else
					if_rfop <= "00";
					id_rfop <= "00";
					pc_rfwe <= '1';
				end if;
		end normal_ins;
		procedure branch_ins(last_rd, last_lw_rd, last_last_lw_rd, nn_written_st, n_written_st, target_failed: in boolean) is
		begin
				if n_written_st then
					if_rfop <= "11";
					pc_rfwe <= '1';
					id_rfop <= "11";
            elsif nn_written_st then
					if_rfop <= "11";
					pc_rfwe <= '1';
					id_rfop <= "00";
            elsif target_failed and not (last_rd or last_last_lw_rd) then
					if_rfop <= "11";
					id_rfop <= "00";
					pc_rfwe <= '1';
			elsif last_rd or last_last_lw_rd then
					if_rfop <= "10";
					id_rfop <= "11";
					pc_rfwe <= '0';
			else
					if_rfop <= "00";
					id_rfop <= "00";
					pc_rfwe <= '1';
			end if;
		end branch_ins;
	begin
		target_failed := idpc /= pc_rf_pc;
		---------------------------------------------------------------------------------
		nn_written_st := (id_rf_op = "11011" or id_rf_op = "11010") and exe_res = pc_rf_pc;
		n_written_st := (id_rf_op = "11011" or id_rf_op = "11010") and exe_res = if_rf_opc;
		---------------------------------------------------------------------------------
		--init
		last_rd := false;
		last_lw_rd := false;
		last_last_lw_rd := false;
		
		case if_rf_st(15 downto 11) is
			when "01001" => -- addiu
				data_conflict (x => '0' & if_rf_st(10 downto 8), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
				normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
			when "01000" => -- addiu3
				data_conflict (x => '0' & if_rf_st(10 downto 8), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
				normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
			when "01100" => 
				case if_rf_st (10 downto 8) is
					when "011" => -- addsp
						data_conflict (x => "1001", last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
						normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
					when "000" => --btnez
						data_conflict (x => "1010", last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
						branch_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
					when "100" => --mtsp
						data_conflict (x => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
						normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
					when others =>
						if_rfop <= "00";
						id_rfop <= "00";
				end case;
			when "00000" => --addsp3
				data_conflict (x => "1001", last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
				normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
			when "00010" => -- b
				branch_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
			when "00100" => -- beqz
				data_conflict (x => '0' & if_rf_st(10 downto 8), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
				branch_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
			when "00101" => -- bnez
				data_conflict (x => '0' & if_rf_st(10 downto 8), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
				branch_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
			when "01110" => -- cmpi
				data_conflict (x => '0' & if_rf_st(10 downto 8), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
				normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
			when "01101" => -- li
				normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
			when "10011" => -- lw
				data_conflict (x => '0' & if_rf_st(10 downto 8), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
				normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
			when "10010" => -- lw_sp
				data_conflict (x => "1001", last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
				normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
			when "00110" => -- sll, sra
				case if_rf_st(1 downto 0) is
					when "00" =>
						data_conflict (x => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
					when "11" =>
						data_conflict (x => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
					when others =>
						if_rfop <= "00";
						id_rfop <= "00";
				end case;
				normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
			when "01010" => -- slti
				data_conflict (x => '0' & if_rf_st(10 downto 8), y => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
				normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
			when "01111" => --move
				data_conflict (x => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
				normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
			when "11011" => -- sw
				data_conflict (x => '0' & if_rf_st(10 downto 8), y => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
				normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
			when "11010" => -- swsp
				data_conflict (x => '0' & if_rf_st(10 downto 8), y => "1001", last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
				normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
			when "11100" => 
				case if_rf_st(1 downto 0) is
					when "01" => --addu
						data_conflict (x => '0' & if_rf_st(10 downto 8), y => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
					when "11" => --subu
						data_conflict (x => '0' & if_rf_st(10 downto 8), y => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
					when others =>
						if_rfop <= "00";
						id_rfop <= "00";
				end case;
				normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
			when "11101" =>
				case if_rf_st(4 downto 0) is
					when "01100" => -- and
						data_conflict (x => '0' & if_rf_st(10 downto 8), y => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
						normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
					when "01010" => --cmp
						data_conflict (x => '0' & if_rf_st(10 downto 8), y => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
						normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
					when "01101" => --or
						data_conflict (x => '0' & if_rf_st(10 downto 8), y => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
						normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
					when "00100" => -- sllv
						data_conflict (x => '0' & if_rf_st(10 downto 8), y => '0' & if_rf_st(7 downto 5), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
						normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
					when "00000" => 
						if if_rf_st(7 downto 5) = "000" then --jr
							data_conflict (x => '0' & if_rf_st(10 downto 8), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
								branch_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
						elsif if_rf_st(7 downto 5) = "010" then --mfpc
								normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
						else
								if_rfop <= "00";
								id_rfop <= "00";
						end if;
					when others =>
						if_rfop <= "00";
						id_rfop <= "00";
				end case;
			when "11110" => --mfih and mtih
				case if_rf_st(0) is
					when '0' => -- mfih
					when '1' => -- mtih
						data_conflict (x => '0' & if_rf_st(10 downto 8), last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd);
					when others =>
				end case;
				normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
			when "11111" => --int
				if_rfop <= "00";
				id_rfop <= "00";
			when others =>
				normal_ins (last_rd => last_rd, last_lw_rd => last_lw_rd, last_last_lw_rd => last_last_lw_rd, nn_written_st => nn_written_st, n_written_st => n_written_st, target_failed => target_failed);
		end case;
	end process;

	-- 产生RXTOP，然后传给IDPCRXT使用，不保存
	-- 使用IF段寄存器中的指令字段
	process (if_rf_st, id_rf_rd, exe_rf_rd, mem_rf_rd, mem_rf_op)
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
			idpcop <= "11";
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
	process (if_rf_st, idpc, pc_rf_pc)
	begin
		if if_rf_st(15 downto 11) = "00010" and idpc /= pc_rf_pc then --b
			pc_src_id <= "001";
		elsif if_rf_st(15 downto 11) = "00100" and idpc /= pc_rf_pc then --beqz
			pc_src_id <= "001";
		elsif if_rf_st(15 downto 11) = "00101" and idpc /= pc_rf_pc then --bnez
			pc_src_id <= "001";
		elsif if_rf_st(15 downto 8) = "01100000" and idpc /= pc_rf_pc then --bteqz
			pc_src_id <= "001";
		elsif if_rf_st(15 downto 11) = "11101" and if_rf_st(7 downto 0) = "00000000" and idpc /= pc_rf_pc then --jr
			pc_src_id <= "001";
		else
			pc_src_id <= "000";
		end if;
	end process;
	-- pc_src_exe
	-- pc_src_exe <= "111";
	-- pc_src_mem
	pc_src_mem <= "111";
	-- pc_src_wb
	pc_src_wb <= "111";
	--综合
    -- 000 PDTPC
    -- 001 IDPC
    -- 010 异常处理地址
    -- 011 IF_RF_PC_ORIGIN
    -- 100 不能写
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
    --- 000 rx
    --- 001 ry
    --- 011 rz
    --- 010 SP
    --- 110 IH
    --- 100 T
    --- others 1111 ILLEGAL
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
                    memen <= '0';
            when "01000" => -- addiu3
					aluop <= "0000";
					dir := "001";
					regwrbop <= "00";
					ramrwop <= '0';
					swsrc <= '0';
                    memen <= '0';
            when "01100" => --addsp, bteqz, mtsp
					ramrwop <= '0';
					swsrc <= '0';
					case if_rf_st (10 downto 8) is
						when "011" => -- addsp
							aluop <= "0000";
							dir := "010";
							regwrbop <= "00";
                            memen <= '0';
						when "000" => --btnez
							aluop <= "0110";
							dir := "111";
							regwrbop <= "11";
                            memen <= '0';
						when "100" => --mtsp
							aluop <= "0011";
							dir := "010";
							regwrbop <= "00";
                            memen <= '0';
						when others =>
							aluop <= "1111";
							dir := "111";
							regwrbop <= "11";
                            memen <= '0';
					end case;
            when "00000" => --addsp3
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0000";
					dir := "000";
					regwrbop <= "00";
                    memen <= '0';
            when "00010" => -- b
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0000";
					dir := "111";
					regwrbop <= "11";
                    memen <= '0';
            when "00100" => -- beqz
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0110";
					dir := "111";
					regwrbop <= "11";
                    memen <= '0';
            when "00101" => -- bnez
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0110";
					dir := "111";
					regwrbop <= "11";
                    memen <= '0';
            when "01110" => -- cmpi
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0110";
					dir := "100";
					regwrbop <= "10";
                    memen <= '0';
            when "01101" => -- li
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0011";
					dir := "000";
					regwrbop <= "00";
                    memen <= '0';
            when "10011" => -- lw
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0000";
					dir := "001";
					regwrbop <= "01";
                    memen <= '1';
            when "10010" => -- lw_sp
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0000";
					dir := "000";
					regwrbop <= "01";
                    memen <= '1';
            when "00110" => 
					ramrwop <= '0';
					swsrc <= '0';
                    memen <= '0';
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
						regwrbop <= "11";
					end case;
            when "01010" => -- slti
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0001";
					dir := "100";
					regwrbop <= "00";
                    memen <= '0';
				when "01111" => --move
					ramrwop <= '0';
					swsrc <= '0';
					aluop <= "0011";
					dir := "000";
					regwrbop <= "00";
                    memen <= '0';
            when "11011" => -- sw
					aluop <= "0000";
					dir := "111";
					ramrwop <= '1';
					swsrc <= '1';
					regwrbop <= "11";
                    memen <= '1';
            when "11010" => -- swsp
					aluop <= "0000";
					dir := "111";
					ramrwop <= '1';
					swsrc <= '0';
					regwrbop <= "11";
                    memen <= '1';
				when "11100" => 
					ramrwop <= '0';
					swsrc <= '0';
                    memen <= '0';
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
							regwrbop <= "11";
					end case;
				when "11101" =>
					ramrwop <= '0';
					swsrc <= '0';
                    memen <= '0';
					case if_rf_st(4 downto 0) is
						when "01100" => -- and
							aluop <= "0011";
							dir := "000";
							regwrbop <= "00";
						when "01010" => --cmp
							aluop <= "0110";
							dir := "100";
							regwrbop <= "10";
						when "01101" => --or
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
                    memen <= '0';
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
                    memen <= '0';
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
						exdigitsop <= "111";
						exsignop <= '1';
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
    
	 
--	-- template
--	process
--		variable op: STD_LOGIC_VECTOR (4 downto 0);
--	begin
--		op := if_rf_st (15 downto 11);
--		case op is
--			when "01001" => -- addiu
--			when "01000" => -- addiu3
--			when "01100" => 
--				case if_rf_st (10 downto 8) is
--					when "011" => -- addsp
--					when "000" => --btnez
--					when "100" => --mtsp
--					when others =>
--				end case;
--			when "00000" => --addsp3
--			when "00010" => -- b
--			when "00100" => -- beqz
--			when "00101" => -- bnez
--			when "01110" => -- cmpi
--			when "01101" => -- li
--			when "10011" => -- lw
--			when "10010" => -- lw_sp
--			when "00110" => 
--				case if_rf_st(1 downto 0) is
--					when "00" => -- sll
--					when "11" => -- sra
--					when others =>
--				end case;
--			when "01010" => -- slti
--			when "01111" => --move
--			when "11011" => -- sw
--			when "11010" => -- swsp
--			when "11100" => 
--				case if_rf_st(1 downto 0) is
--					when "01" => --addu
--					when "11" => --subu
--					when others =>
--				end case;
--			when "11101" =>
--				case if_rf_st(4 downto 0) is
--					when "01100" => -- and
--					when "01010" => --cmp
--					when "11101" => --or
--					when "00100" => -- sllv
--					when "00000" => 
--						if if_rf_st(7 downto 5) = "0000" then --jr
--						elsif if_rf_st(7 downto 5) = "0100" then --mfpc
--						else
--						end if;
--					when others =>
--				end case;
--			when "11110" => --mfih and mtih
--				case if_rf_st(0) is
--					when '0' => -- mfih
--					when '1' => -- mtih
--					when others =>
--				end case;
--			when others =>
--		end case;
--	end process;
end Behavioral;
