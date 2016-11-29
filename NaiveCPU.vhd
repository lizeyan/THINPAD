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
			  clk_50 : in STD_LOGIC;
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
           -- LED LIGHTS
			  ledlights : out STD_LOGIC_VECTOR (15 downto 0);
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
					
               EXE_RF_Res : in STD_LOGIC_VECTOR(15 downto 0);
               ID_RF_PC : in STD_LOGIC_VECTOR(15 downto 0);
               ID_RF_Rx : in STD_LOGIC_VECTOR(15 downto 0);
               ID_RF_Ry : in STD_LOGIC_VECTOR(15 downto 0);
               ID_RF_IH : in STD_LOGIC_VECTOR(15 downto 0);
               ID_RF_SP : in STD_LOGIC_VECTOR(15 downto 0);
               ID_RF_T : in STD_LOGIC_VECTOR(15 downto 0);
               MEM_RF_LW : in STD_LOGIC_VECTOR(15 downto 0); --mem�μĴ�����memȡ��������
               MEM_RF_Res : in STD_LOGIC_VECTOR(15 downto 0)); --mem�μĴ�����alu�����Ľ���
    end component;
    
    -- ALU Src B Mux
    component BMux
        Port ( BMuxOp : in STD_LOGIC_VECTOR(2 downto 0);--
               BSrc : out STD_LOGIC_VECTOR(15 downto 0);
               EXE_RF_Res : in STD_LOGIC_VECTOR(15 downto 0);
               ID_RF_Imm : in STD_LOGIC_VECTOR(15 downto 0);
               ID_RF_Ry : in STD_LOGIC_VECTOR(15 downto 0);
               MEM_RF_LW : in STD_LOGIC_VECTOR(15 downto 0);
               MEM_RF_Res : in STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    -- Branch Target Buffer
    component BTB
        Port ( clk : in std_logic;
               PDTPC : out std_logic_vector(15 downto 0);
               
               BTBOp : in std_logic; --�Ƿ�����תָ��
               BTBTOp : in std_logic; -- �Ƿ���ת
               IF_RF_OPC : in std_logic_vector(15 downto 0);
               
               IDPC : in std_logic_vector(15 downto 0);
               IF_RF_PC : in std_logic_vector(15 downto 0);
               PC_RF_PC : in std_logic_vector(15 downto 0));
    end component;
    

    -- Clock Module
    component ClockModule
        Port ( clk_in : in STD_LOGIC;
               --��Ƶ
					clk: out STD_LOGIC;
               clk_2 : out STD_LOGIC;
               clk_4 : out STD_LOGIC;
               clk_8 : out STD_LOGIC;
               clk_16 : out STD_LOGIC;
               clk_1k : out std_logic);
    end component;
    
    -- Control Unit
    component ControlUnit
        Port ( -- IF
               ExDigitsOp : out std_logic_vector(2 downto 0); --��չλ������
               ExSignOp : out std_logic; 
               
               -- ID
               AluOp : out std_logic_vector(3 downto 0); --alu������
               AMuxOp : out std_logic_vector(3 downto 0);
               BMuxOp : out std_logic_vector(2 downto 0);
               DirOp : out std_logic_vector(2 downto 0); --rd��ѡ���ź�
               IDPCOp : out std_logic_vector(1 downto 0);  
               
               -- add
               BTBOp : out std_logic;  -- is jumping ins(1) or not(0)
               RamRWOp : out std_logic; -- 0 read, 1 write --���浽ID_RF
               RegWrbOp : out std_logic_vector(1 downto 0); -- �Ĵ���д�����ݵ�ѡ�� -- ���浽ID_RF
               RXTOp : out std_logic_vector(2 downto 0);
               SWSrc : out std_logic; -- 0 rx, 1 ry --���浽ID_RF
                SWMUXOP : out std_logic_vector (2 downto 0);
               memen : out std_logic;
               
               -- ENABLE  complex
               EXE_RFOp : out std_logic_vector(1 downto 0);
               ID_RFOp : out std_logic_vector(1 downto 0);
               IF_RFOp : out std_logic_vector(1 downto 0);
               MEM_RFOp : out std_logic_vector(1 downto 0);
               PC_RFOp : out std_logic_vector(2 downto 0);
					PC_RFWE: out std_logic;
               
               -- ��IF�θոմ��ڴ���ȡ�������ʵ�ָ��
               PC_RF_PC : in std_logic_vector (15 downto 0);
               IF_Ins : in std_logic_vector(15 downto 0);
               IF_RF_OP : in std_logic_vector(4 downto 0);
               IF_RF_St : in std_logic_vector (15 downto 0);  -- IF�μĴ����б����ģ�ָ�������ݡ���Ϊ�е�ָ����Ҫ�ж�funct�ֶ�
					IF_RF_OPC : in STD_LOGIC_VECTOR (15 downto 0);
               IDPC : in std_logic_vector (15 downto 0);  -- IDPCRXT������IDPC
               ID_RF_OP : in std_logic_vector(4 downto 0); 
               ID_RF_Rd : in std_logic_vector(3 downto 0);
               EXE_RF_OP : in std_logic_vector(4 downto 0);
               EXE_RF_Rd : in std_logic_vector(3 downto 0);
               EXE_Res : in std_logic_vector (15 downto 0);  -- ALU�ļ�ʱ����
               MEM_RF_OP : in std_logic_vector(4 downto 0);
               MEM_RF_Rd : in std_logic_vector(3 downto 0));
    end component;
    
    -- Digit 7 Light
    component Digit7Light
        Port ( Data : in STD_LOGIC_VECTOR(3 downto 0);
               Output : out STD_LOGIC_VECTOR(6 downto 0));
    end component;
    
    -- Direction Module
	 -- ѡ��RD
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
					-- 10 => д��in�ź�
					-- 11 => д��NOPָ����Ӧ���ź�
					-- others => ��д��
               EXE_RFOp : in STD_LOGIC_VECTOR(1 downto 0);  -- 10 for WE_N, 11 for NOP, 0- for WE
               
               RF_Flags_In : in STD_LOGIC_VECTOR(3 downto 0);
               RF_PC_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_Rd_In : in STD_LOGIC_VECTOR(3 downto 0);
               RF_Res_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_Rx_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_Ry_In : in STD_LOGIC_VECTOR(15 downto 0);
               RF_St_In : in STD_LOGIC_VECTOR(15 downto 0);
					RF_swsrcop_in : in std_logic;
					RF_SWMUXOP_in : in std_logic_vector (2 downto 0);
               
               RF_RamRWOp_In : in std_logic;
               RF_RegWrbOp_In : in std_logic_vector(1 downto 0);
               rf_memen_in: in std_logic;
               
               RF_Flags_Out : out STD_LOGIC_VECTOR(3 downto 0);
               RF_PC_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_Rd_Out : out STD_LOGIC_VECTOR(3 downto 0);
               RF_Res_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_Rx_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_Ry_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_St_Out : out STD_LOGIC_VECTOR(15 downto 0);
               
               RF_RamRWOp_Out : out std_logic;
               RF_RegWrbOp_Out : out std_logic_vector(1 downto 0);
					RF_swsrcop_out : out std_logic;
                    rf_memen_out : out std_logic;
					RF_SWMUXOP_out : out std_logic_vector (2 downto 0));
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
        Port ( BTBTOp : out std_logic;
               IDPC : out std_logic_vector(15 downto 0);
               IDPCOp : in std_logic_vector(1 downto 0); --�Ƿ��Ƿ�ָ֧�
               RXTOp : in std_logic_vector(2 downto 0);
               
               ID_Res : in std_logic_vector(15 downto 0);
               ID_Rx : in std_logic_vector(15 downto 0);
               ID_T : in std_logic_vector(15 downto 0);
               IF_RF_PC : in std_logic_vector(15 downto 0);
               EXE_RF_Res : in std_logic_vector(15 downto 0);
               MEM_RF_LW : in std_logic_vector(15 downto 0);
               MEM_RF_Res : in std_logic_vector(15 downto 0));
    end component;
    
    -- ID PC Adder
    component ID_PCAdder
        Port ( IF_RF_PC : in STD_LOGIC_VECTOR(15 downto 0);
               ID_Imm : in STD_LOGIC_VECTOR(15 downto 0); -- use IF_RF_IMM actually
               ID_Res : out STD_LOGIC_VECTOR(15 downto 0));
    end component;
    
    -- ID/EXE Register
    component ID_RF
        Port ( clk : in std_logic;
               ID_RFOp : in std_logic_vector(1 downto 0);  -- 10 for WE_N, 11 for NOP, 0- for WE
               
               RF_Imm_In : in std_logic_vector(15 downto 0);
               RF_IH_In : in std_logic_vector(15 downto 0);
               RF_PC_In : in std_logic_vector(15 downto 0);
               RF_Res_In : in std_logic_vector(15 downto 0);
               RF_Rd_In : in std_logic_vector(3 downto 0);
               RF_Rx_In : in std_logic_vector(15 downto 0);
               RF_Ry_In : in std_logic_vector(15 downto 0);
               RF_SP_In : in std_logic_vector(15 downto 0);
               RF_St_In : in std_logic_vector(15 downto 0);
               RF_T_In : in std_logic_vector(15 downto 0);
               
               -- control signal
               RF_AluOp_In : in std_logic_vector(3 downto 0);
               RF_AmuxOp_In : in std_logic_vector(3 downto 0);
               RF_BmuxOp_In : in std_logic_vector(2 downto 0);
               RF_RamRWOp_In : in std_logic;
               RF_RegWrbOp_In : in std_logic_vector(1 downto 0);
					RF_swsrcop_in : in std_logic;
					RF_SWMUXOP_in : in std_logic_vector (2 downto 0);
                    rf_memen_in : in std_logic;
               
               RF_Imm_Out : out std_logic_vector(15 downto 0);
               RF_IH_Out : out std_logic_vector(15 downto 0);
               RF_PC_Out : out std_logic_vector(15 downto 0);
               RF_Res_Out : out std_logic_vector(15 downto 0);
               RF_Rd_Out : out std_logic_vector(3 downto 0);
               RF_Rx_Out : out std_logic_vector(15 downto 0);
               RF_Ry_Out : out std_logic_vector(15 downto 0);
               RF_SP_Out : out std_logic_vector(15 downto 0);
               RF_St_Out : out std_logic_vector(15 downto 0);
               RF_T_Out : out std_logic_vector(15 downto 0);
               
               RF_AluOp_Out : out std_logic_vector(3 downto 0);
               RF_AmuxOp_Out : out std_logic_vector(3 downto 0);
               RF_BmuxOp_Out : out std_logic_vector(2 downto 0);
               RF_RamRWOp_Out : out std_logic;
               RF_RegWrbOp_Out : out std_logic_vector(1 downto 0);
                RF_swsrcop_out : out std_logic;
                rf_memen_out : out std_logic;
                RF_SWMUXOP_out : out std_logic_vector (2 downto 0));
    end component;
    
    -- IF PC Adder
    component IF_PCAdder
        Port ( PC_RF_PC : in STD_LOGIC_VECTOR(15 downto 0);
               IF_Res : out STD_LOGIC_VECTOR(15 downto 0));
    end component;
        
    -- IF/ID Register
    component IF_RF
        Port ( clk : in std_logic;
               IF_RFOp : in std_logic_vector(1 downto 0);  -- 10 for WE_N, 11 for NOP, 0- for WE
               
               RF_Imm_In : in std_logic_vector(15 downto 0);
               RF_Ins_In : in std_logic_vector(15 downto 0);
               RF_PC_In : in std_logic_vector(15 downto 0);
               RF_OPC_In : in std_logic_vector(15 downto 0);
               
               RF_Imm_Out : out std_logic_vector(15 downto 0);
               RF_Ins_Out : out std_logic_vector(15 downto 0);
               RF_PC_Out : out std_logic_vector(15 downto 0);
               RF_OPC_Out : out std_logic_vector(15 downto 0));
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
               
               RF_RegWrbOp_In : in std_logic_vector(1 downto 0);
               
               RF_Flags_Out : out STD_LOGIC_VECTOR(3 downto 0);
               RF_LW_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_Rd_Out : out STD_LOGIC_VECTOR(3 downto 0);
               RF_Res_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_PC_Out : out STD_LOGIC_VECTOR(15 downto 0);
               RF_St_Out : out STD_LOGIC_VECTOR(15 downto 0);
               
               RF_RegWrbOp_Out : out std_logic_vector(1 downto 0));
    end component;
	 
    component MEM_SW_MUX 
    Port ( mem_sw_muxop : in  STD_LOGIC_VECTOR (2 downto 0);
           mem_sw_srcop : in  STD_LOGIC;
           lw_in : in  STD_LOGIC_VECTOR (15 downto 0);
           res_in : in  STD_LOGIC_VECTOR (15 downto 0);
			  mem_rf_lw : in  STD_LOGIC_VECTOR (15 downto 0);
			  mem_rf_res : in  STD_LOGIC_VECTOR (15 downto 0);
			  exe_rf_rx : in  STD_LOGIC_VECTOR (15 downto 0); 
			  exe_rf_ry : in  STD_LOGIC_VECTOR (15 downto 0);
           clk : in  STD_LOGIC;
           mem_sw_data : out  STD_LOGIC_VECTOR (15 downto 0));
	end component;
	
    -- Mem & Uart
    component MemUart
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               
               -- IF
               PC_RF_PC : in STD_LOGIC_VECTOR(15 downto 0);
               IF_Ins : out STD_LOGIC_VECTOR(15 downto 0);
               
               -- MEM
					MEM_SW_DATA : in STD_LOGIC_VECTOR (15 downto 0);
               EXE_RF_Res : in STD_LOGIC_VECTOR(15 downto 0);
               alures : in std_logic_vector (15 downto 0);
               MEM_LW : out STD_LOGIC_VECTOR(15 downto 0);
               --DEBUG
					state_out: out std_logic_vector (3 downto 0);
               -- IF & MEM
               mem_en : in std_logic;
               mem_en_lh : in std_logic;
               RamRWOp : in std_logic;  -- (1) for Ram1, (0) for Ram2; 0 for R, 1 for W
               ramrwop_lh : in std_logic;
               
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
        Port ( clk : in std_logic;
               rst : in std_logic;
               PC_RFOp : in std_logic_vector(2 downto 0);  -- 00 for PDTPC, 01 for IDPC, 10 for WE_down, 11 for EX
               PC_RFWE : in std_logic;
               IDPC : in std_logic_vector(15 downto 0);
               EXE_RES_PC : in std_logic_vector(15 downto 0);
               PDTPC : in std_logic_vector(15 downto 0);
               
               RF_PC_Out : out std_logic_vector(15 downto 0));
    end component;
    
    -- Registers
    -- �Ĵ�����
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
               
               R0 : in std_logic_vector(15 downto 0);
               R1 : in std_logic_vector(15 downto 0);
               R2 : in std_logic_vector(15 downto 0);
               R3 : in std_logic_vector(15 downto 0);
               R4 : in std_logic_vector(15 downto 0);
               R5 : in std_logic_vector(15 downto 0);
               R6 : in std_logic_vector(15 downto 0);
               R7 : in std_logic_vector(15 downto 0);
               IH : in std_logic_vector(15 downto 0);
               SP : in std_logic_vector(15 downto 0);
               T : in std_logic_vector(15 downto 0);
					
					PC_RF_PC : in std_logic_vector(15 downto 0);
					IF_RF_INS : in std_logic_vector(15 downto 0)
					);
    end component;
    
    -- Clock Signals
	 -- ��clockmodule���ɣ����ӵ�����component
	 signal clk: STD_LOGIC;
     signal clkfx: std_logic;
    signal clk_2 : STD_LOGIC;
    signal clk_4 : STD_LOGIC;
    signal clk_8 : STD_LOGIC;
    signal clk_16 : STD_LOGIC;
    signal clk_25 : STD_LOGIC;
	 --DEBUG
	 signal state_out : std_logic_vector (3 downto 0);
	 
    -- Wire Signals
    -- IF
    signal ExDigitsOp : std_logic_vector(2 downto 0);
    signal ExSignOp : std_logic;
    -- ID
    signal AluOp : std_logic_vector(3 downto 0);
    signal AMuxOp : std_logic_vector(3 downto 0);
    signal BMuxOp : std_logic_vector(2 downto 0);
    signal DirOp : std_logic_vector(2 downto 0);
    signal IDPCOp : std_logic_vector(1 downto 0);
    -- add
    signal BTBOp : std_logic;
    signal BTBTOp : std_logic;
    signal RamRWOp : std_logic;
    signal RegWrbOp : std_logic_vector(1 downto 0);
    signal RXTOp : std_logic_vector(2 downto 0);
    signal SWSrc : std_logic;
	 signal SWMUXOP : std_logic_vector (2 downto 0);
    signal memen : std_logic;
    -- ENABLE complex
    signal EXE_RFOp : std_logic_vector(1 downto 0);
    signal ID_RFOp : std_logic_vector(1 downto 0);
    signal IF_RFOp : std_logic_vector(1 downto 0);
    signal MEM_RFOp : std_logic_vector(1 downto 0);
    signal PC_RFOp : std_logic_vector(2 downto 0);
	 signal PC_RFWE : std_logic;
    
    -- IF/ID/EXE/MEM/WB signals
    -- IF
    signal IF_Ins : STD_LOGIC_VECTOR(15 downto 0);
    signal IF_Res : STD_LOGIC_VECTOR(15 downto 0);
    signal IF_Imm : STD_LOGIC_VECTOR(15 downto 0);
    -- ID
    signal ID_IH : STD_LOGIC_VECTOR(15 downto 0);
--    signal ID_Imm : STD_LOGIC_VECTOR(15 downto 0);
    signal ID_Rd : STD_LOGIC_VECTOR(3 downto 0);
    signal ID_Res : STD_LOGIC_VECTOR(15 downto 0);
    signal ID_Rx : STD_LOGIC_VECTOR(15 downto 0);
    signal ID_Ry : STD_LOGIC_VECTOR(15 downto 0);
    signal ID_SP : STD_LOGIC_VECTOR(15 downto 0);
    signal ID_T : STD_LOGIC_VECTOR(15 downto 0);
    signal IDPC : STD_LOGIC_VECTOR(15 downto 0);
    signal PDTPC : STD_LOGIC_VECTOR(15 downto 0);
    -- EXE
    signal ASrc : STD_LOGIC_VECTOR(15 downto 0); --直接给ALU
    signal BSrc : STD_LOGIC_VECTOR(15 downto 0); --直接给ALU
    signal AluRes : STD_LOGIC_VECTOR(15 downto 0); --直接取ALU的输��
    signal AluFlags : STD_LOGIC_VECTOR(3 downto 0);  -- ZCSO --直接取ALU的输��
    -- MEM
	 signal MEM_SW_DATA : STD_LOGIC_VECTOR (15 downto 0);
    signal MEM_LW : STD_LOGIC_VECTOR(15 downto 0);
    -- WB
    signal RegWrbData : STD_LOGIC_VECTOR(15 downto 0);
    
    -- RF Registers
    -- PC
    signal PC_RF_PC : STD_LOGIC_VECTOR(15 downto 0);
    -- IF
    signal IF_RF_Imm : std_logic_vector(15 downto 0);
    signal IF_RF_Ins : std_logic_vector(15 downto 0);
    signal IF_RF_PC : std_logic_vector(15 downto 0);
    signal IF_RF_OPC : std_logic_vector(15 downto 0);
    -- ID
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
	 signal ID_RF_SWSRCOP: STD_LOGIC;
	 signal ID_RF_SWMUXOP : STD_LOGIC_VECTOR (2 downto 0);
     signal id_rf_memen : std_logic;
    -- EXE
    signal EXE_RF_Flags : STD_LOGIC_VECTOR(3 downto 0);  -- ZCSO
    signal EXE_RF_PC : STD_LOGIC_VECTOR(15 downto 0);
    signal EXE_RF_Rd : STD_LOGIC_VECTOR(3 downto 0);
    signal EXE_RF_Res : STD_LOGIC_VECTOR(15 downto 0);
    signal EXE_RF_Rx : STD_LOGIC_VECTOR(15 downto 0);
    signal EXE_RF_Ry : STD_LOGIC_VECTOR(15 downto 0);
    signal EXE_RF_St : STD_LOGIC_VECTOR(15 downto 0);
	 signal EXE_RF_SWSRCOP: STD_LOGIC;
	 signal EXE_RF_SWMUXOP : STD_LOGIC_VECTOR (2 downto 0);
     signal exe_rf_memen : std_logic;
    -- MEM
    signal MEM_RF_Flags : STD_LOGIC_VECTOR(3 downto 0);  -- ZCSO
    signal MEM_RF_LW : STD_LOGIC_VECTOR(15 downto 0);
    signal MEM_RF_Rd : STD_LOGIC_VECTOR(3 downto 0);
    signal MEM_RF_Res : STD_LOGIC_VECTOR(15 downto 0);
    signal MEM_RF_PC : STD_LOGIC_VECTOR(15 downto 0);
    signal MEM_RF_St : STD_LOGIC_VECTOR(15 downto 0);  
    -- UART
    signal UartWrnTMP, UartRdnTMP : STD_LOGIC;
    -- control signal in RF
    -- ID
    signal ID_RF_ALUOp : std_logic_vector(3 downto 0);
    signal ID_RF_AMUXOp : std_logic_vector(3 downto 0);
    signal ID_RF_BMUXOp : std_logic_vector(2 downto 0);
    signal ID_RF_RamRWOp : std_logic;
    signal ID_RF_RegWrbOp : std_logic_vector(1 downto 0);
    -- EXE
    signal EXE_RF_RamRWOp : std_logic;
    signal EXE_RF_RegWrbOp : std_logic_vector(1 downto 0);
    -- MEM
    signal MEM_RF_RegWrbOp : std_logic_vector(1 downto 0);
    
    -- VGA signals
    signal R0 : std_logic_vector(15 downto 0);
    signal R1 : std_logic_vector(15 downto 0);
    signal R2 : std_logic_vector(15 downto 0);
    signal R3 : std_logic_vector(15 downto 0);
    signal R4 : std_logic_vector(15 downto 0);
    signal R5 : std_logic_vector(15 downto 0);
    signal R6 : std_logic_vector(15 downto 0);
    signal R7 : std_logic_vector(15 downto 0);
    signal IH : std_logic_vector(15 downto 0);
    signal SP : std_logic_vector(15 downto 0);
    signal T : std_logic_vector(15 downto 0);
    signal clk_source : STD_LOGIC;
begin
    ledlights(2) <= dataready;
    ledlights(1) <= tbre;
    ledlights(0) <= tsre;
    ledlights(13 downto 3) <= "00000000000";
    ledlights(15 downto 14) <= uartwrntmp & uartrdntmp;

    UartWrn <= UartWrnTMP;
    UartRdn <= UartRdnTMP;
	process (clk_50)
	begin
		if rising_edge (clk_50) then
			clk_25 <= not clk_25;
		end if;
	end process;
    Process_ALU: ALU
    port map (
        AluOp => ID_RF_AluOp,
        ASrc => ASrc,
        BSrc => BSrc,
        
        Fout => AluRes,
        Flags => AluFlags
    );
    
    Process_AMux: AMux
    port map (
        AMuxOp => ID_RF_AMuxOp,
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
        BMuxOp => ID_RF_BMuxOp,
        BSrc => BSrc,
        
        EXE_RF_Res => EXE_RF_Res,
        ID_RF_Imm => ID_RF_Imm,
        ID_RF_Ry => ID_RF_Ry,
        MEM_RF_LW => MEM_RF_LW,
        MEM_RF_Res => MEM_RF_Res
    );
    
    Process_BTB: BTB
    port map (
        clk => clk_2,
        PDTPC => PDTPC,
        
        BTBOp => BTBOp,
        BTBTOp => BTBTOp,
        IF_RF_OPC => IF_RF_OPC,
        
        IDPC => IDPC,
        IF_RF_PC => IF_RF_PC,
        PC_RF_PC => PC_RF_PC
    );

    Process_ClockModule: ClockModule
    port map (
        clk_in => clk_50,
        clk => clk,
        clk_2 => clk_2,
        clk_4 => clk_4,
        clk_8 => clk_8,
        clk_16 => clk_16
    );
    
    Process_ControlUnit: ControlUnit
    port map (
        ExDigitsOp => ExDigitsOp,
        ExSignOp => ExSignOp,
        
        AluOp => AluOp,
        AMuxOp => AMuxOp,
        BMuxOp => BMuxOp,
        DirOp => DirOp,
        IDPCOp => IDPCOp,
        
        BTBOp => BTBOp,
        RamRWOp => RamRWOp,
        RegWrbOp => RegWrbOp,
        RXTOp => RXTOp,
        SWSrc => SWSrc,
		  SWMUXOP => swmuxop, 
          memen => memen,

        EXE_RFOp => EXE_RFOp,
        ID_RFOp => ID_RFOp,
        IF_RFOp => IF_RFOp,
        MEM_RFOp => MEM_RFOp,
        PC_RFOp => PC_RFOp,
		  PC_RFWE => PC_RFWE, 
        
        PC_RF_PC => PC_RF_PC,
        IF_Ins => IF_Ins,
        IF_RF_OP => IF_RF_Ins(15 downto 11),  -- this is not necessary with if_rf_st
        IF_RF_St => IF_RF_Ins,
		  IF_RF_OPC => IF_RF_OPC,  
        IDPC => IDPC,
        ID_RF_OP => ID_RF_St(15 downto 11),
        ID_RF_Rd => ID_RF_Rd,
        EXE_RF_OP => EXE_RF_St(15 downto 11),
        EXE_RF_Rd => EXE_RF_Rd,
        EXE_Res => AluRes,
        MEM_RF_OP => MEM_RF_St(15 downto 11),
        MEM_RF_Rd => MEM_RF_Rd
    );
    
    process_Digit7LightLeft: Digit7Light
    port map(
        Data => PC_RF_PC(3 downto 0),
        output => Digit7Left
    );
    
    process_Digit7LightRight: Digit7Light
    port map(
        Data => state_out,
        output => Digit7Right
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
        clk => clk_2,
        EXE_RFOp => EXE_RFOp,
        
        RF_Flags_In => AluFlags,
        RF_PC_In => ID_RF_PC,
        RF_Rd_In => ID_RF_Rd,
        RF_Res_In => AluRes,
        RF_Rx_In => ID_RF_Rx,
        RF_Ry_In => ID_RF_Ry,
        RF_St_In => ID_RF_St,
        rf_swsrcop_in => id_rf_swsrcop,
		  RF_SWMUXOP_in => ID_RF_SWMUXOP,
        RF_RamRWOp_In => ID_RF_RamRWOp,
        RF_RegWrbOp_In => ID_RF_RegWrbOp,
        rf_memen_in => id_rf_memen,
        
        RF_Flags_Out => EXE_RF_Flags,
        RF_PC_Out => EXE_RF_PC,
        RF_Rd_Out => EXE_RF_Rd,
        RF_Res_Out => EXE_RF_Res,
        RF_Rx_Out => EXE_RF_Rx,
        RF_Ry_Out => EXE_RF_Ry,
        RF_St_Out => EXE_RF_St,
        
        RF_RamRWOp_OUT => EXE_RF_RamRWOp,
        RF_RegWrbOp_OUT => EXE_RF_RegWrbOp,
		  rf_swsrcop_out => exe_rf_swsrcop,
		  RF_SWMUXOP_out => EXE_RF_SWMUXOP,
          rf_memen_out => exe_rf_memen
    );
    
    Process_ExtendModule: ExtendModule
    port map (
        ExSrc => IF_Ins(10 downto 0),
        ExImm => IF_Imm,
        
        ExDigitsOp => ExDigitsOp,
        ExSignOp => ExSignOp
    );
    
    Process_IDPCRXT: IDPCRXT
    port map (
        BTBTOp => BTBTOp,
        IDPC => IDPC,
        IDPCOp => IDPCOp,
        RXTOp => RXTOp,
        
        ID_Res => ID_Res,
        ID_Rx => ID_Rx,
        ID_T => ID_T,
        IF_RF_PC => IF_RF_PC,
        EXE_RF_Res => EXE_RF_Res,
        MEM_RF_LW => MEM_RF_LW,
        MEM_RF_Res => MEM_RF_Res
    );
    
    Process_ID_PCAdder: ID_PCAdder
    port map (
        IF_RF_PC => IF_RF_PC,
        ID_Imm => IF_RF_IMM,
        ID_Res => ID_Res
    );
    
    Process_ID_RF: ID_RF
    port map (
        clk => clk_2,
        ID_RFOp => ID_RFOp,
        
        RF_Imm_In => IF_RF_IMM,
        RF_IH_In => ID_IH,
        RF_PC_In => IF_RF_PC,
        RF_Res_In => ID_Res,
        RF_Rd_In => ID_Rd,
        RF_Rx_In => ID_Rx,
        RF_Ry_In => ID_Ry,
        RF_SP_In => ID_SP,
        RF_St_In => IF_RF_Ins,
        RF_T_In => ID_T,
        
        RF_AluOp_In => AluOp,
        RF_AmuxOp_In => AmuxOp,
        RF_BmuxOp_In => BmuxOp,
        RF_RamRWOp_In => RamRWOp,
        RF_RegWrbOp_In => RegWrbOp,
		  RF_SWSRCOP_IN => swsrc, 
		  RF_SWMUXOP_IN => swmuxop, 
          rf_memen_in => memen,
        
        RF_Imm_Out => ID_RF_Imm,
        RF_IH_Out => ID_RF_IH,
        RF_PC_Out => ID_RF_PC,
        RF_Res_Out => ID_RF_Res,
        RF_Rd_Out => ID_RF_Rd,
        RF_Rx_Out => ID_RF_Rx,
        RF_Ry_Out => ID_RF_Ry,
        RF_SP_Out => ID_RF_SP,
        RF_St_Out => ID_RF_St,
        RF_T_Out => ID_RF_T,
        
        RF_AluOp_Out => ID_RF_AluOp,
        RF_AmuxOp_Out => ID_RF_AmuxOp,
        RF_BmuxOp_Out => ID_RF_BmuxOp,
        RF_RamRWOp_Out => ID_RF_RamRWOp,
        RF_RegWrbOp_Out => ID_RF_RegWrbOp,
		  RF_SWSRCOP_OUT => ID_rf_SWSRCOP,
		  RF_SWMUXOP_OUT => ID_RF_SWMUXOP,
          RF_memen_out => id_rf_memen
    );
    
    Process_IF_PCAdder: IF_PCAdder
    port map (
        PC_RF_PC => PC_RF_PC,
        IF_Res => IF_Res
    );
    
    Process_IF_RF: IF_RF
    port map (
        clk => clk_2,
        IF_RFOp => IF_RFOp,
        
        RF_Imm_In => IF_Imm,
        RF_Ins_In => IF_Ins,
        RF_PC_In => IF_Res,
        RF_OPC_In => PC_RF_PC,
        
        RF_Imm_Out => IF_RF_Imm,
        RF_Ins_Out => IF_RF_Ins,
        RF_PC_Out => IF_RF_PC,
        RF_OPC_Out => IF_RF_OPC
    );
    
    Process_MEM_RF: MEM_RF
    port map (
        clk => clk_2,
        MEM_RFOp => MEM_RFOp,
        RF_Flags_In => EXE_RF_Flags,
        RF_LW_In => MEM_LW,
        RF_Rd_In => EXE_RF_Rd,
        RF_Res_In => EXE_RF_Res,
        RF_PC_In => EXE_RF_PC,
        RF_St_In => EXE_RF_St,
        RF_RegWrbOp_IN => EXE_RF_RegWrbOp,
        
        RF_Flags_Out => MEM_RF_Flags,
        RF_LW_Out => MEM_RF_LW,
        RF_Rd_Out => MEM_RF_Rd,
        RF_Res_Out => MEM_RF_Res,
        RF_PC_Out => MEM_RF_PC,
        RF_St_Out => MEM_RF_St,
        RF_RegWrbOp_OUT => MEM_RF_RegWrbOp
    );
	 
	 Process_MEM_SWMUX : MEM_SW_MUX
	 port map (
		clk => clk_2,
		mem_sw_muxop => exe_rf_swmuxop,
		mem_sw_srcop => exe_rf_swsrcop,
		lw_in => mem_rf_lw,
		res_in => mem_rf_res,
		mem_rf_lw => mem_rf_lw,
		mem_rf_res => mem_rf_res,
		exe_rf_rx => exe_rf_rx,
		exe_rf_ry => exe_rf_ry,
		mem_sw_data => mem_sw_data
	);
	 
--    IF_Ins <= inputSW;
    Process_MemUart: MemUart
    port map (
        clk => clk,
        rst => '1',
        mem_sw_data => mem_sw_data,
        
        PC_RF_PC => PC_RF_PC,
        IF_Ins => IF_Ins,
        
        EXE_RF_Res => EXE_RF_Res,
        alures => alures,
        MEM_LW => MEM_LW,
        
        RamRWOp => EXE_RF_RamRWOp,
        ramrwop_lh => id_rf_ramrwop,
        mem_en => exe_rf_memen,
        mem_en_lh => id_rf_memen,
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
        UartRdn => UartRdnTMP,
        UartWrn => UartWrnTMP,
        DataReady => DataReady,
        Tbre => Tbre,
        Tsre => Tsre,
		  
		  --DEBUG
		  state_out => state_out
    );
    
    Process_PC_RF: PC_RF
    port map (
        clk => clk_2,
        rst => rst,
        PC_RFOp => PC_RFOp,
        PC_RFWE => PC_RFWE,
        IDPC => IDPC,
        EXE_RES_PC => ALURes,
        PDTPC => PDTPC,
        
        RF_PC_Out => PC_RF_PC
    );
    
    Process_Registers: Registers
    port map (
        clk => clk,
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
        RegWrbOp => MEM_RF_RegWrbOp,
        RegWrbOut => RegWrbData,
        
        MEM_RF_FlagSign => MEM_RF_Flags(1),
        MEM_RF_LW => MEM_RF_LW,
        MEM_RF_Res => MEM_RF_Res
    );
    
    Process_VGAController: VGAController
    port map (
        clk => clk_25,
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
        T => T,
		  
		  PC_RF_PC => PC_RF_PC,
		  IF_RF_Ins => IF_RF_Ins
--         R0, R1, R2, R3, R4, R5, R6, R7, IH, SP, T : in STD_LOGIC_VECTOR(15 downto 0)
    );
end Behavioral;
