--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:40:07 11/26/2016
-- Design Name:   
-- Module Name:   C:/Users/cslab/Desktop/THINPAD_LLY/src/test5.vhd
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
 
ENTITY test5 IS
END test5;
 
ARCHITECTURE behavior OF test5 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT NaiveCPU
    PORT(
         clk_in : IN  std_logic;
         clk_50 : IN  std_logic;
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
         ledlights : OUT  std_logic_vector(15 downto 0);
         Hs : OUT  std_logic;
         Vs : OUT  std_logic;
         R : OUT  std_logic_vector(2 downto 0);
         G : OUT  std_logic_vector(2 downto 0);
         B : OUT  std_logic_vector(2 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk_in : std_logic := '0';
   signal clk_50 : std_logic := '0';
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
   signal ledlights : std_logic_vector(15 downto 0);
   signal Hs : std_logic;
   signal Vs : std_logic;
   signal R : std_logic_vector(2 downto 0);
   signal G : std_logic_vector(2 downto 0);
   signal B : std_logic_vector(2 downto 0);

   -- Clock period definitions
   constant clk_in_period : time := 10 ns;
   constant clk_50_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: NaiveCPU PORT MAP (
          clk_in => clk_in,
          clk_50 => clk_50,
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
          ledlights => ledlights,
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
        rst <= '1';
      wait for clk_in_period * 3;
      inputsw <= "0110111010111111";
      wait for clk_in_period * 4;
      inputsw <= "0011011011000000";
      wait for clk_in_period * 4;
      inputsw <= "0100111000010000";
      wait for clk_in_period * 4;
        inputsw <= "1001111010100101"; --LW R6 R5 5
      wait for clk_in_period * 4;
        inputsw <= "1001111001000010"; --LW R6 R2 2
      wait for clk_in_period * 4;
      wait for clk_in_period * 4;
      wait for clk_in_period * 4;
      wait for clk_in_period * 4;
      wait;
   end process;

END;
