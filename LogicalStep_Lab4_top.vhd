-- Team Members: George Wang, Samson Shaji
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY LogicalStep_Lab4_top IS
   PORT
	(
   clkin_50		: in	std_logic;							-- The 50 MHz FPGA Clockinput
	rst_n			: in	std_logic;							-- The RESET input (ACTIVE LOW)
	pb_n			: in	std_logic_vector(3 downto 0); -- The push-button inputs (ACTIVE LOW)
 	sw   			: in  std_logic_vector(7 downto 0); -- The switch inputs
   leds			: out std_logic_vector(7 downto 0);	-- for displaying the the lab4 project details
	-------------------------------------------------------------
	-- you can add temporary output ports here if you need to debug your design 
	-- or to add internal signals for your simulations
	-------------------------------------------------------------
	
   seg7_data 	: out std_logic_vector(6 downto 0); -- 7-bit outputs to a 7-segment
	seg7_char1  : out	std_logic;							-- seg7 digi selectors
	seg7_char2  : out	std_logic;							-- seg7 digi selectors
	
	
	sm_clken_out	: out std_logic;						-- Output signals for sm_clken (for simulation)
	blink_sig_out : out std_logic;						-- Output signals for blinK_sig (for simulation)
	
	EW_a, EW_d, EW_g 	: out std_logic;					-- Output signals for EW a, d, g signals (for simulation)
	NS_a, NS_d, NS_g	: out std_logic					-- Output signals for NS a, d, g signals (for simulation)
	
	
	);
END LogicalStep_Lab4_top;

ARCHITECTURE SimpleCircuit OF LogicalStep_Lab4_top IS

   component segment7_mux port ( -- 7-segment mux
          clk        : in  std_logic := '0';
			 DIN2 		: in  std_logic_vector(6 downto 0);	--bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DIN1 		: in  std_logic_vector(6 downto 0); --bits 6 to 0 represent segments G,F,E,D,C,B,A
			 DOUT			: out	std_logic_vector(6 downto 0); 
			 DIG2			: out	std_logic;
			 DIG1			: out	std_logic
   );
   end component;

   component clock_generator port ( -- clock generator
			sim_mode			: in boolean; -- 1 bit input if we are in simulation mode
			reset				: in std_logic; -- 1 bit input for reset
         clkin      		: in  std_logic; -- clock input
			sm_clken			: out	std_logic; -- 1 bit output clock for state machine
			blink		  		: out std_logic -- 1 bit blink signal
  );
   end component;

   component pb_inverters port ( -- pb inverters 
			 pb_n					: in std_logic_vector(3 downto 0); -- 4 bit button input (active low)
			 pb			  		: out std_logic_vector(3 downto 0) -- 4 bit button output (active high)
  );
   end component;

	
	component synchronizer port( -- synchronizer
			clk					: in std_logic; -- 1 bit clock input
			reset					: in std_logic; -- 1 bit input to reset
			din					: in std_logic; -- 1 bit input for asynchronous input signal
			dout					: out std_logic -- 1 bit output for sychronous ouput signal
  );
   end component;
 
  component holding_register port ( -- holding register
			clk					: in std_logic; -- 1 bit clock input
			reset					: in std_logic; -- 1 bit input to reset
			register_clr			: in std_logic; -- 1 bit input to clear holding register
			din					: in std_logic; -- 1 bit input to be held
			dout					: out std_logic -- 1 bit output that is held
  );
  end component;
  
  component TLC_State_Machine port ( -- TLC State Machine
			clk_input		: IN std_logic; -- 1 bit clock input
			reset				: IN std_logic; -- 1 bit clock input to reset
			sm_clken		: IN std_logic; -- 1 bit clock input for each state
			blink_sig	: IN std_logic; -- 1 bit blink signal input (for blinking traffic light)
			
			NS_jump		: IN std_logic; -- 1 bit input for a NS jump request
			EW_jump		: IN std_logic; -- 1 bit input for a EW jump request
			
			NS_red_out		: OUT std_logic; -- 1 bit output for NS red light
			NS_yellow_out		: OUT std_logic; -- 1 bit output for NS yellow light
			NS_green_out		: OUT std_logic; -- 1 bit output for NS green light
			NS_crossing 		: OUT std_logic; -- 1 bit output for NS crossing signal
			
			
			EW_red_out		: OUT std_logic; -- 1 bit output for EW red light
			EW_yellow_out		: OUT std_logic; -- 1 bit output for EW yellow light
			EW_green_out		: OUT std_logic; -- 1 bit output for EW green light
			EW_crossing 		: OUT std_logic; -- 1 bit output for EW crossing signal
			
			NS_crossing_clear : OUT std_logic; -- 1 bit output to clear NS crossing request
			EW_crossing_clear : OUT std_logic;	-- 1 bit output to clear EW crossing request
			
			state_leds : OUT std_logic_vector(3 downto 0) -- 1 bit output to show current state for leds
	);
	end component;
				
	
----------------------------------------------------------------------------------------------------
	CONSTANT	sim_mode						: boolean := TRUE; -- set to FALSE for LogicalStep board downloads
	                                                     -- set to TRUE for SIMULATIONS
	
	SIGNAL sm_clken, blink_sig			: std_logic; -- 1 bit signals for sm_clken, blink_sig
	
	SIGNAL pb								: std_logic_vector(3 downto 0); -- pb(3) is used as an active-high reset for all registers
	
	SIGNAL sync_in_EW, sync_in_NS 	: std_logic; -- 1 bit signals for synchronized NS and EW crossing requests
	
	SIGNAL NS_green, NS_yellow, NS_red : std_logic; -- 1 bit signals for NS lights (red, yellow, green)
	
	SIGNAL EW_green, EW_yellow, EW_red : std_logic; -- 1 bit signals for EW lights (red, yellow, green)
	
	SIGNAL NS_cross_req					: std_logic; -- 1 bit signals for NS and EW crossing requests
	SIGNAL EW_cross_req					: std_logic;
	
	SIGNAL NS_cross_clear				: std_logic; -- 1 bit signals to clear NS and EW crossing requests
	SIGNAL EW_cross_clear				: std_logic;
BEGIN
----------------------------------------------------------------------------------------------------
INST1: pb_inverters		port map (pb_n, pb); -- PB inverters instance
INST2: clock_generator 	port map (sim_mode, pb(3), clkin_50, sm_clken, blink_sig); -- clock generator instance


INST3: synchronizer 		port map (clkin_50, pb(3), pb(1), sync_in_EW); -- synchronizer for EW crossing instance
INST4: synchronizer		port map (clkin_50, pb(3), pb(0), sync_in_NS); --synchronizer for NS crossing instance

INST5: holding_register port map (clkin_50, pb(3), EW_cross_clear, sync_in_EW, EW_cross_req); -- holding register for EW crossing instance
INST6: holding_register port map (clkin_50, pb(3), NS_cross_clear, sync_in_NS, NS_cross_req); -- holding register for NS crossing instance

INST7: TLC_State_Machine port map (clkin_50, pb(3), sm_clken, blink_sig, NS_cross_req , EW_cross_req, NS_red, NS_yellow, NS_green, 
												leds(0), EW_red, EW_yellow, EW_green, leds(2), NS_cross_clear, EW_cross_clear, leds(7 downto 4)); -- TLC state machine instance

INST8: segment7_mux 		port map (clkin_50, NS_yellow & "00" & NS_green & "00" & NS_red, EW_yellow & "00" & EW_green & "00" & EW_red, 
												seg7_data, seg7_char2, seg7_char1); -- segment 7 mux instance

leds(1) <= NS_cross_req; -- led 1 is the NS crossing request
leds(3) <= EW_cross_req; -- led 2 is the EW crossing request

NS_a <= NS_red; -- connect the NS light signals to NS a, d, g outputs
NS_d <= NS_green;
NS_g <= NS_yellow;

EW_a <= EW_red; -- connect the EW light signals to EW a, d, g, outputs
EW_d <= EW_green;
EW_g <= EW_yellow;

sm_clken_out <= sm_clken; -- connect the sm_clken and blink_sig to their respective outputs
blink_sig_out <= blink_sig;


END SimpleCircuit;
