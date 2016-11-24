--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   15:54:02 11/24/2016
-- Design Name:   
-- Module Name:   C:/Users/zy-li14/Desktop/THINPAD_LLY/src/controlunit_test_abmux.vhd
-- Project Name:  NaiveCPU
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ControlUnit
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
 
ENTITY controlunit_test_abmux IS
END controlunit_test_abmux;
 
ARCHITECTURE behavior OF controlunit_test_abmux IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ControlUnit
    PORT(
         ExDigitsOp : OUT  std_logic_vector(2 downto 0);
         ExSignOp : OUT  std_logic;
         AluOp : OUT  std_logic_vector(3 downto 0);
         AMuxOp : OUT  std_logic_vector(3 downto 0);
         BMuxOp : OUT  std_logic_vector(2 downto 0);
         DirOp : OUT  std_logic_vector(2 downto 0);
         IDPCOp : OUT  std_logic_vector(1 downto 0);
         RegWrbOp : OUT  std_logic_vector(1 downto 0);
         RXTOp : OUT  std_logic_vector(2 downto 0);
         SWSrc : OUT  std_logic;
         RamRWOp : OUT  std_logic;
         BTBOP : OUT  std_logic;
         EXE_RFOp : OUT  std_logic_vector(1 downto 0);
         ID_RFOp : OUT  std_logic_vector(1 downto 0);
         IF_RFOp : OUT  std_logic_vector(1 downto 0);
         MEM_RFOp : OUT  std_logic_vector(1 downto 0);
         PC_RFOp : OUT  std_logic_vector(2 downto 0);
         PC_RF_PC : IN  std_logic_vector(15 downto 0);
         IF_Ins : IN  std_logic_vector(15 downto 0);
         IF_RF_OP : IN  std_logic_vector(4 downto 0);
         IF_RF_ST : IN  std_logic_vector(15 downto 0);
         IDPC : IN  std_logic_vector(15 downto 0);
         ID_RF_OP : IN  std_logic_vector(4 downto 0);
         ID_RF_Rd : IN  std_logic_vector(3 downto 0);
         EXE_RF_OP : IN  std_logic_vector(4 downto 0);
         EXE_RF_Rd : IN  std_logic_vector(3 downto 0);
         EXE_Fout : IN  std_logic_vector(15 downto 0);
         MEM_RF_OP : IN  std_logic_vector(4 downto 0);
         MEM_RF_Rd : IN  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal PC_RF_PC : std_logic_vector(15 downto 0) := (others => '0');
   signal IF_Ins : std_logic_vector(15 downto 0) := (others => '0');
   signal IF_RF_OP : std_logic_vector(4 downto 0) := (others => '0');
   signal IF_RF_ST : std_logic_vector(15 downto 0) := (others => '0');
   signal IDPC : std_logic_vector(15 downto 0) := (others => '0');
   signal ID_RF_OP : std_logic_vector(4 downto 0) := (others => '0');
   signal ID_RF_Rd : std_logic_vector(3 downto 0) := (others => '0');
   signal EXE_RF_OP : std_logic_vector(4 downto 0) := (others => '0');
   signal EXE_RF_Rd : std_logic_vector(3 downto 0) := (others => '0');
   signal EXE_Fout : std_logic_vector(15 downto 0) := (others => '0');
   signal MEM_RF_OP : std_logic_vector(4 downto 0) := (others => '0');
   signal MEM_RF_Rd : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal ExDigitsOp : std_logic_vector(2 downto 0);
   signal ExSignOp : std_logic;
   signal AluOp : std_logic_vector(3 downto 0);
   signal AMuxOp : std_logic_vector(3 downto 0);
   signal BMuxOp : std_logic_vector(2 downto 0);
   signal DirOp : std_logic_vector(2 downto 0);
   signal IDPCOp : std_logic_vector(1 downto 0);
   signal RegWrbOp : std_logic_vector(1 downto 0);
   signal RXTOp : std_logic_vector(2 downto 0);
   signal SWSrc : std_logic;
   signal RamRWOp : std_logic;
   signal BTBOP : std_logic;
   signal EXE_RFOp : std_logic_vector(1 downto 0);
   signal ID_RFOp : std_logic_vector(1 downto 0);
   signal IF_RFOp : std_logic_vector(1 downto 0);
   signal MEM_RFOp : std_logic_vector(1 downto 0);
   signal PC_RFOp : std_logic_vector(2 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ControlUnit PORT MAP (
          ExDigitsOp => ExDigitsOp,
          ExSignOp => ExSignOp,
          AluOp => AluOp,
          AMuxOp => AMuxOp,
          BMuxOp => BMuxOp,
          DirOp => DirOp,
          IDPCOp => IDPCOp,
          RegWrbOp => RegWrbOp,
          RXTOp => RXTOp,
          SWSrc => SWSrc,
          RamRWOp => RamRWOp,
          BTBOP => BTBOP,
          EXE_RFOp => EXE_RFOp,
          ID_RFOp => ID_RFOp,
          IF_RFOp => IF_RFOp,
          MEM_RFOp => MEM_RFOp,
          PC_RFOp => PC_RFOp,
          PC_RF_PC => PC_RF_PC,
          IF_Ins => IF_Ins,
          IF_RF_OP => IF_RF_OP,
          IF_RF_ST => IF_RF_ST,
          IDPC => IDPC,
          ID_RF_OP => ID_RF_OP,
          ID_RF_Rd => ID_RF_Rd,
          EXE_RF_OP => EXE_RF_OP,
          EXE_RF_Rd => EXE_RF_Rd,
          EXE_Fout => EXE_Fout,
          MEM_RF_OP => MEM_RF_OP,
          MEM_RF_Rd => MEM_RF_Rd
        );
 

   -- Stimulus process
   stim_proc: process
   begin
		-- or 没有旁路 rx:000 ry:001
		-- amux 0010
		-- bmux 010
      if_rf_st  <= "1110100000101101";
		id_rf_op <= "11101";
		id_rf_rd <= "1111";
		exe_rf_op <= "11100";
		exe_rf_rd <= "0111";
		wait for 10 ns;
		-- amux上一条目标冲突
		-- amux 0000
		-- bmux 010
      if_rf_st  <= "1110100000101101";
		id_rf_op <= "11101";
		id_rf_rd <= "0000";
		exe_rf_op <= "11100";
		exe_rf_rd <= "0111";
		wait for 10 ns;
		-- bmux上一条目标冲突
		-- amux  0010
		-- bmux 000
      if_rf_st  <= "1110100000101101";
		id_rf_op <= "11101";
		id_rf_rd <= "0001";
		exe_rf_op <= "11100";
		exe_rf_rd <= "0111";
		wait for 10 ns;
		-- amux上上条目标冲突且为LW
		-- amux 0111
		-- bmux 010
      if_rf_st  <= "1110100000101101";
		id_rf_op <= "11101";
		id_rf_rd <= "1111";
		exe_rf_op <= "10010";
		exe_rf_rd <= "0000";
		wait for 10 ns;
		-- bmux上上条目标冲突且为LW
		-- amux 0010
		-- bmux 011
      if_rf_st  <= "1110100000101101";
		id_rf_op <= "11101";
		id_rf_rd <= "1111";
		exe_rf_op <= "10010";
		exe_rf_rd <= "0001";
		wait for 10 ns;
		-- amux上上条目标冲突且不是LW
		-- amux 1000
		-- bmux 010
      if_rf_st  <= "1110100000101101";
		id_rf_op <= "11101";
		id_rf_rd <= "1111";
		exe_rf_op <= "00011";
		exe_rf_rd <= "0000";
		wait for 10 ns;
		-- bmux上上条目标冲突且不是LW
		-- amux 0010
		-- bmux 100
      if_rf_st  <= "1110100000101101";
		id_rf_op <= "11101";
		id_rf_rd <= "1111";
		exe_rf_op <= "00011";
		exe_rf_rd <= "0001";
		wait for 10 ns;
   end process;

END;
