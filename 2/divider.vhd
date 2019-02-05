--  Copyright (c) 2018 by Taemin Yeom, All rights reserved.
library IEEE;
use IEEE.numeric_bit.all;
entity DIVIDER is
    port (BINARY : in bit_vector(5 downto 0);
          BCD_H, BCD_L : out bit_vector(3 downto 0));
end DIVIDER;

architecture archi_DIVIDER of DIVIDER is
signal BCD_H0 : unsigned(3 downto 0); -- inner signal of BCD_H
signal BCD_L0 : unsigned(5 downto 0); -- inner signal of BCD_L
begin
    process(BINARY)
    begin
        if BINARY > "110001" then -- input >= 50
            BCD_H0 <= "0101"; -- higher digit is 5
            BCD_L0 <= unsigned(BINARY) - "110010"; -- calculate lower digit

        elsif BINARY > "100111" then -- 40 <= input <= 49
            BCD_H0 <= "0100"; -- higher digit is 4
            BCD_L0 <= unsigned(BINARY) - "101000"; -- calculate lower digit

        elsif BINARY > "011101" then -- 30 <= input <= 39
            BCD_H0 <= "0011"; -- higher digit is 3
            BCD_L0 <= unsigned(BINARY) - "011110"; -- calculate lower digit

        elsif BINARY > "010011" then -- 20 <= input <= 29
            BCD_H0 <= "0010"; -- higher digit is 2
            BCD_L0 <= unsigned(BINARY) - "010100"; -- calculate lower digit

        elsif BINARY > "001001" then -- 10 <= input <= 19
            BCD_H0 <= "0001"; -- higher digit is 1
            BCD_L0 <= unsigned(BINARY) - "001010"; -- calculate lower digit

        else -- input < 10
            BCD_H0 <= "0000"; -- higher digit is 0
            BCD_L0 <= unsigned(BINARY);

        end if;

    end process;

    -- assign inner singal to output
    BCD_H <= bit_vector(BCD_H0);
    BCD_L <= bit_vector(BCD_L0(3 downto 0));
end;