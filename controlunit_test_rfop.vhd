--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:23:27 11/24/2016
-- Design Name:   
-- Module Name:   C:/Users/zy-li14/Desktop/THINPAD_LLY/src/controlunit_test_rfop.vhd
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
 
ENTITY controlunit_test_rfop IS
END controlunit_test_rfop;
 
ARCHITECTURE behavior OF controlunit_test_rfop IS 
 
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
         IF_RF_OPC : IN std_logic_vector(15 downto 0);
         IDPC : IN  std_logic_vector(15 downto 0);
         ID_RF_OP : IN  std_logic_vector(4 downto 0);
         ID_RF_Rd : IN  std_logic_vector(3 downto 0);
         EXE_RF_OP : IN  std_logic_vector(4 downto 0);
         EXE_RF_Rd : IN  std_logic_vector(3 downto 0);
         EXE_Res : IN  std_logic_vector(15 downto 0);
         MEM_RF_OP : IN  std_logic_vector(4 downto 0);
         MEM_RF_Rd : IN  std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal PC_RF_PC : std_logic_vector(15 downto 0) := (others => '0');
   signal IF_Ins : std_logic_vector(15 downto 0) := (others => '0');
   signal IF_RF_OP : std_logic_vector(4 downto 0) := (others => '0');
   signal IF_RF_ST : std_logic_vector(15 downto 0) := (others => '0');
   signal IF_RF_OPC : std_logic_vector(15 downto 0) := (others => '0');
   signal IDPC : std_logic_vector(15 downto 0) := (others => '0');
   signal ID_RF_OP : std_logic_vector(4 downto 0) := (others => '0');
   signal ID_RF_Rd : std_logic_vector(3 downto 0) := (others => '0');
   signal EXE_RF_OP : std_logic_vector(4 downto 0) := (others => '0');
   signal EXE_RF_Rd : std_logic_vector(3 downto 0) := (others => '0');
   signal EXE_Res : std_logic_vector(15 downto 0) := (others => '0');
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
          IF_RF_OPC => IF_RF_OPC,
          IDPC => IDPC,
          ID_RF_OP => ID_RF_OP,
          ID_RF_Rd => ID_RF_Rd,
          EXE_RF_OP => EXE_RF_OP,
          EXE_RF_Rd => EXE_RF_Rd,
          EXE_Res => EXE_Res,
          MEM_RF_OP => MEM_RF_OP,
          MEM_RF_Rd => MEM_RF_Rd
        );

   -- Stimulus process
   stim_proc: process
   begin
		-- 未发生任何问题
		-- ID_RFOP 00
		-- IF_RFOP 00
        wait for 10 ns;
		-- 仅跳转失败
		-- ID_RFOP 00
		-- IF_RFOP 11
        IF_RF_St <= "0010011100000000";
        IDPC <= "0000000000000001";
		wait for 10 ns;
		-- 普通指令 上一条指令是LW且目标冲突
		-- ID_RFOP 11
		-- IF_RFOP 10
        IDPC <= "0000000000000000";
        IF_RF_St <= "1110100011101100";  -- AND R0 R7
        ID_RF_Op <= "10011";
        ID_RF_Rd <= "0111";
        wait for 10 ns;
		-- 普通指令 上一条指令是LW且目标不冲突
		-- ID_RFOP 00
		-- IF_RFOP 00
        ID_RF_Rd <= "1001";
		wait for 10 ns;
		-- 跳转指令BEQZ 上一条指令是LW且目标冲突
		-- ID_RFOP 11
		-- IF_RFOP 10
        IF_RF_St <= "0010011100000000";  -- BEQZ R7 0
		ID_RF_Rd <= "0111";
        wait for 10 ns;
		-- 跳转指令BEQZ 上一条指令不是LW且目标冲突
		-- ID_RFOP 11
		-- IF_RFOP 10
        ID_RF_Op <= "11101";
		wait for 10 ns;
		-- 跳转指令BEQZ 上一条指令是LW且目标冲突 且跳转失败
		-- ID_RFOP 11
		-- IF_RFOP 10
		ID_RF_Op <= "10011";
        IDPC <= "0000000000000001";
        wait for 10 ns;
		-- 跳转指令BTEQZ 上上条指令不是LW且目标冲突
		-- ID_RFOP 00
		-- IF_RFOP 00
        IDPC <= "0000000000000000";
		IF_RF_St <= "0110000000000000";
        EXE_RF_OP <= "11101";
        EXE_RF_Rd <= "1010";
        wait for 10 ns;
		-- 跳转指令JR 上上条指令是LW且目标冲突
		-- ID_RFOP 11
		-- IF_RFOP 10
		IF_RF_St <= "1110111100000000";
        EXE_RF_OP <= "10011";
        EXE_RF_Rd <= "0111";
        wait for 10 ns;
		-- 跳转指令JR 上上条指令是LW且目标不冲突
		-- ID_RFOP 00
		-- IF_RFOP 00
        ID_RF_Rd <= "0000";
		EXE_RF_Rd <= "0000";
        wait for 10 ns;
		-- 仅发现重写指令 IF
		-- ID_RFOP 00
		-- IF_RFOP 11
        ID_RF_OP <= "11011";  -- SW
        PC_RF_PC <= "0000000000000001";
        EXE_Res <= "0000000000000001";
        wait for 10 ns;
        -- 仅发现重写指令 ID
		-- ID_RFOP 11
		-- IF_RFOP 11
        IF_RF_OP <= "10011";  -- LW
        ID_RF_OP <= "11010";  -- SW_SP
        IF_RF_OPC <= "0000000000000001";
        wait for 10 ns;
   end process;
END;
