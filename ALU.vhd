----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    10:36:47 11/18/2016 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
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
--	0000	|	add			|		Fout <= A + B	
--	0001	|	sub			|		Fout <= A - B
--	0011		|	and			|		Fout <= A & B
--	0010	|	or				|		Fout <= A | B
--	0110		|	xor			|		Fout <= A ^ B
--	0111		|	sll_imm	|		Fout <= A << (B == 0?8:B)
--	0101		|	sll_v			|		Fout <= B << A
-- 	0100	|	sra_imm	|		Fout <= A >> (B == 0?8:B) (arith)
--	others |	ERROR	|		Fout <= Z... and Flags <= Z...
entity ALU is
    Port ( AluOp : in STD_LOGIC_VECTOR(3 downto 0);
           ASrc : in STD_LOGIC_VECTOR(15 downto 0);
           BSrc : in STD_LOGIC_VECTOR(15 downto 0);
           
           Fout : out STD_LOGIC_VECTOR(15 downto 0);
           Flags : out STD_LOGIC_VECTOR(3 downto 0));  -- OZSC
end ALU;

architecture Behavioral of ALU is
	signal res_add : STD_LOGIC_VECTOR (16 downto 0) := "00000000000000000";
	signal res_sub : STD_LOGIC_VECTOR (16 downto 0) := "00000000000000000";
	signal res_sll_imm : STD_LOGIC_VECTOR (16 downto 0) := "00000000000000000";
	signal res_sll_v : STD_LOGIC_VECTOR (16 downto 0) := "00000000000000000";
	signal res_and : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
	signal res_or : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
	signal res_xor : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
	signal res_sra_imm : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
begin
	-- ADD
	process (asrc, bsrc)
		variable A: STD_LOGIC_VECTOR (16 downto 0);
		variable B: STD_LOGIC_VECTOR (16 downto 0);
	begin
		A := '0'& asrc;
		B := '0' & bsrc;
		Res_add <= A + B;
	end process;
	
	--SUB
	process (asrc, bsrc)
		variable A: STD_LOGIC_VECTOR (16 downto 0);
		variable B: STD_LOGIC_VECTOR (16 downto 0);
	begin
		A := '0' & Asrc;
		B := '0' & Bsrc;
		Res_sub <= A - B;
	end process;
	
	--SLL_IMM
	process (asrc, bsrc)
		variable A: STD_LOGIC_VECTOR (16 downto 0);
		variable B: STD_LOGIC_VECTOR (16 downto 0);
	begin
		A := '0' & Asrc;
		B := '0' & Bsrc;
		if b = "00000000000000000" then
			Res_sll_imm <= To_StdLogicVector(To_bitvector(A) sll 8);
		else
			Res_sll_imm <= To_StdLogicVector(To_bitvector(A) sll CONV_INTEGER(B));
		end if;
	end process;
	
	-- SLL_V
	process (asrc, bsrc)
		variable A: STD_LOGIC_VECTOR (16 downto 0);
		variable B: STD_LOGIC_VECTOR (16 downto 0);
	begin
		A := '0' & Asrc;
		B := '0' & Bsrc;
		Res_sll_v <= To_StdLogicVector(To_bitvector(B) sll CONV_INTEGER(A));
	end process;
	
	--SRA_imm
	process (asrc, bsrc)
	begin
		if bsrc = "0000000000000000" then
			Res_sra_imm <= To_StdLogicVector(To_bitvector(Asrc) sra 8);
		else
			Res_sra_imm <= To_StdLogicVector(To_bitvector(Asrc) sra CONV_INTEGER(Bsrc(2 downto 0)));
		end if;
	end process;
	
	--AND
	process (asrc, bsrc)
	begin
		res_and <= asrc and bsrc;
	end process;
	
	--OR
	process (asrc, bsrc)
	begin
		res_or <= asrc or bsrc;
	end process;
	
	--xor
	process (asrc, bsrc)
	begin
		res_xor <= asrc xor bsrc;
	end process;
	
	--generate fout and flags
	process (aluop, asrc, bsrc, res_add, res_sub, res_sll_imm, res_sll_v, res_sra_imm, res_and, res_or, res_xor)
		variable flagO, flagZ, flagC, A_sign, B_sign, Res_sign: STD_LOGIC := '0';
		variable res : STD_LOGIC_VECTOR (15 downto 0);
	begin
		A_sign := Asrc (15);
		B_sign := Bsrc (15);
		
		case aluop is 
			when "0000" =>
				res := res_add(15 downto 0);
				flagc := res_add (16);
				res_sign := res_add (15);
				flago := ((not A_sign) and (not b_sign) and res_sign) or (a_sign and b_sign and (not res_sign));
			when "0001" =>
				res := res_sub (15 downto 0);
				flagc := res_sub (16);
				res_sign := res_sub(15);
				flagO := (a_sign and (not b_sign) and (not res_sign)) or ((not a_sign) and b_sign and res_sign);
			when "0011" =>
				res := res_and;
				flagc := '0';
				flago := '0';
			when "0010" =>
				res := res_or;
				flagc := '0';
				flago := '0';
			when "0110" =>
				res := res_xor;
				flagc := '0';
				flago := '0';
			when "0111" =>
				res := res_sll_imm (15 downto 0);
				flagc := res_sll_imm (16);
				flago := '0';
			when "0101" =>
				res := res_sll_v (15 downto 0);
				flagc := res_sll_v (16);
				flago := '0';
			when "0100" =>
				res := res_sra_imm;
				flagc := '0';
				flago := '0';
			when others =>
				res := "1111111111111111";
				flagc := '1';
				flago := '1';
		end case;
		
		flagz := '0';
		for i in 0 to 15 loop
			flagz := flagz  or res(i);
		end loop;
		flags <= flago & (not flagz) & res(15) & flagc;
		fout <= res;
	end process;
end Behavioral;
