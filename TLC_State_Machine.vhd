-- Team Members: George Wang, Samson Shaji
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

Entity TLC_State_Machine IS Port
(
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
END ENTITY;

ARCHITECTURE SM OF TLC_State_Machine IS
 
 
 TYPE STATE_NAMES IS (S0, S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15);   -- list all the STATE_NAMES values

 
 SIGNAL current_state, next_state	:  STATE_NAMES;     	-- signals of type STATE_NAMES

BEGIN

  --------------------------------------------------------------------------------
 --State Machine:
 --------------------------------------------------------------------------------

 -- REGISTER_LOGIC PROCESS EXAMPLE
 
Register_Section: PROCESS (clk_input, sm_clken, reset)  -- this process updates with a clock
BEGIN
	IF(rising_edge(clk_input)) THEN -- on each rising edge of clock, if reset is 1 then set current state to 0
		IF (reset = '1') THEN
			current_state <= S0;
		ELSIF (reset = '0' AND (sm_clken = '1')) THEN -- on each rising edge of clock and when state-machine clock changes, 
																		-- set current state to the next state
			current_state <= next_state;
		END IF;
	END IF;
END PROCESS;	



-- TRANSITION LOGIC PROCESS EXAMPLE

Transition_Section: PROCESS (current_state) 

BEGIN
  CASE current_state IS -- Each state S(N) has the next state S(N+1) with a few exceptions:
			WHEN S0 => 
			
				IF (EW_jump = '1' AND NS_jump = '0') THEN  -- IF EW_jump is active (and NS_jump isn't) then perform jump to S6
					next_state <= S6;

				ELSE
					next_state <= S1;
				END IF;
				
			WHEN S1 =>
				IF (EW_jump = '1' AND NS_jump = '0') THEN -- IF EW_jump is active (and NS_jump isn't) then perform jump to S6
					next_state <= S6;

				ELSE
					next_state <= S2;
				END IF;

			WHEN S2 =>
				next_state <= S3;
				
			WHEN S3 =>
				next_state <= S4;

			WHEN S4 =>		
					next_state <= S5;

         WHEN S5 =>		
					next_state <= S6;
				
         WHEN S6 =>		
				next_state <= S7;

				
         WHEN S7 =>		
				next_state <= S8;
			
			WHEN S8 =>
				if(NS_jump = '1' AND EW_jump = '0') THEN -- IF NS_jump is active (and EW_jump isn't) then perform jump to S14
					next_state <= S14;

					
				ELSE
					next_state <= S9;
					
				END IF;
			
			WHEN S9 =>
				if(NS_jump = '1' AND EW_jump = '0') THEN -- IF NS_jump is active (and EW_jump isn't) then perform jump to S14
					next_state <= S14;

				ELSE
					next_state <= S10;
				END IF;
			
			WHEN S10 =>		
				next_state <= S11;
			
			WHEN S11 =>		
				next_state <= S12;
			
			WHEN S12 =>		
				next_state <= S13;
			
			WHEN S13 =>		
				next_state <= S14;
			
			WHEN S14 =>		
				next_state <= S15;

			
			WHEN S15 =>		
				next_state <= S0;

			WHEN OTHERS =>
            next_state <= S0;
	  END CASE;
 END PROCESS;
 

-- DECODER SECTION PROCESS EXAMPLE (MOORE FORM SHOWN)

Decoder_Section: PROCESS (current_state, NS_jump, EW_jump, blink_sig) 

BEGIN 
     CASE current_state IS
	  
         WHEN S0  =>		-- S0: NS Blinking green and EW red
				NS_red_out <= '0';
				NS_yellow_out <= '0';
				NS_green_out <= blink_sig;
				
				NS_crossing <= '0';
				
				EW_red_out <= '1';
				EW_yellow_out <= '0';
				EW_green_out <= '0';
			
				EW_crossing <= '0';
				
				state_leds <= "0000";

         WHEN S1 =>		 -- S1: NS Blinking green and EW red
				NS_red_out <= '0';
				NS_yellow_out <= '0';
				NS_green_out <= blink_sig;
				
				NS_crossing <= '0';
				
				EW_red_out <= '1';
				EW_yellow_out <= '0';
				EW_green_out <= '0';
			
				EW_crossing <= '0';
				
				state_leds <= "0001";

         WHEN S2 =>		-- S2: NS solid green and EW red (NS can cross)
				NS_red_out <= '0';
				NS_yellow_out <= '0';
				NS_green_out <= '1';
				
				NS_crossing <= '1';
				
				EW_red_out <= '1';
				EW_yellow_out <= '0';
				EW_green_out <= '0';
			
				EW_crossing <= '0';
				
				state_leds <= "0010";
			
         WHEN S3 			-- S3: NS solid green and EW red (NS can cross)
				NS_red_out <= '0';
				NS_yellow_out <= '0';
				NS_green_out <= '1';
				
				NS_crossing <= '1';
				
				EW_red_out <= '1';
				EW_yellow_out <= '0';
				EW_green_out <= '0';
			
				EW_crossing <= '0';
				

				state_leds <= "0011";
         WHEN S4 =>		-- S4: NS solid green and EW red (NS can cross)
				NS_red_out <= '0';
				NS_yellow_out <= '0';
				NS_green_out <= '1';
				
				NS_crossing <= '1';
				
				EW_red_out <= '1';
				EW_yellow_out <= '0';
				EW_green_out <= '0';
			
				EW_crossing <= '0';
				
				state_leds <= "0100";

         WHEN S5 =>		-- S5: NS solid green and EW red (NS can cross)
				NS_red_out <= '0';
				NS_yellow_out <= '0';
				NS_green_out <= '1';
				
				NS_crossing <= '1';
				
				EW_red_out <= '1';
				EW_yellow_out <= '0';
				EW_green_out <= '0';
			
				EW_crossing <= '0';
				
				state_leds <= "0101";
         WHEN S6 =>		-- S6: NS yellow and EW red
				NS_red_out <= '0';
				NS_yellow_out <= '1';
				NS_green_out <= '0';
				
				NS_crossing <= '0';
				
				EW_red_out <= '1';
				EW_yellow_out <= '0';
				EW_green_out <= '0';
			
				EW_crossing <= '0';
				
				state_leds <= "0110";
         WHEN S7 =>		-- S7: NS yellow and EW red
				NS_red_out <= '0';
				NS_yellow_out <= '1';
				NS_green_out <= '0';
				
				NS_crossing <= '0';
				
				EW_red_out <= '1';
				EW_yellow_out <= '0';
				EW_green_out <= '0';
			
				EW_crossing <= '0';
				
				
				state_leds <= "0111";
			WHEN S8 => 		-- S8: NS red and EW blinking green
				
				NS_red_out <= '1';
				NS_yellow_out <= '0';
				NS_green_out <= '0';
				
				NS_crossing <= '0';
				
				EW_red_out <= '0';
				EW_yellow_out <= '0';
				EW_green_out <= blink_sig;
			
				EW_crossing <= '0';
			
				state_leds <= "1000";
			WHEN S9 =>		-- S9: NS red and EW blinking green
				
				NS_red_out <= '1';
				NS_yellow_out <= '0';
				NS_green_out <= '0';
				
				NS_crossing <= '0';
				
				EW_red_out <= '0';
				EW_yellow_out <= '0';
				EW_green_out <= blink_sig;
			
				EW_crossing <= '0';
				
				state_leds <= "1001";
			
			WHEN S10 =>		-- S10: NS red and EW solid green (EW can cross)
				
				NS_red_out <= '1';
				NS_yellow_out <= '0';
				NS_green_out <= '0';
				
				NS_crossing <= '0';
				
				EW_red_out <= '0';
				EW_yellow_out <= '0';
				EW_green_out <= '1';
			
				EW_crossing <= '1';
			
				state_leds <= "1010";
			
			WHEN S11 => 	-- S11: NS red and EW solid green (EW can cross)
			
				NS_red_out <= '1';
				NS_yellow_out <= '0';
				NS_green_out <= '0';
				
				NS_crossing <= '0';
				
				EW_red_out <= '0';
				EW_yellow_out <= '0';
				EW_green_out <= '1';
			
				EW_crossing <= '1';
			
			
				state_leds <= "1011";
			WHEN S12 =>		-- S12: NS red and EW solid green (EW can cross)
			
				NS_red_out <= '1';
				NS_yellow_out <= '0';
				NS_green_out <= '0';
				
				NS_crossing <= '0';
				
				EW_red_out <= '0';
				EW_yellow_out <= '0';
				EW_green_out <= '1';
			
				EW_crossing <= '1';
			
				state_leds <= "1100";
			
			WHEN S13 =>		-- S13: NS red and EW solid green (EW can cross)
			
				NS_red_out <= '1';
				NS_yellow_out <= '0';
				NS_green_out <= '0';
				
				NS_crossing <= '0';
				
				EW_red_out <= '0';
				EW_yellow_out <= '0';
				EW_green_out <= '1';
			
				EW_crossing <= '1';
			
				state_leds <= "1101";
			
			WHEN S14 =>		-- S14: NS red and EW yellow
			
				NS_red_out <= '1';
				NS_yellow_out <= '0';
				NS_green_out <= '0';
				
				NS_crossing <= '0';
				
				EW_red_out <= '0';
				EW_yellow_out <= '1';
				EW_green_out <= '0';
			
				EW_crossing <= '0';
			
				state_leds <= "1110";
			
			WHEN S15 =>		-- S15: NS red and EW yellow
			
				NS_red_out <= '1';
				NS_yellow_out <= '0';
				NS_green_out <= '0';
				
				NS_crossing <= '0';
				
				EW_red_out <= '0';
				EW_yellow_out <= '1';
				EW_green_out <= '0';
			
				EW_crossing <= '0';
			
		
				state_leds <= "1111";
			
	  END CASE;
	  
	  CASE current_state IS -- Send NS crossing clear signal in S6
			WHEN S6 =>
				NS_crossing_clear <= '1';
			WHEN OTHERS =>
				NS_crossing_clear <= '0';
				
		END CASE;
	  
	  CASE current_state IS -- Send EW crossing clear signal in S14
			WHEN S14 =>
				EW_crossing_clear <= '1';
			WHEN OTHERS =>
				EW_crossing_clear <= '0';
				
		END CASE;
	  
 END PROCESS;

 END ARCHITECTURE SM;