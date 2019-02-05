-- entity of 4Bit Shift Right Register
entity rshift4 is 
	port (CLK, SI : in bit; SO : out bit);
end rshift4;

-- architecture of 4Bit Shift Right Register
architecture Structure of rshift4 is
signal Q1, Q2, Q3, Q4 : bit;

begin
	SO <= Q4;
	process(CLK)
	begin
		if CLK'event and CLK = '1' then -- when CLK ='1' do right shift
			Q1 <= SI; Q2 <= Q1; Q3 <= Q2; Q4 <= Q3; 
		end if;
	end process;
end Structure;
