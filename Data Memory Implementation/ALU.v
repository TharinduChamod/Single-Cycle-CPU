/*    CO224  Lab 06
Part 01 - ALU
Group No - 07

E/18/285 - Ranasinghe S.M.T.S.C.
E/18/028 - Ariyawansha P.H.J.U.


*/



module ALU(DATA1, DATA2, RESULT, SELECT, ZERO);               // ALU module

    input [7:0] DATA1, DATA2;                           // Get data words with length of 8
    input [2:0] SELECT;                                 // Get selector word with length 0f 3 bit
    output [7:0] RESULT;                                // Return output with length 0f 8 bit
    output reg ZERO;                                        // Inidcate whether output is zero or not (if output is zero ZERO = 1, otherwise ZERO =0)

    wire [7:0] TEMP1, TEMP2, TEMP3, TEMP4, TEMP5, TEMP6, TEMP7, TEMP8;              // Temp wires for for storing 

    FORWARD FORWARD1(DATA2, TEMP1);                     // Instance of FORWARD module is created
    ADD ADD1(DATA1, DATA2, TEMP2);                      // Instance of ADD module is created
    AND AND1(DATA1, DATA2, TEMP3);                      // Instance of AND module is created
    OR OR1(DATA1, DATA2, TEMP4);                        // Instance of OR module is created
                                   
    MUX8x1 MUX1(TEMP1, TEMP2, TEMP3, TEMP4, TEMP5, TEMP6, TEMP7, TEMP8, SELECT, RESULT);


    always@(DATA1, DATA2, SELECT, TEMP2) begin
        if(TEMP2 == 8'B00000000) begin
            assign ZERO = 1'B1;                         // When output of ADD operation equal to zero indicate ZERO as 1
        end

        else begin
            assign ZERO = 1'B0;                         // When output of ADD operation inequal to zero, indicate ZERO as 0
        end
    end     

endmodule




module FORWARD(DATA, RESULT);               // Module for FORWARD condition

    input [7:0] DATA;                       // Get 8 bit word using input array with length as 8
    output [7:0] RESULT;                    // Store output value in register as 8 bit word

    assign #1 RESULT = DATA;                // copy value of data to result (with unit delay of 1)

endmodule


module ADD(DATA1, DATA2, RESULT);           // Module module for ADD function

    input [7:0] DATA1, DATA2;               // Getting two inputs with word length as 8
    output signed[7:0] RESULT;              // Return sum as 8 bit word
    
    assign #2 RESULT = DATA1 + DATA2;       // Calcultaing Sum and assign sum to output string with length 0f 8 bit (with unit delay of 2)
    
endmodule


module AND(DATA1, DATA2, RESULT);           // Module to do bitwise AND operation

    input [7:0] DATA1, DATA2;               // Get inputs as word with length of 8
    output [7:0] RESULT;                    // Return output word with length of 8

    assign #1 RESULT = DATA1 & DATA2;       // Doing bitwise AND operation (with unit delay of 1)

endmodule


module OR(DATA1, DATA2, RESULT);            // Module to do bitwis OR operation

    input [7:0] DATA1, DATA2;               // Get inputs as word with length of 8
    output [7:0] RESULT;                    // Return output word with length of 8

    assign #1 RESULT = DATA1 | DATA2;       // Doing bitwise OR operation( with unit delay of 1)

endmodule


module MUX8x1(DATA1, DATA2, DATA3, DATA4, DATA5, DATA6, DATA7, DATA8, SELECT, OUT);   //8x1 MUX

    input[7:0] DATA1, DATA2, DATA3, DATA4, DATA5, DATA6, DATA7, DATA8;
    input [2:0] SELECT;
    output reg[7:0] OUT;

    always@(SELECT)begin                                // Check whether selector is changed or not
        
        case(SELECT)                                    // Case structure for selector

            3'b000:
                assign OUT = DATA1;                 // If selector is 000 RESULT is getting from FORWARD instance

            3'b001:
                assign OUT = DATA2;                 // If selector is 001 RESULT is getting from ADD instance

            3'b010:
                assign OUT = DATA3;                 // If selector is 010 RESULT is getting from AND instance

            3'b011:
                assign OUT = DATA4;                 // If selector is 011 RESULT is getting from OR instance

            3'b100:
                assign OUT = DATA5;                 // For reserved instruction

            3'b101:
                assign OUT = DATA6;                 // For reserved instruction

            3'b110:
                assign OUT = DATA7;                 // For reserved instruction

            3'b111:
                assign OUT = DATA8;                 // For reserved instruction

            default:
                assign OUT = 8'bxxxxxxxx;           // Default case for unknown outputs


        endcase                                      // End the case structure
    end

endmodule
