/*    CO224  Lab 05
Part 03 - Register File
Group No - 07

E/18/285 - Ranasinghe S.M.T.S.C.
E/18/028 - Ariyawansha P.H.J.U.


*/

// Import ALu and Register file
`include "ALU.v"
`include "RegisterFile.v"



module cpu(PC, INSTRUCTION, CLK, RESET);

    input [31:0] INSTRUCTION;                              // 32 bit Input for instruction
    input CLK, RESET;                                      // inputs for clock and reset
    output [31:0] PC;                                      // output the value of pc

    reg [7:0] OPCODE, IMMEDIATE;                           // Registers for decoding instruction
    reg [2:0] READREG1, READREG2, WRITEREG;                // Register Inputs for Register File
    reg [7:0] OFFSET;                                      // Register for holding branch addresses in j and beq instruction


    wire COMPLEMENT, WRITEENABLE, ImmediateEnable;         // Registers for Muxes and RegisterFile
    wire [2:0] ALUOP;                                      // Opcode for ALU 
    

    // WIRES TO CONNECT MODULES

    wire [7:0] REGOUT1, REGOUT2;                           // Output for control unit
    wire [7:0] REGOUT2NEGATIVE;                            // Output from 2's complement
    wire [7:0] MUXOUT1;                                    // Output from selecting 2's complement
    wire [7:0] MUXOUT2;                                    // Output from selecting immediate value
    wire [7:0] ALURESULT;                                  // Output from ALU result
    wire ZERO;                                             // ALU output for getting branch
    wire [31:0] NEXT;                                      // next pc value
    wire [31:0] PC_VALUE;                                  // Value of pc to update
    wire [31:0] TARGET;                                    // Target address
    wire [1:0] PC_SELECT;                                  // Selector for pc
    wire SHIFT_TYPE;                                       // Selecting SHIFT type
    wire BNE;                                              // wire for branch not equal



    always@(INSTRUCTION) begin                           // Decoding Instruction

        OPCODE = INSTRUCTION [31:24];
        OFFSET = INSTRUCTION [23:16];
        WRITEREG = INSTRUCTION [18:16];
        READREG1 = INSTRUCTION [10:8];
        READREG2 = INSTRUCTION [2:0];
        IMMEDIATE = INSTRUCTION [7:0];
        
    end

    
    PC PC1(CLK , RESET , PC , NEXT);

    TARGET_PC TARGET_PC1(PC ,PC_VALUE , OFFSET ,TARGET ) ;

    PC_UPDATE PC_UPDATE1(PC_SELECT , ZERO , NEXT , PC_VALUE , TARGET, BNE);
                            
    control_unit CONTROLUNIT(OPCODE, COMPLEMENT, ImmediateEnable, ALUOP, WRITEENABLE, PC_SELECT, SHIFT_TYPE);                // Generating control signals

    reg_file REGISTERFILE(ALURESULT, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);         // Instance of Register File

    COMP_2S NEGATIVE_VAL(REGOUT2, REGOUT2NEGATIVE);                       // Calcultaing 2's Complement of REGOUT2

    MUX2x1 MUX1(REGOUT2, REGOUT2NEGATIVE, COMPLEMENT, MUXOUT1);           // Select 2's Complement for SUB Instruction

    MUX2x1 MUX2(MUXOUT1, IMMEDIATE, ImmediateEnable, MUXOUT2);            // Select Immediate value for ALU

    ALU ALU1(REGOUT1, MUXOUT2, ALURESULT, ALUOP, ZERO, SHIFT_TYPE);                   // ALU Instance

    BNE BNE1(PC_SELECT, ZERO, BNE);                                  // BNE SIgnal



    
endmodule





module COMP_2S(INPUT, OUTPUT);                        //Module for 2s Complement

    input [7:0] INPUT;                                //Declaring input
    output reg [7:0] OUTPUT;                          //Declaring output

    always@(INPUT) begin
         
       #1 OUTPUT = ~INPUT + 8'B00000001;              //Negate the value with 1 time unit delay

    end
endmodule



module control_unit(OPCODE, COMPLEMENT, IMMEDIATE, ALUOP, WRITEENABLE, PC_SELECTOR, SHIFT_TYPE);            // Module for control unit

    input [7:0] OPCODE;                                  // Declare inputs for OPCODE
    output reg SHIFT_TYPE;                                    // Select LEFT shit or RIGHT Shift
    output reg[2:0] ALUOP;                               // Output for ALU opcode
    output reg WRITEENABLE;                              // Output for WRITEENABLE
    output reg COMPLEMENT;                               // Output for select 2s Complement
    output reg IMMEDIATE;                                // Output for select IMMEDIATE or not
    output reg [1:0] PC_SELECTOR;                        // Selector for jump or beq

    always@(OPCODE) begin
        
        case(OPCODE)

            8'B00000000:        // loadi Instruction
            begin #1
                assign ALUOP = 3'B000;                       // Signals for FORWARD
                assign WRITEENABLE = 1'B1;                   // Enable WRITEENABLE
                assign IMMEDIATE = 1'B1;                     // Use immediate value
                assign COMPLEMENT = 1'B0;                    // Use positive values
                assign PC_SELECTOR = 2'B00;                  // Selector jump or beq
                assign SHIFT_TYPE = 1'B0;                    // Select shifting
                
            end



            8'B00000001:         // mov instruction  
            begin #1                     
                assign ALUOP = 3'B000;                       // Signals for FORWARD
                assign WRITEENABLE = 1'B1;                   // WRITEENABLE set to 0
                assign IMMEDIATE = 1'B0;                     // Don't care about OPERAND2
                assign COMPLEMENT = 1'B0;                    // Use positive values
                assign PC_SELECTOR = 2'B00;                  // Select jump or beq
                assign SHIFT_TYPE = 1'B0;                    // Select shifting

            end


            8'B00000010:        // add instruction 
            begin #1                    
                assign ALUOP = 3'B001;                       // Signals for ADD
                assign WRITEENABLE = 1'B1;                   // Enable WRITEENABLE
                assign IMMEDIATE = 1'B0;                     // Don't care about OPERAND2
                assign COMPLEMENT = 1'B0;                    // Use positive value
                assign PC_SELECTOR = 2'B00;                  // Select jump or beq
                assign SHIFT_TYPE = 1'B0;                    // Select shifting   

            end


            8'B00000011:        // sub Instruction
            begin #1                    
                assign ALUOP = 3'B001;                       // Signals For SUB
                assign WRITEENABLE = 1'B1;                   // Enable WRITEENABLE
                assign IMMEDIATE = 1'B0;                     // Don't care about OPERAND2
                assign COMPLEMENT = 1'B1;                    // Use 2s Complement
                assign PC_SELECTOR = 2'B00;                  // Select jump or beq
                assign SHIFT_TYPE = 1'B0;                    // Select shifting

            end


            8'B00000100:         // and instruction    
            begin #1                
                assign ALUOP = 3'B010;                       // Signals for AND
                assign WRITEENABLE = 1'B1;                   // Enable WRITEENABLE
                assign IMMEDIATE = 1'B0;                     // Don't care about OPERAND2
                assign COMPLEMENT = 1'B0;                    // Use positive value
                assign PC_SELECTOR = 2'B00;                  // Select jump or beq
                assign SHIFT_TYPE = 1'B0;                    // Select shifting

            end


            8'B00000101:        // or instruction  
            begin #1                 
                assign ALUOP = 3'B011;                       // Signals for OR
                assign WRITEENABLE = 1'B1;                   // Enable WRITEENABLE
                assign IMMEDIATE = 1'B0;                     // Don't care about OPERAND2
                assign COMPLEMENT = 1'B0;                    // Use positive value
                assign PC_SELECTOR = 2'B00;                  // Select jump or beq
                assign SHIFT_TYPE = 1'B0;                    // Select shifting

            end


            8'B00000110:        // j instruction  (jump to address)
            begin #1                 
                assign ALUOP = 3'B001;                       // Signals for AND
                assign WRITEENABLE = 1'B0;                   // Enable WRITEENABLE
                assign IMMEDIATE = 1'B0;                     // Don't care about OPERAND2
                assign COMPLEMENT = 1'B0;                    // Use positive value
                assign PC_SELECTOR = 2'B01;                  // Select jump or beq
                assign SHIFT_TYPE = 1'B0;                    // Select shifting

            end


            8'B00000111:        // beq instruction  
            begin #1                 
                assign ALUOP = 3'B001;                       // Signals for AND
                assign WRITEENABLE = 1'B0;                   // Enable WRITEENABLE
                assign IMMEDIATE = 1'B0;                     // Don't care about OPERAND2
                assign COMPLEMENT = 1'B1;                    // Use negative value to compare variables using SUB operation and output of ZERO of ALU module
                assign PC_SELECTOR = 2'B10;                  // Select jump or beq
                assign SHIFT_TYPE = 1'B0;                    // Select shifting

            end


            8'B00001010:        // left shift instruction  
            begin #1                 
                assign ALUOP = 3'B100;                       // Signals for AND
                assign WRITEENABLE = 1'B1;                   // Enable WRITEENABLE
                assign IMMEDIATE = 1'B1;                     // care about OPERAND2
                assign COMPLEMENT = 1'B0;                    // Use negative value to compare variables using SUB operation and output of ZERO of ALU module
                assign PC_SELECTOR = 2'B00;                  // Select jump or beq
                assign SHIFT_TYPE = 1'B1;                    // Select shifting

            end


            8'B00001011:        // right shift instruction  
            begin #1                 
                assign ALUOP = 3'B100;                       // Signals for AND
                assign WRITEENABLE = 1'B1;                   // Enable WRITEENABLE
                assign IMMEDIATE = 1'B1;                     // care about OPERAND2
                assign COMPLEMENT = 1'B0;                    // Use negative value to compare variables using SUB operation and output of ZERO of ALU module
                assign PC_SELECTOR = 2'B00;                  // Select jump or beq
                assign SHIFT_TYPE = 1'B0;                    // Select shifting

            end

            8'B00001111:        // BNE instruction  
            begin #1                 
                assign ALUOP = 3'B001;                       // Signals for AND
                assign WRITEENABLE = 1'B0;                   // Enable WRITEENABLE
                assign IMMEDIATE = 1'B0;                     // Don't care about OPERAND2
                assign COMPLEMENT = 1'B1;                    // Use negative value to compare variables using SUB operation and output of ZERO of ALU module
                assign PC_SELECTOR = 2'B10;                  // Select jump or beq
                assign SHIFT_TYPE = 1'B0;                    // Select shifting

            end

         
        endcase
    end
endmodule



module MUX2x1(DATA1, DATA2, SELECT, RESULT);           // 2x1 Multiplexer for 2s Complement selecting and immediate value selecting

    input [7:0] DATA1, DATA2;                          // Input data
    input SELECT;                                      // Selector
    output reg [7:0] RESULT;                           // Output result

    always @(SELECT, DATA1, DATA2) begin

        case(SELECT)                                   // Select selector bit of multiplexer

            1'B0:
                assign RESULT = DATA1;                            // if selector is 0 RESULT = DATA1

            1'B1:
                assign RESULT = DATA2;                            // if selector is 1 RESULT = DATA2

            default:
                assign RESULT = 8'Bx;                             // Undefined output for default case

        endcase    
    end
endmodule




module MUX_32BIT_2x1(DATA1, DATA2, SELECT, RESULT);    // 32 bit MUX for branching

    input [31:0] DATA1, DATA2;                         // 32 bit input for mux
    input SELECT;                                      // Selector for mux
    output reg[31:0] RESULT;                              // 32 bit mux output

    always@(DATA1, DATA2, SELECT) begin
        
        case(SELECT)                                   // Select selector bit of multiplexer

            1'B0:
                assign RESULT = DATA1;                            // if selector is 0 RESULT = DATA1

            1'B1:
                assign RESULT = DATA2;                            // if selector is 1 RESULT = DATA2

            default:
                assign RESULT = DATA1;                             // Undefined output for default case

        endcase 
    end

endmodule



module TARGET_PC(PC ,PC_TEMP , OFFSET ,TARGET ) ; //offset is from instruction

    // decalring variables

    output reg [31:0] PC_TEMP ;
    input [7:0] OFFSET ;
    input [31:0] PC ;
    output reg [31:0] TARGET ;
    reg [31:0] temp;

    wire [31:0] SE;         // Sign extend
    wire [31:0] VAL;        // shifting
    

    SIGN_EXTEND SE1(OFFSET, SE);   // Sign extend
    SHIFTER S1(SE, VAL);           // Shifting

    always@(VAL) begin
        temp = VAL;                // 
    end

    always @(temp) begin
        #2 TARGET = PC_TEMP + temp ;                    // Calculate target address
    end

    always @(PC) begin
        #1 PC_TEMP = PC + 32'd4 ;                       // Update tempory pc
    end

endmodule 



//module for next PC value
module PC_UPDATE(SELECT , ZERO , NEXT, PC_VALUE , TARGET, BNE);

    // Declare input output
    input [31:0] PC_VALUE , TARGET ;
    input [1:0] SELECT ;
    input ZERO ;
    input BNE;
    output reg [31:0] NEXT ;


    always @(SELECT , ZERO , PC_VALUE , TARGET) begin
        
        // SELECT PC next
        if(SELECT==3'b01)begin                                 // jump instruction
            NEXT = TARGET ;
        end 
        
        else if (SELECT==3'b10 && ZERO==1'b1) begin            // if beq instruction
            NEXT = TARGET;
        end 
     
        else begin
            NEXT = PC_VALUE;
        end
    end

    always@(PC_VALUE, TARGET, BNE) begin
        if(BNE) begin
            NEXT = TARGET;
        end
    end


endmodule



// Calculate PC

module PC (CLK , RESET , PC  , NEXT_PC);

    // Declaring input outputs
    input CLK ,RESET;
    output reg[31:0] PC ;
    input [31: 0] NEXT_PC ; // gives the next PC value


    // Updating PC with positive clock edge

    always @(posedge CLK) begin
        if ( RESET == 1'b1 ) begin
            #1 PC = 32'b00000000000000000000000000000000;  // Reset pc if reset is high
        end else  begin
            #1 PC = NEXT_PC ;
        end  
        
    end

    
endmodule

// Module for sign extend

module SIGN_EXTEND(IN, OUT);

    // Declaring input and outputs
    input [7:0] IN;
    output [31:0] OUT;

    assign OUT = $signed(IN);    // sign extension

endmodule



// Module for shifting

module SHIFTER(IN, OUT);

    // Declaring input and outputs
    input [31:0] IN;
    output [31:0] OUT;

    assign OUT = IN<<2;         // Shifting

endmodule


module BNE(BEQ, ZERO, OUT);     // Calculate BNE

    // Branch not equal
    input [1:0] BEQ;
    input ZERO;
    output OUT;

    and A1(OUT, BEQ[1], ~BEQ[0], ~ZERO);  // Calculate BNE

endmodule