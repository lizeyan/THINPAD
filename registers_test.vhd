--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:47:48 11/20/2016
-- Design Name:   
-- Module Name:   C:/jiyuan/ClassProject/THINPAD_LLY/registers_test.vhd
-- Project Name:  NaiveCPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Registers
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
 
ENTITY registers_test IS
END registers_test;
 
ARCHITECTURE behavior OF registers_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Registers
    PORT(
         clk : IN  std_logic;
         IF_RF_RX : IN  std_logic_vector(2 downto 0);
         IF_RF_RY : IN  std_logic_vector(2 downto 0);
         RegWrbAddr : IN  std_logic_vector(3 downto 0);
         RegWrbData : IN  std_logic_vector(15 downto 0);
         ID_Rx : OUT  std_logic_vector(15 downto 0);
         ID_Ry : OUT  std_logic_vector(15 downto 0);
         ID_IH : OUT  std_logic_vector(15 downto 0);
         ID_SP : OUT  std_logic_vector(15 downto 0);
         ID_T : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal IF_RF_RX : std_logic_vector(2 downto 0) := (others => '0');
   signal IF_RF_RY : std_logic_vector(2 downto 0) := (others => '0');
   signal RegWrbAddr : std_logic_vector(3 downto 0) := (others => '0');
   signal RegWrbData : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal ID_Rx : std_logic_vector(15 downto 0);
   signal ID_Ry : std_logic_vector(15 downto 0);
   signal ID_IH : std_logic_vector(15 downto 0);
   signal ID_SP : std_logic_vector(15 downto 0);
   signal ID_T : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Registers PORT MAP (
          clk => clk,
          IF_RF_RX => IF_RF_RX,
          IF_RF_RY => IF_RF_RY,
          RegWrbAddr => RegWrbAddr,
          RegWrbData => RegWrbData,
          ID_Rx => ID_Rx,
          ID_Ry => ID_Ry,
          ID_IH => ID_IH,
          ID_SP => ID_SP,
          ID_T => ID_T
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
    
   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.

      -- insert stimulus here 
        RegWrbAddr <= "0000";
        RegWrbData <= "1111000011110000";
		  if_rf_rx <= "000";
		  if_rf_ry <= "000";
		  wait for 10ns;
        RegWrbAddr <= "0000";
        RegWrbData <= "0000111111111111";   
        IF_RF_RX <= "000";
        IF_RF_RY <= "000";
        wait for 10 ns;
        
 
   end process;

END;
