--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:21:01 11/19/2016
-- Design Name:   
-- Module Name:   C:/Users/zy-li14/Desktop/THINPAD_LLY/alu_test.vhd
-- Project Name:  NaiveCPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ALU
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY alu_test IS
END alu_test;
 
ARCHITECTURE behavior OF alu_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ALU
    PORT(
         AluOp : IN  std_logic_vector(3 downto 0);
         ASrc : IN  std_logic_vector(15 downto 0);
         BSrc : IN  std_logic_vector(15 downto 0);
         Fout : OUT  std_logic_vector(15 downto 0);
         Flags : OUT  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal AluOp : std_logic_vector(3 downto 0) := (others => '0');
   signal ASrc : std_logic_vector(15 downto 0) := (others => '0');
   signal BSrc : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal Fout : std_logic_vector(15 downto 0);
   signal Flags : std_logic_vector(3 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ALU PORT MAP (
          AluOp => AluOp,
          ASrc => ASrc,
          BSrc => BSrc,
          Fout => Fout,
          Flags => Flags
        );

   -- Stimulus process
   stim_proc: process
   begin		
		-- flags 1010
		-- fout 1000000000000000
		Aluop <= "0000";
		asrc<="0111000000000000";
		bsrc<="0001000000000000";
      wait for 5 ns;	
		--flags 0001
		-- fout 0010000000000000
		aluop <= "0000";
		asrc<="1111000000000000";
		bsrc<="0011000000000000";
		wait for 5 ns;
		-- flags 1101
		-- fout 0000000000000000
		aluop <= "0000";
		asrc <= "1000000000000000";
		bsrc <= "1000000000000000";
		wait for 5 ns;
		-- flags 0011
		-- fout 1110000000000000
		aluop <= "0001";
		asrc <= "0001000000000000";
		bsrc <= "0011000000000000";
		wait for 5 ns;
		-- flags 0100
		-- fout 0000000000000000
		aluop <= "0001";
		asrc <= "1111111111111111";
		bsrc <= "1111111111111111";
		wait for 5 ns;
		-- flags 0000
		-- fout 0001000000000000
		aluop <= "0011";
		asrc <= "1001000000000000";
		bsrc <= "0101000000000000";
		wait for 5 ns;
		-- flags 0010
		-- fout 1101000000000000
		aluop <= "0010";
		asrc <= "1001000000000000";
		bsrc <= "0101000000000000";
		wait for 5 ns;
		-- flags 0010
		-- fout 1100000000000000
		aluop <= "0110";
		asrc <= "1001000000000000";
		bsrc <= "0101000000000000";
		wait for 5 ns;
		-- flags 0011
		-- fout 1000000000000000
		aluop <= "0111";
		asrc <= "1001001110000000";
		bsrc <= "0000000000000000";
		wait for 5 ns;
		-- flags 0010
		-- fout 1001110000000000
		aluop <= "0111";
		asrc <= "1001001110000000";
		bsrc <= "0000000000000011";
		wait for 5 ns;
		-- flags 0010
		-- fout 1001001110000000
		aluop <= "0101";
		bsrc <= "1001001110000000";
		asrc <= "0000000000000000";
		wait for 5 ns;
		-- flags 0010
		-- fout 1001110000000000
		aluop <= "0101";
		bsrc <= "1001001110000000";
		asrc <= "0000000000000011";
		wait for 5 ns;
		-- flags 0000
		-- fout 0000000000000001
		aluop <= "0100";
		asrc <= "0000000101011001";
		bsrc <= "0000000000000000";
		wait for 5 ns;
		-- flags 0000
		-- fout 0000000000101011"
		aluop <= "0100";
		asrc <= "0000000101011101";
		bsrc <= "0000000000000011";
		wait for 5 ns;


   end process;

END;
