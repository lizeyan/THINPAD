--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:54:51 11/20/2016
-- Design Name:   
-- Module Name:   C:/Users/OnionYST/Desktop/XilinxProjects/NaiveCPU/idpcadder_test.vhd
-- Project Name:  NaiveCPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ID_PCAdder
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
 
ENTITY idpcadder_test IS
END idpcadder_test;
 
ARCHITECTURE behavior OF idpcadder_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ID_PCAdder
    PORT(
         IF_RF_PC : IN  std_logic_vector(15 downto 0);
         ID_Imm : IN  std_logic_vector(15 downto 0);
         ID_Res : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal IF_RF_PC : std_logic_vector(15 downto 0) := (others => '0');
   signal ID_Imm : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal ID_Res : std_logic_vector(15 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ID_PCAdder PORT MAP (
          IF_RF_PC => IF_RF_PC,
          ID_Imm => ID_Imm,
          ID_Res => ID_Res
        );

   -- Stimulus process
   stim_proc: process
   begin
      -- ID_Res 0001111001000001
      IF_RF_PC <= "0000111100001111";
      ID_Imm   <= "0000111100110010";
      wait for 10 ns;
   end process;

END;
