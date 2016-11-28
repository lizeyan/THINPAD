----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:27:11 11/27/2016 
-- Design Name: 
-- Module Name:    Flash - Behavioral 
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

entity Flash is
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
end Flash;

architecture Behavioral of Flash is
    signal state : std_logic_vector(2 downto 0) := (others => '0');
begin

    flash_byte <= '1';
    flash_vpen <= '1';
    flash_ce <= '0';
    flash_rp <= '1';
    loadReady <= '1';
    process(clk, rst)
    begin
        if rst='0' then
            dataout <= "0000100000000000";
            flash_oe <= '1';
            flash_we <= '1';
            state <= "000";
            flash_data <= (others => 'Z');
            loadReady <= '1';
        else
            if clk'event and clk='1' then
                if flash_read='0' then
                    case state is
                        when "000" =>  -- boot start 1
                            flash_we <= '0';
                            state <= "001";
                            loadReady <= '0';
                        when "001" =>  -- boot start 2
                            flash_data <= "0000000011111111";
                            state <= "010";
                            loadReady <= '0';
                        when "010" =>  -- boot start 3
                            flash_we <= '1';
                            state <= "011";
                            loadReady <= '0';
                        when "011" =>  -- boot addr ready
                            flash_addr <= address;
                            flash_oe <= '0';
                            flash_data <= (others => 'Z');
                            state <= "100";
                            loadReady <= '0';
                        when "100" =>  -- boot data read
                            dataout <= flash_data;
                            flash_oe <= '1';
                            state <= "101";
                            loadReady <= '0';
                        when "101" =>  -- boot data read2
                            state <= "000";
                            loadReady <= '1';
                        when others => 
                            null;
                    end case;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
