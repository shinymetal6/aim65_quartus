`timescale 1ns / 1ps
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
