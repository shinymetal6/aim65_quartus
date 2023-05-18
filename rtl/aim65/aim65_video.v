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

module aim65_video #(parameter FONT_FILENAME = "rtl/aim65/ROM/ATIx550_8x8.HEX")
(
	input         	pixel_clk,
	input         	cpu_clk,
	input         	reset,
	input 			video_clear,
	input         	video_vscroll,
	input         	video_ce,
	input         	video_we,
	input [9:0]		video_addr,
	input [7:0]   	video_data,
	
	input         	scandouble,
	output reg    	ce_pix,
	input  [1:0] 	color,

	output reg    	HBlank,
	output reg    	HSync,
	output reg    	VBlank,
	output reg    	VSync,

	output reg [7:0] r,
	output reg [7:0] g,
	output reg [7:0] b
);

// horizontal timings
parameter HVIDEO_LEN	= 320;           			// active pixels
parameter HSYNC_LEN 	= 80;           			// hsync len
parameter HSYNC_START 	= 40 + HVIDEO_LEN;  		// hsync start
parameter HSYNC_END 	= HSYNC_START + HSYNC_LEN;  // hsync start
parameter HVIDEO_TOTAL	= 448;           			// total h video

// vertical timings
parameter VVIDEO_LEN 	= 200;           			// active line
parameter VSYNC_LEN 	= 15;           			// vsync len
parameter VSYNC_START 	= 26 + VVIDEO_LEN; 			// vsync start
parameter VSYNC_END 	= VSYNC_START + VSYNC_LEN;  // hsync start
parameter VVIDEO_TOTAL 	= 254;    					// total v video

/* memories */
wire  	[9:0]	ram_char_addr;	// Video RAM intf
assign 			ram_char_addr = ~HBlank ? {vc_addr + hc[8:3]} : vc_addr;
wire 	[7:0]	ram_char_data;

wire  	[9:0]	ram_video_int_addr;	// Video RAM intf
wire 	[7:0]	ram_video_int_data;
wire 			ram_video_int_we;
wire			ram_video_int_clk;

wire  	[10:0]  rom_char_addr;	// char rom intf
assign 			rom_char_addr   = {ram_char_data, vc[2:0]};
wire 	[7:0]   rom_char_data;

assign	ram_video_int_addr = clear_request ? internal_addr-4 : video_addr;
assign	ram_video_int_data = clear_request ? 8'h0 : video_data;
assign	ram_video_int_we   = clear_request ? 1'b1 : (video_we & video_ce);



`define CHAR_RAM_WIDTH 8
`define CHAR_RAM_DEPTH 1024
`define CHAR_RAM_ADDR_WIDTH $clog2(`CHAR_RAM_DEPTH) 
dpram #(
    .MEM_WIDTH(`CHAR_RAM_WIDTH),
    .MEM_DEPTH(`CHAR_RAM_DEPTH)
	)
	char_ram 
	(
	.wr_clk(cpu_clk),
	.rd_clk(pixel_clk),
	.we(ram_video_int_we),
	.re(1'b1),
	.reset(reset),
	.w_addr(ram_video_int_addr),
	.w_data(ram_video_int_data),
	.r_addr(ram_char_addr),
	.r_data(ram_char_data)
); 

`define FONT_ROM_WIDTH 8
`define FONT_ROM_DEPTH 2048
`define FONT_ROM_ADDR_WIDTH $clog2(`FONT_ROM_DEPTH) 
rom #(
    .ADDR_WIDTH(`FONT_ROM_ADDR_WIDTH),
    .DEPTH(`FONT_ROM_DEPTH),
    .INIT_FILE(FONT_FILENAME)
	) 
font_rom(
    .clk (pixel_clk),
    .cs (1'b1),
    .addr (rom_char_addr),
    .data_out (rom_char_data)
);
/* video registers */

reg   [8:0] hc;
reg   [7:0] vc;
wire  [9:0] vc_addr;
reg   [9:0] vc_addr_local;
reg			i_HBlank;	
reg			i_HSync;	
reg			i_VBlank;	
reg			i_VSync;	
reg			video_vscroll0,video_vscroll1,video_vscroll_signal;	
assign		vc_addr = vc_addr_local;

reg   [9:0] internal_addr;
reg   		clear_request;
reg   		line_clear;
reg		[3:0]	line_clear_c;

always @(posedge cpu_clk) 
begin
	if ( reset ) 				 
	begin
		internal_addr = 0;
		clear_request = 0;
	end
	else
	begin	
		if ( clear_request )
		begin
			internal_addr = internal_addr + 1;
			if ( internal_addr == 1000 )				
				clear_request = 0;
		end	
		if ( video_clear )
		begin
			internal_addr = 0;
			clear_request = 1;
		end
		if ( line_clear )
		begin
			internal_addr = 960;
			clear_request = 1;
		end
	end
end

always @(posedge pixel_clk) begin 
	if(scandouble) 
		ce_pix <= 1;
	else 
		ce_pix <= ~ce_pix;
		
	if(reset) begin
		hc <= 0;
		vc <= VVIDEO_TOTAL-1;
		i_HBlank <= 1;
		i_VBlank <= 0;
		i_HSync <= 1;
		i_VSync <= 0;
		vc_addr_local <= 0;
		video_vscroll0 <= 0;
		video_vscroll1 <= 0;
		video_vscroll_signal <= 0;
		line_clear <= 0;
		line_clear_c = 4'b0000;
	end
	else
	begin
		video_vscroll1 = video_vscroll0;
		video_vscroll0 = video_vscroll;
		
		if ( line_clear )
			line_clear_c = line_clear_c + 1'b1;
		else
			line_clear_c = 4'b0000;
			
		if ( ~video_vscroll1 & video_vscroll0 )
		begin
			video_vscroll_signal <= 1;
			line_clear = 1;
			vc_addr_local = vc_addr_local + 40;
			if (( vc_addr_local == 1000 ) || ( video_clear == 1 ))
				vc_addr_local = 0;
		end				   
		else
		begin
			if ( line_clear_c == 4'b1111  )
				line_clear = 0;
		end
		hc <= hc + 1'd1;
		if (hc > HVIDEO_LEN) 
			i_HBlank <= 1;

		if(hc == HSYNC_START-1) 
		begin
			i_HSync <= 1;
			if ( i_VBlank == 0 )
			begin
				if ( vc[2:0] == 3'b111 )
				begin
					vc_addr_local = vc_addr_local + 40;
					if ( vc_addr_local == 1000 )
						vc_addr_local = 0;
				end
			end
		end
			
		if(hc == HSYNC_END-1)
			i_HSync <= 0;
		if(hc == HVIDEO_TOTAL-1) 
		begin
			hc <= 0;
			i_HBlank <= 0;
		end
		if(hc == HVIDEO_TOTAL-2) 
		begin
			vc <= vc + 1'd1;
			if(vc == VVIDEO_LEN-1) 
			begin
				i_VBlank <= 1;
				if ( video_vscroll_signal == 1 )
				begin
					video_vscroll_signal <= 0;
				end
			end
			if (vc == VSYNC_START-1) 
				i_VSync <= 1;
			if (vc == VSYNC_END-1) 
			begin
				i_VSync <= 0;
			end
			if(vc == VVIDEO_TOTAL-1)
			begin
				vc <= 0;
				i_VBlank <= 0;
			end
		end 
   	end
end

/* resync all */
reg			i_HBlank_1;	
reg			i_HBlank_2;	
reg			i_HBlank_3;	
reg			i_HSync_1;	
reg			i_VBlank_1;	
reg			i_VSync_1;	

always @(posedge pixel_clk) 
begin
	i_HBlank_1 <= i_HBlank;	   	// char ram
	i_HBlank_2 <= i_HBlank_1;	// font rom
	i_HBlank_3 <= i_HBlank_2;	// serializer
	HBlank <= i_HBlank_3;		// clock sync
	
	i_VBlank_1 <= i_VBlank;
	i_HSync_1 <= i_HSync;
	i_VSync_1 <= i_VSync;
	VBlank <= i_VBlank_1;
	HSync <= i_HSync_1;
	VSync <= i_VSync_1;
end

reg [2:0] sel;
reg	srout;
always @(posedge pixel_clk) 
begin
	if ((reset == 1) || ( i_HBlank_2 == 1 ))
	begin
		sel = 3'b111;
		srout = 0;
	end
	else
	begin
		srout = rom_char_data[sel];
		sel = sel - 1'b1;
    end 
end

parameter R_COLOR	= 8'h70;           			// active pixels
parameter G_COLOR	= 8'h70;           			// active pixels
parameter B_COLOR	= 8'h70;           			// active pixels
parameter W_COLOR	= 8'hff;           			// active pixels
parameter N_COLOR	= 8'h0f;           			// active pixels
parameter A_COLOR	= 8'h00;           			// active pixels

always @(posedge pixel_clk) 
begin		 	 
	if (~(i_HBlank | i_VBlank ))
	begin
		if ( srout )
		begin
			case ( color )
				2'b00 :
					begin
						r <= W_COLOR;
						g <= W_COLOR;
						b <= W_COLOR;
					end		
				2'b01 :
					begin
						r <= R_COLOR;
						g <= N_COLOR;
						b <= N_COLOR;
					end		
				2'b10 :
					begin
						r <= N_COLOR;
						g <= G_COLOR;
						b <= N_COLOR;
					end		
				2'b11 :
					begin
						r <= N_COLOR;
						g <= N_COLOR;
						b <= B_COLOR;
					end		
			endcase	
		end		
		else
		begin
			r <= N_COLOR;
			g <= N_COLOR;
			b <= N_COLOR;
		end
	end		
	else
	begin
		r <= A_COLOR;
		g <= A_COLOR;
		b <= A_COLOR;
	end
end
endmodule
