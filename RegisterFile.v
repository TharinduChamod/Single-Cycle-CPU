/*    CO224  Lab 05
Part 02 - Register File
Group No - 07

E/18/285 - Ranasinghe S.M.T.S.C.
E/18/028 - Ariyawansha P.H.J.U.


*/



module reg_file(IN, OUT1, OUT2, INADDRESS, OUT1ADDRESS, OUT2ADDRESS, WRITE, CLOCK, RESET);

    input [2:0] INADDRESS;                                  // 2 bit input for INADDRESS (register number)
    input [2:0] OUT1ADDRESS, OUT2ADDRESS;                   // 2 bit input for OUT1ADDRESS and OUT2ADDRESS (register numbers)
    input [7:0] IN;                                         // 8 bit input for IN (8 Bit value)
    output reg [7:0] OUT1, OUT2;                            // 8 bit output for OUT1ADDRESS and OUT2ADDRESS(8 bit values)  
    input WRITE;                                            // input wire for WRITE (WRITEENABLE)
    input CLOCK, RESET;                                     // input for CLOCK and RESET (for synchronization)

    integer i;

    reg [7:0] registers [7:0];                              // Creating 8 registers array of 8 bit 



    always@(OUT1ADDRESS,
     OUT2ADDRESS, 
     registers[0],
     registers[1],
     registers[2], 
     registers[3], 
     registers[4], 
     registers[5], 
     registers[6], 
     registers[7])begin              // If one of registers value is changed or OUT1ADDRESS and OUT2ADDRESS is changed always block executed

        #2 OUT1 <=  registers[OUT1ADDRESS];          // Produce 8 bit output for OUT1 when OUT1ADDRESS is changed (with delay of 2 time units)
           OUT2 <=  registers[OUT2ADDRESS];          // Produce 8 bit output for OUT2 when OUT2ADDRESS is changed (with delay of 2 time units)

        
    end


    always@(posedge(CLOCK)) begin                             // When positive edge of clock detected,

        if(RESET) begin                                       // If RESET = 1   
            
            #1 for(i=0; i<8; i=i+1) begin                     // If RESET = 0 assign all registers to 0 (with delay of 1 time unit)
                registers[i] <=  8'B00000000;                 // Set every register to 0
            end

        end

        else if(WRITE) begin                                  // else if WRITE = 1, when RESET != 1 doing write operation

            #1 registers[INADDRESS] <= IN;                    // Write IN value to register which is in INADDRESS 

        end     
    end




endmodule




