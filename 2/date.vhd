--  Copyright (c) 2018 by Taemin Yeom, All rights reserved.
library IEEE;
use IEEE.numeric_bit.all;

entity DATE is
    port (CLK, HOUR_CARRY, INCREASE, nRESET: in bit;
          MODE1, MODE2 : in bit_vector(1 downto 0);
          MON : out bit_vector(3 downto 0);
          DAY : out bit_vector(4 downto 0));
end DATE;

architecture archi_DATE of DATE is
signal INC_MON, INC_DAY : bit;  -- SET_GEN to DATE_GEN signal

-- to use MON, DAY as unsigned type inner signal
signal MON0 : unsigned(3 downto 0);  
signal DAY0 : unsigned(4 downto 0); 

begin
    -- SET_GEN Block
    process(MODE1, MODE2, INCREASE)  -- Combinational Circuit
    begin

        if INCREASE = '1' and MODE1 ="01" then -- when Date mode and receive INCREASE signal
            if MODE2 = "01" then -- when month increase mode
                INC_MON <= '1';
                INC_DAY <= '0';
            elsif MODE2 = "10" then -- when day increase mode
                INC_MON <= '0';
                INC_DAY <= '1';
            end if;
        else -- when not Date mode
            INC_MON <= '0';
            INC_DAY <= '0';
        end if;
    end process;

	-- DATE_GEN Block
    process(CLK, nRESET) -- Sequential Circuit
    begin
	
        if nRESET = '0' then -- when asynch reset make initial state
            MON0 <= "0001"; -- January
            DAY0 <= "00001"; -- 1st day
	
        elsif CLK = '1' then -- Rising edge
            if INC_MON = '1' then  -- when month increase mode
                if MON0 = "1100" then -- when December, make month January
                    MON0 <= "0001"; 
                else
                    MON0 <= MON0 + 1; -- add a month
                end if;
	
            elsif INC_DAY ='1' then -- when day increase mode

                -- January, March, May, July, August, October, December's maximum day is 31
                if MON0 = "0001" or MON0 = "0011" or MON0 = "0101" or MON0 = "0111" 
                    or MON0 = "1000" or MON0 = "1010" or MON0 = "1100" then
                    if DAY0 >= "11111" then -- if day is 31
                        DAY0 <= "00001"; 
                    else 
                        DAY0 <= DAY0 + 1; -- add a day
                    end if;

	        -- April, June, September, November's maximum day is 30
                elsif MON0 = "0100" or MON0 = "0110" 
                    or MON0 = "1001" or MON0 = "1011" then
                    if DAY0 >= "11110" then -- if day is 30
                        DAY0 <= "00001"; 
                    else 
                        DAY0 <= DAY0 + 1; 
                    end if;
	
                else -- February's maximum day is 28 
                    if DAY0 >= "11100" then -- if day is 28
                        DAY0 <= "00001"; 
                    else 
                        DAY0 <= DAY0 + 1; 
                    end if;                                 
                end if;
	
            -- when not increase mode and receive HOUR_CARRY
            elsif HOUR_CARRY = '1' then 
	
                -- January, March, May, July, August, October, December's maximum day is 31
                if MON0 = "0001" or MON0 = "0011" or MON0 = "0101" or MON0 = "0111" 
                    or MON0 = "1000" or MON0 = "1010" or MON0 = "1100" then
                    if DAY0 = "11111" then -- if day is 31
                        DAY0 <= "00001";
                            if MON0 = "1100" then -- when December
                                MON0 <= "0001"; -- make month January
                            else
                                MON0 <= MON0 + 1; 
                            end if;
                    else  
                        DAY0 <= DAY0 + 1; 
                    end if;
	
	        -- April, June, September, November's maximum day is 30
                elsif MON0 = "0100" or MON0 = "0110" 
                    or MON0 = "1001" or MON0 = "1011" then
                    if DAY0 = "11110" then -- if day is 30
                        DAY0 <= "00001"; 
                        MON0 <= MON0 + 1;
                    else 
                        DAY0 <= DAY0 + 1; 
                    end if;
	
                else -- February's maximum day is 28 
                    if DAY0 = "11100" then -- if day is 28
                        DAY0 <= "00001"; 
                        MON0 <= MON0 + 1; 
                    else 
                        DAY0 <= DAY0 + 1; 
                    end if;                                 
                end if;
            end if;
        end if;
    end process;

    -- assign inner signal to output
    MON <= bit_vector(MON0); 
    DAY <= bit_vector(DAY0); 

end archi_DATE;