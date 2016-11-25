--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:23:23 11/21/2016
-- Design Name:   
-- Module Name:   C:/Users/zy-li14/Desktop/THINPAD_LLY/src/memuart_test.vhd
-- Project Name:  NaiveCPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MemUart
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
 
ENTITY memuart_test IS
END memuart_test;
 
ARCHITECTURE behavior OF memuart_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MemUart
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         PC_RF_PC : IN  std_logic_vector(15 downto 0);
         IF_Ins : OUT  std_logic_vector(15 downto 0);
         MEM_SW_SrcOP : IN  std_logic;
         EXE_RF_Res : IN  std_logic_vector(15 downto 0);
         EXE_RF_Rx : IN  std_logic_vector(15 downto 0);
         EXE_RF_Ry : IN  std_logic_vector(15 downto 0);
         MEM_LW : OUT  std_logic_vector(15 downto 0);
         RamRWOp : IN  std_logic;
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
         Tsre : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal PC_RF_PC : std_logic_vector(15 downto 0) := (others => '0');
   signal MEM_SW_SrcOP : std_logic := '0';
   signal EXE_RF_Res : std_logic_vector(15 downto 0) := (others => '0');
   signal EXE_RF_Rx : std_logic_vector(15 downto 0) := (others => '0');
   signal EXE_RF_Ry : std_logic_vector(15 downto 0) := (others => '0');
   signal RamRWOp : std_logic := '0';
   signal DataReady : std_logic := '0';
   signal Tbre : std_logic := '0';
   signal Tsre : std_logic := '0';

	--BiDirs
   signal Data1 : std_logic_vector(15 downto 0) := "0000000000000000";
   signal Data2 : std_logic_vector(15 downto 0) := "0000000000000000";

 	--Outputs
   signal IF_Ins : std_logic_vector(15 downto 0);
   signal MEM_LW : std_logic_vector(15 downto 0);
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

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MemUart PORT MAP (
          clk => clk,
          rst => rst,
          PC_RF_PC => PC_RF_PC,
          IF_Ins => IF_Ins,
          MEM_SW_SrcOP => MEM_SW_SrcOP,
          EXE_RF_Res => EXE_RF_Res,
          EXE_RF_Rx => EXE_RF_Rx,
          EXE_RF_Ry => EXE_RF_Ry,
          MEM_LW => MEM_LW,
          RamRWOp => RamRWOp,
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
          Tsre => Tsre
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
		rst <= '1';
--		-- test for if and read write ram1
		-- ¶Áram2
		pc_rf_pc <= "0000000000001111";
		exe_rf_res <= "0000000011111111";
		ramrwop <= '0';
		data2 <= "1010000010100000";
		wait for clk_period * 4;
		-- Ð´ram2
		data2 <= "ZZZZZZZZZZZZZZZZ";
		pc_rf_pc <= "0000000000011111";
		exe_rf_res <= "0000000011111110";
		ramrwop <= '1';
		mem_sw_srcop <= '0';
		exe_rf_rx <= "1111000000001111";
		exe_rf_ry <= "0000111111110000";
		wait for clk_period * 4;
		
		-- ¶Áram1
		pc_rf_pc <= "0000000000001111";
		exe_rf_res <= "1000000011111111";
		data1 <= "1010101111110000";
		ramrwop <= '0';
		data2 <= "1010000010100000";
		wait for clk_period * 4;
		-- Ð´ram1
		data1 <= "ZZZZZZZZZZZZZZZZ";
		pc_rf_pc <= "0000000000011111";
		exe_rf_res <= "1000000011111110";
		ramrwop <= '1';
		mem_sw_srcop <= '0';
		exe_rf_rx <= "1111000000001111";
		exe_rf_ry <= "0000111111110000";
		wait for clk_period * 4;
		
		-- ¶Á´®¿ÚÊý¾Ý
		pc_rf_pc <= "0000000000001111";
		exe_rf_res <= "1011111100000000";
		ramrwop <= '0';
		data2 <= "1010000010100000";
		wait for clk_period * 4;
		
		-- Ð´´®¿ÚÊý¾Ý
		pc_rf_pc <= "0000000000011111";
		exe_rf_res <= "1011111100000000";
		ramrwop <= '1';
		mem_sw_srcop <= '0';
		exe_rf_rx <= "1111000000001111";
		exe_rf_ry <= "0000111111110000";
		wait for clk_period * 4;
		
		-- ¶Á´®¿Ú×´Ì¬
		pc_rf_pc <= "0000000000001111";
		exe_rf_res <= "1011111100000001";
		ramrwop <= '0';
		data2 <= "1010000010100000";
		dataready <= '0';
		tbre <= '1';
		tsre <= '1';
		wait for clk_period * 4;
		
		pc_rf_pc <= "0000000000001111";
		exe_rf_res <= "1011111100000001";
		ramrwop <= '0';
		data2 <= "1010000010100000";
		dataready <= '1';
		tbre <= '0';
		tsre <= '1';
		wait for clk_period * 4;
   end process;

END;
