-- entity of testbench
entity rshift4_test is
end rshift4_test;

-- architecture of testbench
architecture testbench of rshift4_test is
signal SI_port, CLK_port, SO_port: bit; -- signal will be used in testbench

-- testbench's input and output
constant stimulus : bit_vector(0 to 11) := "110010100000"; 
constant response : bit_vector(0 to 11) := "000011001010";

-- using rshift4 as component
component rshift4
	port(SI, CLK: in bit;
		SO: out bit);
end component;

-- architecture of testbench
begin
	CLK_port <= not CLK_port after 10 ns; -- 50 MHz clock
	U1: rshift4 port map(SI_port, CLK_port, SO_port); -- component of rshift4

	process -- definition of testbench's process
	variable sequence : integer:= 0; -- to get sequnce of testbench
	begin
		-- wait until rising edge 
		wait until CLK_port'event and CLK_port = '1'; 
			report integer'image(sequence) & " clock sequence"; -- progress message
			if sequence < 8 then -- "11001010" 8 bit
				SI_port <= stimulus(sequence); -- assign SI_port to test case
			end if;
				sequence := sequence + 1; -- add 1 to sequence when rising edge
		
		wait for 5 ns; 
		-- compare output with expected response vector
		if sequence > 4 and sequence < 13 then -- expected output "11001010" is 8 bit
			assert SO_port = response(sequence-1) -- compare with expected output
                        -- if output is different with expected response, report.
			report "Wrong Answer. Expected answer is " & bit'image(response(sequence)) 
				& " But Current answer is " & bit'image(SO_port)
			severity error;
		end if;
	end process;

end testbench;