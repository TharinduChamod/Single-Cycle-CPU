`include "Shifter.v"

module TestBench;

    reg IN1, IN2;
    //wire OUT;
    reg S;

    reg signed [7:0] IN;
    reg [7:0] SHIFT;
    reg SHIFT_TYPE;
    wire signed[7:0] OUT;

    //LSU LSU1(IN1, IN2, S, OUT);

    SHIFTER LS1(IN, SHIFT, OUT, SHIFT_TYPE);

    

    initial begin
        //$monitor("IN1 = %B      IN2 = %B      S= %B       OUT = %B", IN1, IN2, S, OUT);

        $monitor("IN = %b (%d)      SHIFT = %b (%d)         OUT = %B (%d)       SHIFT TYPE = %b", IN, IN, SHIFT, SHIFT, OUT, OUT, SHIFT_TYPE);

        /*IN = 8'b00010101;

        #2 SHIFT_TYPE = 1'b1;
        #2 SHIFT = 4'B0000;
        #2 SHIFT = 4'B0001;
        #2 SHIFT = 4'B0011;
        #2 SHIFT = 4'B0000;

        #2 SHIFT_TYPE = 1'b0;
        #2 SHIFT = 4'B0000;
        #2 SHIFT = 4'B0001;
        #2 SHIFT = 4'B0011;
        #2 SHIFT = 4'B0000;

        #2 
        IN = 8'b01111111;

        #2 SHIFT = 4'B0000;
        #1 SHIFT = 4'B0001;
        #1 SHIFT = 4'B0011;
        #1 SHIFT = 4'B0000;

        #2*/
        IN = 8'b11111111;

        #2 SHIFT_TYPE = 1'b1;
        //#2 SHIFT = 4'B0000;
        //#2 SHIFT = 4'B0001;
        #2 SHIFT = 4'B0011;
        #2 SHIFT = 4'B0000;

        /*SHIFT_TYPE = 1'b0;
        #2 SHIFT = 4'B0000;
        #2 SHIFT = 4'B0001;
        #2 SHIFT = 4'B0011;
        #2 SHIFT = 4'B0000;

        /*#2
        IN = 8'b10101010;

        #2 SHIFT = 4'B0000;
        #2 SHIFT = 4'B0001;
        #2 SHIFT = 4'B0011;
        #2 SHIFT = 4'B0000;
        #2 SHIFT = 4'b1000;


        /*#1
        SHIFT = 3'B010;

        #1
        SHIFT = 3'B011;

        #1
        SHIFT = 3'B111;*/



        /*IN1 = 0;
        IN2 = 0;
        S =0;

        #1
        IN1 = 1;
        IN2 = 0;
        S =0;

        #1
        IN1 = 1;
        IN2 = 0;
        S =1;*/


    end



endmodule
