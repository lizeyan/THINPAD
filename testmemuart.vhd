----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:27:40 11/27/2016 
-- Design Name: 
-- Module Name:    testmemuart - Behavioral 
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity testmemuart is
    Port ( inputsw : in  STD_LOGIC_VECTOR (15 downto 0);
           clk : in  STD_LOGIC;
			  mode : in STD_LOGIC;
           dataready : in  STD_LOGIC;
           tbre : in  STD_LOGIC;
           tsre : in  STD_LOGIC;
           addr1 : out  STD_LOGIC_VECTOR (15 downto 0);
           data1 : inout  STD_LOGIC_VECTOR (15 downto 0);
           uartwrn : out  STD_LOGIC;
			  ledlights : out STD_LOGIC_VECTOR (15 downto 0);
			  ram1en : out STD_LOGIC;
			  ram1we : out STD_LOGIC;
			  ram1oe : out STD_LOGIC;
           uartrdn : out  STD_LOGIC);
end testmemuart;

architecture Behavioral of testmemuart is
	component MemUart
        Port ( clk : in STD_LOGIC;
               rst : in STD_LOGIC;
               
               -- IF
               PC_RF_PC : in STD_LOGIC_VECTOR(15 downto 0);
               IF_Ins : out STD_LOGIC_VECTOR(15 downto 0);
               
               -- MEM
					MEM_SW_DATA : in STD_LOGIC_VECTOR (15 downto 0);
               EXE_RF_Res : in STD_LOGIC_VECTOR(15 downto 0);
               MEM_LW : out STD_LOGIC_VECTOR(15 downto 0);
               --DEBUG
					state_out: out std_logic_vector (3 downto 0);
               -- IF & MEM
               RamRWOp : in std_logic;  -- (1) for Ram1, (0) for Ram2; 0 for R, 1 for W
               
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
	 
	 signal lw : std_logic_vector (15 downto 0);
begin
	ledlights( 7 downto 0) <= lw(7 downto 0);
	ledlights(8) <= dataready;
	ledlights(9) <= tbre;
	ledlights(10) <= tsre;
	ledlights(11) <= '0';
	process_memuart : MEMUART
	port map (
		clk => clk,
		rst => '1',
		pc_rf_pc => "0000000000000000",
		mem_sw_data => inputsw,
		exe_rf_res => "1011111100000000",
		mem_lw => lw,
		state_out => ledlights (15 downto 12),
		ramrwop => mode,
		addr1 => addr1,
		data1 => data1,
		ram1en => ram1en,
		ram1oe => ram1oe,
		ram1we => ram1we,
		uartrdn => uartrdn,
		uartwrn => uartwrn,
		dataready => dataready,
		tbre => tbre,
		tsre => tsre
	);
		

end Behavioral;

