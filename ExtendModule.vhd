----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    11:10:53 11/18/2016 
-- Design Name: 
-- Module Name:    ExtendModule - Behavioral 
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
use IEEE.numeric_std.all;
-- EX Digits Op
-- 000 10:0
-- 001 7:0
-- 011 4:0
-- 010 4:2
-- 110 3:0
-- others Z... (ILLEGAL)
entity ExtendModule is
    Port ( ExSrc : in STD_LOGIC_VECTOR(10 downto 0);
           ExImm : out STD_LOGIC_VECTOR(15 downto 0);
           
           ExDigitsOp : in STD_LOGIC_VECTOR(2 downto 0);
           ExSignOp : in STD_LOGIC);
end ExtendModule;

architecture Behavioral of ExtendModule is
begin
	process (exsrc, exdigitsop, exsignop)
--		variable sign : STD_LOGIC := '0';
	begin 
		if exsignop = '0' then
			case exdigitsop is
				when "000" => eximm <= "00000" & exsrc;
				when "001" => eximm <= "00000000" & exsrc(7 downto 0);
				when "011" => eximm <= "00000000000" & exsrc (4 downto 0);
				when "010" => eximm <= "0000000000000" & exsrc (4 downto 2);
                when "110" => eximm <= "000000000000" & exsrc(3 downto 0);
				when others => eximm <= "ZZZZZZZZZZZZZZZZ";
			end case;
		elsif exsignop = '1' then
			case exdigitsop is
				when "000" => 
--					sign := exsrc(10);
					eximm (10 downto 0) <= exsrc;
					eximm (15 downto 11) <= (others => exsrc(10));
				when "001" => 
--					sign := exsrc(7);
					eximm (7 downto 0) <= exsrc (7 downto 0);
					eximm (15 downto 8) <= (others => exsrc(7));
				when "011" => 
--					sign := exsrc(4);
					eximm (4 downto 0) <= exsrc (4 downto 0);
					eximm (15 downto 5) <= (others => exsrc(4));
				when "010" => 
--					sign := exsrc(4);
					eximm (2 downto 0) <= exsrc (4 downto 2);
					eximm (15 downto 3) <= (others => exsrc(4));
				when others => eximm <= "ZZZZZZZZZZZZZZZZ";
			end case;
		else
			eximm <= "ZZZZZZZZZZZZZZZZ";
		end if;
	end process;

end Behavioral;
