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

module aim65 (
	input         	pixel_clk,
	input         	cpu_clk,
	input         	reset,	 
	output  reg    	led_user,
	output  [1:0] 	led_power,
	output  [1:0] 	led_disk,	
	
    input			kbd_not_tty,
    input           rx_data,
    output 		    tx_data,
	input [1:0]  	ext_selector,
	
	input         	scandouble,
	input [10:0]  	ps2_key,
	output     		ce_pix,
	input  [1:0] 	color,

	output     		HBlank,
	output     		HSync,
	output     		VBlank,
	output     		VSync,

	output  [7:0] 	r,
	output  [7:0] 	g,
	output  [7:0] 	b
);
// led user
integer counter;
always@(posedge cpu_clk)
begin
	if (reset==1)
		counter = 0;
	else
	begin
		counter = counter + 1;
		if (counter >= 900000 )
			led_user = 1;
		else 
			led_user = 0;
		if ( counter >= 1000000 )
			counter = 0;
	end
end

assign led_power = kbd_not_tty ? 2'b10 : 2'b11;

// decoder
wire [7:0] ram_do;
wire [7:0] video_do;
wire [7:0] z22_do;
wire [7:0] z23_do;
wire [7:0] z24_do;
wire [7:0] z25_do;
wire [7:0] z26_do; 
wire [7:0] z25_26_do;
wire [7:0] csa0_6522_do;
wire [7:0] csa4_6532_do;
wire [7:0] csa8_6522_do;
wire [7:0] csac_6520_do;  

wire ram_cs 		=	(addr[15:12] < 4'h8 ) ? 1'b1 : 1'b0;
wire video_cs 		=	(addr[15:12] == 4'h9 ) ? 1'b1 : 1'b0;

wire z22_cs			=	(addr[15:12] == 4'hf) ? 1'b1 : 1'b0; 	
wire z23_cs			=	(addr[15:12] == 4'he) ? 1'b1 : 1'b0; 	
wire z24_cs			=	(addr[15:12] == 4'hd) ? 1'b1 : 1'b0; 	
wire z25_cs			=	(addr[15:12] == 4'hc) ? 1'b1 : 1'b0; 	
wire z26_cs			=	(addr[15:12] == 4'hb) ? 1'b1 : 1'b0; 
wire csa0_6522 		= 	(addr[15:8] == 8'ha0) ? 1'b1 : 1'b0;
wire csa4_6532 		= 	(addr[15:8] == 8'ha4) ? 1'b1 : 1'b0;
wire csa8_6522 		= 	(addr[15:8] == 8'ha8) ? 1'b1 : 1'b0;
wire csac_6520 		= 	(addr[15:8] == 8'hac) ? 1'b1 : 1'b0; 

reg video_cs_prev = 1'b0;
always @(posedge cpu_clk) video_cs_prev <= video_cs;
reg csa0_6522_prev = 1'b0;
always @(posedge cpu_clk) csa0_6522_prev <= csa0_6522;
reg csa4_6532_prev = 1'b0;
always @(posedge cpu_clk) csa4_6532_prev <= csa4_6532;
reg csa8_6522_prev = 1'b0;
always @(posedge cpu_clk) csa8_6522_prev <= csa8_6522;
reg csac_6520_prev = 1'b0;
always @(posedge cpu_clk) csac_6520_prev <= csac_6520;
	

//
// RAM
//

reg ram_cs_prev = 1'b0;
always @(posedge cpu_clk) ram_cs_prev <= ram_cs;

`define RAM_WIDTH 8
`define RAM_DEPTH 32768
`define RAM_ADDR_WIDTH $clog2(`RAM_DEPTH) 	
ram #(
    .ADDR_WIDTH(`RAM_ADDR_WIDTH),
    .DATA_WIDTH(`RAM_WIDTH),
    .DEPTH(`RAM_DEPTH)
	)
ram(
    .clk (cpu_clk),
    .cs (ram_cs),
    .rw (rw ),
    .addr (addr[`RAM_ADDR_WIDTH-1:0]),
    .data_in (cpu_dout),
    .data_out (ram_do)
);

//
// Z22
//
reg z22_cs_prev = 1'b0;
always @(posedge cpu_clk) z22_cs_prev <= z22_cs;
`define Z22_ROM_WIDTH 8
`define Z22_ROM_DEPTH 4096
`define Z22_ROM_ADDR_WIDTH $clog2(`Z22_ROM_DEPTH) 
rom #(
    .ADDR_WIDTH(`Z22_ROM_ADDR_WIDTH),
    .DATA_WIDTH(`Z22_ROM_WIDTH),
    .DEPTH(`Z22_ROM_DEPTH),
    .INIT_FILE("D:/SVN/verilog/Projects/aim65/aim65_quartus/rtl/aim65/ROM/monitor_z22.hex"))
z22(
    .clk (cpu_clk),
    .cs (z22_cs),
    .addr (addr[`Z22_ROM_ADDR_WIDTH-1:0]),
    .data_out (z22_do)
);

//
// Z23
//
reg z23_cs_prev = 1'b0;
always @(posedge cpu_clk) z23_cs_prev <= z23_cs;
`define Z23_ROM_WIDTH 8
`define Z23_ROM_DEPTH 4096
`define Z23_ROM_ADDR_WIDTH $clog2(`Z23_ROM_DEPTH) 
rom #(
    .ADDR_WIDTH(`Z23_ROM_ADDR_WIDTH),
    .DATA_WIDTH(`Z23_ROM_WIDTH),
    .DEPTH(`Z23_ROM_DEPTH),
    .INIT_FILE("D:/SVN/verilog/Projects/aim65/aim65_quartus/rtl/aim65/ROM//monitor_z23.hex"))
z23(
    .clk (cpu_clk),
    .cs (z23_cs),
    .addr (addr[`Z23_ROM_ADDR_WIDTH-1:0]),
    .data_out (z23_do)
);

//
// Z24
//
reg z24_cs_prev = 1'b0;
always @(posedge cpu_clk) z24_cs_prev <= z24_cs;
`define Z24_ROM_WIDTH 8
`define Z24_ROM_DEPTH 4096
`define Z24_ROM_ADDR_WIDTH $clog2(`Z24_ROM_DEPTH) 
rom #(
    .ADDR_WIDTH(`Z24_ROM_ADDR_WIDTH),
    .DATA_WIDTH(`Z24_ROM_WIDTH),
    .DEPTH(`Z24_ROM_DEPTH),
    .INIT_FILE("D:/SVN/verilog/Projects/aim65/aim65_quartus/rtl/aim65/ROM//assembler_z24.hex"))
z24(
    .clk (cpu_clk),
    .cs (z24_cs),
    .addr (addr[`Z24_ROM_ADDR_WIDTH-1:0]),
    .data_out (z24_do)
);

//
// Z25 ROM
//
reg z25_cs_prev = 1'b0;
always @(posedge cpu_clk) z25_cs_prev <= z25_cs;

`define Z25_ROM_WIDTH 8
`define Z25_ROM_DEPTH 4096
`define Z25_ROM_ADDR_WIDTH $clog2(`Z25_ROM_DEPTH) 
rom #(
    .ADDR_WIDTH(`Z25_ROM_ADDR_WIDTH),
    .DATA_WIDTH(`Z25_ROM_WIDTH),
    .DEPTH(`Z25_ROM_DEPTH),
    .INIT_FILE("D:/SVN/verilog/Projects/aim65/aim65_quartus/rtl/aim65/ROM/basic_z25.hex")) 
z25_basic(
    .clk (cpu_clk),
    .cs (z25_cs),
    .addr (addr[`Z25_ROM_ADDR_WIDTH-1:0]),
    .data_out (z25_basic_do)
);

`define Z25_ROM_WIDTH 8
`define Z25_ROM_DEPTH 4096
`define Z25_ROM_ADDR_WIDTH $clog2(`Z25_ROM_DEPTH) 
rom #(
    .ADDR_WIDTH(`Z25_ROM_ADDR_WIDTH),
    .DATA_WIDTH(`Z25_ROM_WIDTH),
    .DEPTH(`Z25_ROM_DEPTH),
    .INIT_FILE("D:/SVN/verilog/Projects/aim65/aim65_quartus/rtl/aim65/ROM/forth_z25.hex")) 
z25_forth(
    .clk (cpu_clk),
    .cs (z25_cs),
    .addr (addr[`Z25_ROM_ADDR_WIDTH-1:0]),
    .data_out (z25_forth_do)
);

`define Z25_ROM_WIDTH 8
`define Z25_ROM_DEPTH 4096
`define Z25_ROM_ADDR_WIDTH $clog2(`Z25_ROM_DEPTH) 
rom #(
    .ADDR_WIDTH(`Z25_ROM_ADDR_WIDTH),
    .DATA_WIDTH(`Z25_ROM_WIDTH),
    .DEPTH(`Z25_ROM_DEPTH),
    .INIT_FILE("D:/SVN/verilog/Projects/aim65/aim65_quartus/rtl/aim65/ROM/pl65_z25.hex")) 
z25_pl65(
    .clk (cpu_clk),
    .cs (z25_cs),
    .addr (addr[`Z25_ROM_ADDR_WIDTH-1:0]),
    .data_out (z25_pl65_do)
);

//
// Z26 ROM
//
reg z26_cs_prev = 1'b0;
always @(posedge cpu_clk) z26_cs_prev <= z26_cs;
	
`define Z26_ROM_WIDTH 8
`define Z26_ROM_DEPTH 4096
`define Z26_ROM_ADDR_WIDTH $clog2(`Z26_ROM_DEPTH) 
rom #(
    .ADDR_WIDTH(`Z26_ROM_ADDR_WIDTH),
    .DEPTH(`Z26_ROM_DEPTH),
    .INIT_FILE("D:/SVN/verilog/Projects/aim65/aim65_quartus/rtl/aim65/ROM/basic_z26.hex")) 
z26_basic(
    .clk (cpu_clk),
    .cs (z26_cs),
    .addr (addr[`Z26_ROM_ADDR_WIDTH-1:0]),
    .data_out (z26_basic_do)
);								 

`define Z26_ROM_WIDTH 8
`define Z26_ROM_DEPTH 4096
`define Z26_ROM_ADDR_WIDTH $clog2(`Z26_ROM_DEPTH) 
rom #(
    .ADDR_WIDTH(`Z26_ROM_ADDR_WIDTH),
    .DEPTH(`Z26_ROM_DEPTH),
    .INIT_FILE("D:/SVN/verilog/Projects/aim65/aim65_quartus/rtl/aim65/ROM/forth_z26.hex")) 
z26_forth(
    .clk (cpu_clk),
    .cs (z26_cs),
    .addr (addr[`Z26_ROM_ADDR_WIDTH-1:0]),
    .data_out (z26_forth_do)
);								 

`define Z26_ROM_WIDTH 8
`define Z26_ROM_DEPTH 4096
`define Z26_ROM_ADDR_WIDTH $clog2(`Z26_ROM_DEPTH) 
rom #(
    .ADDR_WIDTH(`Z26_ROM_ADDR_WIDTH),
    .DEPTH(`Z26_ROM_DEPTH),
    .INIT_FILE("D:/SVN/verilog/Projects/aim65/aim65_quartus/rtl/aim65/ROM/pl65_z26.hex")) 
z26_pl65(
    .clk (cpu_clk),
    .cs (z26_cs),
    .addr (addr[`Z26_ROM_ADDR_WIDTH-1:0]),
    .data_out (z26_pl65_do)
);								 

// data mux for applications 
wire [7:0]	z25_basic_do,z25_forth_do,z25_pl65_do;	
wire [7:0]	z26_basic_do,z26_forth_do,z26_pl65_do;	

assign z25_do =
    (ext_selector == 2'b01) ? z25_basic_do :
    (ext_selector == 2'b10) ? z25_forth_do :
    (ext_selector == 2'b11) ? z25_pl65_do :
    8'h00;	
	
assign z26_do =
    (ext_selector == 2'b01) ? z26_basic_do :
    (ext_selector == 2'b10) ? z26_forth_do :
    (ext_selector == 2'b11) ? z26_pl65_do :
    8'h00;	
	
// Peripherals 
`define DUMMY_VAL 8'h00
`define DUMMY_VALH 8'hff

wire [7:0] csa0_via6522_paOut,csa0_via6522_pbOut;
wire [7:0] csa8_via6522_portb_in = {1'b1,rx_data,1'b0,1'b0,kbd_not_tty,1'b0,1'b0,1'b0};
wire [7:0] csa8_via6522_paOut,csa8_via6522_pbOut;
wire ca1_in=1'b1,ca2_in=1'b1, cb1_in=1'b1,cb2_in=1'b1;
assign tx_data = csa8_via6522_pbOut[2];

via6522 csa8_via6522 (
	.cs(csa8_6522),
	.clk(cpu_clk),
	.reset(reset),
	.rw(rw),
	.addr(addr[3:0]),
	.dataIn(cpu_dout),
	.dataOut(csa8_6522_do),
	.paIn(`DUMMY_VAL),
	.paOut(csa8_via6522_paOut),
	.pbIn(csa8_via6522_portb_in),
	.pbOut(csa8_via6522_pbOut),
	.ca1_in(1'b1),
	.ca2_out(ca2_out),
	.ca2_in(1'b1),
	.cb1_out(cb1_out),
	.cb1_in(cb1_in),
	.cb2_out(cb2_out),
	.cb2_in(cb2_in),
	.irq(irq)
);	
		
wire [7:0] csa4_riot6532_pbOut;
riot6532 csa4_riot6532 (
	.cs(csa4_6532),
	.clk(cpu_clk),
	.reset(reset),
	.rw(rw),
	.rs(addr[7]),
	.addr(addr[6:0]),
	.dataIn(cpu_dout),
	.dataOut(csa4_6532_do),
	.paIn(`DUMMY_VALH),
	.paOut(csa4_riot6532_paOut),
	.pbIn(csa4_riot6532_pbIn),
	.pbOut(csa4_riot6532_pbOut),
	.irq(irq)
); 
wire [7:0] csa4_riot6532_paOut,csa4_riot6532_pbIn;

aim65_keyboard aim65_keyboard (
	.reset(reset),
	.clk(cpu_clk),
	.ps2_key(ps2_key),
	.video_clear(video_clear),
	.csa4_riot6532_paOut(csa4_riot6532_paOut),
	.csa4_riot6532_pbIn(csa4_riot6532_pbIn)
);

pia6520 csac_pia6520 (
	.cs(csac_6520),
	.clk(cpu_clk),
	.reset(reset),
	.rw(rw),
	.addr(addr[1:0]),
	.dataIn(cpu_dout),
	.dataOut(csac_6520_do),
	.paIn(`DUMMY_VAL),
	.paOut(csac_pia6520_porta_out),
	.pbIn(`DUMMY_VAL),
	.pbOut(csac_pia6520_portb_out),
	.ca1_in(ca1_in),
	.ca2_out(ca2_out),
	.ca2_in(ca2_in),
	.cb1_in(cb1_in),
	.cb2_out(cb2_out),
	.cb2_in(cb2_in),
	.irqa(irqa),
	.irqb(irqb)
);

wire	[7:0]	csac_pia6520_porta_out,csac_pia6520_portb_out; 
wire	[9:0]	video_addr;
wire	[7:0]	video_data;
wire			video_ce,video_we,video_vscroll;

aim65_display aim65_display (
	.clk(cpu_clk),
	.reset(reset),
	.ce1(csac_pia6520_porta_out[2]),
	.ce2(csac_pia6520_porta_out[3]),
	.ce3(csac_pia6520_porta_out[4]),
	.ce4(csac_pia6520_porta_out[5]),
	.ce5(csac_pia6520_porta_out[6]),
	.w(csac_pia6520_porta_out[7]),
	.daddr(csac_pia6520_porta_out[1:0]),
	.cu(csac_pia6520_portb_out[7]),
	.ddata({1'b0,csac_pia6520_portb_out[6:0]}),
	.video_clear(video_clear),
	.video_vscroll(video_vscroll),
	.video_addr(video_addr),
	.video_data(video_data),
	.video_ce(video_ce),
	.video_we(video_we)
);

//
// Video
//
video video_aim65 (
	.pixel_clk(pixel_clk),
	.cpu_clk(cpu_clk),
	.reset(reset),
	.video_clear(video_clear),
	.video_vscroll(video_vscroll),
	.video_we(video_we),
	.video_ce(video_ce),
	.video_addr(video_addr),
	.video_data(video_data),
	.scandouble(scandouble),
	.ce_pix(ce_pix),
	.color(color),
	.HBlank(HBlank),
	.HSync(HSync),
	.VBlank(VBlank),
	.VSync(VSync),
	.r(r),
	.g(g),
	.b(b)
	);
//
// CPU
//

wire	rdy = 1;
wire	sync;
wire	[7:0] instruction;
wire [15:0] addr;
wire [7:0] cpu_dout;
wire [7:0] cpu_din;

cpu_65c02 cpu(
    .clk (cpu_clk),
    .reset (reset),
    .AB (addr),
    .DI (cpu_din),
    .DO (cpu_dout),
    .RW (rw),
    .IRQ (1'b0),
    .NMI (1'b0),
    .SYNC (sync),
    //.instruction (instruction),
    .RDY (rdy)
);

assign cpu_din =
    ram_cs_prev ? ram_do :
    video_cs_prev ? video_do :
    z22_cs_prev ? z22_do :
    z23_cs_prev ? z23_do :
    z24_cs_prev ? z24_do :
    z25_cs_prev ? z25_do :
    z26_cs_prev ? z26_do :
    csa0_6522_prev ? csa0_6522_do :
    csa4_6532_prev ? csa4_6532_do :
    csa8_6522_prev ? csa8_6522_do :
    csac_6520_prev ? csac_6520_do :
    8'h00;	

endmodule
