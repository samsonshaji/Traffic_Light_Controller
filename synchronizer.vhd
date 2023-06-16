-- Team Members: George Wang, Samson Shaji
library ieee;
use ieee.std_logic_1164.all;


entity synchronizer is port (

			clk					: in std_logic;  -- 1 bit clock input
			reset					: in std_logic;  -- 1 bit input to reset 
			din					: in std_logic;  -- 1 bit input for asynchronous input signal
			dout					: out std_logic	-- 1 bit output for sychronous ouput signal
  );
 end synchronizer;
 
 
architecture circuit of synchronizer is

	Signal sign_in			: std_logic;			-- internal signal for second flip-flop input

BEGIN

process(clk, reset) is
begin
	IF (rising_edge(clk)) THEN		-- logic for the synchronizer

		IF (reset = '1') THEN		-- if reset is 1, then the output for synchronous output signal and internal signal for second flipflop is set to 0
			dout <= '0';	
			sign_in <= '0';
		ELSIF (reset = '0') THEN	-- otherwise, the output is set to internal signal and internal signal is set to input
			dout <= sign_in;
			sign_in <= din;
		END IF;
			
		
	
	END IF;

end process;
end;											-- end
