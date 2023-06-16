# FPGA - Traffic Light Controller System

> By Samson Shaji and George Wang

## Description
This project involves the implementation of a traffic light controller using VHDL on an FPGA. The controller is designed to control the traffic lights at an intersection, providing signals for both the North-South (NS) and East-West (EW) directions.

## Components
The project consists of the following components:

1. `LogicalStep_Lab4_top`: The top-level entity that instantiates all the sub-components and defines the input and output ports.
2. `segment7_mux`: A 7-segment multiplexer used to display information on a 7-segment display.
3. `clock_generator`: A clock generator module that generates the required clocks for the state machine and blinking functionality.
4. `pb_inverters`: A module that inverts the push-button inputs.
5. `synchronizer`: A synchronizer module that synchronizes the crossing requests for both NS and EW directions.
6. `holding_register`: A holding register module that holds the crossing requests.
7. `TLC_State_Machine`: The main state machine module that controls the traffic lights based on the crossing requests and generates the necessary output signals.

## Inputs
- `clkin_50`: The 50 MHz FPGA clock input.
- `rst_n`: The RESET input (ACTIVE LOW).
- `pb_n`: The push-button inputs (ACTIVE LOW).
- `sw`: The switch inputs.

## Outputs
- `leds`: The output signals used to display the project details.
- `seg7_data`: The 7-bit outputs to a 7-segment display.
- `seg7_char1`, `seg7_char2`: The segment selector signals for the 7-segment display.
- `sm_clken_out`: Output signal for the state machine clock (for simulation).
- `blink_sig_out`: Output signal for the blinking signal (for simulation).
- `EW_a`, `EW_d`, `EW_g`: Output signals for the EW traffic light (a, d, g) (for simulation).
- `NS_a`, `NS_d`, `NS_g`: Output signals for the NS traffic light (a, d, g) (for simulation).

## Simulation Mode
The `sim_mode` constant in the architecture can be set to `TRUE` for simulations or `FALSE` for LogicalStep board downloads.

