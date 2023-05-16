//============================================================================
//  AIM65 replica
// 
//  Port to MiSTer
//  Copyright (C) 2023 Fil shinymetal6@gmail.com
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================

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
