----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    14:25:27 11/19/2016 
-- Design Name: 
-- Module Name:    ClockModule - Behavioral 
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

entity ClockModule is
    Port ( clk_in : in STD_LOGIC;
           
           clk : out STD_LOGIC;
           clk_2 : out STD_LOGIC;
           clk_4 : out STD_LOGIC;
           clk_8 : out STD_LOGIC;
           clk_16 : out STD_LOGIC;
          clk_1k : out STD_LOGIC);
end ClockModule;

architecture Behavioral of ClockModule is
    signal tempClk2 : STD_LOGIC := '0';
    signal tempClk4 : STD_LOGIC := '0';
    signal tempClk8 : STD_LOGIC := '0';
    signal tempClk16 : STD_LOGIC := '0';
	 signal tempClk1k : STD_LOGIC := '0';
	 
	 signal cnt : INTEGER range 0 to 65535*2 := 0;
begin
    clk <= clk_in;
    clk_2 <= tempClk2;
    clk_4 <= tempClk4;
    clk_8 <= tempClk8;
    clk_16 <= tempClk16;
	 clk_1k <= tempclk1k;
	 process(clk_in)
	 begin
		if clk_in'event and clk_in='1' then
            cnt <= cnt + 1;
            if cnt=100000 then
                cnt <= 0;
                tempClk1k <= not tempClk1k;
            end if;
        end if;
    end process;
    
    process(clk_in)
    begin
        if clk_in'event and clk_in='1' then
            tempClk2 <= not tempClk2;
        end if;
    end process;
    
    process(tempClk2)
    begin
        if tempClk2'event and tempClk2='1' then
            tempClk4 <= not tempClk4;
        end if;
    end process;
    
    process(tempClk4)
    begin
        if tempClk4'event and tempClk4='1' then
            tempClk8 <= not tempClk8;
        end if;
    end process;
    
    process(tempClk8)
    begin
        if tempClk8'event and tempClk8='1' then
            tempClk16 <= not tempClk16;
        end if;
    end process;
end Behavioral;
