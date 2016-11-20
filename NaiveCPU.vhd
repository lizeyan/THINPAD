----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    09:58:45 11/18/2016 
-- Design Name: 
-- Module Name:    NaiveCPU - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity NaiveCPU is
    Port ( clk_in : in STD_LOGIC;
           rst : in STD_LOGIC;
           InputSW : in STD_LOGIC_VECTOR(15 downto 0);
           
           -- Ram 1, 2 and Uart
           Addr1 : out STD_LOGIC_VECTOR(15 downto 0);
           Addr2 : out STD_LOGIC_VECTOR(15 downto 0);
           Data1 : inout STD_LOGIC_VECTOR(15 downto 0);  -- low 8 digits for Uart
           Data2 : inout STD_LOGIC_VECTOR(15 downto 0);
           Ram1EN : out STD_LOGIC;
           Ram1OE : out STD_LOGIC;
           Ram1WE : out STD_LOGIC;
           Ram2EN : out STD_LOGIC;
           Ram2OE : out STD_LOGIC;
           Ram2WE : out STD_LOGIC;
           UartRdn : out STD_LOGIC;
           UartWrn : out STD_LOGIC;
           DataReady : in STD_LOGIC;
           Tbre : in STD_LOGIC;
           Tsre : in STD_LOGIC;
           
           -- Digit 7 Lights
           Digit7Left : out STD_LOGIC_VECTOR(6 downto 0);
           DIgit7Right : out STD_LOGIC_VECTOR(6 downto 0);
           
           -- VGA
           Hs : out STD_LOGIC;
           Vs : out STD_LOGIC;
           R : out STD_LOGIC_VECTOR(2 downto 0);
           G : out STD_LOGIC_VECTOR(2 downto 0);
           B : out STD_LOGIC_VECTOR(2 downto 0));
end NaiveCPU;

architecture Behavioral of NaiveCPU is
    -- ALU
    component ALU
        Port ( AluOp : in STD_LOGIC_VECTOR(3 downto 0);
               ASrc : in STD_LOGIC_VECTOR(15 downto 0);
               BSrc : in STD_LOGIC_VECTOR(15 downto 0);
               
               Fout : out STD_LOGIC_VECTOR(15 downto 0);
               Flags : out STD_LOGIC_VECTOR(3 downto 0));  -- ZCSO
    end component;

    -- ALU Src A Mux
    component AMux
        Port ( AMuxOp : in STD_LOGIC_VECTOR(3 downto 0); --
               ASrc : out STD_LOGIC_VECTOR(15 downto 0);
               ID_RF_PC : in STD_LOGIC_VECTOR(15 downto 0);
               ID_RF_Rx : in STD_LOGIC_VECTOR(15 downto 0);
               ID_RF_Ry : in STD_LOGIC_VECTOR(15 downto 0);
               ID_RF_IH : in STD_LOGIC_VECTOR(15 downto 0);
               ID_RF_SP : in STD_LOGIC_VECTOR(15 downto 0);
               ID_RF_T : in STD_LOGIC_VECTOR(15 downto 0);
               EXE_RF_Res : in STD_LOGIC_VECTOR(15 downto 0);
               MEM_RF_LW : in STD_LOGIC_VECTOR(15 downto 0); --mem段寄存器中mem取出的数据
               MEM_RF_Res : in STD_LOGIC_VECTOR(15 downto 0)); --mem段寄存器中alu计算的结果
    end component;
    
    -- ALU Src B Mux
    component BMux
        Port ( BMuxOp : in STD_LOGIC_VECTOR(2 downto 0);--
               BSrc : out STD_LOGIC_VECTOR(15 downto 0);
               ID_RF_Imm : in STD_LOGIC_VECTOR(15 downto 0);
               ID_RF_Ry : in STD_LOGIC_VECTOR(15 downto 0);
               EXE_RF_Res : in STD_LOGIC_VECTOR(15 downto 0);
               MEM_RF_LW : in STD_LOGIC_VECTOR(15 downto 0);
               MEM_RF_Res : in STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    -- Branch Target Buffer
    component BTB
        Port ( clk : in STD_LOGIC;
               PDTPC : out STD_LOGIC_VECTOR(15 downto 0);
               
               IDPC : in STD_LOGIC_VECTOR(15 downto 0);
               IF_Res : in STD_LOGIC_VECTOR(15 downto 0); -- 一定等于PC_RF_PC+1.
               IF_RF_OP : in STD_LOGIC_VECTOR(4 downto 0);
               IF_RF_PC : in STD_LOGIC_VECTOR(15 downto 0);
               PC_RF_PC : in STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    -- Clock Module
    component ClockModule
        Port ( clk_in : in STD_LOGIC;
               --分频
					clk: out STD_LOGIC;
               clk_2 : out STD_LOGIC;
               clk_4 : out STD_LOGIC;
               clk_8 : out STD_LOGIC;
               clk_16 : out STD_LOGIC);
    end component;
    
    -- Control Unit
    component ControlUnit
        Port ( AluOp : out STD_LOGIC_VECTOR(3 downto 0); --alu操作数
               AMuxOp : out STD_LOGIC_VECTOR(3 downto 0);
               BMuxOp : out STD_LOGIC_VECTOR(2 downto 0);
               DirOp : out STD_LOGIC_VECTOR(2 downto 0); --rd的选择信号
               ExDigitsOp : out STD_LOGIC_VECTOR(2 downto 0); --扩展位数控制
               ExSignOp : out STD_LOGIC; 
               IDPCOp : out STD_LOGIC_VECTOR(1 downto 0); --是不是跳转指令
			   RamEn: out STD_LOGIC_VECTOR(1 downto 0);
               RamRWOp : out STD_LOGIC_VECTOR(1 downto 0); 
               RegWrbOp : out STD_LOGIC_VECTOR(1 downto 0);
               RXTOp : out STD_LOGIC_VECTOR(1 downto 0);
               
               EXE_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
               ID_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
               IF_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
               MEM_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
               PC_RFOp : out STD_LOGIC_VECTOR(1 downto 0);
               
               IF_RF_OP : in STD_LOGIC_VECTOR(4 downto 0);
               ID_RF_OP : in STD_LOGIC_VECTOR(4 downto 0);
               ID_RF_Rd : in STD_LOGIC_VECTOR(3 downto 0);
               EXE_RF_OP : in STD_LOGIC_VECTOR(4 downto 0);
               EXE_RF_Rd : in STD_LOGIC_VECTOR(3 downto 0)
               
               
               );
    end component;
    
    -- Digit 7 Light
    component Digit7Light
        Port ( Data : in STD_LOGIC_VECTOR(3 downto 0);
               Output : out STD_LOGIC_VECTOR(6 downto 0));
    end component;
    
    -- Direction Module
	 -- 选择RD
    component DirectionModule
        Port ( ID_Rd : out STD_LOGIC_VECTOR(3 downto 0);
               DirOp : in STD_LOGIC_VECTOR(2 downto 0);
               
               IF_RF_RX : in STD_LOGIC_VECTOR(2 downto 0);
               IF_RF_RY : in STD_LOGIC_VECTOR(2 downto 0);
               IF_RF_RZ : in STD_LOGIC_VECTOR(2 downto 0));
    end component;
    
    -- EXE/MEM Register
    component EXE_RF
        Port ( clk : in STD_LOGIC;
					-- 10 => 写入in信号
					-- 11 => 写入NOP指令对应的信号
					-- others => 不写入
               EXE_RFOp : in STD_LOGIC_VECTOR(1 downto 0);  -- 10 for WE_N, 11 for NOP, 0- for WE
               
               RF_Flags_In : in STD_LOGIC_VECTOR(3 downto 0);
               RF_PC_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_Rd_In : in STD_LOGIC_VECTOR(3 downto 0);
               RF_Res_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_Rx_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_Ry_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_St_In : in STD_LOGIC_VECTOR(15 downto 0);
               
               RF_Flags_Out : out STD_LOGIC_VECTOR(3 downto 0);
               RF_PC_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_Rd_Out : out STD_LOGIC_VECTOR(3 downto 0);
               RF_Res_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_Rx_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_Ry_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_St_Out : out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    -- Extend Module
    component ExtendModule
        Port ( ExSrc : in STD_LOGIC_VECTOR(10 downto 0);
               ExImm : out STD_LOGIC_VECTOR(15 downto 0);
               
               ExDigitsOp : in STD_LOGIC_VECTOR(2 downto 0);
               ExSignOp : in STD_LOGIC);
    end component;
    
    -- IDPC Selector
    component IDPCRXT
        Port ( IDPC : out STD_LOGIC_VECTOR(15 downto 0);
               IDPCOp : in STD_LOGIC_VECTOR(1 downto 0); --是否是分支指令。
               RXTOp : in STD_LOGIC_VECTOR(1 downto 0);
               
               ID_Res : in STD_LOGIC_VECTOR(15 downto 0);
               ID_Rx : in STD_LOGIC_VECTOR(15 downto 0);
               ID_T : in STD_LOGIC_VECTOR(15 downto 0);
               IF_RF_PC : in STD_LOGIC_VECTOR(15 downto 0);
               EXE_RF_Res : in STD_LOGIC_VECTOR(15 downto 0);
               MEM_RF_LW : in STD_LOGIC_VECTOR(15 downto 0);
               PC_RF_PC : in STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    -- ID PC Adder
    component ID_PCAdder
        Port ( IF_RF_PC : in STD_LOGIC_VECTOR(15 downto 0);
               ID_Imm : in STD_LOGIC_VECTOR(15 downto 0);
               ID_Res : out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    -- ID/EXE Register
    component ID_RF
        Port ( clk : in STD_LOGIC;
               ID_RFOp : in STD_LOGIC_VECTOR(1 downto 0);  -- 10 for WE_N, 11 for NOP, 0- for WE
               
               RF_Imm_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_IH_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_PC_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_Res_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_Rd_In : in STD_LOGIC_VECTOR(3 downto 0);
               RF_Rx_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_Ry_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_SP_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_St_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_T_In : in STD_LOGIC_VECTOR(15 downto 0);
               
               RF_Imm_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_IH_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_PC_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_Res_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_Rd_Out : out STD_LOGIC_VECTOR(3 downto 0);
               RF_Rx_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_Ry_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_SP_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_St_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_T_Out : out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    -- IF PC Adder
    component IF_PCAdder
        Port ( PC_RF_PC : in STD_LOGIC_VECTOR(15 downto 0);
               IF_Res : out STD_LOGIC_VECTOR(15 downto 0));
    end component;
        
    -- IF/ID Register
    component IF_RF
        Port ( clk : in STD_LOGIC;
               IF_RFOp : in STD_LOGIC_VECTOR(1 downto 0);  -- 10 for WE_N, 11 for NOP, 0- for WE
               
               RF_PC_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_Ins_In : in STD_LOGIC_VECTOR(15 downto 0);
               
               RF_PC_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_Ins_Out : out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    -- MEM/WB Register
    component MEM_RF
        Port ( clk : in STD_LOGIC;
               MEM_RFOp : in STD_LOGIC_VECTOR(1 downto 0);
               
               RF_Flags_In : in STD_LOGIC_VECTOR(3 downto 0);
               RF_LW_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_Rd_In : in STD_LOGIC_VECTOR(3 downto 0);
               RF_Res_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_PC_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_St_In : in STD_LOGIC_VECTOR(15 downto 0);
               
               RF_Flags_Out : out STD_LOGIC_VECTOR(3 downto 0);
               RF_LW_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_Rd_Out : out STD_LOGIC_VECTOR(3 downto 0);
               RF_Res_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_PC_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_St_Out : out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    -- Mem & Uart
    component MemUart
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               
               -- IF
               PC_RF_PC : in STD_LOGIC_VECTOR(15 downto 0);
               IF_Ins : out STD_LOGIC_VECTOR(15 downto 0);
               
               -- MEM
               EXE_RF_Res : in STD_LOGIC_VECTOR(15 downto 0);
               EXE_RF_Rx : in STD_LOGIC_VECTOR(15 downto 0);
               EXE_RF_Ry : in STD_LOGIC_VECTOR(15 downto 0);
               MEM_LW : out STD_LOGIC_VECTOR(15 downto 0);
               
               -- IF & MEM
               RamRWOp : in STD_LOGIC_VECTOR(1 downto 0);  -- (1) for Ram1, (0) for Ram2; 0 for R, 1 for W
               
               Addr1 : out STD_LOGIC_VECTOR(15 downto 0);
               Addr2 : out STD_LOGIC_VECTOR(15 downto 0);
               Data1 : inout STD_LOGIC_VECTOR(15 downto 0);  -- low 8 digits for Uart
               Data2 : inout STD_LOGIC_VECTOR(15 downto 0);
               Ram1EN : out STD_LOGIC;
               Ram1OE : out STD_LOGIC;
               Ram1WE : out STD_LOGIC;
               Ram2EN : out STD_LOGIC;
               Ram2OE : out STD_LOGIC;
               Ram2WE : out STD_LOGIC;
               UartRdn : out STD_LOGIC;
               UartWrn : out STD_LOGIC;
               DataReady : in STD_LOGIC;
               Tbre : in STD_LOGIC;
               Tsre : in STD_LOGIC);
    end component;
    
    -- PC RF
    component PC_RF
        Port ( clk : in STD_LOGIC;
               PC_RFOp : in STD_LOGIC_VECTOR(1 downto 0);  -- 00 for PDTPC, 01 for IDPC, 10 for WE_down, 11 for NOP
               
               IDPC : in STD_LOGIC_VECTOR(15 downto 0);
               PDTPC : in STD_LOGIC_VECTOR(15 downto 0);
               RF_PC_Out : out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    -- Registers
	 -- 寄存器堆
    component Registers
        Port ( clk : in STD_LOGIC;
               IF_RF_RX : in STD_LOGIC_VECTOR(2 downto 0);
               IF_RF_RY : in STD_LOGIC_VECTOR(2 downto 0);
               RegWrbData : in STD_LOGIC_VECTOR(15 downto 0);
               RegWrbAddr : in STD_LOGIC_VECTOR(3 downto 0);
               
               ID_Rx : out STD_LOGIC_VECTOR(15 downto 0);
               ID_Ry : out STD_LOGIC_VECTOR(15 downto 0);
               ID_IH : out STD_LOGIC_VECTOR(15 downto 0);
               ID_SP : out STD_LOGIC_VECTOR(15 downto 0);
               ID_T : out STD_LOGIC_VECTOR(15 downto 0);
               R0, R1, R2, R3, R4, R5, R6, R7, IH, SP, T : out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    -- Register Write Back Module
    component RegWrbModule
        Port ( RegWrbOp : in STD_LOGIC_VECTOR(1 downto 0);
               RegWrbOut : out STD_LOGIC_VECTOR(15 downto 0);
               
               MEM_RF_FlagSign : in STD_LOGIC;
               MEM_RF_LW : in STD_LOGIC_VECTOR(15 downto 0);
               MEM_RF_Res : in STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    --  Controller
    component VGAController
        Port ( clk : in STD_LOGIC;  -- 25 MHz
               rst : in STD_LOGIC;
               InputSW : in STD_LOGIC_VECTOR(15 downto 0);
               Hs : out STD_LOGIC;
               Vs : out STD_LOGIC;
               R : out STD_LOGIC_VECTOR(2 downto 0);
               G : out STD_LOGIC_VECTOR(2 downto 0);
               B : out STD_LOGIC_VECTOR(2 downto 0);
               
               R0, R1, R2, R3, R4, R5, R6, R7, IH, SP, T : in STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    -- Clock Signals
	signal clk: STD_LOGIC;
    signal clk_2 : STD_LOGIC;
    signal clk_4 : STD_LOGIC;
    signal clk_8 : STD_LOGIC;
    signal clk_16 : STD_LOGIC;
    
    -- Wire Signals
    signal AluOp : STD_LOGIC_VECTOR(3 downto 0);
    signal AMuxOp : STD_LOGIC_VECTOR(3 downto 0);
    signal BMuxOp : STD_LOGIC_VECTOR(2 downto 0);
    signal DirOp : STD_LOGIC_VECTOR(2 downto 0);
    signal ExDigitsOp : STD_LOGIC_VECTOR(2 downto 0);
    signal ExSignOp : STD_LOGIC;
    signal IDPCOp : STD_LOGIC_VECTOR(1 downto 0);
	signal RamEn: STD_LOGIC_VECTOR (1 downto 0);
    signal RamRWOp: STD_LOGIC_VECTOR(1 downto 0);
    signal RegWrbOp : STD_LOGIC_VECTOR(1 downto 0);
    signal RXTOp : STD_LOGIC_VECTOR(1 downto 0);
    
    signal EXE_RFOp : STD_LOGIC_VECTOR(1 downto 0);
    signal ID_RFOp : STD_LOGIC_VECTOR(1 downto 0);
    signal IF_RFOp : STD_LOGIC_VECTOR(1 downto 0);
    signal MEM_RFOp : STD_LOGIC_VECTOR(1 downto 0);
    signal PC_RFOp : STD_LOGIC_VECTOR(1 downto 0);
    
    signal IF_Ins : STD_LOGIC_VECTOR(15 downto 0);
    signal IF_Res : STD_LOGIC_VECTOR(15 downto 0);
    
    signal ID_IH : STD_LOGIC_VECTOR(15 downto 0);
    signal ID_Imm : STD_LOGIC_VECTOR(15 downto 0);
    signal ID_Rd : STD_LOGIC_VECTOR(3 downto 0);
    signal ID_Res : STD_LOGIC_VECTOR(15 downto 0);
    signal ID_Rx : STD_LOGIC_VECTOR(15 downto 0);
    signal ID_Ry : STD_LOGIC_VECTOR(15 downto 0);
    signal ID_SP : STD_LOGIC_VECTOR(15 downto 0);
    signal ID_T : STD_LOGIC_VECTOR(15 downto 0);
    signal IDPC : STD_LOGIC_VECTOR(15 downto 0);
    signal PDTPC : STD_LOGIC_VECTOR(15 downto 0);
    
    signal ASrc : STD_LOGIC_VECTOR(15 downto 0);
    signal BSrc : STD_LOGIC_VECTOR(15 downto 0);
    signal AluRes : STD_LOGIC_VECTOR(15 downto 0);
    signal AluFlags : STD_LOGIC_VECTOR(3 downto 0);  -- ZCSO
    
    signal MEM_LW : STD_LOGIC_VECTOR(15 downto 0);
    
    signal RegWrbData : STD_LOGIC_VECTOR(15 downto 0);
    
    -- RF Registers
    signal PC_RF_PC : STD_LOGIC_VECTOR(15 downto 0);
    
    signal IF_RF_PC : STD_LOGIC_VECTOR(15 downto 0);
    signal IF_RF_Ins : STD_LOGIC_VECTOR(15 downto 0);
    
    signal ID_RF_Imm : STD_LOGIC_VECTOR(15 downto 0);
    signal ID_RF_IH : STD_LOGIC_VECTOR(15 downto 0);
    signal ID_RF_PC : STD_LOGIC_VECTOR(15 downto 0);
    signal ID_RF_Res : STD_LOGIC_VECTOR(15 downto 0);
    signal ID_RF_Rd : STD_LOGIC_VECTOR(3 downto 0);
    signal ID_RF_Rx : STD_LOGIC_VECTOR(15 downto 0);
    signal ID_RF_Ry : STD_LOGIC_VECTOR(15 downto 0);
    signal ID_RF_SP : STD_LOGIC_VECTOR(15 downto 0);
    signal ID_RF_St : STD_LOGIC_VECTOR(15 downto 0);
    signal ID_RF_T : STD_LOGIC_VECTOR(15 downto 0);
    
    signal EXE_RF_Flags : STD_LOGIC_VECTOR(3 downto 0);  -- ZCSO
    signal EXE_RF_PC : STD_LOGIC_VECTOR(15 downto 0);
    signal EXE_RF_Rd : STD_LOGIC_VECTOR(3 downto 0);
    signal EXE_RF_Res : STD_LOGIC_VECTOR(15 downto 0);
    signal EXE_RF_Rx : STD_LOGIC_VECTOR(15 downto 0);
    signal EXE_RF_Ry : STD_LOGIC_VECTOR(15 downto 0);
    signal EXE_RF_St : STD_LOGIC_VECTOR(15 downto 0);
    
    signal MEM_RF_Flags : STD_LOGIC_VECTOR(3 downto 0);  -- ZCSO
    signal MEM_RF_LW : STD_LOGIC_VECTOR(15 downto 0);
    signal MEM_RF_Rd : STD_LOGIC_VECTOR(3 downto 0);
    signal MEM_RF_Res : STD_LOGIC_VECTOR(15 downto 0);
    signal MEM_RF_PC : STD_LOGIC_VECTOR(15 downto 0);
    signal MEM_RF_St : STD_LOGIC_VECTOR(15 downto 0);  

    signal R0, R1, R2, R3, R4, R5, R6, R7, IH, SP, T : STD_LOGIC_VECTOR(15 downto 0); -- vga
begin
    Process_ALU: ALU
    port map (
        AluOp => AluOp,
        ASrc => ASrc,
        BSrc => BSrc,
        
        Fout => AluRes,
        Flags => AluFlags
    );
    
    Process_AMux: AMux
    port map (
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
    
    Process_BMux: BMux
    port map (
        BMuxOp => BMuxOp,
        BSrc => BSrc,
        
        EXE_RF_Res => EXE_RF_Res,
        ID_RF_Imm => ID_RF_Imm,
        ID_RF_Ry => ID_RF_Ry,
        MEM_RF_LW => MEM_RF_LW,
        MEM_RF_Res => MEM_RF_Res
    );
    
    Process_BTB: BTB
    port map (
        clk => clk_4,
        PDTPC => PDTPC,
        
        IDPC => IDPC,
        IF_Res => IF_Res,
        IF_RF_OP => IF_RF_Ins(15 downto 11),
        IF_RF_PC => IF_RF_PC,
        PC_RF_PC => PC_RF_PC
    );
    
    Process_ClockModule: ClockModule
    port map (
        clk_in => clk_in,
        clk => clk,
        clk_2 => clk_2,
        clk_4 => clk_4,
        clk_8 => clk_8,
        clk_16 => clk_16
    );
    
    Process_ControlUnit: ControlUnit
    port map (
        AluOp => AluOp,
        AMuxOp => AMuxOp,
        BMuxOp => BMuxOp,
        DirOp => DirOp,
        ExDigitsOp => ExDigitsOp,
        ExSignOp => ExSignOp,
        IDPCOp => IDPCOp,
        RamEn => RamEn,
        RamRWOp => RamRWOp,
        RegWrbOp => RegWrbOp,
        RXTOp => RXTOp,
        
        EXE_RFOp => EXE_RFOp,
        ID_RFOp => ID_RFOp,
        IF_RFOp => IF_RFOp,
        MEM_RFOp => MEM_RFOp,
        PC_RFOp => PC_RFOp,
        
        IF_RF_OP => IF_RF_Ins(15 downto 11),
        ID_RF_OP => ID_RF_St(15 downto 11),
        ID_RF_Rd => ID_RF_Rd,
        EXE_RF_OP => EXE_RF_St(15 downto 11),
        EXE_RF_Rd => EXE_RF_Rd
        
        
    );
    
    Process_DirectionModule: DirectionModule
    port map (
        ID_Rd => ID_Rd,
        DirOp => DirOp,
        
        IF_RF_RX => IF_RF_Ins(10 downto 8),
        IF_RF_RY => IF_RF_Ins(7 downto 5),
        IF_RF_RZ => IF_RF_Ins(4 downto 2)
    );
    
    Process_EXE_RF: EXE_RF
    port map (
        clk => clk,
        EXE_RFOp => EXE_RFOp,
        
        RF_Flags_In => AluFlags,
        RF_PC_In => ID_RF_PC,
        RF_Rd_In => ID_RF_Rd,
        RF_Res_In => AluRes,
        RF_Rx_In => ID_RF_Rx,
        RF_Ry_In => ID_RF_Ry,
        RF_St_In => ID_RF_St,
        
        RF_Flags_Out => EXE_RF_Flags,
        RF_PC_Out => EXE_RF_PC,
        RF_Rd_Out => EXE_RF_Rd,
        RF_Res_Out => EXE_RF_Res,
        RF_Rx_Out => EXE_RF_Rx,
        RF_Ry_Out => EXE_RF_Ry,
        RF_St_Out => EXE_RF_St
    );
    
    Process_ExtendModule: ExtendModule
    port map (
        ExSrc => IF_RF_Ins(10 downto 0),
        ExImm => ID_Imm,
        
        ExDigitsOp => ExDigitsOp,
        ExSignOp => ExSignOp
    );
    
    Process_IDPCRXT: IDPCRXT
    port map (
        IDPC => IDPC,
        IDPCOp => IDPCOp,
        RXTOp => RXTOp,
        
        ID_Res => ID_Res,
        ID_Rx => ID_Rx,
        ID_T => ID_T,
        IF_RF_PC => IF_RF_PC,
        EXE_RF_Res => EXE_RF_Res,
        MEM_RF_LW => MEM_RF_LW,
        PC_RF_PC => PC_RF_PC
    );
    
    Process_ID_PCAdder: ID_PCAdder
    port map (
        IF_RF_PC => IF_RF_PC,
        ID_Imm => ID_Imm,
        ID_Res => ID_Res
    );
    
    Process_ID_RF: ID_RF
    port map (
        clk => clk,
        ID_RFOp => ID_RFOp,
        
        RF_Imm_In => ID_Imm,
        RF_IH_In => ID_IH,
        RF_PC_In => IF_RF_PC,
        RF_Res_In => ID_Res,
        RF_Rd_In => ID_Rd,
        RF_Rx_In => ID_Rx,
        RF_Ry_In => ID_Ry,
        RF_SP_In => ID_SP,
        RF_St_In => IF_RF_Ins(15 downto 0),
        RF_T_In => ID_T,
        
        RF_Imm_Out => ID_RF_Imm,
        RF_IH_Out => ID_RF_IH,
        RF_PC_Out => ID_RF_PC,
        RF_Res_Out => ID_RF_Res,
        RF_Rd_Out => ID_RF_Rd,
        RF_Rx_Out => ID_RF_Rx,
        RF_Ry_Out => ID_RF_Ry,
        RF_SP_Out => ID_RF_SP,
        RF_St_Out => ID_RF_St,
        RF_T_Out => ID_RF_T
    );
    
    Process_IF_PCAdder: IF_PCAdder
    port map (
        PC_RF_PC => PC_RF_PC,
        IF_Res => IF_Res
    );
    
    Process_IF_RF: IF_RF
    port map (
        clk => clk_4,
        IF_RFOp => IF_RFOp,
        
        RF_PC_In => IF_Res,
        RF_Ins_In => IF_Ins,
        
        RF_PC_Out => IF_RF_PC,
        RF_Ins_Out => IF_RF_Ins
    );
    
    Process_MEM_RF: MEM_RF
    port map (
        clk => clk,
        MEM_RFOp => MEM_RFOp,
        
        RF_Flags_In => EXE_RF_Flags,
        RF_LW_In => MEM_LW,
        RF_Rd_In => EXE_RF_Rd,
        RF_Res_In => EXE_RF_Res,
        RF_PC_In => EXE_RF_PC,
        RF_St_In => EXE_RF_St,
        
        RF_Flags_Out => MEM_RF_Flags,
        RF_LW_Out => MEM_RF_LW,
        RF_Rd_Out => MEM_RF_Rd,
        RF_Res_Out => MEM_RF_Res,
        RF_PC_Out => MEM_RF_PC,
        RF_St_Out => MEM_RF_St
    );
    
    Process_MemUart: MemUart
    port map (
        clk => clk,
        rst => rst,
        
        PC_RF_PC => PC_RF_PC,
        IF_Ins => IF_Ins,
        
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
    
    Process_PC_RF: PC_RF
    port map (
        clk => clk_4,
        PC_RFOp => PC_RFOp,
        
        IDPC => IDPC,
        PDTPC => PDTPC,
        RF_PC_Out => PC_RF_PC
    );
    
    Process_Registers: Registers
    port map (
        clk => clk_4,
        IF_RF_RX => IF_RF_ins(10 downto 8),
        IF_RF_RY => IF_RF_ins (7 downto 5),
        RegWrbAddr => MEM_RF_Rd,
        RegWrbData => RegWrbData,
        
        ID_Rx => ID_Rx,
        ID_Ry => ID_Ry,
        ID_IH => ID_IH,
        ID_SP => ID_SP,
        ID_T => ID_T,
        
        R0 => R0,
        R1 => R1,
        R2 => R2,
        R3 => R3,
        R4 => R4,
        R5 => R5,
        R6 => R6,
        R7 => R7,
        IH => IH,
        SP => SP,
        T => T
    );
    
    Process_RegWrbModule: RegWrbModule
    port map (
        RegWrbOp => RegWrbOp,
        RegWrbOut => RegWrbData,
        
        MEM_RF_FlagSign => MEM_RF_Flags(1),
        MEM_RF_LW => MEM_RF_LW,
        MEM_RF_Res => MEM_RF_Res
    );
    
    Process_VGAController: VGAController
    port map (
        clk => clk_2,
        rst => rst,
        InputSW => InputSW,
        Hs => Hs,
        Vs => Vs,
        R => R,
        G => G,
        B => B,
        
        R0 => R0,
        R1 => R1,
        R2 => R2,
        R3 => R3,
        R4 => R4,
        R5 => R5,
        R6 => R6,
        R7 => R7,
        IH => IH,
        SP => SP,
        T => T
--         R0, R1, R2, R3, R4, R5, R6, R7, IH, SP, T : in STD_LOGIC_VECTOR(15 downto 0)
    );
end Behavioral;
