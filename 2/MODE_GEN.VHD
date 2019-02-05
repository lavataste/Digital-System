--  Copyright (c) 2018 by Taemin Yeom, All rights reserved.
entity MODE_GEN is
	port (CLK, SW1, SW2, SET, nRESET: in bit;
		MODE1, MODE2 : out bit_vector(1 downto 0);
		INCREASE : out bit);
end MODE_GEN;

architecture ARCHI_MG of MODE_GEN is
signal INC0, INC1 : bit;	-- inner signal of INCREASE
signal change : bit;	-- record when change mode1 to initialize mode2  
signal md1, md2 : integer range 0 to 3;	 -- inner signal of MODE1, MODE2
					 -- MODE's 00, 01, 10, 11 is matched to md's 0, 1, 2, 3
begin
	-- when Clock change or nRESET is low and md1, md2 change
	process(CLK, md1, md2, nRESET)
	begin

		-- when SW1 press at rising edge
		if CLK'event and CLK='1' and SW1='1' and SW2='0' then
			if md1 < 3 then
				md1 <= md1 + 1; -- mode1 change to next mode.
			else 
				md1 <= 0;	-- if last mode1, return to first mode1.
			end if;
			change <= '1';		-- to initialize mode2, record the signal "change".
		end if;

		-- when SW2 press at rising edge
		if CLK'event and CLK='1' and SW2='1' and SW1='0' then
			if md2 < 2 then
				md2 <= md2 + 1;	-- mode2 change to next mode.
			else 
				md2 <= 0;	-- if last mode2, return to first mode2.
			end if;
		end if;

		case md1 is	-- by md1, assign MODE1 output signal.
			when 0 => MODE1 <= "00"; 
			when 1 => MODE1 <= "01"; 
			when 2 => MODE1 <= "10";
			when 3 => MODE1 <= "11";
			when others => null;
		end case;


		if change = '1' then	-- when change MODE1, initialize MODE2.
			MODE2 <= "00";
			md2 <= 0;
			change <= '0';

		else 
			case md2 is	-- by md2, assign MODE2 output signal.
				when 0 => MODE2 <= "00"; 
				when 1 => MODE2 <= "01"; 
				when 2 => MODE2 <= "10";
				when others => null;
			end case;
		end if;

		-- when receive SET input and in Using INCREASE signal mode, make INC1 '1'.
		if CLK'event and CLK = '1' and md1 /= 2 and md2 /= 0 and SET = '1' then
			INC1 <= '1';
		
		-- when INC1 is '1' at falling edge, make INCREASE '1' with INC0 '1'.
		elsif CLK'event and CLK = '0' and INC1 = '1' then
			INC0 <= '1';
			INC1 <= '0'; 

		-- after a clock make INCREASE 0.
		elsif CLK'event and CLK = '0' and INC0 = '1' then
			INC0 <= '0';
		end if;

		-- when nRESET is low, do asynch reset.
		if nRESET = '0' then
			md1 <= 0; md2 <= 0;
			MODE1 <="00"; MODE2 <="00";
			INC0 <= '0'; INC1 <= '0';
		end if;

	end process;

	INCREASE <= INC0;	-- assign inner signal to output.
end ARCHI_MG;
