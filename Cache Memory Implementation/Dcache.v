/*    CO224  Lab 06
Part 02 - Cache Memory
Group No - 07

E/18/285 - Ranasinghe S.M.T.S.C.
E/18/028 - Ariyawansha P.H.J.U.


*/

`timescale 1ns/100ps

module dcache (
    clock,
    reset,
    read,
    write,
    address,
    writedata,
    readdata,
    busywait,
    mem_readdata,
    mem_address,
    mem_writedata,
    mem_write,
    mem_read,
    mem_busywait
);

 // Input Output Declaration

    input           clock;
    input           reset;
    input           read;
    input           write;
    input[7:0]      address;
    input[7:0]      writedata;
    output reg [7:0]readdata;
    output reg      busywait;

    input           mem_busywait;
    input [31:0]    mem_readdata;
    output reg [5:0]  mem_address;
    output reg [31:0] mem_writedata;
    output reg      mem_read;
    output reg      mem_write;

    integer i;      // Iteration for loops

    reg readaccess;         // Register for read Access
    reg writeaccess;        // Register for write Access

    reg dirty;          // DirtyBit register
    reg valid;          // Valid bit register
    reg [2:0] tag;          // tag that keeps first 5 digits of address
    reg [2:0] index;        // index of arrays
    reg [1:0] OFFSET;       // Offset
    reg hit;                // Flag to check hit or miss. If HIT = 1 it is a hit , otherwise miss
    reg [2:0] C_TAG;        // Cache tag


    // Data word Blocks

    reg [7:0] DATA1;
    reg [7:0] DATA2;
    reg [7:0] DATA3;
    reg [7:0] DATA4;
    reg [31:0] DATA_BLOCK;


    // Data Cache Array

    reg [36:0] CACHE [7:0];                     // 32 Bits for Data, 1 Bit for Dirty Bit, 1 it for Valid Bit, 3 bits for tag


    // Asserting the Busy Wait, Read Access, Write Access

    always @(read, write) begin
        busywait = (read || write)? 1 : 0;                  // Check busywait for every instruction
        readaccess = (read && !write)? 1 : 0;               // Check read for every instruction
        writeaccess = (!read && write)? 1 : 0;              // Check write for every instruction
    end





    // Resetting Valid Bits with reset positive edge

    always @(posedge clock, reset) begin

        if(reset == 1'B1) begin

            busywait = 1'b0;            // Set Busywait to zero when resetting

            #1 for(i=0; i<8; i=i+1) begin
                CACHE[i] <= 37'B0;      // Reset the Cache Memory
            end
        end
    end





    always @(address, readaccess, writeaccess, writedata, CACHE[index]) begin    // CACHE[index] is used here because, then READDATA can be assigned wehn read miss is detected        

        if((readaccess == 1'B1) || (writeaccess == 1'B1)) begin

            // Get offset, index and tag

            #1
            OFFSET = address[1:0];              // Get OFFSET
            index = address[4:2];               // Get index
            C_TAG = address[7:5];                 // Get tag

            // Get Relevant Fields from Cache
            // Get words separatley so it can be write easily
            DATA1 = CACHE[index][7:0];
            DATA2 = CACHE[index][15:8];
            DATA3 = CACHE[index][23:16];
            DATA4 = CACHE[index][31:24];

            // Get 4 words together to write back to main memory
            DATA_BLOCK = CACHE[index][31:0];            // Data block write Back operation

            // Get dirty bit, valid bit and C_TAG for comparison
            valid = CACHE[index][32];
            dirty = CACHE[index][33];
            tag = CACHE[index][36:34];

        end

    end






    // Finding Hit or Miss (tag Comparison)

    always @(valid, C_TAG, tag) begin

        if((valid==1'b1) && (tag==C_TAG)) begin     
            #0.9 hit =1'B1;                     // Identified Hit
        end

        else begin
            #0.9 hit = 1'B0;                    // Identified Miss
        end

    end



    // Returning ReadData according to the offset
    // This time delay will overlap the it determine delay

    always @(DATA1, DATA2, DATA3, DATA4, OFFSET) begin      // When one of followng changes, Read Data output will be Changed
        
        #1
        case (OFFSET)           // Determine Read Data output According to the OFFSEt

            2'b00: readdata = DATA1;
                
            2'b01: readdata = DATA2;
            
            2'b10: readdata = DATA3;

            2'b11: readdata = DATA4;
            
        endcase
    end




    // Resolving misses and hits

    always @(*) begin

        ///////////////////////////////////////////////////////////////////////////
        //                                READ-HIT
        ///////////////////////////////////////////////////////////////////////////

        if((readaccess==1'B1) && (hit==1'B1)) begin

            busywait = 1'B0;                // De asserting busywait Signal
            readaccess = 1'B0;              // Read signal set to Zero
            CACHE[index][32] = 1'B1;        // Set Valid Bit to Zero

        end

    end

        ///////////////////////////////////////////////////////////////////////////
        //                             WRITE-HIT
        ///////////////////////////////////////////////////////////////////////////
    
    always @ (posedge clock) begin
            
        if((writeaccess==1'B1) && (hit==1'B1)) begin

            busywait = 1'B0;            // De-assert busywait
            
            #1                          // 1 time unit delay that cannot overlap with data word decoding
            case (OFFSET)               // Write according to the offset

                2'b00:
                    CACHE[index][7:0] = writedata;

                2'b01:
                    CACHE[index][15:8] = writedata;

                2'b10:
                    CACHE[index][23:16] = writedata;

                2'b11:
                    CACHE[index][31:24] = writedata;
                
            endcase

            CACHE[index][33] = 1'B1;                // Assign Dirty Bit to 1 (values are different in Cache and Main memory)
            CACHE[index][32] = 1'B1;                // Assign Valid Bit to 1
            writeaccess = 1'B0;                     // Set write access to zero
            
        end 
    end






    /* Cache Controller FSM Start */

    parameter IDLE = 3'b000, MEM_READ = 3'b001, MEM_WRITE = 3'b010, FETCH = 3'b011;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((read || write) && !dirty && !hit)  begin
                    next_state = MEM_READ;
                end

                else if ((read || write) && dirty && !hit) begin
                    next_state = MEM_WRITE;
                end

                else begin
                    next_state = IDLE;
                end
            

            MEM_READ:
                if (!mem_busywait) begin
                    next_state = FETCH;
                end

                else begin   
                    next_state = MEM_READ;
                end


            MEM_WRITE:
                if (!mem_busywait) begin
                    next_state = MEM_READ;
                end

                else begin
                    next_state = MEM_WRITE;
                end

            FETCH:
                next_state = IDLE;             // When Memory Read Called, Before ideling Cache Memory Should Be fetched


            
        endcase
    end




    // combinational output logic
    always @(*)
    begin
        case(state)

            IDLE:
            begin
                mem_read = 0;
                mem_write = 0;
                mem_address = 6'dx;
                mem_writedata = 8'dx;
                

            end
         

            MEM_READ: 
            begin
                mem_read = 1;
                mem_write = 0;
                mem_address = {tag, index};
                mem_writedata = 32'dx;
                busywait = 1;  

            end


            MEM_WRITE:
            begin
                mem_read = 0;
                mem_write = 1;
                mem_address = {tag, index};
                mem_writedata = DATA_BLOCK;
                busywait = 1;

            end



            FETCH:
            begin
                mem_read = 0;
                mem_write = 0;
                mem_address = 6'dx;
                mem_writedata = 8'dx;
                busywait = 1;               // Set busywait 1 utill fetching is finished

                // Fecth Cache memory fro main memory
                #1 
                CACHE[index][31:0] = mem_readdata;                      // Fetch from memory
                CACHE[index][32] = 1'B1;                                // Set Valid bit to zero after fetching
                CACHE[index][33] = 1'B0;                                // Set Dirty Bit to zero
                CACHE[index][36:34] = C_TAG;                            // Set tag Address
            end
            
        endcase
    end




    // sequential logic for state transitioning 
    always @(posedge clock, reset)
    begin
        if(reset) begin
            state = IDLE;
        end

        else begin
            state = next_state;
        end
    end

    /* Cache Controller FSM End */

endmodule