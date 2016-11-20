--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:04:11 11/20/2016
-- Design Name:   
-- Module Name:   C:/Users/OnionYST/Desktop/XilinxProjects/NaiveCPU/bmux_test.vhd
-- Project Name:  NaiveCPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: BMux
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
 
ENTITY bmux_test IS
END bmux_test;
 
ARCHITECTURE behavior OF bmux_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT BMux
    PORT(
         BMuxOp : IN  std_logic_vector(2 downto 0);
         BSrc : OUT  std_logic_vector(15 downto 0);
         EXE_RF_Res : IN  std_logic_vector(15 downto 0);
         ID_RF_Imm : IN  std_logic_vector(15 downto 0);
         ID_RF_Ry : IN  std_logic_vector(15 downto 0);
         MEM_RF_LW : IN  std_logic_vector(15 downto 0);
         MEM_RF_Res : IN  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal BMuxOp : std_logic_vector(2 downto 0) := (others => '0');
   signal EXE_RF_Res : std_logic_vector(15 downto 0) := (others => '0');
   signal ID_RF_Imm : std_logic_vector(15 downto 0) := (others => '0');
   signal ID_RF_Ry : std_logic_vector(15 downto 0) := (others => '0');
   signal MEM_RF_LW : std_logic_vector(15 downto 0) := (others => '0');
   signal MEM_RF_Res : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal BSrc : std_logic_vector(15 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: BMux PORT MAP (
          BMuxOp => BMuxOp,
          BSrc => BSrc,
          EXE_RF_Res => EXE_RF_Res,
          ID_RF_Imm => ID_RF_Imm,
          ID_RF_Ry => ID_RF_Ry,
          MEM_RF_LW => MEM_RF_LW,
          MEM_RF_Res => MEM_RF_Res
        );

   -- Stimulus process
   stim_proc: process
   begin		
     EXE_RF_Res <= "0000000000000001";
     ID_RF_Imm  <= "0000000000000010";
     ID_RF_Ry   <= "0000000000000100";
     MEM_RF_LW  <= "0000000000001000";
     MEM_RF_Res <= "0000000000010000";
     
     -- BSrc 0000000000000001
     BMuxOp <= "000";
     wait for 5 ns;
     -- BSrc 0000000000000010
     BMuxOp <= "001";
     wait for 5 ns;
     -- BSrc 0000000000000100
     BMuxOp <= "010";
     wait for 5 ns;
     -- BSrc 0000000000001000
     BMuxOp <= "100";
     wait for 5 ns;
     -- BSrc 1000000000000000
     BMuxOp <= "000";
     EXE_RF_Res <= "1000000000000000";
     wait for 5 ns;
     -- BSrc 0000000000000000
     BMuxOp <= "101";
     wait for 5 ns;
     -- BSrc 0000000000000000
     BMuxOp <= "110";
     wait for 5 ns;
     -- BSrc 0000000000000000
     BMuxOp <= "111";
     wait for 5 ns;
   end process;

END;
