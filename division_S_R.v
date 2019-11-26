// division signed restoring


module divisionSR
                #( parameter M=16,  // default value divisor size
                   parameter N=16)  // default value for quotient size
                (
                 input clock,
                 input reset,
                 input start,
                 input signed [M-1:0] numerator,    // dividend
                 input signed [N-1:0] denominator,  // divisor
				 output signed [M-1:0] quotient
			   );

reg signed [N-1:0] A0;    // resto
reg [M-1:0] counter;      // tamanho errado, devia ser log2 de M
reg sD;                   // sinal do dividendo
reg sA;                   // sinal do resto
reg signed [N+M-1:0] AQ;  // identico à concatenação A e Q dos slides
reg green_flag;

always@(posedge clock)
if(reset)
begin
  A0 <= 16'd0;
  counter <= 16'd0;
  sD <= 0;
  sA <= 0;
  AQ <= 32'd0;
  green_flag <= 0; 
end

else
begin
    if(start)
    begin
       AQ <= {{N{numerator[M-1]}},numerator};  //extensão sinal
       counter <= M;
       sD <= AQ[N+M-1];
       green_flag <= 0;
    end

    else
    begin
        if(counter != 0)
        begin
            if(~green_flag)
            begin
                AQ <= AQ << 1;       //confirmar com o prof posição disto(devia ser no else, mas assim garante que avaliação das condições já pode ser feita; menos 1 clock?
                sA <= AQ[N+M-1];     // sinal do resto actual
                A0 <= AQ[N+M-1:M];   // guarda A
                green_flag <= 1;
            end
            
            else
            begin
                if( AQ[N+M-1] == denominator[N-1] )
                    AQ[N+M-1:M] <= AQ[N+M-1:M] - denominator;
                else
                    AQ[N+M-1:M] <= AQ[N+M-1:M] + denominator;

                if( AQ[N+M-1] == sA || (AQ[N+M-1:M]==0 && AQ[M-1:0]==0) )
                    AQ[0] <= 1;
                else
                begin
                    AQ[0] <= 0;
                    AQ[N+M-1:M] <= A0;
                end
                green_flag <= 0;
                counter <= counter -1;
            end
        end

        else
        begin
            if(sD != denominator[N-1])
                AQ[M-1:0] <= ~AQ[M-1:0];
            else
                AQ[M-1:0] <= AQ[M-1:0];
        end
    end          
end

assign quotient = AQ[M-1:0];    // Output

endmodule