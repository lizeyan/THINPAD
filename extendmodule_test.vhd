--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:28:26 11/20/2016
-- Design Name:   
-- Module Name:   C:/Users/zy-li14/Desktop/THINPAD_LLY/src/extendmodule_test.vhd
-- Project Name:  NaiveCPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ExtendModule
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
 
ENTITY extendmodule_test IS
END extendmodule_test;
 
ARCHITECTURE behavior OF extendmodule_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ExtendModule
    PORT(
         ExSrc : IN  std_logic_vector(10 downto 0);
         ExImm : OUT  std_logic_vector(15 downto 0);
         ExDigitsOp : IN  std_logic_vector(2 downto 0);
         ExSignOp : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal ExSrc : std_logic_vector(10 downto 0) := (others => '0');
   signal ExDigitsOp : std_logic_vector(2 downto 0) := (others => '0');
   signal ExSignOp : std_logic := '0';

 	--Outputs
   signal ExImm : std_logic_vector(15 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 

 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ExtendModule PORT MAP (
          ExSrc => ExSrc,
          ExImm => ExImm,
          ExDigitsOp => ExDigitsOp,
          ExSignOp => ExSignOp
        );


   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		-- 1111110010010000
		wait for 2 ns;
		exsrc <= "10010010000";
		exdigitsop <= "000";
		exsignop <= '1';
		wait for 2 ns;
		-- 11111111100100000
		exsrc <= "10010010000";
		exdigitsop <= "001";
		exsignop <= '1';
		wait for 2 ns;
		-- 1111111111110000
		exsrc <= "10010010000";
		exdigitsop <= "011";
		exsignop <= '1';
		wait for 2 ns;
		-- 1111111111111100
		exsrc <= "10010010000";
		exdigitsop <= "010";
		exsignop <= '1';
		wait for 2 ns;
		-- 0000010010010000
		exsrc <= "10010010000";
		exdigitsop <= "000";
		exsignop <= '0';
		wait for 2 ns;
		-- 0000000010010000
		exsrc <= "10010010000";
		exdigitsop <= "001";
		exsignop <= '0';
		wait for 2 ns;
		-- 000000000010000
		exsrc <= "10010010000";
		exdigitsop <= "011";
		exsignop <= '0';
		wait for 2 ns;
		-- 000000000000100
		exsrc <= "10010010000";
		exdigitsop <= "010";
		exsignop <= '0';
		wait for 2 ns;
		-- 00000000100000000
		exsrc <= "00010000000";
		exdigitsop <= "000";
		exsignop <= '1';
		wait for 2 ns;
		-- 1111111110000000
		exsrc <= "00010000000";
		exdigitsop <= "001";
		exsignop <= '1';
		wait for 2 ns;
		-- 0000000000000001
		exsrc <= "00010000001";
		exdigitsop <= "011";
		exsignop <= '1';
		wait for 2 ns;
		-- 0000000000000000
		exsrc <= "00010000000";
		exdigitsop <= "010";
		exsignop <= '1';
		wait for 2 ns;

      -- insert stimulus here 

      wait;
   end process;

END;
