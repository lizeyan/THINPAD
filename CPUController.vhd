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
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.std_logic_unsigned.all;

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
           B : out STD_LOGIC_VECTOR(2 downto 0);
           -- NaiveCPU ------------------------------------
			  
			  -- Flash ---------------------------------------
			  flash_byte : out std_logic;
           flash_vpen : out std_logic;
           flash_ce : out std_logic;
           flash_oe : out std_logic;
           flash_we : out std_logic;
           flash_rp : out std_logic;
           flash_addr : out std_logic_vector(22 downto 1) := (others => '0');
           flash_data : inout std_logic_vector(15 downto 0) := (others => 'Z')
			  -- Flash ---------------------------------------
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
        
    signal boot_ram2en : std_logic;
    signal cpu_ram2en : std_logic;
    signal boot_ram2oe : std_logic;
    signal cpu_ram2oe : std_logic;
    signal boot_ram2we : std_logic;
    signal cpu_ram2we : std_logic;
    signal boot_addr2 : std_logic_vector(15 downto 0);
    signal cpu_addr2 : std_logic_vector(15 downto 0);
    signal boot_data2 : std_logic_vector(15 downto 0);
    signal cpu_data2 : std_logic_vector(15 downto 0);
    
	signal clk : std_logic;
    signal boot_clk : std_logic;
    signal cpu_clk : std_logic;
	 
--	signal flash_address : std_logic_vector(22 downto 1) := (others => '0');
    signal addr_count : std_logic_vector(15 downto 0) := (others => '0');
    signal data_temp : std_logic_vector(15 downto 0) := (others => '0');
--    signal flash_dataout : std_logic_vector(15 downto 0);
--    signal ram2_addr : std_logic_vector(15 downto 0) := (others => '0');
--	signal ram2_data : std_logic_vector(15 downto 0) := (others => '0');
    
	signal boot_finish : boolean := false;
     
    signal state : std_logic_vector(3 downto 0) := "0000"; 
	 
    
begin
    
	 clk <= clk_50;
	 process(boot_finish, clk)
	 begin
		if not boot_finish then
			boot_clk <= clk_50;
			ram2en <= boot_ram2en;
			ram2oe <= boot_ram2oe;
			ram2we <= boot_ram2we;
			addr2 <= boot_addr2;
			data2 <= boot_data2;
			cpu_clk <= '0';
		else
			boot_clk <= '0';
			cpu_clk <= clk_50;
			ram2en <= cpu_ram2en;
			ram2oe <= cpu_ram2oe;
			ram2we <= cpu_ram2we;
			addr2 <= cpu_addr2;
			data2 <= cpu_data2;
		end if;
	 end process;
	 
     flash_byte <= '1';
     flash_vpen <= '1';
     flash_ce <= '0';
     flash_rp <= '1';
     
	 process(clk)
	 begin
		if(clk'event and clk='1') then
			if addr_count < x"0005" then -- boot
				boot_finish <= false;
				case state is
                    when "0000" => -- read
                        flash_we <= '0';
                        flash_data <= "0000000011111111";
                        state <= "0001";
                    when "0001" => 
                        flash_we <= '1';
                        state <= "0010";
                    when "0010" =>
                        flash_oe <= '0';
                        flash_addr <= "000000"&addr_count;
                        flash_data <= (others => '0');
                        state <= "0011";
                    when "0011" =>
                        data_temp <= flash_data;
                        flash_oe <= '1';
                        state <= "0100";
                    when "0100" =>
                        boot_ram2en <= '0';
                        boot_ram2we <= '1';
                        boot_ram2oe <= '1';
                        state <= "0101";
                    when "0101" =>
                        boot_ram2we <= '0';
                        boot_addr2 <= addr_count;
                        boot_data2 <= data_temp;
                        state <= "0110";
                    when "0110" =>
                        addr_count <= addr_count + 1;
                        state <= "0000";
                    when others => 
                        state <= "0000";
				end case;
			else -- boot finish
				boot_finish <= true;
			end if;
		end if;
	 end process;
	 
	 
	 
    
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
        Data2 => cpu_data2,
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
	 
     
     
--    component Flash
--        Port ( address : in std_logic_vector(22 downto 1);  -- 22 downto 1 ?
--               dataout : out std_logic_vector(15 downto 0);  -- 
--               flashRead : in boolean;
--               loadReady : out boolean;
--               clk : in std_logic;
--               rst : in std_logic;
--               
--               flash_byte : out std_logic;
--               flash_vpen : out std_logic;
--               flash_ce : out std_logic;
--               flash_oe : out std_logic;
--               flash_we : out std_logic;
--               flash_rp : out std_logic;
--               flash_addr : out std_logic_vector(22 downto 1);
--               flash_data : inout std_logic_vector(15 downto 0));
--    end component;
--    
--    component SWRam2
--        Port ( clk : in  STD_LOGIC;
--               rst : in  STD_LOGIC;
--               Addr : in  STD_LOGIC_VECTOR (15 downto 0);
--               Data : in  STD_LOGIC_VECTOR (15 downto 0);
--               ramWrite : in boolean;
--               storeReady : out boolean;
--               EN : out  STD_LOGIC;
--               OE : out  STD_LOGIC;
--               WE : out  STD_LOGIC;
--               ramAddr : out std_logic_vector(15 downto 0);
--               ramData : out std_logic_vector(15 downto 0)
--               );
--    end component;

     
     
--	 Process_Flash : Flash
--	 port map (
--		    address => flash_address,
--			dataout => flash_dataout,
--			flashRead => flash_read,
--			loadReady => load_ready,
--			clk => boot_clk,
--			rst => rst,
--			
--			flash_byte => flash_byte,
--			flash_vpen => flash_vpen,
--			flash_ce => flash_ce,
--			flash_oe => flash_oe,
--			flash_we => flash_we,
--			flash_rp => flash_rp,
--			flash_addr => flash_addr,
--			flash_data => flash_data
--			
--	 );
--	 
--	 Process_SWRam2 : SWRam2
--	 port map (
--		clk => boot_clk,
--		rst => rst,
--		Addr => ram2_addr,
--		data => ram2_data,
--		ramWrite => ram2_write,
--		storeReady => store_ready,
--		
--		en => boot_ram2en,
--		oe => boot_ram2oe,
--		we => boot_ram2we,
--		ramAddr => boot_addr2,
--		ramData => boot_data2
--	 );

end Behavioral;

