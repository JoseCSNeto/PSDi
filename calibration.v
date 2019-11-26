module calibration
    #( parameter M=16, // default value for M -> input
        parameter N=16) // default value for N --> output
     (   input clock,
         input reset,
         input start,  // set to 1 to start a new conversion
         output ready, // set to 1 when ready
         input signed [M-1 : 0 ] X,
         output signed [N-1 : 0 ] Y,
         output [4:0] pos
     );
     

    wire [3:0] left, right, middle;
    reg [3:0] left_x, right_x;
    //reg [4:0] lp;   //lp = lowest position 
    reg [3:0] counter;
    wire signed [15:0] aux;
    reg signed [N-1 : 0 ] Y_x;
     
    // The lookup table, 16 locations, X and Y pairs:
    reg signed [ M + N - 1 : 0 ] LUTcalib[0:15];
    // Load initial contents to the LUT from file PHASE_CALIB_LUT.hex”:
    
	initial
    begin
        $readmemh("PHASE_CALIB_LUT.hex", LUTcalib );
    end

    assign left = left_x;
    assign right = right_x;
    assign Y = Y_x;
    assign pos = middle;
	
    assign middle = start ? 7 : ((left_x + right_x) >> 1); 
    assign aux    = (LUTcalib[middle] >> 16) & 0'shFFFF;
	
   
    always@(posedge clock)

    if (start)
    begin
        left_x <= 4'd0;
        right_x <= M-1;
        counter <= 3'd0; 
    end
        
    else
    begin
        if(counter != 4)
        begin
			$display("left_x = %d\n", left_x);
            if(aux > X)
            begin 
                right_x <= middle - 1;
				counter  <= counter + 1;
            end
			
           else if (aux < X)
            begin
                left_x <= middle + 1;
				counter  <= counter + 1;
            end 
            else
            begin
                counter <= 4;
            end                           
        end
/* 
        else
        begin        
		    counter <= 0;
		    if(lp[4] != 1)
	    	begin
			    // Interpolation 
			    //velocity = va + (vb-va)*((theta-ta)/(tb-ta));t = x v = y

			    Y_x = (LUTcalib[lp] & 0'h0000FFFF) + (LUTcalib[lp+1] & 0'h0000FFFF);
		    end		
        end
*/        

    end
endmodule