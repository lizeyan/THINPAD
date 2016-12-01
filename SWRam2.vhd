----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:14:09 11/28/2016 
-- Design Name: 
-- Module Name:    SWRam2 - Behavioral 
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

entity SWRam2 is
    Port ( clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           Addr : in  STD_LOGIC_VECTOR (15 downto 0);
           Data : in  STD_LOGIC_VECTOR (15 downto 0);
           ramWrite : in boolean;
           storeReady : out boolean := true;
           EN : out  STD_LOGIC;
           OE : out  STD_LOGIC;
           WE : out  STD_LOGIC;
           ramAddr : out std_logic_vector(15 downto 0);
           ramData : out std_logic_vector(15 downto 0)
           
           );
end SWRam2;

architecture Behavioral of SWRam2 is
    signal state : std_logic_vector(1 downto 0) := "00";
begin
    process(clk, rst)
    begin
        if rst='0' then
            en <= '0';   we <= '1';		oe <= '1';
            storeReady <= true;
            state <= "00";
        else
            if clk'event and clk='1' then
                if ramWrite then
                    case state is
                        when "00" => 
                            state <= "01";
                            storeReady <= true;
                        when "01" =>
                            en <= '0';
                            we <= '1';
                            oe <= '1';
                            storeReady <= false;
                            state <= "10";
                        when "10" => 
                            we <= '0';
                            ramAddr <= Addr;
                            ramData <= Data;
                            storeReady <= false;
                            state <= "11";
                        when "11" =>
                            state <= "00";
                            storeReady <= true;
                        when others => 
                            null;
                    end case;
                end if;
            end if;
        end if;
    end process;

end Behavioral;

