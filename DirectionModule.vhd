----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    11:21:37 11/18/2016 
-- Design Name: 
-- Module Name:    DirectionModule - Behavioral 
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

--- 000 rx
--- 001 ry
--- 011 rz
--- 010 SP
--- 110 IH
--- 100 T
--- others 1111 ILLEGAL
entity DirectionModule is
    Port ( ID_Rd : out STD_LOGIC_VECTOR(3 downto 0);
           DirOp : in STD_LOGIC_VECTOR(2 downto 0);
           
           IF_RF_RX : in STD_LOGIC_VECTOR(2 downto 0);
           IF_RF_RY : in STD_LOGIC_VECTOR(2 downto 0);
           IF_RF_RZ : in STD_LOGIC_VECTOR(2 downto 0));
end DirectionModule;

architecture Behavioral of DirectionModule is
begin
	process (DirOp, IF_RF_RX, IF_RF_RY, IF_RF_RZ)
	begin
		case dirOp is
			when "000" =>
				id_rd <='0' &  if_rf_rx;
			when "001" =>
				id_rd <= '0' & if_rf_ry;
			when "011" =>
				id_rd <= '0' & if_rf_rz;
			when "010" =>
				id_rd <= "1001";
			when "110" =>
				id_rd <= "1000";
			when "100" =>
				id_rd <= "1010";
			when others =>
				id_rd <= "1111";
		end case;
	end process;

end Behavioral;
