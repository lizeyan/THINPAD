--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:00:56 11/25/2016
-- Design Name:   
-- Module Name:   C:/Users/zy-li14/Desktop/THINPAD_LLY/src/test1.vhd
-- Project Name:  NaiveCPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: NaiveCPU
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
 
ENTITY test1 IS
END test1;
 
ARCHITECTURE behavior OF test1 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT NaiveCPU
    PORT(
         clk_in : IN  std_logic;
         rst : IN  std_logic;
         InputSW : IN  std_logic_vector(15 downto 0);
         Addr1 : OUT  std_logic_vector(15 downto 0);
         Addr2 : OUT  std_logic_vector(15 downto 0);
         Data1 : INOUT  std_logic_vector(15 downto 0);
         Data2 : INOUT  std_logic_vector(15 downto 0);
         Ram1EN : OUT  std_logic;
         Ram1OE : OUT  std_logic;
         Ram1WE : OUT  std_logic;
         Ram2EN : OUT  std_logic;
         Ram2OE : OUT  std_logic;
         Ram2WE : OUT  std_logic;
         UartRdn : OUT  std_logic;
         UartWrn : OUT  std_logic;
         DataReady : IN  std_logic;
         Tbre : IN  std_logic;
         Tsre : IN  std_logic;
         Digit7Left : OUT  std_logic_vector(6 downto 0);
         DIgit7Right : OUT  std_logic_vector(6 downto 0);
         Hs : OUT  std_logic;
         Vs : OUT  std_logic;
         R : OUT  std_logic_vector(2 downto 0);
         G : OUT  std_logic_vector(2 downto 0);
         B : OUT  std_logic_vector(2 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk_in : std_logic := '0';
   signal rst : std_logic := '0';
   signal InputSW : std_logic_vector(15 downto 0) := (others => '0');
   signal DataReady : std_logic := '0';
   signal Tbre : std_logic := '0';
   signal Tsre : std_logic := '0';

	--BiDirs
   signal Data1 : std_logic_vector(15 downto 0);
   signal Data2 : std_logic_vector(15 downto 0);

 	--Outputs
   signal Addr1 : std_logic_vector(15 downto 0);
   signal Addr2 : std_logic_vector(15 downto 0);
   signal Ram1EN : std_logic;
   signal Ram1OE : std_logic;
   signal Ram1WE : std_logic;
   signal Ram2EN : std_logic;
   signal Ram2OE : std_logic;
   signal Ram2WE : std_logic;
   signal UartRdn : std_logic;
   signal UartWrn : std_logic;
   signal Digit7Left : std_logic_vector(6 downto 0);
   signal DIgit7Right : std_logic_vector(6 downto 0);
   signal Hs : std_logic;
   signal Vs : std_logic;
   signal R : std_logic_vector(2 downto 0);
   signal G : std_logic_vector(2 downto 0);
   signal B : std_logic_vector(2 downto 0);

   -- Clock period definitions
   constant clk_in_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: NaiveCPU PORT MAP (
          clk_in => clk_in,
          rst => rst,
          InputSW => InputSW,
          Addr1 => Addr1,
          Addr2 => Addr2,
          Data1 => Data1,
          Data2 => Data2,
          Ram1EN => Ram1EN,
          Ram1OE => Ram1OE,
          Ram1WE => Ram1WE,
          Ram2EN => Ram2EN,
          Ram2OE => Ram2OE,
          Ram2WE => Ram2WE,
          UartRdn => UartRdn,
          UartWrn => UartWrn,
          DataReady => DataReady,
          Tbre => Tbre,
          Tsre => Tsre,
          Digit7Left => Digit7Left,
          DIgit7Right => DIgit7Right,
          Hs => Hs,
          Vs => Vs,
          R => R,
          G => G,
          B => B
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
		wait for clk_in_period * 3;
		inputsw <= "0110100000000000"; -- LI R0 0
		-- R0 0
		wait for clk_in_period * 4;
      inputsw <= "0100100000000001"; -- ADDIU R0 1
		-- R0 1
		wait for clk_in_period * 4;
		inputsw <= "0100000000100010"; -- ADDIU3 R0 R1 2
		-- R1 3; R0 1
		wait for clk_in_period * 4;
		inputsw <= "0110010000100000"; --MTSP R1
		-- R1 3; R0 1; SP 3
		wait for clk_in_period * 4;
		inputsw <= "0000001000000010"; --ADDSP R2 2
		-- R2: 5; R1 3; R0 1; SP 3
		wait for clk_in_period * 4;
		inputsw <= "0011001101000111"; --SRA R3 R2 1
		-- R3: 2; R2: 5; R1 3; R0 1; SP 3
		wait for clk_in_period * 4;
      -- insert stimulus here 

      wait;
   end process;

END;
