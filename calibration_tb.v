`timescale 1ns / 1ps

module calibration_tb;

	// Inputs
	reg clock;
	reg reset;
	reg start;
	reg signed [15:0] X0;
	wire [4:0] pos;


	// Outputs
    wire ready;
	wire signed [15:0] Y0;

	// Instantiate the Unit Under Test (UUT)
	calibration uut (
		.clock(clock), 
		.reset(reset), 
		.start(start), 
		.ready(ready),
		.X(X0),
		.Y(Y0),
		.pos(pos)
	);

	// Initialize inputs:
	initial begin
		clock = 0;
		reset = 0;
		start = 0;
	end
	
	// Generate the clock (50 ns period, frequency = 20 MHz)
	initial
	begin
	  #9
	  forever #25 clock = ~clock;
	end
	
	// Apply reset:
	initial
	begin
	  #1
	  reset = 1;
	  #2
	  reset = 0;
	end

	integer printresults = 1;

	// Main verification program:
	initial
	begin
	  #10
	  // Call the task to start calibration:
	  calibration_task(0'shFFFF);	 
	  $stop;
	  
	end
	
	
	//--------------------------------------------------------------------
	//   apply inputs, set enable to 1, raise start for 1 clock cycle, wait 32 clock cyles
	// set variable "printresults" to 1 to enable printing the results during simulation
	task calibration_task;
	//input [31:0] LUT [0:15];
	input [15:0] X_task;
           	

	begin   
		X0 = X_task;
		
	  #14
	  start = 1;
	  #18
	  start = 0;
	   
	   repeat(20)
	   	@(negedge clock);
	   
	   $display("calib %d lp\n",pos);
	  /* if ( printresults )
	   begin  
	   	// Calculate the expected results:

	    end
	*/
	end
	
	endtask


endmodule
// end of module calibration_tb
