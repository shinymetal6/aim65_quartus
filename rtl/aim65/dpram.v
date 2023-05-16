//============================================================================
//  AIM65 replica
// 
//  Port to MiSTer
//  Copyright (C) 2017-2019 Fil shinymetal6@gmail.com
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

module dpram #(parameter
    MEM_WIDTH = 8,
    MEM_DEPTH = 1024,
    ADDR_WIDTH = $clog2(MEM_DEPTH),
    INIT_FILE = "foo.hex")
	(
    input               			wr_clk,
    input               			rd_clk,
    input               			we,
    input               			re,
    input               			reset,
    input       [ADDR_WIDTH - 1:0]	w_addr,
    input       [ADDR_WIDTH - 1:0]	r_addr,
    input       [MEM_WIDTH - 1:0]  	w_data,
    output  reg [MEM_WIDTH - 1:0]	r_data
);

reg [MEM_WIDTH - 1:0]  mem [0:MEM_DEPTH - 1];
always @ (posedge wr_clk) 
begin
    if (we)
        mem[w_addr] <= w_data;
end

always @ (posedge rd_clk) begin
	if (re)
		r_data <= mem[r_addr];
end
/*    
integer cnt;    

initial 
begin
	if (INIT_FILE) 
	    $readmemh(INIT_FILE, mem);
end
*/    
endmodule
