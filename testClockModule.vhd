--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:08:23 11/20/2016
-- Design Name:   
-- Module Name:   C:/Users/zy-li14/Desktop/THINPAD_LLY/testClockModule.vhd
-- Project Name:  NaiveCPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ClockModule
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
 
ENTITY testClockModule IS
END testClockModule;
 
ARCHITECTURE behavior OF testClockModule IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ClockModule
    PORT(
         clk_in : IN  std_logic;
         clk : OUT  std_logic;
         clk_2 : OUT  std_logic;
         clk_4 : OUT  std_logic;
         clk_8 : OUT  std_logic;
         clk_16 : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk_in : std_logic := '0';

 	--Outputs
   signal clk : std_logic;
   signal clk_2 : std_logic;
   signal clk_4 : std_logic;
   signal clk_8 : std_logic;
   signal clk_16 : std_logic;

   -- Clock period definitions
   constant clk_in_period : time := 10 ns;
   constant clk_period : time := 10 ns;
   constant clk_2_period : time := 10 ns;
   constant clk_4_period : time := 10 ns;
   constant clk_8_period : time := 10 ns;
   constant clk_16_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ClockModule PORT MAP (
          clk_in => clk_in,
          clk => clk,
          clk_2 => clk_2,
          clk_4 => clk_4,
          clk_8 => clk_8,
          clk_16 => clk_16
        );

   -- Clock process definitions
   clk_in_process :process
   begin
		clk_in <= '0';
		wait for clk_in_period/2;
		clk_in <= '1';
		wait for clk_in_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.

      -- insert stimulus here 

      wait;
   end process;

END;
