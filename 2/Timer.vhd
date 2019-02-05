--  Copyright (c) 2018 by Taemin Yeom, All rights reserved.
library IEEE;
use IEEE.numeric_bit.all;

entity TIMER is
    port (CLK, nRESET: in bit;
          MODE1, MODE2 : in bit_vector(1 downto 0);
          MIN_SW, SEC_SW : out bit_vector(5 downto 0);
          SECC_SW : out bit_vector(3 downto 0));
End TIMER;

architecture archi_TIMER of TIMER is
signal count10 : integer range 0 to 10; -- when count 10 is 10, SECC increase

-- to use MIN_SW, SEC_SW, SECC_SW as unsigned type inner signal
signal MIN_SW0, SEC_SW0 : unsigned(5 downto 0);
signal SECC_SW0 : unsigned(3 downto 0);

begin
    process(CLK, nRESET)
    begin

        -- if nRESET push or change mode, initialize
        if nRESET = '0' or (MODE1 = "10" and MODE2 = "00") then
            MIN_SW0 <= "000000";
            SEC_SW0 <= "000000";
            SECC_SW0 <= "0000";
	
        -- when Timer Start mode
        elsif CLK = '1' and MODE1 = "10" and MODE2 = "01" then
            if count10 = 9 then -- when count10 is 9, add a SECC 
                count10 <= 0;
                if SECC_SW0 = "1001" then -- when SECC is 9, add a SEC
                    SECC_SW0 <= "0000";
                    if SEC_SW0 = "111011" then -- when SEC is 59, add a MIN
                        SEC_SW0 <= "000000";
                        if MIN_SW0 = "111011" then -- when MIN is 59, initialize
                            MIN_SW0 <= "000000";
                        else 
                            MIN_SW0 <= MIN_SW0 + 1;
                        end if;
                    else
                        SEC_SW0 <= SEC_SW0 + 1;
                    end if;
                else 	
                    SECC_SW0 <= SECC_SW0 + 1;
                end if;
            else
                count10 <= count10 + 1;
            end if;
        end if;

    end process;

     -- assign inner signal to output
    MIN_SW <= bit_vector(MIN_SW0);
    SEC_SW <= bit_vector(SEC_SW0);
    SECC_SW <= bit_vector(SECC_SW0);

end archi_TIMER;				