----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:35:24 11/26/2016 
-- Design Name: 
-- Module Name:    MEM_SW_MUX - Behavioral 
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
-- 000 lw
-- 001 res
-- 010 mem_rf_lw
-- 011 mem_rf_res
-- 1xx exe_rf_rx or ry
-- 101 PC
-- 110 EXPCODE
entity MEM_SW_MUX is
    Port ( mem_sw_muxop : in  STD_LOGIC_VECTOR (2 downto 0);
           mem_sw_srcop : in  STD_LOGIC;
           lw_in : in  STD_LOGIC_VECTOR (15 downto 0);
           res_in : in  STD_LOGIC_VECTOR (15 downto 0);
           mem_rf_lw : in  STD_LOGIC_VECTOR (15 downto 0);
           mem_rf_res : in  STD_LOGIC_VECTOR (15 downto 0);
           exe_rf_rx : in  STD_LOGIC_VECTOR (15 downto 0); 
           exe_rf_ry : in  STD_LOGIC_VECTOR (15 downto 0);
           exe_rf_st : in  STD_LOGIC_VECTOR (15 downto 0);
           exe_rf_pc : in  STD_LOGIC_VECTOR (15 downto 0);
           clk : in  STD_LOGIC;
           mem_sw_data : out  STD_LOGIC_VECTOR (15 downto 0));
end MEM_SW_MUX;

architecture Behavioral of MEM_SW_MUX is
	signal lw, res : std_logic_vector (15 downto 0) := "0000000000000000";
begin
	process (clk)
	begin
		if rising_edge (clk) then
			lw <= lw_in;
			res <= res_in;
		end if;
	end process;

	process (mem_sw_muxop, mem_sw_srcop, lw, res, mem_rf_lw, mem_rf_res, exe_rf_rx, exe_rf_ry, exe_rf_pc, exe_rf_st)
	begin
		case mem_sw_muxop is
			when "000" => mem_sw_data <= lw;
			when "001" => mem_sw_data <= res;
			when "010" => mem_sw_data <= mem_rf_lw;
			when "011" => mem_sw_data <= mem_rf_res;
			when "100" =>
				if mem_sw_srcop = '0' then
					mem_sw_data <= exe_rf_rx;
				else
					mem_sw_data <= exe_rf_ry;
				end if;
            when "101" =>
                mem_sw_data <= exe_rf_pc;
            when "110" =>
                mem_sw_data <= "000000000000" & exe_rf_st(3 downto 0);
            when others =>
                if mem_sw_srcop = '0' then
					mem_sw_data <= exe_rf_rx;
				else
					mem_sw_data <= exe_rf_ry;
				end if;
		end case;
	end process;
end Behavioral;

