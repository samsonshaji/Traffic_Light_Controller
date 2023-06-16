-- Team Members: George Wang, Samson Shaji
library ieee;
use ieee.std_logic_1164.all;


entity PB_inverters is port ( -- PB Inverters
 	pb_n	: in  std_logic_vector (3 downto 0); -- 4 bit input buttons (active low)
	pb	: out	std_logic_vector(3 downto 0)		-- 4 bit output (active high)
	); 
end PB_inverters;

architecture ckt of PB_inverters is

begin
pb <= NOT(pb_n); -- invert each button


end ckt;