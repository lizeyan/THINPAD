----------------------------------------------------------------------------------
-- Company: Concept Computer Corporation
-- Engineer: LXH, LZY, YST
-- 
-- Create Date:    10:19:04 11/18/2016 
-- Design Name: 
-- Module Name:    VGAController - Behavioral 
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

entity VGAController is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           InputSW : in STD_LOGIC_VECTOR(15 downto 0);
           Hs : out STD_LOGIC;
           Vs : out STD_LOGIC;
           R : out STD_LOGIC_VECTOR(2 downto 0);
           G : out STD_LOGIC_VECTOR(2 downto 0);
           B : out STD_LOGIC_VECTOR(2 downto 0);
           
           R0, R1, R2, R3, R4, R5, R6, R7, IH, SP, T : in STD_LOGIC_VECTOR(15 downto 0));
end VGAController;

architecture Behavioral of VGAController is
    signal tempHs : STD_LOGIC;
    signal tempVs : STD_LOGIC;
    signal tempR : STD_LOGIC_VECTOR(2 downto 0);
    signal tempG : STD_LOGIC_VECTOR(2 downto 0);
    signal tempB : STD_LOGIC_VECTOR(2 downto 0);
    signal x : STD_LOGIC_VECTOR(9 downto 0);
    signal y : STD_LOGIC_VECTOR(9 downto 0);
	constant half : STD_LOGIC_VECTOR(2 downto 0) := "001";
        
	function print_register(input: STD_LOGIC_VECTOR(15 downto 0))
	return STD_LOGIC_VECTOR is
	variable temp_G : STD_LOGIC_VECTOR (2 downto 0);
		begin
		if x<60 or (x>=100 and x<110) or (x>=150 and x<160) or (x>=200 and x<210) or x>=250 then
			 temp_G := "000";
		elsif (x>=60 and x<70 and input(15)='1') or (x>=70 and x<80 and input(14)='1') or
				(x>=80 and x<90 and input(13)='1') or (x>=90 and x<100 and input(12)='1') or
				(x>=110 and x<120 and input(11)='1') or (x>=120 and x<130 and input(10)='1') or
				(x>=130 and x<140 and input(9)='1') or (x>=140 and x<150 and input(8)='1') or
				(x>=160 and x<170 and input(7)='1') or (x>=170 and x<180 and input(6)='1') or
				(x>=180 and x<190 and input(5)='1') or (x>=190 and x<200 and input(4)='1') or
				(x>=210 and x<220 and input(3)='1') or (x>=220 and x<230 and input(2)='1') or
				(x>=230 and x<240 and input(1)='1') or (x>=240 and x<250 and input(0)='1') then
			 temp_G := "111";
		else
			 temp_G := half;
		end if;
		return temp_G;
	end print_register;
begin
    -- H scan pixels 800
    process(clk, rst)
    begin
        if rst='0' then
            x <= (others => '0');
        elsif clk'event and clk='1' then
            if x=799 then
                x <= (others => '0');
            else
                x <= x + 1;
            end if;
        end if;
    end process;
    
    -- V scan pixels 525 dependent on H pixels
    process(clk, rst)
    begin
        if rst='0' then
            y <= (others => '0');
        elsif clk'event and clk='1' then
            if x=799 then
                if y=524 then
                    y <= (others => '0');
                else
                    y <= y + 1;
                end if;
            end if;
        end if;
    end process;
    
    -- Hs down in [656, 752)
    process(clk, rst)
    begin
        if rst='0' then
            tempHs <= '0';
        elsif clk'event and clk='1' then
            if x>=656 and x<752 then
                tempHs <= '0';
            else
                tempHs <= '1';
            end if;
        end if;
    end process;
    
    -- Vs down in [490, 492)
    process(clk, rst)
    begin
        if rst='0' then
            tempVs <= '0';
        elsif clk'event and clk='1' then
            if y>=490 and y<492 then
                tempVs <= '0';
            else
                tempVs <= '1';
            end if;
        end if;
    end process;
    
    -- Hs output
    process(clk, rst)
    begin
        if rst='0' then
            Hs <= '0';
        elsif clk'event and clk='1' then
            Hs <= tempHs;
        end if;
    end process;
    
    -- Vs output
    process(clk, rst)
    begin
        if rst='0' then
            Vs <= '0';
        elsif clk'event and clk='1' then
            Vs <= tempVs;
        end if;
    end process;
    
    -- RGB output
    process(tempHs, tempVs, tempR, tempG, tempB)
    begin
        if tempHs='1' and tempVs='1' then
            R <= tempR;
            G <= tempG;
            B <= tempB;
        else
            R <= (others => '0');
            G <= (others => '0');
            B <= (others => '0');
        end if;
    end process;
    
    -- Graph Design
    process(clk, rst, x, y)
	 variable G_register : STD_LOGIC_VECTOR(2 downto 0) := "000";
    begin
        if rst='0' then
            tempR <= (others => '0');
            tempG <= (others => '0');
            tempB <= (others => '0');
        else
            if clk'event and clk='1' then
                if x>=640 or y>=480 then
                    tempR <= (others => '0');
                    tempG <= (others => '0');
                    tempB <= (others => '0');
                else
                    if y>=10 and y<20 then
                        if x>=10 and x<50 then
                            tempR <= half;
                        else
                            tempR <= (others => '0');
                        end if;
								G_register := print_register(R0);
                        tempG <= print_register(R0);
                    elsif y>=30 and y<40 then
                        if x>=10 and x<40 then
                            tempR <= half;
                        elsif x>=40 and x<50 then
                            tempR <= (others => '1');
                        else
                            tempR <= (others => '0');
                        end if;
								G_register := print_register(R1);
                        tempG <= print_register(R1);
                    elsif y>=50 and y<60 then
                        if (x>=10 and x<30) or (x>=40 and x<50) then
                            tempR <= half;
                        elsif x>=30 and x<40 then
                            tempR <= (others => '1');
                        else
                            tempR <= (others => '0');
                        end if;
								G_register := print_register(R2);
                        tempG <= print_register(R2);
                    elsif y>=70 and y<80 then
                        if x>=10 and x<30 then
                            tempR <= half;
                        elsif x>=30 and x<50 then
                            tempR <= (others => '1');
                        else
                            tempR <= (others => '0');
                        end if;
								G_register := print_register(R3);
                        tempG <= print_register(R3);
                    elsif y>=90 and y<100 then
                        if (x>=10 and x<20) or (x>=30 and x<50) then
                            tempR <= half;
                        elsif x>=20 and x<30 then
                            tempR <= (others => '1');
                        else
                            tempR <= (others => '0');
                        end if;
                        G_register := print_register(R4);
                        tempG <= print_register(R4);
                    elsif y>=110 and y<120 then
                        if (x>=10 and x<20) or (x>=30 and x<40) then
                            tempR <= half;
                        elsif (x>=20 and x<30) or (x>=40 and x<50) then
                            tempR <= (others => '1');
                        else
                            tempR <= (others => '0');
                        end if;
                        G_register := print_register(R5);
                        tempG <= print_register(R5);
                    elsif y>=130 and y<140 then
                        if (x>=10 and x<20) or (x>=40 and x<50) then
                            tempR <= half;
                        elsif x>=20 and x<40 then
                            tempR <= (others => '1');
                        else
                            tempR <= (others => '0');
                        end if;
								G_register := print_register(R6);
                        tempG <= print_register(R6);
                    elsif y>=150 and y<160 then
                        if x>=10 and x<20 then
                            tempR <= half;
                        elsif x>=20 and x<50 then
                            tempR <= (others => '1');
                        else
                            tempR <= (others => '0');
                        end if;
								G_register := print_register(R7);
                        tempG <= print_register(R7);
                    elsif x>=190 and x<200 then
                        if x>=20 and x<50 then
                            tempR <= half;
                        elsif x>=10 and x<20 then
                            tempR <= (others => '1');
                        else
                            tempR <= (others => '0');
                        end if;
								G_register := print_register(IH);
                        tempG <= print_register(IH);
                    elsif x>=210 and x<220 then
                        if x>=20 and x<40 then
                            tempR <= half;
                        elsif (x>=10 and x<20) or (x>=40 and x<50) then
                            tempR <= (others => '1');
                        else
                            tempR <= (others => '0');
                        end if;
								G_register := print_register(SP);
                        tempG <= print_register(SP);
                    elsif x>=230 and x<240 then
                        if (x>=20 and x<30) or (x>=40 and x<50) then
                            tempR <= half;
                        elsif (x>=10 and x<20) or (x>=30 and x<40) then
                            tempR <= (others => '1');
                        else
                            tempR <= (others => '0');
                        end if;
								G_register := print_register(T);
                        tempG <= print_register(T);
                    else
                        tempR <= (others => '0');
                        tempG <= (others => '1');
                    end if;
                    tempB <= (others => '0');
                end if;
            end if;
        end if;
    end process;
end Behavioral;
