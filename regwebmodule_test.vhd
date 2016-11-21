--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:20:18 11/21/2016
-- Design Name:   
-- Module Name:   C:/Users/zy-li14/Desktop/THINPAD_LLY/regwebmodule_test.vhd
-- Project Name:  NaiveCPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RegWrbModule
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
 
ENTITY regwebmodule_test IS
END regwebmodule_test;
 
ARCHITECTURE behavior OF regwebmodule_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RegWrbModule
    PORT(
         RegWrbOp : IN  std_logic_vector(1 downto 0);
         RegWrbOut : OUT  std_logic_vector(15 downto 0);
         MEM_RF_FlagSign : IN  std_logic;
         MEM_RF_LW : IN  std_logic_vector(15 downto 0);
         MEM_RF_Res : IN  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal RegWrbOp : std_logic_vector(1 downto 0) := (others => '0');
   signal MEM_RF_FlagSign : std_logic := '0';
   signal MEM_RF_LW : std_logic_vector(15 downto 0) := (others => '0');
   signal MEM_RF_Res : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal RegWrbOut : std_logic_vector(15 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RegWrbModule PORT MAP (
          RegWrbOp => RegWrbOp,
          RegWrbOut => RegWrbOut,
          MEM_RF_FlagSign => MEM_RF_FlagSign,
          MEM_RF_LW => MEM_RF_LW,
          MEM_RF_Res => MEM_RF_Res
        );
 

   -- Stimulus process
   stim_proc: process
   begin		
      regwrbop <= "00";
		mem_rf_flagsign <= '1';
		mem_rf_lw <= "1111000011110000";
		mem_rf_res <= "0000111100001111";
		wait for 1 ns;
		regwrbop <= "01";
		wait for 1 ns;
		regwrbop <= "10";
		wait for 1 ns;
		regwrbop <= "11";
		wait for 1 ns;

   end process;

END;
