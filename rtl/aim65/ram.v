/* Copyright (c) 2018 Upi Tamminen, All rights reserved.
 * See the LICENSE file for more information */

module ram #(parameter
    ADDR_WIDTH = 16,
    DATA_WIDTH = 8,
    DEPTH = 1024)
(
    input wire clk,
    input wire cs,
    input wire [ADDR_WIDTH-1:0] addr, 
    input wire rw,
    input wire [DATA_WIDTH-1:0] data_in,
    output reg [DATA_WIDTH-1:0] data_out 
);

reg [DATA_WIDTH-1:0] memory_array [0:DEPTH-1]; 

always @(posedge clk) 
begin
    if (cs & ~rw )
        memory_array[addr] <= data_in;
    data_out <= memory_array[addr];
end		

// Initialization (if available) 
// synopsys translate_off 
integer i;
initial
begin
	
	for (i = 0; i < DEPTH; i = i + 1) 
	    memory_array[i] <= 8'hff;
end	
// synopsys translate_on    
endmodule
