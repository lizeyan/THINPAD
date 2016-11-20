--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:11:35 11/20/2016
-- Design Name:   
-- Module Name:   C:/Users/OnionYST/Desktop/XilinxProjects/NaiveCPU/ifpcadder_test.vhd
-- Project Name:  NaiveCPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: IF_PCAdder
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
 
ENTITY ifpcadder_test IS
END ifpcadder_test;
 
ARCHITECTURE behavior OF ifpcadder_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT IF_PCAdder
    PORT(
         PC_RF_PC : IN  std_logic_vector(15 downto 0);
         IF_Res : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal PC_RF_PC : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal IF_Res : std_logic_vector(15 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: IF_PCAdder PORT MAP (
          PC_RF_PC => PC_RF_PC,
          IF_Res => IF_Res
        );

   -- Stimulus process
   stim_proc: process
   begin		
      -- IF_Res 0000111100010000
      PC_RF_PC <= "0000111100001111";
      wait for 10 ns;
   end process;

END;
