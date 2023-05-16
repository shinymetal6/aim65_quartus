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

module aim65_keyboard
(
	input             	reset,
	input             	clk,
	input      [10:0] 	ps2_key, 
	output reg			video_clear,
	/* kbd if */
	input		[7:0]	csa4_riot6532_paOut,
	output reg	[7:0]	csa4_riot6532_pbIn	
);

wire [7:0] scancode = ps2_key[7:0];
wire	select	= ps2_key[9];
reg  [7:0] keys[8];
reg [3:0] out_index;

always @(posedge clk) 
begin 
	if ( reset )
		csa4_riot6532_pbIn =  8'hff;
	else
	begin
		case ( csa4_riot6532_paOut )
			8'b11111110 : csa4_riot6532_pbIn = keys[0];
			8'b11111101 : csa4_riot6532_pbIn = keys[1];
			8'b11111011 : csa4_riot6532_pbIn = keys[2];
			8'b11110111 : csa4_riot6532_pbIn = keys[3];
			8'b11101111 : csa4_riot6532_pbIn = keys[4];
			8'b11011111 : csa4_riot6532_pbIn = keys[5];
			8'b10111111 : csa4_riot6532_pbIn = keys[6];
			8'b01111111 : csa4_riot6532_pbIn = keys[7];
			8'b10001111 : csa4_riot6532_pbIn = keys[6] & keys[5] & keys[4];
			default :  csa4_riot6532_pbIn =  8'hff;
		endcase	
	end
end

reg old_stb;
reg key_valid;
reg [2:0] out_sm;
reg shift;
reg cntrl;

parameter   PB7 = 7;
parameter   PB6 = 6;
parameter   PB5 = 5;
parameter   PB4 = 4;
parameter   PB3 = 3;
parameter   PB2 = 2;
parameter   PB1 = 1;
parameter   PB0 = 0;

parameter   PA7 = 7;
parameter   PA6 = 6;
parameter   PA5 = 5;
parameter   PA4 = 4;
parameter   PA3 = 3;
parameter   PA2 = 2;
parameter   PA1 = 1;
parameter   PA0 = 0;			  
reg	[7:0]	kbd_ascii_out;
reg			f4_pressed;

always @(posedge clk) begin
	if(reset )
	begin
		keys[PA0] = 8'hff;
		keys[PA1] = 8'hff;
		keys[PA2] = 8'hff;
		keys[PA3] = 8'hff;
		keys[PA4] = 8'hff;
		keys[PA5] = 8'hff;
		keys[PA6] = 8'hff;
		keys[PA7] = 8'hff;		
		key_valid = 0;
		shift = 1'b0;
		cntrl = 1'b0;
		out_sm = 3'b000;
		kbd_ascii_out = 8'h00;
		f4_pressed = 1'b0;
		video_clear = 1'b0;
	end
	
	old_stb <= ps2_key[10];
	if ( select == 0 )
	begin
		keys[PA0] = 8'hff;
		keys[PA1] = 8'hff;
		keys[PA2] = 8'hff;
		keys[PA3] = 8'hff;
		keys[PA4] = {7'b1111111,~cntrl};
		keys[PA5] = {7'b1111111,~shift};
		keys[PA6] = {7'b1111111,~shift};
		keys[PA7] = 8'hff;		
		key_valid = 0;
	end
	else
	begin
		if ( video_clear == 1 )
			video_clear = 0;
		if ( f4_pressed == 1 )
		begin
			f4_pressed = 0;
			video_clear = 1;
		end
		if(old_stb != ps2_key[10])
		begin
			keys[PA0] = 8'hff;
			keys[PA1] = 8'hff;
			keys[PA2] = 8'hff;
			keys[PA3] = 8'hff;
			keys[PA4] = {7'b1111111,~cntrl};
			keys[PA5] = {7'b1111111,~shift};
			keys[PA6] = {7'b1111111,~shift};
			keys[PA7] = 8'hff;
			
			case(scancode)
				8'h0C: f4_pressed = 1'b1;
				8'h29: begin keys[PA0][PB0] <= ~select; key_valid = 1; kbd_ascii_out = " ";   	end  	// SPACE
				8'h5A: begin keys[PA3][PB0] <= ~select; key_valid = 1; kbd_ascii_out = 8'h0d; 	end  	// RETURN
				8'h14: begin keys[PA4][PB0] <= ~select; key_valid = 0; cntrl = 1; 				end  	// ctrl
				8'h59: begin keys[PA5][PB0] <= ~select; key_valid = 0; shift = 1; 				end  	// right shift
				8'h12: begin keys[PA6][PB0] <= ~select; key_valid = 0; shift = 1; 				end  	// left shift 
					
				8'h71: begin keys[PA6][PB1] <= ~select; key_valid = 0; kbd_ascii_out = 8'h71; end 	// DEL
				8'h76: begin keys[PA2][PB7] <= ~select; key_valid = 0; kbd_ascii_out = 8'h76; end	// ESC
				8'h04: begin keys[PA5][PB7] <= ~select; key_valid = 0; kbd_ascii_out = 8'h04; end	// F3
				8'h06: begin keys[PA6][PB7] <= ~select; key_valid = 0; kbd_ascii_out = 8'h06; end	// F2
				8'h05: begin keys[PA7][PB7] <= ~select; key_valid = 0; kbd_ascii_out = 8'h05; end	// F1
					
				8'h1C: begin keys[PA1][PB6] <= ~select; key_valid = 1; kbd_ascii_out = "A"; end  // a
				8'h32: begin keys[PA0][PB4] <= ~select; key_valid = 1; kbd_ascii_out = "B"; end  // b
				8'h21: begin keys[PA0][PB5] <= ~select; key_valid = 1; kbd_ascii_out = "C"; end  // c
				8'h23: begin keys[PA1][PB5] <= ~select; key_valid = 1; kbd_ascii_out = "D"; end  // d
				8'h24: begin keys[PA3][PB6] <= ~select; key_valid = 1; kbd_ascii_out = "E"; end  // e
				8'h2B: begin keys[PA6][PB5] <= ~select; key_valid = 1; kbd_ascii_out = "F"; end  // f
				8'h34: begin keys[PA1][PB4] <= ~select; key_valid = 1; kbd_ascii_out = "G"; end  // g
				8'h33: begin keys[PA6][PB4] <= ~select; key_valid = 1; kbd_ascii_out = "H"; end  // h
				8'h43: begin keys[PA2][PB3] <= ~select; key_valid = 1; kbd_ascii_out = "I"; end  // i
				8'h3B: begin keys[PA1][PB3] <= ~select; key_valid = 1; kbd_ascii_out = "J"; end  // j
				8'h42: begin keys[PA6][PB3] <= ~select; key_valid = 1; kbd_ascii_out = "K"; end  // k
				8'h4B: begin keys[PA1][PB2] <= ~select; key_valid = 1; kbd_ascii_out = "L"; end  // l
				8'h3A: begin keys[PA0][PB3] <= ~select; key_valid = 1; kbd_ascii_out = "M"; end  // m
				8'h31: begin keys[PA7][PB4] <= ~select; key_valid = 1; kbd_ascii_out = "N"; end  // n
				8'h44: begin keys[PA3][PB3] <= ~select; key_valid = 1; kbd_ascii_out = "O"; end  // o
				8'h4D: begin keys[PA2][PB2] <= ~select; key_valid = 1; kbd_ascii_out = "P"; end  // p
				8'h15: begin keys[PA3][PB7] <= ~select; key_valid = 1; kbd_ascii_out = "Q"; end  // q
				8'h2D: begin keys[PA2][PB5] <= ~select; key_valid = 1; kbd_ascii_out = "R"; end  // r
				8'h1B: begin keys[PA6][PB6] <= ~select; key_valid = 1; kbd_ascii_out = "S"; end  // s
				8'h2C: begin keys[PA3][PB5] <= ~select; key_valid = 1; kbd_ascii_out = "T"; end  // t
				8'h3C: begin keys[PA3][PB4] <= ~select; key_valid = 1; kbd_ascii_out = "U"; end  // u
				8'h2A: begin keys[PA7][PB5] <= ~select; key_valid = 1; kbd_ascii_out = "V"; end  // v
				8'h1D: begin keys[PA2][PB6] <= ~select; key_valid = 1; kbd_ascii_out = "W"; end  // w
				8'h22: begin keys[PA7][PB6] <= ~select; key_valid = 1; kbd_ascii_out = "X"; end  // x
				8'h35: begin keys[PA2][PB4] <= ~select; key_valid = 1; kbd_ascii_out = "Y"; end  // y
				8'h1A: begin keys[PA0][PB6] <= ~select; key_valid = 1; kbd_ascii_out = "Z"; end  // z
				
				8'h45: begin keys[PA5][PB2] <= ~select; key_valid = 1; kbd_ascii_out = "0"; end // 0
				8'h16: begin keys[PA4][PB7] <= ~select; key_valid = 1; kbd_ascii_out = shift ? "!" : "1"; end // 1 or !
				8'h1E: begin keys[PA5][PB6] <= ~select; key_valid = 1; kbd_ascii_out = shift ? "\"": "2"; end // 2 or "
				8'h26: begin keys[PA4][PB6] <= ~select; key_valid = 1; kbd_ascii_out = shift ? "#" : "3"; end // 3 or #
				8'h25: begin keys[PA5][PB5] <= ~select; key_valid = 1; kbd_ascii_out = shift ? "$" : "4"; end // 4 or %
				8'h2E: begin keys[PA4][PB5] <= ~select; key_valid = 1; kbd_ascii_out = shift ? "%" : "5"; end // 5 or %
				8'h36: begin keys[PA5][PB4] <= ~select; key_valid = 1; kbd_ascii_out = shift ? "&" : "6"; end // 6 or '
				8'h3D: begin keys[PA4][PB4] <= ~select; key_valid = 1; kbd_ascii_out = shift ? "`" : "7"; end // 7 or `
				8'h3e: begin keys[PA5][PB3] <= ~select; key_valid = 1; kbd_ascii_out = shift ? "(" : "8"; end // 8 or (
				8'h46: begin keys[PA4][PB3] <= ~select; key_valid = 1; kbd_ascii_out = shift ? ")" : "9"; end // 9 or )
				
				8'h41: begin keys[PA7][PB3] <= ~select;  key_valid = 1; kbd_ascii_out = shift ? "<" : ","; end	// , or <
				8'h49: begin keys[PA0][PB2] <= ~select;  key_valid = 1; kbd_ascii_out = shift ? ">" : "."; end	// . or >
				8'h4E: begin keys[PA3][PB2] <= ~select;  key_valid = 1; kbd_ascii_out = shift ? "=" : "-"; end	// - or =
				8'h4C: begin keys[PA4][PB2] <= ~select;  key_valid = 1; kbd_ascii_out = shift ? "*" : ":"; end	// : or *	
				8'h55: begin keys[PA6][PB2] <= ~select;  key_valid = 1; kbd_ascii_out = shift ? "+" : ";"; end // ; or +
				8'h4A: begin keys[PA7][PB2] <= ~select;  key_valid = 1; kbd_ascii_out = shift ? "?" : "/"; end // / or ?
				
				default : key_valid = 0;
			endcase
				
			if ( key_valid == 1 ) 
			begin
				out_sm = 3'b001;
			end
			else
			begin
				out_sm = 3'b000;
			end
		end
		
		case ( out_sm )
			0: 	begin
					out_sm = 0;
				end
			1: 	begin
					out_sm = out_sm + 1'b1;
				end
			2: 	begin
					out_sm = out_sm + 1'b1;
				end
			3: 	begin
					out_sm = out_sm + 1'b1;
				end
			4: 	begin
					out_sm = out_sm + 1'b1;
				end
			5: 	begin
					out_sm = out_sm + 1'b1;
				end
			6: 	begin
					out_sm = out_sm + 1'b1;
				end
			7: 	begin
					out_sm = 3'b000;
					shift = 1'b0;
					cntrl = 1'b0;
				end
		endcase
	end
end
endmodule				
