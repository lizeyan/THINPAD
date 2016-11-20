--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:37:40 11/20/2016
-- Design Name:   
-- Module Name:   C:/Users/OnionYST/Desktop/XilinxProjects/NaiveCPU/amux_test.vhd
-- Project Name:  NaiveCPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: AMux
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
 
ENTITY amux_test IS
END amux_test;
 
ARCHITECTURE behavior OF amux_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT AMux
    PORT(
         AMuxOp : IN  std_logic_vector(3 downto 0);
         ASrc : OUT  std_logic_vector(15 downto 0);
         EXE_RF_Res : IN  std_logic_vector(15 downto 0);
         ID_RF_PC : IN  std_logic_vector(15 downto 0);
         ID_RF_Rx : IN  std_logic_vector(15 downto 0);
         ID_RF_Ry : IN  std_logic_vector(15 downto 0);
         ID_RF_IH : IN  std_logic_vector(15 downto 0);
         ID_RF_SP : IN  std_logic_vector(15 downto 0);
         ID_RF_T : IN  std_logic_vector(15 downto 0);
         MEM_RF_LW : IN  std_logic_vector(15 downto 0);
         MEM_RF_Res : IN  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal AMuxOp : std_logic_vector(3 downto 0) := (others => '0');
   signal EXE_RF_Res : std_logic_vector(15 downto 0) := (others => '0');
   signal ID_RF_PC : std_logic_vector(15 downto 0) := (others => '0');
   signal ID_RF_Rx : std_logic_vector(15 downto 0) := (others => '0');
   signal ID_RF_Ry : std_logic_vector(15 downto 0) := (others => '0');
   signal ID_RF_IH : std_logic_vector(15 downto 0) := (others => '0');
   signal ID_RF_SP : std_logic_vector(15 downto 0) := (others => '0');
   signal ID_RF_T : std_logic_vector(15 downto 0) := (others => '0');
   signal MEM_RF_LW : std_logic_vector(15 downto 0) := (others => '0');
   signal MEM_RF_Res : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal ASrc : std_logic_vector(15 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: AMux PORT MAP (
          AMuxOp => AMuxOp,
          ASrc => ASrc,
          EXE_RF_Res => EXE_RF_Res,
          ID_RF_PC => ID_RF_PC,
          ID_RF_Rx => ID_RF_Rx,
          ID_RF_Ry => ID_RF_Ry,
          ID_RF_IH => ID_RF_IH,
          ID_RF_SP => ID_RF_SP,
          ID_RF_T => ID_RF_T,
          MEM_RF_LW => MEM_RF_LW,
          MEM_RF_Res => MEM_RF_Res
        );

   -- Stimulus process
   stim_proc: process
   begin		
        EXE_RF_Res <= "0000000000000001";
        ID_RF_PC   <= "0000000000000010";
        ID_RF_Rx   <= "0000000000000100";
        ID_RF_Ry   <= "0000000000001000";
        ID_RF_IH   <= "0000000000010000";
        ID_RF_SP   <= "0000000000100000";
        ID_RF_T    <= "0000000001000000";
        MEM_RF_LW  <= "0000000010000000";
        MEM_RF_Res <= "0000000100000000";
        
        -- ASrc 0000000000000001
        AMuxOp <= "0000";
        wait for 5 ns;
        -- ASrc 0000000000000010
        AMuxOp <= "0001";
        wait for 5 ns;
        -- ASrc 0000000000000100
        AMuxOp <= "0010";
        wait for 5 ns;
        -- ASrc 0000000000001000
        AMuxOp <= "0011";
        wait for 5 ns;
        -- ASrc 0000000000010000
        AMuxOp <= "0100";
        wait for 5 ns;
        -- ASrc 0000000000100000
        AMuxOp <= "0101";
        wait for 5 ns;
        -- ASrc 0000000001000000
        AMuxOp <= "0110";
        wait for 5 ns;
        -- ASrc 0000000010000000
        AMuxOp <= "0111";
        wait for 5 ns;
        -- ASrc 0000000100000000
        AMuxOp <= "1000";
        wait for 5 ns;
        -- ASrc 1000000000000000
        AMuxOp <= "0000";
        EXE_RF_Res <= "1000000000000000";
        wait for 5 ns;
        -- ASrc 0000000000000000
        AMuxOp <= "1001";
        wait for 5 ns;
        -- ASrc 0000000000000000
        AMuxOp <= "1010";
        wait for 5 ns;
        -- ASrc 0000000000000000
        AMuxOp <= "1011";
        wait for 5 ns;
        -- ASrc 0000000000000000
        AMuxOp <= "1100";
        wait for 5 ns;
        -- ASrc 0000000000000000
        AMuxOp <= "1101";
        wait for 5 ns;
        -- ASrc 0000000000000000
        AMuxOp <= "1110";
        wait for 5 ns;
        -- ASrc 0000000000000000
        AMuxOp <= "1111";
        wait for 5 ns;
   end process;

END;
