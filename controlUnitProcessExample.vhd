architecture Behavioral of ControlUnit is
    
begin
    process(******)
    begin
        case ***(15 downto 11) is
            when "01001" => -- addiu

            when "01000" => -- addiu3

            when "01100" => --addsp, bteqz, mtsp

            when "00000" => --addsp3

            when "11100" => -- addu, subu

            when "11101" => -- and, cmp, jr, mfpc, or, sllv

            when "00010" => -- b

            when "00100" => -- beqz

            when "00101" => -- bnez

            when "01110" => -- cmpi

            when "01101" => -- li

            when "10011" => -- lw

            when "10010" => -- lw_sp

            when "11110" => -- mfih, mtih

            when "01111" => -- move

            when "00001" => -- nop

            when "00110" => -- sll, sra

            when "01010" => -- slti

            when "11011" => -- sw

            when "11010" => -- swsp

            when others =>

        end case;
    end process;
    
end Behavioral;
