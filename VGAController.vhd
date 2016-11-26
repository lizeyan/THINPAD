----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:19:34 11/17/2016 
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
    Port ( clk : in std_logic;
           rst : in std_logic;
           InputSW : in std_logic_vector(15 downto 0);
           Hs : out std_logic;
           Vs : out std_logic;
           R : out std_logic_vector(2 downto 0);
           G : out std_logic_vector(2 downto 0);
           B : out std_logic_vector(2 downto 0);
			  
			  R0 : in std_logic_vector(15 downto 0);
			  R1 : in std_logic_vector(15 downto 0);
			  R2 : in std_logic_vector(15 downto 0);
			  R3 : in std_logic_vector(15 downto 0);
			  R4 : in std_logic_vector(15 downto 0);
			  R5 : in std_logic_vector(15 downto 0);
			  R6 : in std_logic_vector(15 downto 0);
			  R7 : in std_logic_vector(15 downto 0);
			  IH : in std_logic_vector(15 downto 0);
			  SP : in std_logic_vector(15 downto 0);
			  T : in std_logic_vector(15 downto 0)
			  
			  );
end VGAController;

architecture Behavioral of VGAController is
    signal tempHs : std_logic;
    signal tempVs : std_logic;
    signal tempR : std_logic_vector(2 downto 0);
    signal tempG : std_logic_vector(2 downto 0);
    signal tempB : std_logic_vector(2 downto 0);
    signal x : std_logic_vector(9 downto 0);
    signal y : std_logic_vector(9 downto 0);
    
    
begin
    -- Frequency Division
    
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
    
    type CharMatrix is array(15 downto 0) of std_logic_vector(15 downto 0);
    
    -- 0
    function Print_0(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant Char0 : CharMatrix := (
            "0000000000000000",
            "0000001110000000",
            "0000010001000000",
            "0000110001100000",
            "0000100000100000",
            "0001100000110000",
            "0001100000110000",
            "0001100000110000",
            "0001100000110000",
            "0001100000110000",
            "0001100000110000",
            "0000100000100000",
            "0000110001100000",
            "0000010001000000",
            "0000001110000000",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if Char0(15-conv_integer(y))(15-conv_integer(x))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_0;
    
    -- 1
    function Print_1(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant Char1 : CharMatrix := (
            "0000000000000000",
            "0000000110000000",
            "0000011110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000011111100000",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if Char1(15-conv_integer(y))(15-conv_integer(x))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_1;
    
    -- 2
    function Print_2(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant Char2 : CharMatrix := (
            "0000000000000000",
            "0000011110000000",
            "0000111111000000",
            "0001100011100000",
            "0001000001100000",
            "0000000001100000",
            "0000000001100000",
            "0000000001000000",
            "0000000010000000",
            "0000000010000000",
            "0000000100000000",
            "0000001000000000",
            "0000010000010000",
            "0000111111110000",
            "0001111111100000",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if Char2(15-conv_integer(y))(15-conv_integer(x))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_2;
    
    -- 3
    function Print_3(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant Char3 : CharMatrix := (
            "0000000000000000",
            "0000001111000000",
            "0000010011100000",
            "0000100001100000",
            "0000000001100000",
            "0000000001000000",
            "0000000110000000",
            "0000001111100000",
            "0000000011100000",
            "0000000001110000",
            "0000000000110000",
            "0000000000110000",
            "0000000000100000",
            "0000110001100000",
            "0000111110000000",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if Char3(15-conv_integer(y))(15-conv_integer(x))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_3;
    
    -- 4
    function Print_4(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant Char4 : CharMatrix := (
            "0000000000000000",
            "0000000001100000",
            "0000000001100000",
            "0000000011100000",
            "0000000101100000",
            "0000001001100000",
            "0000001001100000",
            "0000010001100000",
            "0000100001100000",
            "0001000001100000",
            "0001000001100000",
            "0001111111111000",
            "0000000001100000",
            "0000000001100000",
            "0000000001100000",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if Char4(15-conv_integer(y))(15-conv_integer(x))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_4;
    
    -- 5
    function Print_5(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant Char5 : CharMatrix := (
            "0000000000000000",
            "0000000111110000",
            "0000001111100000",
            "0000001000000000",
            "0000011100000000",
            "0000011111000000",
            "0000000111100000",
            "0000000001110000",
            "0000000000110000",
            "0000000000110000",
            "0000000000010000",
            "0000000000010000",
            "0000000000100000",
            "0000110001000000",
            "0000111110000000",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if Char5(15-conv_integer(y))(15-conv_integer(x))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_5;
    
    -- 6
    function Print_6(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant Char6 : CharMatrix := (
            "0000000000000000",
            "0000000001110000",
            "0000000110000000",
            "0000001100000000",
            "0000011000000000",
            "0000110000000000",
            "0000101111000000",
            "0001110001100000",
            "0001100001110000",
            "0001100000110000",
            "0001100000110000",
            "0001100000110000",
            "0000110000100000",
            "0000110001100000",
            "0000001111000000",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if Char6(15-conv_integer(y))(15-conv_integer(x))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_6;
    
    -- 7
    function Print_7(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant Char7 : CharMatrix := (
            "0000000000000000",
            "0000111111110000",
            "0000111111100000",
            "0001000000100000",
            "0000000000100000",
            "0000000001000000",
            "0000000001000000",
            "0000000001000000",
            "0000000010000000",
            "0000000010000000",
            "0000000010000000",
            "0000000100000000",
            "0000000100000000",
            "0000000100000000",
            "0000001000000000",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if Char7(15-conv_integer(y))(15-conv_integer(x))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_7;
    
    -- 8
    function Print_8(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant Char8 : CharMatrix := (
            "0000000000000000",
            "0000011111000000",
            "0000110001100000",
            "0001100000110000",
            "0001100000110000",
            "0001110000110000",
            "0000111001100000",
            "0000011110000000",
            "0000001111000000",
            "0000110011100000",
            "0001100001110000",
            "0001100000110000",
            "0001100000110000",
            "0000110001100000",
            "0000011111000000",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if Char8(15-conv_integer(y))(15-conv_integer(x))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_8;
    
    -- 9
    function Print_9(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant Char9 : CharMatrix := (
            "0000000000000000",
            "0000011110000000",
            "0000110001100000",
            "0000100001100000",
            "0001100000110000",
            "0001100000110000",
            "0001100000110000",
            "0001110000110000",
            "0000110000110000",
            "0000011111100000",
            "0000000001100000",
            "0000000001000000",
            "0000000110000000",
            "0000001100000000",
            "0001110000000000",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if Char9(15-conv_integer(y))(15-conv_integer(x))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_9;
    
    -- A
    function Print_A(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant CharA : CharMatrix := (
            "0000000000000000",
            "0000000010000000",
            "0000000110000000",
            "0000000111000000",
            "0000001011000000",
            "0000001001100000",
            "0000001001100000",
            "0000010001100000",
            "0000010000110000",
            "0000111111110000",
            "0000100000110000",
            "0001000000011000",
            "0001000000011000",
            "0011000000011100",
            "0111100000111110",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if CharA(15-conv_integer(y))(15-conv_integer(x))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_A;
    
    -- B
    function Print_B(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant CharB : CharMatrix := (
            "0000000000000000",
            "0111111111100000",
            "0001100000110000",
            "0001100000011000",
            "0001100000011000",
            "0001100000011000",
            "0001100000110000",
            "0001111111100000",
            "0001100000111000",
            "0001100000011100",
            "0001100000001100",
            "0001100000001100",
            "0001100000001100",
            "0001100000011000",
            "0111111111110000",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if CharB(15-conv_integer(y))(15-conv_integer(x))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_B;
    
    -- C
    function Print_C(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant CharC : CharMatrix := (
            "0000000000000000",
            "0000001111100100",
            "0000011000011100",
            "0000100000001100",
            "0001100000001100",
            "0011000000000100",
            "0011000000000000",
            "0011000000000000",
            "0011000000000000",
            "0011000000000000",
            "0011000000000000",
            "0001100000000100",
            "0001100000001000",
            "0000111000010000",
            "0000001111100000",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if CharC(15-conv_integer(y))(15-conv_integer(x))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_C;
    
    -- D
    function Print_D(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant CharD : CharMatrix := (
            "0000000000000000",
            "0111111111100000",
            "0001100000111000",
            "0001100000011100",
            "0001100000001100",
            "0001100000000110",
            "0001100000000110",
            "0001100000000110",
            "0001100000000110",
            "0001100000000110",
            "0001100000000110",
            "0001100000001100",
            "0001100000011000",
            "0001100000110000",
            "0111111111100000",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if CharD(15-conv_integer(y))(15-conv_integer(x))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_D;
    
    -- E
    function Print_E(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant CharE : CharMatrix := (
            "0000000000000000",
            "0111111111111000",
            "0001100000011000",
            "0001100000001000",
            "0001100000000000",
            "0001100000100000",
            "0001100000100000",
            "0001111111100000",
            "0001100000100000",
            "0001100000100000",
            "0001100000000000",
            "0001100000000100",
            "0001100000001000",
            "0001100000011000",
            "0111111111111000",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if CharE(15-conv_integer(y))(15-conv_integer(x))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_E;
    
    -- F
    function Print_F(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant CharF : CharMatrix := (
            "0000000000000000",
            "0011111111111000",
            "0000110000011000",
            "0000110000001000",
            "0000110000000000",
            "0000110000100000",
            "0000110000100000",
            "0000111111100000",
            "0000110000100000",
            "0000110000100000",
            "0000110000000000",
            "0000110000000000",
            "0000110000000000",
            "0000110000000000",
            "0011111100000000",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if CharF(15-conv_integer(y))(15-conv_integer(x))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_F;
    
    -- H
    function Print_H(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant CharH : CharMatrix := (
            "0000000000000000",
            "1111110001111110",
            "0011000000011000",
            "0011000000011000",
            "0011000000011000",
            "0011000000011000",
            "0011000000011000",
            "0011111111111000",
            "0011000000011000",
            "0011000000011000",
            "0011000000011000",
            "0011000000011000",
            "0011000000011000",
            "0011000000011000",
            "1111110001111110",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if CharH(CONV_INTEGER(x))(CONV_INTEGER(y))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_H;
    
    -- I
    function Print_I(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant CharI : CharMatrix := (
            "0000000000000000",
            "0000011111100000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000011111100000",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if CharI(CONV_INTEGER(x))(CONV_INTEGER(y))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_I;
    
    -- P
    function Print_P(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant CharP : CharMatrix := (
            "0000000000000000",
            "0011111111100000",
            "0000110000110000",
            "0000110000011000",
            "0000110000011000",
            "0000110000011000",
            "0000110000011000",
            "0000110000110000",
            "0000111111100000",
            "0000110000000000",
            "0000110000000000",
            "0000110000000000",
            "0000110000000000",
            "0000110000000000",
            "0011111100000000",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if CharP(CONV_INTEGER(x))(CONV_INTEGER(y))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_P;
    
    -- R
    function Print_R(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant CharR : CharMatrix := (
            "0000000000000000",
            "0111111111000000",
            "0001100001100000",
            "0001100000110000",
            "0001100000110000",
            "0001100000110000",
            "0001100001100000",
            "0001111111000000",
            "0001100110000000",
            "0001100111000000",
            "0001100011000000",
            "0001100001100000",
            "0001100001110000",
            "0001100000111000",
            "0111111000011110",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if CharR(15-conv_integer(y))(15-conv_integer(x))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_R;
    
    -- S
    function Print_S(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant CharS : CharMatrix := (
            "0000000000000000",
            "0000011100100000",
            "0000110011100000",
            "0001100001100000",
            "0001100000100000",
            "0001110000100000",
            "0000111000000000",
            "0000011110000000",
            "0000000111000000",
            "0000000011100000",
            "0001000001110000",
            "0001000000110000",
            "0001100000110000",
            "0001110001100000",
            "0001001111000000",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if CharS(CONV_INTEGER(x))(CONV_INTEGER(y))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_S;
    
    -- T
    function Print_T(x: std_logic_vector(3 downto 0);
                     y: std_logic_vector(3 downto 0))
    return std_logic_vector is
        constant CharT : CharMatrix := (
            "0000000000000000",
            "0011111111111100",
            "0011000110001100",
            "0010000110000100",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000000110000000",
            "0000011111100000",
            "0000000000000000"
            );
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if CharT(CONV_INTEGER(x))(CONV_INTEGER(y))='1' then
            tempC := "111";
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_T;
    
    function Print_Char(input: std_logic_vector(3 downto 0);
                        x: std_logic_vector(3 downto 0);
                        y: std_logic_vector(3 downto 0))  -- needs 16 - y
    return std_logic_vector is
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        case input is
            when "0000" => 
                tempC := Print_0(y, x);
            when "0001" => 
                tempC := Print_1(y, x);
            when "0010" => 
                tempC := Print_2(y, x);
            when "0011" => 
                tempC := Print_3(y, x);
            when "0100" => 
                tempC := Print_4(y, x);
            when "0101" => 
                tempC := Print_5(y, x);
            when "0110" => 
                tempC := Print_6(y, x);
            when "0111" => 
                tempC := Print_7(y, x);
            when "1000" => 
                tempC := Print_8(y, x);
            when "1001" => 
                tempC := Print_9(y, x);
            when "1010" => 
                tempC := Print_A(y, x);
            when "1011" => 
                tempC := Print_B(y, x);
            when "1100" => 
                tempC := Print_C(y, x);
            when "1101" => 
                tempC := Print_D(y, x);
            when "1110" => 
                tempC := Print_E(y, x);
            when "1111" => 
                tempC := Print_F(y, x);
            when others =>
                tempC := "000";
        end case;
        return tempC;
    end Print_Char;
    
    function Print_Register(input: std_logic_vector(15 downto 0);
                            x: std_logic_vector(9 downto 0);
                            y: std_logic_vector(8 downto 0))  -- needs 16 - y
    return std_logic_vector is
        variable tempC : std_logic_vector(2 downto 0) := "000";
    begin
        if x>=0 and x<64 and y>=0 and y<16 then
            if x<16 then
                tempC := Print_Char(input(15 downto 12), y(3 downto 0), x(3 downto 0));
            elsif x<32 then
                tempC := Print_Char(input(11 downto 8), y(3 downto 0), x(3 downto 0));
            elsif x<48 then
                tempC := Print_Char(input(7 downto 4), y(3 downto 0), x(3 downto 0));
            elsif x<64 then
                tempC := Print_Char(input(3 downto 0), y(3 downto 0), x(3 downto 0));
            end if;
        else
            tempC := "000";
        end if;
        return tempC;
    end Print_Register;
    
-- ==========
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
                    if x>=10 and x<130 then
                        if y>=10 and y<26 then  -- R0
                            if x<26 then
                                tempR <= Print_R(x-10, y-10);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x<42 then
                                tempR <= Print_0(x-26, y-10);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x>=50 and x<114 then
                                tempR <= (others => '0');
                                tempG <= Print_Register(InputSW, x-50, y-10);
                                tempB <= (others => '0');
                            else
                                tempR <= (others => '0');
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            end if;
                        elsif y>=30 and y<46 then  -- R1
                            if x<26 then
                                tempR <= Print_R(x-10, y-30);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x<42 then
                                tempR <= Print_1(x-26, y-30);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x>=50 and x<114 then
                                tempR <= (others => '0');
                                tempG <= Print_Register(R1, x-50, y-30);
                                tempB <= (others => '0');
                            else
                                tempR <= (others => '0');
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            end if;
                        elsif y>=50 and y<66 then  -- R2
                            if x<26 then
                                tempR <= Print_R(x-10, y-50);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x<42 then
                                tempR <= Print_2(x-26, y-50);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x>=50 and x<114 then
                                tempR <= (others => '0');
                                tempG <= Print_Register(R2, x-50, y-50);
                                tempB <= (others => '0');
                            else
                                tempR <= (others => '0');
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            end if;
                        elsif y>=70 and y<86 then  -- R3
                            if x<26 then
                                tempR <= Print_R(x-10, y-70);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x<42 then
                                tempR <= Print_3(x-26, y-70);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x>=50 and x<114 then
                                tempR <= (others => '0');
                                tempG <= Print_Register(R3, x-50, y-70);
                                tempB <= (others => '0');
                            else
                                tempR <= (others => '0');
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            end if;
                        elsif y>=90 and y<106 then  -- R4
                            if x<26 then
                                tempR <= Print_R(x-10, y-90);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x<42 then
                                tempR <= Print_4(x-26, y-90);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x>=50 and x<114 then
                                tempR <= (others => '0');
                                tempG <= Print_Register(R4, x-50, y-90);
                                tempB <= (others => '0');
                            else
                                tempR <= (others => '0');
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            end if;
                        elsif y>=110 and y<126 then  -- R5
                            if x<26 then
                                tempR <= Print_R(x-10, y-110);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x<42 then
                                tempR <= Print_5(x-26, y-110);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x>=50 and x<114 then
                                tempR <= (others => '0');
                                tempG <= Print_Register(R5, x-50, y-110);
                                tempB <= (others => '0');
                            else
                                tempR <= (others => '0');
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            end if;
                        elsif y>=130 and y<146 then  -- R6
                            if x<26 then
                                tempR <= Print_R(x-10, y-130);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x<42 then
                                tempR <= Print_6(x-26, y-130);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x>=50 and x<114 then
                                tempR <= (others => '0');
                                tempG <= Print_Register(R6, x-50, y-130);
                                tempB <= (others => '0');
                            else
                                tempR <= (others => '0');
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            end if;
                        elsif y>=150 and y<166 then  -- R7
                            if x<26 then
                                tempR <= Print_R(x-10, y-150);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x<42 then
                                tempR <= Print_7(x-26, y-150);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x>=50 and x<114 then
                                tempR <= (others => '0');
                                tempG <= Print_Register(R7, x-50, y-150);
                                tempB <= (others => '0');
                            else
                                tempR <= (others => '0');
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            end if;
                        elsif y>=190 and y<206 then  -- IH
                            if x<26 then
                                tempR <= Print_I(x-10, y-190);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x<42 then
                                tempR <= Print_H(x-26, y-190);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x>=50 and x<114 then
                                tempR <= (others => '0');
                                tempG <= Print_Register(IH, x-50, y-190);
                                tempB <= (others => '0');
                            else
                                tempR <= (others => '0');
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            end if;
                        elsif y>=210 and y<226 then  -- SP
                            if x<26 then
                                tempR <= Print_S(x-10, y-210);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x<42 then
                                tempR <= Print_P(x-26, y-210);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x>=50 and x<114 then
                                tempR <= (others => '0');
                                tempG <= Print_Register(SP, x-50, y-210);
                                tempB <= (others => '0');
                            else
                                tempR <= (others => '0');
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            end if;
                        elsif y>=230 and y<246 then  -- T
                            if x<26 then
                                tempR <= Print_T(x-10, y-230);
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            elsif x>=50 and x<114 then
                                tempR <= (others => '0');
                                tempG <= Print_Register(T, x-50, y-230);
                                tempB <= (others => '0');
                            else
                                tempR <= (others => '0');
                                tempG <= (others => '0');
                                tempB <= (others => '0');
                            end if;
                        else
                            tempR <= (others => '0');
                            tempG <= (others => '0');
                            tempB <= (others => '0');
                        end if;
                    else
                        tempR <= (others => '0');
                        tempG <= (others => '0');
                        tempB <= (others => '0');
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
