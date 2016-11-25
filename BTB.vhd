----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    09:35:51 11/19/2016 
-- Design Name: 
-- Module Name:    BTB - Behavioral 
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

entity BTB is
    Port ( clk : in std_logic;
           PDTPC : out std_logic_vector(15 downto 0);
           
           BTBOp : in std_logic;  -- whether this is a branch instruction
           BTBTOp : in std_logic;  -- this branch instruction really did jump...
           IF_RF_OPC : in std_logic_vector(15 downto 0);  -- pc of branch instruction
           
           IDPC : in std_logic_vector(15 downto 0);
           IF_RF_PC : in std_logic_vector(15 downto 0);
           PC_RF_PC : in std_logic_vector(15 downto 0));
end BTB;

architecture Behavioral of BTB is
    type btbr_type is array(255 downto 0) of std_logic_vector(25 downto 0);  -- 8 HPC + 2 buf + 16 Target
    signal BTBTable : btbr_type := (others => (others => '0'));
    
    signal status : std_logic_vector(1 downto 0) := "00";  -- wait until "11" to do the updating
begin
    process(clk, BTBOp, BTBTOp, IF_RF_OPC)
    begin
		if clk'event and clk='1' then
            case status is
                when "00" => 
                    status <= "01";
                when "01" => 
                    status <= "10";
                when "10" => 
                    status <= "11";
                when "11" => 
                    status <= "00";
                    if BTBOp='1' then  -- is a branch instruction
                        if BTBTable(CONV_INTEGER(IF_RF_OPC(7 downto 0)))(25 downto 18)=IF_RF_OPC(15 downto 8) then  -- hit buffer
                            if BTBTOp='1' then
                                if BTBTable(CONV_INTEGER(IF_RF_OPC(7 downto 0)))(17 downto 16)="00" then
                                    BTBTable(CONV_INTEGER(IF_RF_OPC(7 downto 0)))(17 downto 16) <= "01";
                                elsif BTBTable(CONV_INTEGER(IF_RF_OPC(7 downto 0)))(17 downto 16)="01" or BTBTable(CONV_INTEGER(IF_RF_OPC(7 downto 0)))(17 downto 16)="10" then
                                    BTBTable(CONV_INTEGER(IF_RF_OPC(7 downto 0)))(17 downto 16) <= "11";
                                end if;
                            elsif BTBTOp='0' then
                                if BTBTable(CONV_INTEGER(IF_RF_OPC(7 downto 0)))(17 downto 16)="11" then
                                    BTBTable(CONV_INTEGER(IF_RF_OPC(7 downto 0)))(17 downto 16) <= "10";
                                elsif BTBTable(CONV_INTEGER(IF_RF_OPC(7 downto 0)))(17 downto 16)="10" or BTBTable(CONV_INTEGER(IF_RF_OPC(7 downto 0)))(17 downto 16)="01" then
                                    BTBTable(CONV_INTEGER(IF_RF_OPC(7 downto 0)))(17 downto 16) <= "00";
                                end if;
                            end if;
                        else
                            BTBTable(CONV_INTEGER(IF_RF_OPC(7 downto 0)))(25 downto 0) <= IF_RF_OPC(15 downto 8) & "10" & IF_RF_PC;
                        end if;
                        BTBTable(CONV_INTEGER(IF_RF_OPC(7 downto 0)))(15 downto 0) <= IDPC;
                    end if;
                when others => 
                    null;
            end case;
		end if;
    end process;
    
    process(clk, PC_RF_PC, IF_RF_PC)
    begin
		if falling_edge (clk) then
        if BTBTable(CONV_INTEGER(PC_RF_PC(7 downto 0)))(25 downto 18)=PC_RF_PC(15 downto 8) and BTBTable(CONV_INTEGER(PC_RF_PC(7 downto 0)))(17)='1' then
            PDTPC <= BTBTable(CONV_INTEGER(PC_RF_PC(7 downto 0)))(15 downto 0);
        else
            PDTPC <= IF_RF_PC;
        end if;
		end if;
    end process;        
end Behavioral;
