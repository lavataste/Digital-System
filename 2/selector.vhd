--  Copyright (c) 2018 by Taemin Yeom, All rights reserved.
library IEEE;
use IEEE.numeric_bit.all;

entity SELECTOR is
port (CLK, INCREASE, SET, nRESET: in bit;
      MODE1, MODE2 : in bit_vector(1 downto 0);
      HOUR : in bit_vector(4 downto 0);
      MIN, SEC : in bit_vector(5 downto 0);
      MON : in bit_vector(3 downto 0);
      DAY : in bit_vector(4 downto 0);
      MIN_SW, SEC_SW : in bit_vector(5 downto 0);
      SECC_SW : in bit_vector(3 downto 0);
      OUT_H, OUT_M, OUT_S : out bit_vector(5 downto 0);
      ALARM : out bit);
end SELECTOR;

architecture archi_sel of SELECTOR is
signal ALARM0 : bit; -- inner signal of ALARM 
signal AlARM_H : unsigned(4 downto 0); -- ALARM block's output to SELECTOR block
signal AlARM_M : unsigned(5 downto 0); -- ALARM block's output to SELECTOR block

-- ALARM_SET record whether alarm time is set or not 
-- ALARM_SET2 prevent ring after turning off the alarm
signal ALARM_SET, ALARM_SET2 : bit;

-- inner signal of SELECTOR Block
signal OUT_H0, OUT_M0, OUT_S0 : unsigned(5 downto 0); 
  
begin

    process(CLK, nRESET) -- ALARM block
    begin
        if nRESET = '0' then -- asynch reset
            ALARM_H <= "00000";
            ALARM_M <= "000000";
            ALARM_SET <= '0';

        elsif CLK = '1' then -- rising edge

            if ALARM0 = '1' then  -- when alarm ring

                -- when user push SET switch (= user turn off alarm)
                if SET ='1' then  
                    ALARM0 <= '0'; 
                    ALARM_SET2 <= '0'; -- prevent alarm ring after turning off
                end if;
            end if;

            if MODE1 = "11" and MODE2 /= "00" then -- in alarm time setting mode

                -- receive INCREASE in hour setting mode 
                if MODE2 = "01" and INCREASE = '1' then  
                    if ALARM_H = "10111" then -- when hour is 23
                        ALARM_H <= "00000"; 
                    else
                        ALARM_H <= ALARM_H + 1; -- hour + 1
                    end if;

                    -- record that user set the alarm
                    ALARM_SET <= '1'; 
                    ALARM_SET2 <= '1';

                -- receeive INCREASE in minute setting mode 
                elsif MODE2 = "10" and INCREASE = '1' then
                    if ALARM_M = "111011" then -- when minute is 59
                        ALARM_M <= "000000";
                    else
                        ALARM_M <= ALARM_M + 1; -- minute + 1
                    end if;

                    -- record that user set the alarm
                    ALARM_SET <= '1';
                    ALARM_SET2 <= '1';
                end if;
            end if;

            -- judge current time is same with alarm time when alarm is set
            if ALARM0 = '0' and ALARM_SET = '1' and ALARM_SET2 = '1' then
                if unsigned(HOUR) = ALARM_H and unsigned(MIN) = ALARM_M then
                    ALARM0 <= '1'; -- if they are same, ring the alarm
                end if;

            -- when turn off the alarm but current time is same with alarm time
            elsif ALARM_SET = '1' and ALARM_SET2 = '0' then 
                if unsigned(HOUR) /= ALARM_H or unsigned(MIN) /= ALARM_M then
                    ALARM_SET2 <= '1';  -- when over time, make ALARM_SET2 '1'
                end if;
            end if;
        end if;
    end process; -- end Alarm block

    process(MODE1, HOUR, MIN, SEC, MON, DAY, 
            MIN_SW, SEC_SW, SECC_SW, ALARM_H, ALARM_M) -- SELECTOR block

    begin
        if MODE1 = "00" then -- Time mode
            OUT_H0 <= "0" & unsigned(HOUR); -- make length 6
            OUT_M0 <= unsigned(MIN);
            OUT_S0 <= unsigned(SEC); 

        elsif MODE1 = "01" then -- Date mode
            OUT_H0 <= "00" & unsigned(MON); -- make length 6
            OUT_M0 <= "0" & unsigned(DAY); -- make length 6
            OUT_S0 <= "000000"; -- in Date mode output is always "00"

        elsif MODE1 = "10" then -- Timer mode
            OUT_H0 <= unsigned(MIN_SW);
            OUT_M0 <= unsigned(SEC_SW);
            OUT_S0 <= "00" & unsigned(SECC_SW); -- make length 6

        elsif MODE1 = "11" then -- Alarm mode
            OUT_H0 <= "0" & ALARM_H; -- make length 6
            OUT_M0 <= ALARM_M;
            OUT_S0 <= "000000"; -- in Alarm mode output is always "00"

        end if;
    end process; -- end SECLECTOR block

    -- assign inner signal to output
    OUT_H <= bit_vector(OUT_H0);
    OUT_M <= bit_vector(OUT_M0);
    OUT_S <= bit_vector(OUT_S0);
    ALARM <= ALARM0;

end;