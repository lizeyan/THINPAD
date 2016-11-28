----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:39:48 11/28/2016 
-- Design Name: 
-- Module Name:    CPUController - Behavioral 
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

entity CPUController is
    Port ( 
           -- NaiveCPU -------------------------------------
           clk_in : in STD_LOGIC;
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
           B : out STD_LOGIC_VECTOR(2 downto 0)
           -- NaiveCPU ------------------------------------
           );
end CPUController;

architecture Behavioral of CPUController is
    component NaiveCPU 
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
    end component;
    
    component Flash
        Port ( address : in std_logic_vector(15 downto 0);  -- 22 downto 1 ?
               dataout : out std_logic_vector(15 downto 0);  -- 
               flash_read : in boolean;
               loadReady : out boolean;
               clk : in std_logic;
               rst : in std_logic;
               
               flash_byte : out std_logic := '1';
               flash_vpen : out std_logic := '1';
               flash_ce : out std_logic := '0';
               flash_oe : out std_logic := '1';
               flash_we : out std_logic := '1';
               flash_rp : out std_logic := '1';
               flash_addr : out std_logic_vector(15 downto 0) := (others => '0');
               flash_data : inout std_logic_vector(15 downto 0) := (others => 'Z'));
    end component;
    
    component SWRam2
        Port ( clk : in  STD_LOGIC;
               rst : in  STD_LOGIC;
               Addr : in  STD_LOGIC_VECTOR (15 downto 0);
               Data : in  STD_LOGIC_VECTOR (15 downto 0);
               ramWrite : in boolean;
               storeReady : out boolean;
               EN : out  STD_LOGIC;
               OE : out  STD_LOGIC;
               WE : out  STD_LOGIC;
               ramAddr : out std_logic_vector(15 downto 0);
               ramData : out std_logic_vector(15 downto 0)
               );
    end component;
    
    signal isboot : boolean;
    
    signal boot_ram2en : std_logic;
    signal cpu_ram2en : std_logic;
    signal boot_ram2oe : std_logic;
    signal cpu_ram2oe : std_logic;
    signal boot_ram2we : std_logic;
    signal cpu_ram2we : std_logic;
    signal boot_addr2 : std_logic;
    signal cpu_addr2 : std_logic;
    signal boot_data2 : std_logic;
    signal cpu_data2 : std_logic;
    
    signal boot_clk : std_logic;
    signal cpu_clk : std_logic;
    
begin
    
    
    Process_NaiveCPU : NaiveCPU
    port map (
        clk_in => cpu_clk,
        clk_50 => cpu_clk,
        rst => rst,
        InputSW => InputSW,

        -- Ram 1, 2 and Uart
        Addr1 => Addr1,
        Addr2 => cpu_addr2,
        Data1 => Data1,
        Data2 => cpu,
        Ram1EN => Ram1EN,
        Ram1OE => Ram1OE,
        Ram1WE => Ram1WE,
        Ram2EN => cpu_ram2en,
        Ram2OE => cpu_ram2oe,
        Ram2WE => cpu_ram2we,
        UartRdn => UartRdn,
        UartWrn => UartWrn,
        DataReady => DataReady,
        Tbre => Tbre,
        Tsre => Tsre,

        -- Digit 7 Lights
        Digit7Left => Digit7Left,
        DIgit7Right => Digit7Right,
        -- LED LIGHTS
        ledlights => ledlights,
        -- VGA
        Hs => Hs,
        Vs => Vs,
        R => R,
        G => G,
        B => B
    );

end Behavioral;

