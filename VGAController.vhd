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
           T : in std_logic_vector(15 downto 0);
           
           PC_RF_PC : in std_logic_vector(15 downto 0);
           IF_RF_INS : in std_logic_vector(15 downto 0);
           
           MEM_RF_Res : in std_logic_vector(15 downto 0) := "0000000000000000";
           EXE_RF_Res : in std_logic_vector(15 downto 0) := "0000000000000000"
           
           );
end VGAController;

architecture Behavioral of VGAController is
    component char_mem is
        Port ( clkA : in std_logic;
               AddrA : in std_logic_vector(10 downto 0);
               DoutA : out std_logic_vector(7 downto 0));
    end component;
    
    component lxh_mem is
        Port ( clkA : in std_logic;
               AddrA : in std_logic_vector(12 downto 0);
               DoutA : out std_logic_vector(15 downto 0));
    end component;
    
    component zz_mem is
        Port ( clkA : in std_logic;
               AddrA : in std_logic_vector(12 downto 0);
               DoutA : out std_logic_vector(15 downto 0));
    end component;

    component fifo_mem is
        Port ( wea : in std_logic_vector(0 downto 0);
               AddrA : in std_logic_vector(11 downto 0);
               DinA : in std_logic_vector(7 downto 0);
               clkA : in std_logic;
               AddrB : in std_logic_vector(11 downto 0);
               DoutB : out std_logic_vector(7 downto 0);
               clkB : in std_logic);
    end component;

    signal clk_2 : std_logic;
    signal cnt_10 : integer := 0;
    
    
    signal tempHs : std_logic;
    signal tempVs : std_logic;
    signal tempR : std_logic_vector(2 downto 0);
    signal tempG : std_logic_vector(2 downto 0);
    signal tempB : std_logic_vector(2 downto 0);
    signal x : std_logic_vector(9 downto 0);
    signal y : std_logic_vector(9 downto 0);
    
    constant half : std_logic_vector(2 downto 0) := "001";
    impure function print_register(input: std_logic_vector(15 downto 0))
    return std_logic_vector is
        variable tempG : std_logic_vector(2 downto 0) := (others => '0');
    begin
        if x<60 or (x>=100 and x<110) or (x>=150 and x<160) or (x>=200 and x<210) or x>=250 then
            tempG := "000";
        elsif (x>=60 and x<70 and input(15)='1') or (x>=70 and x<80 and input(14)='1') or 
              (x>=80 and x<90 and input(13)='1') or (x>=90 and x<100 and input(12)='1') or 
              (x>=110 and x<120 and input(11)='1') or (x>=120 and x<130 and input(10)='1') or 
              (x>=130 and x<140 and input(9)='1') or (x>=140 and x<150 and input(8)='1') or 
              (x>=160 and x<170 and input(7)='1') or (x>=170 and x<180 and input(6)='1') or 
              (x>=180 and x<190 and input(5)='1') or (x>=190 and x<200 and input(4)='1') or 
              (x>=210 and x<220 and input(3)='1') or (x>=220 and x<230 and input(2)='1') or 
              (x>=230 and x<240 and input(1)='1') or (x>=240 and x<250 and input(0)='1') then
            tempG := "111";
        else
            tempG := half;
        end if;
        return tempG;
    end print_register;
    
    
    -- Display Panel
    signal mode : std_logic_vector(1 downto 0) := "00";

    
    signal wctrl : std_logic_vector(1 downto 0) := "00";
--    signal waddr : std_logic_vector(10 downto 0) := (others => '0');
    signal wdata : std_logic_vector(7 downto 0);
    
    signal caddr : std_logic_vector(11 downto 0);
    signal caddr_origin : std_logic_vector(11 downto 0);
    signal char : std_logic_vector(7 downto 0);
    signal char_addr : std_logic_vector(10 downto 0);
    signal pr : std_logic_vector(7 downto 0);
    
    signal pic_addr : std_logic_vector(12 downto 0);
    signal lxh_pr : std_logic_vector(15 downto 0);
    signal zz_pr : std_logic_vector(15 downto 0);
    
    
    -- PS2
    signal ps2ready : std_logic_vector(0 downto 0) := "0";
    signal ps2newdata : std_logic := '0';
    
    signal data, clk1, clk2, clk3, check, fok, caps : std_logic := '0';
    signal code : std_logic_vector(7 downto 0);
    signal state : std_logic_vector(3 downto 0) := (others => '0');
    
    signal transData : std_logic_vector(7 downto 0) := (others => '0');
    signal rcdAddr : std_logic_vector(11 downto 0) := "111011001111";


    
    -- CPU
    signal R0, R1, R2, R3, R4, R5, R6, R7, IH, SP, T, PC : std_logic_vector(15 downto 0) := x"BF01";
    signal IF_RF_Ins, EXE_RF_Res, MEM_RF_Res : std_logic_vector(15 downto 0) := x"691A";
    signal newR, newDel, doDel : std_logic := '0';
begin
    
    LED <= mode;
    
    clk1 <= ps2clk when rising_edge(clk);
    clk2 <= clk1 when rising_edge(clk);
    clk3 <= (not clk1) and clk2;
    data <= ps2data when rising_edge(clk);
    check <= code(7) xor code(6) xor code(5) xor code(4) xor code(3) xor code(2) xor code(1) xor code(0) xor '1';
   
    process(clk, rst, clr)
        variable tempAddr : std_logic_vector(11 downto 0) := (others => '0');
        variable ttd : std_logic_vector(7 downto 0) := (others => '0');
        variable invalid : std_logic := '0';
        
        
        function get_ascii(input: std_logic_vector(3 downto 0))
        return std_logic_vector is
            variable temp_ascii : std_logic_vector(7 downto 0) := (others => '0');
        begin
            case input is
                when x"0" => 
                    temp_ascii := x"30";
                when x"1" => 
                    temp_ascii := x"31";
                when x"2" => 
                    temp_ascii := x"32";
                when x"3" => 
                    temp_ascii := x"33";
                when x"4" => 
                    temp_ascii := x"34";
                when x"5" => 
                    temp_ascii := x"35";
                when x"6" => 
                    temp_ascii := x"36";
                when x"7" => 
                    temp_ascii := x"37";
                when x"8" => 
                    temp_ascii := x"38";
                when x"9" => 
                    temp_ascii := x"39";
                when x"A" => 
                    temp_ascii := x"41";
                when x"B" => 
                    temp_ascii := x"42";
                when x"C" => 
                    temp_ascii := x"43";
                when x"D" => 
                    temp_ascii := x"44";
                when x"E" => 
                    temp_ascii := x"45";
                when x"F" => 
                    temp_ascii := x"46";
                when others => 
                    temp_ascii := (others => '0');
            end case;
            return temp_ascii;
        end get_ascii;
        
    begin
        if rst='0' then
            state <= "0000";
            code <= (others => '0');
            fok <= '0';
        elsif clr='0' then
            state <= "0000";
            code <= (others => '0');
            fok <= '0';
            rcdAddr <= "111011001111";
        elsif clk'event and clk='1' then
            case state is
                when "0000" =>  -- delay
                    state <= "0001";
                when "0001" =>  -- start
                    if clk3='1' then
                        if data='0' then
                            state <= "0010";
                        else
                            state <= "0000";
                        end if;
                    end if;
                when "0010" =>  -- d0
                    if clk3='1' then
                        code(0) <= data;
                        state <= "0011";
                    end if;
                when "0011" =>  -- d1
                    if clk3='1' then
                        code(1) <= data;
                        state <= "0100";
                    end if;
                when "0100" =>  -- d2
                    if clk3='1' then
                        code(2) <= data;
                        state <= "0101";
                    end if;
                when "0101" =>  -- d3
                    if clk3='1' then
                        code(3) <= data;
                        state <= "0110";
                    end if;
                when "0110" =>  -- d4
                    if clk3='1' then
                        code(4) <= data;
                        state <= "0111";
                    end if;
                when "0111" =>  -- d5
                    if clk3='1' then
                        code(5) <= data;
                        state <= "1000";
                    end if;
                when "1000" =>  -- d6
                    if clk3='1' then
                        code(6) <= data;
                        state <= "1001";
                    end if;
                when "1001" =>  -- d7
                    if clk3='1' then
                        code(7) <= data;
                        state <= "1010";
                    end if;
                when "1010" =>  -- parity
                    if clk3='1' then
                        if data=check then
                            state <= "1011";
                        else
                            state <= "0000";
                        end if;
                    end if;
                when "1011" =>  -- stop
                    if clk3='1' then
                        if data='1' then
                            state <= "1100";
                        else
                            state <= "0000";
                        end if;
                    end if;
                when "1100" =>  -- finish
                    state <= "0000";
                    if fok='1' then
                        wdata <= code;
                        fok <= '0';
                        ps2newdata <= '1';
--                        LED <= code;
                    end if;
                    if code=x"F0" then
                        fok <= '1';
                    end if;
                when others => 
                    state <= "0000";
            end case;
            
            if cnt_10=1000000 then
                cnt_10 <= 0;
                if ps2newdata='1' then
                    ps2newdata <= '0';
                    ps2ready <= "1";
                    
                    invalid := '0';
                    tempAddr := rcdAddr;
                    
                    case wdata is
                        when x"29" => ttd := x"20";  -- space
                        when x"52" => ttd := x"27";  -- '
                        when x"41" => ttd := x"2C";  -- ,
                        when x"7B" => ttd := x"2D";  -- -
                        when x"4E" => ttd := x"2D";  -- strange -
                        when x"49" => ttd := x"2E";  -- .
                        when x"4A" => ttd := x"2F";  -- /
                        when x"4C" => ttd := x"3B";  -- ;
                        when x"45" => ttd := x"30";  -- 0
                        when x"16" => ttd := x"31";  -- 1
                        when x"1E" => ttd := x"32";  -- 2
                        when x"26" => ttd := x"33";  -- 3
                        when x"25" => ttd := x"34";  -- 4
                        when x"2E" => ttd := x"35";  -- 5
                        when x"36" => ttd := x"36";  -- 6
                        when x"3D" => ttd := x"37";  -- 7
                        when x"3E" => ttd := x"38";  -- 8
                        when x"46" => ttd := x"39";  -- 9
                        when x"55" => ttd := x"3D";  -- =
                        when x"54" => ttd := x"5B";  -- [
                        when x"5D" => ttd := x"5C";  -- \
                        when x"5B" => ttd := x"5D";  -- ]
                        when x"1C" => ttd := x"61";  -- a
                        when x"32" => ttd := x"62";  -- b
                        when x"21" => ttd := x"63";  -- c
                        when x"23" => ttd := x"64";  -- d
                        when x"24" => ttd := x"65";  -- e
                        when x"2B" => ttd := x"66";  -- f
                        when x"34" => ttd := x"67";  -- g
                        when x"33" => ttd := x"68";  -- h
                        when x"43" => ttd := x"69";  -- i
                        when x"3B" => ttd := x"6A";  -- j
                        when x"42" => ttd := x"6B";  -- k
                        when x"4B" => ttd := x"6C";  -- l
                        when x"3A" => ttd := x"6D";  -- m
                        when x"31" => ttd := x"6E";  -- n
                        when x"44" => ttd := x"6F";  -- o
                        when x"4D" => ttd := x"70";  -- p
                        when x"15" => ttd := x"71";  -- q
                        when x"2D" => ttd := x"72";  -- r
                        when x"1B" => ttd := x"73";  -- s
                        when x"2C" => ttd := x"74";  -- t
                        when x"3C" => ttd := x"75";  -- u
                        when x"2A" => ttd := x"76";  -- v
                        when x"1D" => ttd := x"77";  -- w
                        when x"22" => ttd := x"78";  -- x
                        when x"35" => ttd := x"79";  -- y
                        when x"1A" => ttd := x"7A";  -- z
                        when others => 
                            ps2ready <= "0";
                            invalid := '1';
                    end case;
                    
                    
                    
                    if code=x"5A" then  -- enter
                        if tempAddr(6 downto 0)=79 then
                            if tempAddr(11 downto 7)=29 then
                                tempAddr(11 downto 7) := (others => '0');
                            else
                                tempAddr(11 downto 7) := tempAddr(11 downto 7) + 1;
                            end if;
                        else
                            tempAddr(6 downto 0) := "1001111";
                        end if;
                    elsif code=x"75" then  -- U arrow
                        if tempAddr(11 downto 7)=0 then
                            tempAddr(11 downto 7) := "11101";
                        else
                            tempAddr(11 downto 7) := tempAddr(11 downto 7) - 1;
                        end if;
                    elsif code=x"72" then  -- D arrow
                        if tempAddr(11 downto 7)=29 then
                            tempAddr(11 downto 7) := (others => '0');
                        else
                            tempAddr(11 downto 7) := tempAddr(11 downto 7) + 1;
                        end if;
                    elsif code=x"6B" then  -- L arrow
                        if tempAddr(6 downto 0)=0 then
                            tempAddr(6 downto 0) := "1001111";
                            if tempAddr(11 downto 7)=0 then
                                tempAddr(11 downto 7) := "11101";
                            else
                                tempAddr(11 downto 7) := tempAddr(11 downto 7) - 1;
                            end if;
                        else
                            tempAddr(6 downto 0) := tempAddr(6 downto 0) - 1;
                        end if;
                    elsif code=x"74" then  -- R arrow
                        if tempAddr(6 downto 0)=79 then
                            tempAddr(6 downto 0) := (others => '0');
                            if tempAddr(11 downto 7)=29 then
                                tempAddr(11 downto 7) := (others => '0');
                            else
                                tempAddr(11 downto 7) := tempAddr(11 downto 7) + 1;
                            end if;
                        else
                            tempAddr(6 downto 0) := tempAddr(6 downto 0) + 1;
                        end if;
                    elsif code=x"0D" then  -- Tab
                        if caps='0' then
                            if tempAddr(6 downto 0)>75 then
                                tempAddr(6 downto 0) := tempAddr(6 downto 0) - 76;
                                if tempAddr(11 downto 7)=29 then
                                    tempAddr(11 downto 7) := (others => '0');
                                else
                                    tempAddr(11 downto 7) := tempAddr(11 downto 7) + 1;
                                end if;
                            else
                                tempAddr(6 downto 0) := tempAddr(6 downto 0) + 4;
                            end if;
                        elsif caps='1' then  -- Shift Tab
                            if tempAddr(6 downto 0)<4 then
                                tempAddr(6 downto 0) := tempAddr(6 downto 0) + 76;
                                if tempAddr(11 downto 7)=0 then
                                    tempAddr(11 downto 7) := "11101";
                                else
                                    tempAddr(11 downto 7) := tempAddr(11 downto 7) - 1;
                                end if;
                            else
                                tempAddr(6 downto 0) := tempAddr(6 downto 0) - 4;
                            end if;
                        end if;
                    elsif code=x"69" then  -- End
                        if tempAddr(6 downto 0)=79 then
                            tempAddr(6 downto 0) := "1001110";
                            if tempAddr(11 downto 7)=29 then
                                tempAddr(11 downto 7) := (others => '0');
                            else
                                tempAddr(11 downto 7) := tempAddr(11 downto 7) + 1;
                            end if;
                        else
                            tempAddr(6 downto 0) := "1001110";
                        end if;
                    elsif code=x"6C" then  -- Head
                        if tempAddr(6 downto 0)/=79 then
                            if tempAddr(11 downto 7)=0 then
                                tempAddr(11 downto 7) := "11101";
                            else
                                tempAddr(11 downto 7) := tempAddr(11 downto 7) - 1;
                            end if;
                        end if;
                        tempAddr(6 downto 0) := "1001111";
                    elsif code=x"7A" then  -- Page Down
                        if tempAddr(11 downto 7)>25 then
                            tempAddr(11 downto 7) := tempAddr(11 downto 7) - 26;
                        else
                            tempAddr(11 downto 7) := tempAddr(11 downto 7) + 4;
                        end if;
                    elsif code=x"7D" then  -- Page Up
                        tempAddr := rcdAddr;
                        if tempAddr(11 downto 7)<4 then
                            tempAddr(11 downto 7) := tempAddr(11 downto 7) + 26;
                        else
                            tempAddr(11 downto 7) := tempAddr(11 downto 7) - 4;
                        end if;
                    elsif code=x"11" then  -- Alt
                        if mode=0 then
                            mode <= "11";
                        else
                            mode <= mode - 1;
                        end if;
                    elsif code=x"14" then  -- Ctrl
                        if mode=3 then
                            mode <= "00";
                        else
                            mode <= mode + 1;
                        end if;
                    elsif invalid='0' then
                        tempAddr := rcdAddr + 1;
                        if tempAddr(6 downto 0)>=80 then
                            tempAddr(6 downto 0) := (others => '0');
                            tempAddr(11 downto 7) := tempAddr(11 downto 7) + 1;
                        end if;
                        if tempAddr(11 downto 7)>=30 then
                            tempAddr(11 downto 7) := (others => '0');
                        end if;
                        if caps='1' then
                            if ttd>=97 and ttd<123 then
                                ttd := ttd - x"20";
                            else
                                case ttd is
                                    when x"27" => ttd := x"22";  -- "
                                    when x"2C" => ttd := x"3C";  -- <
                                    when x"2D" => ttd := x"5F";  -- _
                                    when x"2E" => ttd := x"3E";  -- >
                                    when x"2F" => ttd := x"3F";  -- ?
                                    when x"3B" => ttd := x"3A";  -- :
                                    when x"30" => ttd := x"29";  -- )
                                    when x"31" => ttd := x"21";  -- !
                                    when x"32" => ttd := x"40";  -- @
                                    when x"33" => ttd := x"23";  -- #
                                    when x"34" => ttd := x"24";  -- $
                                    when x"35" => ttd := x"25";  -- %
                                    when x"36" => ttd := x"5E";  -- ^
                                    when x"37" => ttd := x"26";  -- &
                                    when x"38" => ttd := x"2A";  -- *
                                    when x"39" => ttd := x"28";  -- (
                                    when x"3D" => ttd := x"2B";  -- +
                                    when x"5B" => ttd := x"7B";  -- {
                                    when x"5C" => ttd := x"7C";  -- |
                                    when x"5D" => ttd := x"7D";  -- }
                                    when others => null;
                                end case;
                            end if;
                        end if;
                    end if;
                    
                    -- Note: This 'if mode=3' statement constraints addr change, so only these things can be placed above.
                    --       Other changes such as caps, should be written explicitly here. 
                    if mode=3 then
                        if code=x"1F" or code=x"27" then  -- Left GUI, Right GUI  -- CMD Registers
                            ps2ready <= "0";
                            newR <= '1';
                            tempAddr := rcdAddr + 1;
                            if tempAddr(6 downto 0)>=80 then
                                tempAddr(6 downto 0) := (others => '0');
                                tempAddr(11 downto 7) := tempAddr(11 downto 7) + 1;
                            end if;
                            if tempAddr(11 downto 7)>=30 then
                                tempAddr(11 downto 7) := (others => '0');
                            end if;
                        elsif code=x"58" or code=x"12" or code=x"59" then  -- CAPS, Left Shift, Right Shift
                            caps <= not caps;
                        end if;
                        if code=x"71" then  -- Del
                            if newDel='1' then
                                doDel <= '1';
                                ps2ready <= "0";
                                newDel <= '0';
                                tempAddr := rcdAddr;
                                if tempAddr(6 downto 0)=79 then
                                    tempAddr(6 downto 0) := (others => '0');
                                    if tempAddr(11 downto 7)=29 then
                                        tempAddr(11 downto 7) := (others => '0');
                                    else
                                        tempAddr(11 downto 7) := tempAddr(11 downto 7) + 1;
                                    end if;
                                end if;
                            else
                                newDel <= '1';
                            end if;
                        else
                            newDel <= '0';
                        end if;
                        rcdAddr <= tempAddr;
                    else
                        ps2ready <= "0";
                    end if;
                    
                    transData <= ttd;
                end if;
            else
            
                if mode=3 then
            
                    if newR='1' and cnt_10<=160 then
                    
                        if cnt_10=0 then
                            transData <= x"52";  -- 'R'
                        elsif cnt_10=1 then
                            transData <= x"30";  -- '0'
                        elsif cnt_10=2 then
                            transData <= x"20";  -- space
                        elsif cnt_10=3 then
                            transData <= get_ascii(R0(15 downto 12));
                        elsif cnt_10=4 then
                            transData <= get_ascii(R0(11 downto 8));
                        elsif cnt_10=5 then
                            transData <= get_ascii(R0(7 downto 4));
                        elsif cnt_10=6 then
                            transData <= get_ascii(R0(3 downto 0));
                        elsif cnt_10=7 then
                            transData <= x"20";  -- space
                        elsif cnt_10=8 then
                            transData <= x"20";  -- space
                        elsif cnt_10=9 then
                            transData <= x"20";  -- space
                        elsif cnt_10=10 then
                            transData <= x"20";  -- space
                        elsif cnt_10=11 then
                            transData <= x"20";  -- space
                        elsif cnt_10=12 then
                            transData <= x"52";  -- 'R'
                        elsif cnt_10=13 then
                            transData <= x"31";  -- '1'
                        elsif cnt_10=14 then
                            transData <= x"20";  -- space
                        elsif cnt_10=15 then
                            transData <= get_ascii(R1(15 downto 12));
                        elsif cnt_10=16 then
                            transData <= get_ascii(R1(11 downto 8));
                        elsif cnt_10=17 then
                            transData <= get_ascii(R1(7 downto 4));
                        elsif cnt_10=18 then
                            transData <= get_ascii(R1(3 downto 0));
                        elsif cnt_10=19 then
                            transData <= x"20";  -- space
                        elsif cnt_10=20 then
                            transData <= x"20";  -- space
                        elsif cnt_10=21 then
                            transData <= x"20";  -- space
                        elsif cnt_10=22 then
                            transData <= x"20";  -- space
                        elsif cnt_10=23 then
                            transData <= x"20";  -- space
                        elsif cnt_10=24 then
                            transData <= x"52";  -- 'R'
                        elsif cnt_10=25 then
                            transData <= x"32";  -- '2'
                        elsif cnt_10=26 then
                            transData <= x"20";  -- space
                        elsif cnt_10=27 then
                            transData <= get_ascii(R2(15 downto 12));
                        elsif cnt_10=28 then
                            transData <= get_ascii(R2(11 downto 8));
                        elsif cnt_10=29 then
                            transData <= get_ascii(R2(7 downto 4));
                        elsif cnt_10=30 then
                            transData <= get_ascii(R2(3 downto 0));
                        elsif cnt_10=31 then
                            transData <= x"20";  -- space
                        elsif cnt_10=32 then
                            transData <= x"20";  -- space
                        elsif cnt_10=33 then
                            transData <= x"20";  -- space
                        elsif cnt_10=34 then
                            transData <= x"20";  -- space
                        elsif cnt_10=35 then
                            transData <= x"20";  -- space
                        elsif cnt_10=36 then
                            transData <= x"52";  -- 'R'
                        elsif cnt_10=37 then
                            transData <= x"33";  -- '3'
                        elsif cnt_10=38 then
                            transData <= x"20";  -- space
                        elsif cnt_10=39 then
                            transData <= get_ascii(R3(15 downto 12));
                        elsif cnt_10=40 then
                            transData <= get_ascii(R3(11 downto 8));
                        elsif cnt_10=41 then
                            transData <= get_ascii(R3(7 downto 4));
                        elsif cnt_10=42 then
                            transData <= get_ascii(R3(3 downto 0));
                        elsif cnt_10=43 then
                            transData <= x"20";  -- space
                        elsif cnt_10=44 then
                            transData <= x"20";  -- space
                        elsif cnt_10=45 then
                            transData <= x"20";  -- space
                        elsif cnt_10=46 then
                            transData <= x"20";  -- space
                        elsif cnt_10=47 then
                            transData <= x"20";  -- space
                        elsif cnt_10=48 then
                            transData <= x"20";  -- space
                        elsif cnt_10=49 then
                            transData <= x"20";  -- space
                        elsif cnt_10=50 then
                            transData <= x"20";  -- space
                        elsif cnt_10=51 then
                            transData <= x"20";  -- space
                        elsif cnt_10=52 then
                            transData <= x"20";  -- space
                        elsif cnt_10=53 then
                            transData <= x"20";  -- space
                        elsif cnt_10=54 then
                            transData <= x"20";  -- space
                        elsif cnt_10=55 then
                            transData <= x"20";  -- space
                        elsif cnt_10=56 then
                            transData <= x"20";  -- space
                        elsif cnt_10=57 then
                            transData <= x"20";  -- space
                        elsif cnt_10=58 then
                            transData <= x"20";  -- space
                        elsif cnt_10=59 then
                            transData <= x"20";  -- space
                        elsif cnt_10=60 then
                            transData <= x"20";  -- space
                        elsif cnt_10=61 then
                            transData <= x"49";  -- 'I'
                        elsif cnt_10=62 then
                            transData <= x"48";  -- 'H'
                        elsif cnt_10=63 then
                            transData <= x"20";  -- space
                        elsif cnt_10=64 then
                            transData <= get_ascii(IH(15 downto 12));
                        elsif cnt_10=65 then
                            transData <= get_ascii(IH(11 downto 8));
                        elsif cnt_10=66 then
                            transData <= get_ascii(IH(7 downto 4));
                        elsif cnt_10=67 then
                            transData <= get_ascii(IH(3 downto 0));
                        elsif cnt_10=68 then
                            transData <= x"20";  -- space
                        elsif cnt_10=69 then
                            transData <= x"20";  -- space
                        elsif cnt_10=70 then
                            transData <= x"20";  -- space
                        elsif cnt_10=71 then
                            transData <= x"20";  -- space
                        elsif cnt_10=72 then
                            transData <= x"20";  -- space
                        elsif cnt_10=73 then
                            transData <= x"53";  -- 'S'
                        elsif cnt_10=74 then
                            transData <= x"50";  -- 'P'
                        elsif cnt_10=75 then
                            transData <= x"20";  -- space
                        elsif cnt_10=76 then
                            transData <= get_ascii(SP(15 downto 12));
                        elsif cnt_10=77 then
                            transData <= get_ascii(SP(11 downto 8));
                        elsif cnt_10=78 then
                            transData <= get_ascii(SP(7 downto 4));
                        elsif cnt_10=79 then
                            transData <= get_ascii(SP(3 downto 0));
                        elsif cnt_10=80 then
                            transData <= x"52";  -- 'R'
                        elsif cnt_10=81 then
                            transData <= x"34";  -- '4'
                        elsif cnt_10=82 then
                            transData <= x"20";  -- space
                        elsif cnt_10=83 then
                            transData <= get_ascii(R4(15 downto 12));
                        elsif cnt_10=84 then
                            transData <= get_ascii(R4(11 downto 8));
                        elsif cnt_10=85 then
                            transData <= get_ascii(R4(7 downto 4));
                        elsif cnt_10=86 then
                            transData <= get_ascii(R4(3 downto 0));
                        elsif cnt_10=87 then
                            transData <= x"20";  -- space
                        elsif cnt_10=88 then
                            transData <= x"20";  -- space
                        elsif cnt_10=89 then
                            transData <= x"20";  -- space
                        elsif cnt_10=90 then
                            transData <= x"20";  -- space
                        elsif cnt_10=91 then
                            transData <= x"20";  -- space
                        elsif cnt_10=92 then
                            transData <= x"52";  -- 'R'
                        elsif cnt_10=93 then
                            transData <= x"35";  -- '5'
                        elsif cnt_10=94 then
                            transData <= x"20";  -- space
                        elsif cnt_10=95 then
                            transData <= get_ascii(R5(15 downto 12));
                        elsif cnt_10=96 then
                            transData <= get_ascii(R5(11 downto 8));
                        elsif cnt_10=97 then
                            transData <= get_ascii(R5(7 downto 4));
                        elsif cnt_10=98 then
                            transData <= get_ascii(R5(3 downto 0));
                        elsif cnt_10=99 then
                            transData <= x"20";  -- space
                        elsif cnt_10=100 then
                            transData <= x"20";  -- space
                        elsif cnt_10=101 then
                            transData <= x"20";  -- space
                        elsif cnt_10=102 then
                            transData <= x"20";  -- space
                        elsif cnt_10=103 then
                            transData <= x"20";  -- space
                        elsif cnt_10=104 then
                            transData <= x"52";  -- 'R'
                        elsif cnt_10=105 then
                            transData <= x"36";  -- '6'
                        elsif cnt_10=106 then
                            transData <= x"20";  -- space
                        elsif cnt_10=107 then
                            transData <= get_ascii(R6(15 downto 12));
                        elsif cnt_10=108 then
                            transData <= get_ascii(R6(11 downto 8));
                        elsif cnt_10=109 then
                            transData <= get_ascii(R6(7 downto 4));
                        elsif cnt_10=110 then
                            transData <= get_ascii(R6(3 downto 0));
                        elsif cnt_10=111 then
                            transData <= x"20";  -- space
                        elsif cnt_10=112 then
                            transData <= x"20";  -- space
                        elsif cnt_10=113 then
                            transData <= x"20";  -- space
                        elsif cnt_10=114 then
                            transData <= x"20";  -- space
                        elsif cnt_10=115 then
                            transData <= x"20";  -- space
                        elsif cnt_10=116 then
                            transData <= x"52";  -- 'R'
                        elsif cnt_10=117 then
                            transData <= x"37";  -- '7'
                        elsif cnt_10=118 then
                            transData <= x"20";  -- space
                        elsif cnt_10=119 then
                            transData <= get_ascii(R7(15 downto 12));
                        elsif cnt_10=120 then
                            transData <= get_ascii(R7(11 downto 8));
                        elsif cnt_10=121 then
                            transData <= get_ascii(R7(7 downto 4));
                        elsif cnt_10=122 then
                            transData <= get_ascii(R7(3 downto 0));
                        elsif cnt_10=123 then
                            transData <= x"20";  -- space
                        elsif cnt_10=124 then
                            transData <= x"20";  -- space
                        elsif cnt_10=125 then
                            transData <= x"20";  -- space
                        elsif cnt_10=126 then
                            transData <= x"20";  -- space
                        elsif cnt_10=127 then
                            transData <= x"20";  -- space
                        elsif cnt_10=128 then
                            transData <= x"20";  -- space
                        elsif cnt_10=129 then
                            transData <= x"20";  -- space
                        elsif cnt_10=130 then
                            transData <= x"20";  -- space
                        elsif cnt_10=131 then
                            transData <= x"20";  -- space
                        elsif cnt_10=132 then
                            transData <= x"20";  -- space
                        elsif cnt_10=133 then
                            transData <= x"20";  -- space
                        elsif cnt_10=134 then
                            transData <= x"20";  -- space
                        elsif cnt_10=135 then
                            transData <= x"20";  -- space
                        elsif cnt_10=136 then
                            transData <= x"20";  -- space
                        elsif cnt_10=137 then
                            transData <= x"20";  -- space
                        elsif cnt_10=138 then
                            transData <= x"20";  -- space
                        elsif cnt_10=139 then
                            transData <= x"20";  -- space
                        elsif cnt_10=140 then
                            transData <= x"20";  -- space
                        elsif cnt_10=141 then
                            transData <= x"20";  -- 'space'
                        elsif cnt_10=142 then
                            transData <= x"54";  -- 'T'
                        elsif cnt_10=143 then
                            transData <= x"20";  -- space
                        elsif cnt_10=144 then
                            transData <= get_ascii(T(15 downto 12));
                        elsif cnt_10=145 then
                            transData <= get_ascii(T(11 downto 8));
                        elsif cnt_10=146 then
                            transData <= get_ascii(T(7 downto 4));
                        elsif cnt_10=147 then
                            transData <= get_ascii(T(3 downto 0));
                        elsif cnt_10=148 then
                            transData <= x"20";  -- space
                        elsif cnt_10=149 then
                            transData <= x"20";  -- space
                        elsif cnt_10=150 then
                            transData <= x"20";  -- space
                        elsif cnt_10=151 then
                            transData <= x"20";  -- space
                        elsif cnt_10=152 then
                            transData <= x"20";  -- space
                        elsif cnt_10=153 then
                            transData <= x"50";  -- 'P'
                        elsif cnt_10=154 then
                            transData <= x"43";  -- 'C'
                        elsif cnt_10=155 then
                            transData <= x"20";  -- space
                        elsif cnt_10=156 then
                            transData <= get_ascii(PC(15 downto 12));
                        elsif cnt_10=157 then
                            transData <= get_ascii(PC(11 downto 8));
                        elsif cnt_10=158 then
                            transData <= get_ascii(PC(7 downto 4));
                        elsif cnt_10=159 then
                            transData <= get_ascii(PC(3 downto 0));
                        end if;
                        
                        if cnt_10=0 then
                            tempAddr := rcdAddr;
                            tempAddr(6 downto 0) := (others => '0');
                            if tempAddr(11 downto 7)=29 then
                                tempAddr(11 downto 7) := (others => '0');
                            else
                                tempAddr(11 downto 7) := tempAddr(11 downto 7) + 1;
                            end if;
                            rcdAddr <= tempAddr;
                        elsif cnt_10=80 then
                            tempAddr := rcdAddr;
                            tempAddr(6 downto 0) := (others => '0');
                            if tempAddr(11 downto 7)=29 then
                                tempAddr(11 downto 7) := (others => '0');
                            else
                                tempAddr(11 downto 7) := tempAddr(11 downto 7) + 1;
                            end if;
                            rcdAddr <= tempAddr;
                        elsif cnt_10<160 then
                            rcdAddr <= rcdAddr + 1;
                        end if;
                        if cnt_10=160 then
                            ps2ready <= "0";
                            newR <= '0';
                        elsif cnt_10<160 then
                            ps2ready <= "1";
                        end if;
                        
                    elsif doDel='1' then
                    
                        if caps='0' and cnt_10<=80 then
                    
                            if cnt_10<80 then
                                transData <= x"20";  -- space
                            end if;
                        
                            if cnt_10=0 then
                                tempAddr := rcdAddr;
                                tempAddr(6 downto 0) := (others => '0');
                                rcdAddr <= tempAddr;
                            elsif cnt_10=80 then
                                tempAddr := rcdAddr;
                                if tempAddr(11 downto 7)=0 then
                                    tempAddr(11 downto 7) := "11101";
                                else
                                    tempAddr(11 downto 7) := tempAddr(11 downto 7) - 1;
                                end if;
                                rcdAddr <= tempAddr;
                            elsif cnt_10<80 then
                                rcdAddr <= rcdAddr + 1;
                            end if;
                        
                            if cnt_10=80 then
                                ps2ready <= "0";
                                doDel <= '0';
                            else
                                ps2ready <= "1";
                            end if;
                        
                        elsif caps='1' and cnt_10<=2400 then
                            
                            if cnt_10<2400 then
                                transData <= x"20";
                            end if;
                            
                            if cnt_10=0 then
                                rcdAddr <= (others => '0');
                            elsif cnt_10=80 or cnt_10=160 or cnt_10=240 or cnt_10=320 or cnt_10=400 or 
                                  cnt_10=480 or cnt_10=560 or cnt_10=640 or cnt_10=720 or cnt_10=800 or 
                                  cnt_10=880 or cnt_10=960 or cnt_10=1040 or cnt_10=1120 or cnt_10=1200 or 
                                  cnt_10=1280 or cnt_10=1360 or cnt_10=1440 or cnt_10=1520 or cnt_10=1600 or 
                                  cnt_10=1680 or cnt_10=1760 or cnt_10=1840 or cnt_10=1920 or cnt_10=2000 or 
                                  cnt_10=2080 or cnt_10=2160 or cnt_10=2240 or cnt_10=2320 then
                                tempAddr := rcdAddr;
                                tempAddr(6 downto 0) := (others => '0');
                                tempAddr(11 downto 7) := tempAddr(11 downto 7) + 1;
                                rcdAddr <= tempAddr;
                            elsif cnt_10=2400 then
                                rcdAddr <= "111011001111";
                            elsif cnt_10<2400 then
                                rcdAddr <= rcdAddr + 1;
                            end if;
                        
                            if cnt_10=2400 then
                                ps2ready <= "0";
                                doDel <= '0';
                                caps <= '0';
                            else
                                ps2ready <= "1";
                            end if;
                        
                        end if;
                        
                    end if;
                else  -- mode/="11"
                    if cnt_10=0 then
                        ps2ready <= "0";
                    end if;
--                    cnt_10 <= cnt_10 + 1;
                end if;
                cnt_10 <= cnt_10 + 1;
            end if;
        end if;     
    end process;
    
    
    
    
    -- VGA
    process(x, y)
        variable tx : std_logic_vector(9 downto 0);
    begin
        tx := x + 1;
        caddr <= y(8 downto 4) & tx(9 downto 3);
    end process;
    
    caddr_origin <= y(8 downto 4) & x(9 downto 3);
    char_addr <= char(6 downto 0) & y(3 downto 0);
    
    pic_addr <= y(8 downto 3) & x(9 downto 3);
    
    Process_Char_MEM: char_mem
    port map (
        clkA => clk,
        AddrA => char_addr,
        DoutA => pr
    );
    
    Process_LXH_MEM: lxh_mem
    port map (
        clkA => clk,
        AddrA => pic_addr,
        DoutA => lxh_pr
    );
    
    Process_ZZ_MEM: zz_mem
    port map (
        clkA => clk,
        AddrA => pic_addr,
        DoutA => zz_pr
    );

    Process_FIFO_MEM: fifo_mem
    port map (
        wea => ps2ready,
        AddrA => rcdAddr,
        DinA => transData,
        clkA => clk,
        AddrB => caddr,
        DoutB => char,
        clkB => clk
    );

    -- Frequency Division
    process(clk)
    begin
        if clk'event and clk='1' then
            clk_2 <= not clk_2;
        end if;
    end process;
    
    -- H scan pixels 800
    process(clk_2, rst)
    begin
        if rst='0' then
            x <= (others => '0');
        elsif clk_2'event and clk_2='1' then
            if x=799 then
                x <= (others => '0');
            else
                x <= x + 1;
            end if;
        end if;
    end process;
    
    -- V scan pixels 525 dependent on H pixels
    process(clk_2, rst)
    begin
        if rst='0' then
            y <= (others => '0');
        elsif clk_2'event and clk_2='1' then
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
    process(clk_2, rst)
    begin
        if rst='0' then
            tempHs <= '0';
        elsif clk_2'event and clk_2='1' then
            if x>=656 and x<752 then
                tempHs <= '0';
            else
                tempHs <= '1';
            end if;
        end if;
    end process;
    
    -- Vs down in [490, 492)
    process(clk_2, rst)
    begin
        if rst='0' then
            tempVs <= '0';
        elsif clk_2'event and clk_2='1' then
            if y>=490 and y<492 then
                tempVs <= '0';
            else
                tempVs <= '1';
            end if;
        end if;
    end process;
    
    -- Hs output
    process(clk_2, rst)
    begin
        if rst='0' then
            Hs <= '0';
        elsif clk_2'event and clk_2='1' then
            Hs <= tempHs;
        end if;
    end process;
    
    -- Vs output
    process(clk_2, rst)
    begin
        if rst='0' then
            Vs <= '0';
        elsif clk_2'event and clk_2='1' then
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
    process(clk_2, rst, x, y)
    begin
		if rst='0' then
            tempR <= (others => '0');
            tempG <= (others => '0');
            tempB <= (others => '0');
        else
            if clk_2'event and clk_2='1' then
                if x>=640 or y>=480 then
                    tempR <= (others => '0');
                    tempG <= (others => '0');
                    tempB <= (others => '0');
                else
                    case mode is
                        when "00" => 
                            tempR <= lxh_pr(10 downto 8);
                            tempG <= lxh_pr(6 downto 4);
                            tempB <= lxh_pr(2 downto 0);
                        when "01" => 
                            tempR <= zz_pr(10 downto 8);
                            tempG <= zz_pr(6 downto 4);
                            tempB <= zz_pr(2 downto 0);
                        when "10" => 
                            if y>=10 and y<20 then
                                if x>=10 and x<50 then
                                    tempR <= half;
                                else
                                    tempR <= (others => '0');
                                end if;
                                tempG <= print_register(R0);
                            elsif y>=30 and y<40 then
                                if x>=10 and x<40 then
                                    tempR <= half;
                                elsif x>=40 and x<50 then
                                    tempR <= (others => '1');
                                else
                                    tempR <= (others => '0');
                                end if;
                                tempG <= print_register(R1);
                            elsif y>=50 and y<60 then
                                if (x>=10 and x<30) or (x>=40 and x<50) then
                                    tempR <= half;
                                elsif x>=30 and x<40 then
                                    tempR <= (others => '1');
                                else
                                    tempR <= (others => '0');
                                end if;
                                tempG <= print_register(R2);
                            elsif y>=70 and y<80 then
                                if x>=10 and x<30 then
                                    tempR <= half;
                                elsif x>=30 and x<50 then
                                    tempR <= (others => '1');
                                else
                                    tempR <= (others => '0');
                                end if;
                                tempG <= print_register(R3);
                            elsif y>=90 and y<100 then
                                if (x>=10 and x<20) or (x>=30 and x<50) then
                                    tempR <= half;
                                elsif x>=20 and x<30 then
                                    tempR <= (others => '1');
                                else
                                    tempR <= (others => '0');
                                end if;
                                tempG <= print_register(R4);
                            elsif y>=110 and y<120 then
                                if (x>=10 and x<20) or (x>=30 and x<40) then
                                    tempR <= half;
                                elsif (x>=20 and x<30) or (x>=40 and x<50) then
                                    tempR <= (others => '1');
                                else
                                    tempR <= (others => '0');
                                end if;
                                tempG <= print_register(R5);
                            elsif y>=130 and y<140 then
                                if (x>=10 and x<20) or (x>=40 and x<50) then
                                    tempR <= half;
                                elsif x>=20 and x<40 then
                                    tempR <= (others => '1');
                                else
                                    tempR <= (others => '0');
                                end if;
                                tempG <= print_register(R6);
                            elsif y>=150 and y<160 then
                                if x>=10 and x<20 then
                                    tempR <= half;
                                elsif x>=20 and x<50 then
                                    tempR <= (others => '1');
                                else
                                    tempR <= (others => '0');
                                end if;
                                tempG <= print_register(R7);
                            elsif y>=190 and y<200 then
                                if x>=20 and x<50 then
                                    tempR <= half;
                                elsif x>=10 and x<20 then
                                    tempR <= (others => '1');
                                else
                                    tempR <= (others => '0');
                                end if;
                                tempG <= print_register(IH);
                            elsif y>=210 and y<220 then
                                if x>=20 and x<40 then
                                    tempR <= half;
                                elsif (x>=10 and x<20) or (x>=40 and x<50) then
                                    tempR <= (others => '1');
                                else
                                    tempR <= (others => '0');
                                end if;
                                tempG <= print_register(SP);
                            elsif y>=230 and y<240 then
                                if (x>=20 and x<30) or (x>=40 and x<50) then
                                    tempR <= half;
                                elsif (x>=10 and x<20) or (x>=30 and x<40) then
                                    tempR <= (others => '1');
                                else
                                    tempR <= (others => '0');
                                end if;
                                tempG <= print_register(T);
                            elsif y>=270 and y<280 then
                                if x>=20 and x<30 then
                                    tempR <= half;
                                elsif (x>=10 and x<20) or (x>=30 and x<50) then
                                    tempR <= (others => '1');
                                else
                                    tempR <= (others => '0');
                                end if;
                                tempG <= print_register(PC);
                            elsif y>=290 and y<300 then
                                if x>=30 and x<50 then
                                    tempR <= half;
                                elsif x>=10 and x<30 then
                                    tempR <= (others => '1');
                                else
                                    tempR <= (others => '0');
                                end if;
                                tempG <= print_register(IF_RF_Ins);
                            elsif y>=310 and y<320 then
                                if x>=30 and x<40 then
                                    tempR <= half;
                                elsif (x>=10 and x<30) or (x>=40 and x<50) then
                                    tempR <= (others => '1');
                                else
                                    tempR <= (others => '0');
                                end if;
                                tempG <= print_register(EXE_RF_Res);
                            elsif y>=330 and y<340 then
                                if x>=40 and x<50 then
                                    tempR <= half;
                                elsif x>=10 and x<40 then
                                    tempR <= (others => '1');
                                else
                                    tempR <= (others => '0');
                                end if;
                                tempG <= print_register(MEM_RF_Res);
                            else
                                tempR <= (others => '0');
                                tempG <= (others => '0');
                            end if;
                            tempB <= (others => '0');
                        when "11" => 
                            if pr(CONV_INTEGER(not x(2 downto 0)))='1' then
                                tempR <= (others => '1');
                                tempG <= (others => '1');
                                tempB <= (others => '1');
                            else
                                if (rcdAddr(6 downto 0)<79 and caddr_origin=rcdAddr+1) or 
                                   (rcdAddr(6 downto 0)=79 and caddr_origin(6 downto 0)="000000" and 
                                    ((rcdAddr(11 downto 7)<29 and caddr_origin(11 downto 7)=rcdAddr(11 downto 7)+1) or 
                                     (rcdAddr(11 downto 7)=29 and caddr_origin(11 downto 7)="00000"))) then
                                    tempB <= (others => '0');
                                    if caps='1' then
                                        tempR <= (others => '1');
                                        tempG <= (others => '0');
                                    elsif caps='0' then
                                        tempR <= (others => '0');
                                        tempG <= (others => '1');
                                    else
                                        tempR <= (others => '0');
                                        tempG <= (others => '0');
                                    end if;
                                else
                                    tempR <= (others => '0');
                                    tempG <= (others => '0');
                                    tempB <= (others => '0');
                                end if;
                            end if;
                        when others => 
                            tempR <= (others => '0');
                            tempG <= (others => '1');
                            tempB <= (others => '0');
                    end case;
                end if;
            end if;
        end if;
    end process;
end Behavioral;

