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

module aim65_decmux (
	input             	clk,
	input      [1:0] 	ext_selector, 
	input      [15:0] 	addr, 
	input		[7:0]	ram_do,
	input		[7:0]	video_do,
	input		[7:0]	z22_do,
	input		[7:0]	z23_do,
	input		[7:0]	z24_do,
	input		[7:0]	z25_basic_do,
	input		[7:0]	z25_forth_do,
	input		[7:0]	z25_pl65_do,
	input		[7:0]	z26_basic_do,
	input		[7:0]	z26_forth_do,
	input		[7:0]	z26_pl65_do,
	input		[7:0]	csa0_6522_do,
	input		[7:0]	csa4_6532_do,
	input		[7:0]	csa8_6522_do,
	input		[7:0]	csac_6520_do,
	
	output 				ram_cs,
	output 				video_cs,
	output 				z22_cs,
	output 				z23_cs,
	output 				z24_cs,
	output 				z25_cs,
	output 				z26_cs,
	output 				csa0_6522,
	output 				csa4_6532,
	output 				csa8_6522,
	output 				csac_6520,
	output 		[7:0]	cpu_data	
);

assign ram_cs 			=	(addr[15:12] < 4'h8 ) ? 1'b1 : 1'b0;
assign video_cs 		=	(addr[15:12] == 4'h9 ) ? 1'b1 : 1'b0;

assign z22_cs			=	(addr[15:12] == 4'hf) ? 1'b1 : 1'b0; 	
assign z23_cs			=	(addr[15:12] == 4'he) ? 1'b1 : 1'b0; 	
assign z24_cs			=	(addr[15:12] == 4'hd) ? 1'b1 : 1'b0; 	
assign z25_cs			=	(addr[15:12] == 4'hc) ? 1'b1 : 1'b0; 	
assign z26_cs			=	(addr[15:12] == 4'hb) ? 1'b1 : 1'b0; 
assign csa0_6522 		= 	(addr[15:8] == 8'ha0) ? 1'b1 : 1'b0;
assign csa4_6532 		= 	(addr[15:8] == 8'ha4) ? 1'b1 : 1'b0;
assign csa8_6522 		= 	(addr[15:8] == 8'ha8) ? 1'b1 : 1'b0;
assign csac_6520 		= 	(addr[15:8] == 8'hac) ? 1'b1 : 1'b0; 

reg ram_cs_prev = 1'b0;
always @(posedge clk) ram_cs_prev <= ram_cs;
reg video_cs_prev = 1'b0;
always @(posedge clk) video_cs_prev <= video_cs;
reg z22_cs_prev = 1'b0;
always @(posedge clk) z22_cs_prev <= z22_cs;	
reg z23_cs_prev = 1'b0;
always @(posedge clk) z23_cs_prev <= z23_cs;	
reg z24_cs_prev = 1'b0;
always @(posedge clk) z24_cs_prev <= z24_cs;	
reg z25_cs_prev = 1'b0;
always @(posedge clk) z25_cs_prev <= z25_cs;	
reg z26_cs_prev = 1'b0;
always @(posedge clk) z26_cs_prev <= z26_cs;	
reg csa0_6522_prev = 1'b0;
always @(posedge clk) csa0_6522_prev <= csa0_6522;
reg csa4_6532_prev = 1'b0;
always @(posedge clk) csa4_6532_prev <= csa4_6532;
reg csa8_6522_prev = 1'b0;
always @(posedge clk) csa8_6522_prev <= csa8_6522;
reg csac_6520_prev = 1'b0;
always @(posedge clk) csac_6520_prev <= csac_6520;

wire		[7:0]	z25_do;
wire		[7:0]	z26_do;
	
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
	
assign cpu_data =
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
