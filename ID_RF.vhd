----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    11:17:05 11/19/2016 
-- Design Name: 
-- Module Name:    ID_RF - Behavioral 
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

entity ID_RF is
    Port ( clk : in STD_LOGIC;
           ID_RFOp : in STD_LOGIC_VECTOR(1 downto 0);  -- 10 for WE_N, 11 for NOP, 0- for WE
           
           RF_Imm_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_IH_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_PC_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_Res_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_Rd_In : in STD_LOGIC_VECTOR(3 downto 0);
           RF_Rx_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_Ry_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_SP_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_St_In : in STD_LOGIC_VECTOR(15 downto 0);
           RF_T_In : in STD_LOGIC_VECTOR(15 downto 0);
           
           RF_Imm_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_IH_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_PC_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_Res_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_Rd_Out : out STD_LOGIC_VECTOR(3 downto 0);
           RF_Rx_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_Ry_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_SP_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_St_Out : out STD_LOGIC_VECTOR(15 downto 0);
           RF_T_Out : out STD_LOGIC_VECTOR(15 downto 0));
end ID_RF;

architecture Behavioral of ID_RF is
    signal rd : std_logic_vector(3 downto 0);
    signal imm, ih, pc, res, rx, ry, sp, st, t : std_logic_vector(15 downto 0);
begin
    RF_Imm_Out <= imm;
    RF_IH_Out <= ih;
    RF_PC_Out <= pc;
    RF_Res_Out <= res;
    RF_Rd_Out <= rd;
    RF_Rx_Out <= rx;
    RF_Ry_Out <= ry;
    RF_SP_Out <= sp;
    RF_St_out <= st;
    RF_T_Out <= t;
    
    process(clk)
    begin
        if(clk'event and clk='1') then 
            if(ID_RFOp="11") then -- nop
                imm <= "0000000000000000";
                res <= "0000000000000000";
                rd <= "1111";
                rx <= "0000000000000000";
                ry <= "0000000000000000";
                st <= "0000100000000000";
                
                ih <= RF_IH_IN;
                pc <= RF_PC_IN;
                sp <= RF_SP_IN;
                t <= RF_T_IN;
            elsif(ID_RFOp="00" or ID_RFOp="01") then
                imm <= RF_Imm_IN;
                res <= RF_Res_IN;
                rd <= RF_Rd_IN;
                rx <= RF_RX_IN;
                ry <= RF_RY_IN;
                st <= RF_ST_IN;
                
                ih <= RF_IH_IN;
                pc <= RF_PC_IN;
                sp <= RF_SP_IN;
                t <= RF_T_IN;
            else
            end if;
        end if;
    end process;

end Behavioral;

