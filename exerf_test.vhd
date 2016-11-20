--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:59:49 11/20/2016
-- Design Name:   
-- Module Name:   C:/Users/zy-li14/Desktop/THINPAD_LLY/exerf_test.vhd
-- Project Name:  NaiveCPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: EXE_RF
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
 
ENTITY exerf_test IS
END exerf_test;
 
ARCHITECTURE behavior OF exerf_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT EXE_RF
    PORT(
         clk : IN  std_logic;
         EXE_RFOp : IN  std_logic_vector(1 downto 0);
         RF_Flags_In : IN  std_logic_vector(3 downto 0);
         RF_PC_In : IN  std_logic_vector(15 downto 0);
         RF_Rd_In : IN  std_logic_vector(3 downto 0);
         RF_Res_In : IN  std_logic_vector(15 downto 0);
         RF_Rx_In : IN  std_logic_vector(15 downto 0);
         RF_Ry_In : IN  std_logic_vector(15 downto 0);
         RF_St_In : IN  std_logic_vector(15 downto 0);
         RF_Flags_Out : OUT  std_logic_vector(3 downto 0);
         RF_PC_Out : OUT  std_logic_vector(15 downto 0);
         RF_Rd_Out : OUT  std_logic_vector(3 downto 0);
         RF_Res_Out : OUT  std_logic_vector(15 downto 0);
         RF_Rx_Out : OUT  std_logic_vector(15 downto 0);
         RF_Ry_Out : OUT  std_logic_vector(15 downto 0);
         RF_St_Out : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal EXE_RFOp : std_logic_vector(1 downto 0) := (others => '0');
   signal RF_Flags_In : std_logic_vector(3 downto 0) := (others => '0');
   signal RF_PC_In : std_logic_vector(15 downto 0) := (others => '0');
   signal RF_Rd_In : std_logic_vector(3 downto 0) := (others => '0');
   signal RF_Res_In : std_logic_vector(15 downto 0) := (others => '0');
   signal RF_Rx_In : std_logic_vector(15 downto 0) := (others => '0');
   signal RF_Ry_In : std_logic_vector(15 downto 0) := (others => '0');
   signal RF_St_In : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal RF_Flags_Out : std_logic_vector(3 downto 0);
   signal RF_PC_Out : std_logic_vector(15 downto 0);
   signal RF_Rd_Out : std_logic_vector(3 downto 0);
   signal RF_Res_Out : std_logic_vector(15 downto 0);
   signal RF_Rx_Out : std_logic_vector(15 downto 0);
   signal RF_Ry_Out : std_logic_vector(15 downto 0);
   signal RF_St_Out : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: EXE_RF PORT MAP (
          clk => clk,
          EXE_RFOp => EXE_RFOp,
          RF_Flags_In => RF_Flags_In,
          RF_PC_In => RF_PC_In,
          RF_Rd_In => RF_Rd_In,
          RF_Res_In => RF_Res_In,
          RF_Rx_In => RF_Rx_In,
          RF_Ry_In => RF_Ry_In,
          RF_St_In => RF_St_In,
          RF_Flags_Out => RF_Flags_Out,
          RF_PC_Out => RF_PC_Out,
          RF_Rd_Out => RF_Rd_Out,
          RF_Res_Out => RF_Res_Out,
          RF_Rx_Out => RF_Rx_Out,
          RF_Ry_Out => RF_Ry_Out,
          RF_St_Out => RF_St_Out
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
		 EXE_RFOp <= "00";
		 RF_Flags_In <= "1001";
		 RF_PC_In <= "1111011100110001";
		 RF_Rd_In <= "0111";
		 RF_Res_In <= "1111111100000000";
		 RF_Rx_In <= "1111000011110000";
		 RF_Ry_In <= "0000111100001111";
		 RF_St_In <= "0000100111011101";
		wait for 10 ns;
		 EXE_RFOp <= "11";
		 RF_Flags_In <= "1001";
		 RF_PC_In <= "1111011100110001";
		 RF_Rd_In <= "0111";
		 RF_Res_In <= "1111111100000000";
		 RF_Rx_In <= "1111000011110000";
		 RF_Ry_In <= "0000111100001111";
		 RF_St_In <= "0000100111011101";
		 wait for 10 ns;
		 EXE_RFOp <= "10";
		 RF_Flags_In <= "1001";
		 RF_PC_In <= "1111011100110001";
		 RF_Rd_In <= "0111";
		 RF_Res_In <= "1111111100000000";
		 RF_Rx_In <= "1111000011110000";
		 RF_Ry_In <= "0000111100001111";
		 RF_St_In <= "0000100111011101";
		 wait for 10 ns;
      -- insert stimulus here 
   end process;

END;
