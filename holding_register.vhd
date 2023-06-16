-- Team Members: George Wang, Samson Shaji
library ieee;
use ieee.std_logic_1164.all;


entity holding_register is port (	-- holding register

			clk					: in std_logic;	-- 1 bit clock input
			reset					: in std_logic;   -- 1 bit clock input to reset
			register_clr			: in std_logic; -- 1 bit input to clear holding register
			din					: in std_logic;		-- 1 bit input to be held
			dout					: out std_logic		-- 1 bit output that is held
  );
 end holding_register;
 
 architecture circuit of holding_register is

	Signal sreg				: std_logic;			-- signal to hold internal state


BEGIN

process (clk, reset) is			-- logic for the holding register
begin
	IF(rising_edge(clk)) THEN	 -- when on the rising edge the logic is executed
	
		IF(reset = '0') THEN
			sreg <= (sreg OR din) AND NOT register_clr;	-- if reset is 0, then signal is set to the ouput of the current input or the signal depending on the clear holding register
		
			dout <= sreg;
		ELSIF(reset = '1') THEN		-- otherwise, the signal and output is set to 0 
			sreg <= '0';
			dout <= '0';
		
		END IF;
		
	
		
	END IF;
end process;

end;						-- end