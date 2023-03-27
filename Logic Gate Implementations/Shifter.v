/*    CO224  Lab 05
Part 05 (Bonus) - Register File
Group No - 07

E/18/285 - Ranasinghe S.M.T.S.C.
E/18/028 - Ariyawansha P.H.J.U.


*/

// Shifter for logical LEFT and RIGHT Shift


module LOGICAL_SHIFTER(IN, SHIFT, OUT, SHIFT_TYPE);          // Module for Left and Right logical Shifting

    input [7:0] IN;             // Number for shifting
    input [7:0] SHIFT;          // Amount of shifting
    input SHIFT_TYPE;           // Select left shift or right shift
    output reg[7:0] OUT;           // Return the result

    wire [7:0] LEFT;            // Holding tempory left shift value
    wire [7:0] RIGHT;           // Holding tempory right shift value

    LEFT_SHIFT LS1(IN, SHIFT[3:0], LEFT);       // Calculating Left shift

    RIGHT_SHIFT RS1(IN, SHIFT[3:0], RIGHT);

    // Here if SHIFT_TYPE = 1 for left shift and SHIFT_TYPE = 0 For right shift

    always@(IN, SHIFT, SHIFT_TYPE) begin        // Return shifted amount

        if(SHIFT_TYPE == 1'B0) begin
            #1 OUT = RIGHT;                     // right shift if shift type is 0 with 1 time unit delay
        end

        else if(SHIFT_TYPE == 1'B1) begin
            #1 OUT = LEFT;                      // Left shift if shift type is 1 with 1 time unit delay
        end     

    end

endmodule





module SU(IN1, IN2, S, OUT);    // Unit module for shifting

    input IN1, IN2, S;          // Inputs
    output OUT;                 // Output of module

    wire OR1, OR2;              // Wires for OR gate

    and A1(OR1, ~S, IN1);       // AND gate with selecting
    and A2(OR2, S, IN2);        // AND gate with selecting

    or OR1 (OUT, OR1, OR2);      // Producing output for 2 bit

endmodule





module LEFT_SHIFT(IN, SHIFT, OUT);          // Module for LEFT SHIFTING

    input [7:0] IN;                         // Number for shifting
    input [3:0] SHIFT;                      // Number of bits for shifting
    output reg signed [7:0] OUT;                       // Output after shifting

    // Here we are dealing with 8 bit signed numbers. Then most significant bit for sign of number
    // So, We only want shifting 7 bit number to left when considering sign

    reg S1, S2, S3, S4;                        // Registers for determine amount of shifting

    initial begin                          // Set shifting amount to zero when begin
        S1 = 1'B0;
        S2 = 1'B0;
        S3 = 1'B0;
        S4 = 1'B0;
    end

    wire X1, X2, X3, X4, X5, X6, X7, X8;       // get output from S1 shifting
    wire Y1, Y2, Y3, Y4, Y5, Y6, Y7, Y8;       // get output from S2 shifting
    wire Z1, Z2, Z3, Z4, Z5, Z6, Z7, Z8;       // get output from S3 Shifting
    wire F1, F2, F3, F4, F5, F6, F7, F8;       // get output from S4 shifting

    always@(IN, SHIFT) begin                   // Assign Shifting values
        S1 = SHIFT[0];
        S2 = SHIFT[1];
        S3 = SHIFT[2];
        S4 = SHIFT[3];
    end

    // Shifting from S1

    SU L1(IN[0], 1'B0, S1, X1);
    SU L2(IN[1], IN[0], S1, X2);
    SU L3(IN[2], IN[1], S1, X3);
    SU L4(IN[3], IN[2], S1, X4);
    SU L5(IN[4], IN[3], S1, X5);
    SU L6(IN[5], IN[4], S1, X6);
    SU L7(IN[6], IN[5], S1, X7);
    SU L8(IN[7], IN[6], S1, X8);


    // Shifting form S2

    SU L9(X1, 1'B0, S2, Y1);
    SU L10(X2, 1'B0, S2, Y2);
    SU L11(X3, X1, S2, Y3);
    SU L12(X4, X2, S2, Y4);
    SU L13(X5, X3, S2, Y5);
    SU L14(X6, X4, S2, Y6);
    SU L15(X7, X5, S2, Y7);
    SU L16(X8, X6, S2, Y8);

    // Shifting from S3

    SU L17(Y1, 1'B0, S3, Z1);
    SU L18(Y2, 1'B0, S3, Z2);
    SU L19(Y3, 1'B0, S3, Z3);
    SU L20(Y4, 1'B0, S3, Z4);
    SU L21(Y5, Y1, S3, Z5);
    SU L22(Y6, Y2, S3, Z6);
    SU L23(Y7, Y3, S3, Z7);
    SU L24(Y8, Y4, S3, Z8);

    // Shifting from S4

    SU L25(Z1, 1'B0, S4, F1);
    SU L26(Z2, 1'B0, S4, F2);
    SU L27(Z3, 1'B0, S4, F3);
    SU L28(Z4, 1'B0, S4, F4);
    SU L29(Z5, 1'B0, S4, F5);
    SU L30(Z6, 1'B0, S4, F6);
    SU L31(Z7, 1'B0, S4, F7);
    SU L32(Z8, 1'B0, S4, F8);


    always@(F1, F2, F3, F4, F5, F6, F7, F8) begin       // Assign bits of output when shifted outputs changes 
        OUT[0] = F1;
        OUT[1] = F2;
        OUT[2] = F3;
        OUT[3] = F4;
        OUT[4] = F5;
        OUT[5] = F6;
        OUT[6] = F7;
        OUT[7] = F8;
    end

endmodule





 

module RIGHT_SHIFT(IN, SHIFT, OUT);     // Module for RIGHT SHIFTING

    input [7:0] IN;             // Input for shifting
    input [3:0] SHIFT;          // Amount of shifting
    output reg[7:0] OUT;        // Return the output


    reg S1, S2, S3, S4;             // Registers for determine shifting amount


    initial begin                   // set initial shifting amount for zero
        S1 = 1'B0;
        S2 = 1'B0;
        S3 = 1'B0;
        S4 = 1'B0;
    end

    wire X1, X2, X3, X4, X5, X6, X7, X8;       // get output from S1 shifting
    wire Y1, Y2, Y3, Y4, Y5, Y6, Y7, Y8;       // get output from S2 shifting
    wire Z1, Z2, Z3, Z4, Z5, Z6, Z7, Z8;       // get output from S3 Shifting
    wire F1, F2, F3, F4, F5, F6, F7, F8;       // get output from S4 shifting

    always@(IN, SHIFT) begin                   // Assign Shifting values
        S1 = SHIFT[0];
        S2 = SHIFT[1];
        S3 = SHIFT[2];
        S4 = SHIFT[3];
    end

    // Shifting for S1 values

    SU R1(IN[7], 1'B0, S1, X8);
    SU R2(IN[6], IN[7], S1, X7);
    SU R3(IN[5], IN[6], S1, X6);
    SU R4(IN[4], IN[5], S1, X5);
    SU R5(IN[3], IN[4], S1, X4);
    SU R6(IN[2], IN[3], S1, X3);
    SU R7(IN[1], IN[2], S1, X2);
    SU R8(IN[0], IN[1], S1, X1);

    // Shifting for S2 Values

    SU R9(X8, 1'B0, S2, Y8);
    SU R10(X7, 1'B0, S2, Y7);
    SU R11(X6, X8, S2, Y6);
    SU R12(X5, X7, S2, Y5);
    SU R13(X4, X6, S2, Y4);
    SU R14(X3, X5, S2, Y3);
    SU R15(X2, X4, S2, Y2);
    SU R16(X1, X3, S2, Y1);

    // Shifting for S3 Values

    SU R17(Y8, 1'B0, S3, Z8);
    SU R18(Y7, 1'B0, S3, Z7);
    SU R19(Y6, 1'B0, S3, Z6);
    SU R20(Y5, 1'B0, S3, Z5);
    SU R21(Y4, Y8, S3, Z4);
    SU R22(Y3, Y7, S3, Z3);
    SU R23(Y2, Y6, S3, Z2);
    SU R24(Y1, Y5, S3, Z1);

    // Shifting for S4 Values

    SU R25(Z8, 1'B0, S4, F8);
    SU R26(Z7, 1'B0, S4, F7);
    SU R27(Z6, 1'B0, S4, F6);
    SU R28(Z5, 1'B0, S4, F5);
    SU R29(Z4, 1'B0, S4, F4);
    SU R30(Z3, 1'B0, S4, F3);
    SU R31(Z2, 1'B0, S4, F2);
    SU R32(Z1, 1'B0, S4, F1);


     always@(F1, F2, F3, F4, F5, F6, F7, F8) begin       // Assign bits of output when shifted outputs changes 
        OUT[0] = F1;
        OUT[1] = F2;
        OUT[2] = F3;
        OUT[3] = F4;
        OUT[4] = F5;
        OUT[5] = F6;
        OUT[6] = F7;
        OUT[7] = F8;
    end

endmodule