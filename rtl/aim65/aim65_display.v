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

module aim65_display 
( 
	input 				clk,    // clock
	input 				reset,	// Reset (active low)
	input 				ce1 ,
	input 				ce2 ,
	input 				ce3 ,
	input 				ce4 ,
	input 				ce5 ,
	input 				w ,
	input 				cu ,
	input [1:0]			daddr ,
	input [7:0] 		ddata ,
	input 				video_clear,
	output	reg			video_vscroll,
	output		[9:0]	video_addr,
	output	reg	[7:0]	video_data,
	output	reg			video_ce,
	output	reg			video_we
);

reg	[2:0]	strobe_cntr;
reg			addr_inc_done;
reg	[9:0]	video_addr_ptr;
wire	[1:0]	neg_daddr; 
reg			scroll_status;

assign neg_daddr = ~daddr;

always@(posedge clk)		
begin			
	if (reset==1)
	begin 		
		video_ce = 1'b0;
		video_we = 1'b0; 
		video_data = 8'b00000000;
		strobe_cntr = 3'b000;
		video_addr_ptr = 0;
		addr_inc_done = 0;
		video_vscroll = 0;
		scroll_status = 0;
	end
	else
	begin
		if ( video_clear == 1 )
		begin
			video_addr_ptr = 0;
			video_vscroll = 0;
			scroll_status = 0;
		end
		if ( !w & !ce1 & ( daddr == 3 ) ) /* treat ce1 with we as a cr */
		begin			  
			if ( addr_inc_done == 0 )
			begin
				addr_inc_done = 1;
				video_addr_ptr = video_addr_ptr + 40;
				if ( scroll_status == 1 )
					video_vscroll = 1;
				if ( video_addr_ptr == 1000 )
				begin
					video_addr_ptr = 0;
					video_vscroll = 1;
					scroll_status = 1;
				end
			end
			else
				video_vscroll = 0;
		end		
		else
			addr_inc_done = 0;
					

		if (( !w & !ce1 ) || ( !w & !ce2 ) || ( !w & !ce3 ) || ( !w & !ce4 ) || ( !w & !ce5 ))
		begin 
			case ( strobe_cntr )
			0: 	begin
					strobe_cntr = strobe_cntr + 3'b001;
					video_data = ddata & 8'h7f;
				end
			1: 	begin
					strobe_cntr = strobe_cntr + 3'b001;
					video_ce = 1;
				end
			2: 	begin
					strobe_cntr = strobe_cntr + 3'b001;
					video_we = 1;
				end
			3: 	begin
					strobe_cntr = strobe_cntr + 3'b001;
					video_we = 1;
				end
			4: 	begin
					strobe_cntr = strobe_cntr + 3'b001;
					video_we = 0;
				end
			5: 	begin
					strobe_cntr = strobe_cntr + 3'b001;
					video_ce = 0;
				end
			6: 	begin
					strobe_cntr = strobe_cntr + 3'b001;
				end
			7: 	begin
					strobe_cntr = 3'b111;
				end
			endcase
		end
		else
			strobe_cntr = 3'b000;
	end
end

assign video_addr =
    ( !w & !ce1 ) ? {8'b0000000,neg_daddr} + 10'b00000000 + video_addr_ptr :
    ( !w & !ce2 ) ? {8'b0000000,neg_daddr} + 10'b00000100 + video_addr_ptr :
    ( !w & !ce3 ) ? {8'b0000000,neg_daddr} + 10'b00001000 + video_addr_ptr :
    ( !w & !ce4 ) ? {8'b0000000,neg_daddr} + 10'b00001100 + video_addr_ptr :
    ( !w & !ce5 ) ? {8'b0000000,neg_daddr} + 10'b00010000 + video_addr_ptr :
	9'b00000000;
// synopsys translate_off
reg	[7:0] 	digit0;
reg	[7:0] 	digit1;
reg	[7:0] 	digit2;
reg	[7:0] 	digit3;
reg	[7:0] 	digit4;
reg	[7:0] 	digit5;
reg	[7:0] 	digit6;
reg	[7:0] 	digit7;
reg	[7:0] 	digit8;
reg	[7:0] 	digit9;
reg	[7:0] 	digit10;
reg	[7:0] 	digit11;
reg	[7:0] 	digit12;
reg	[7:0] 	digit13;
reg	[7:0] 	digit14;
reg	[7:0] 	digit15;
reg	[7:0] 	digit16;
reg	[7:0] 	digit17;
reg	[7:0] 	digit18;
reg	[7:0] 	digit19;

always@(posedge clk)		
begin			
	if (reset==1)
	begin 		
		digit0 = 0;
		digit1 = 0;
		digit2 = 0;
		digit3 = 0;
		digit4 = 0;
		digit5 = 0;
		digit6 = 0;
		digit7 = 0;
		digit8 = 0;
		digit9 = 0;
		digit10 = 0;
		digit11 = 0;
		digit12 = 0;
		digit13 = 0;
		digit14 = 0;
		digit15 = 0;
		digit16 = 0;
		digit17 = 0;
		digit18 = 0;
		digit19 = 0;
	end
	else
	begin	
		if ( !w & !ce1 )					   
		begin					
			case(daddr)
				2'h0: digit3=ddata & 8'h7f;
				2'h1: digit2=ddata & 8'h7f;
				2'h2: digit1=ddata & 8'h7f;
				2'h3: digit0=ddata & 8'h7f;
			endcase
		end
		else if ( !w & !ce2 )					   
		begin					
			case(daddr)
				2'h0: digit7=ddata & 8'h7f;
				2'h1: digit6=ddata & 8'h7f;
				2'h2: digit5=ddata & 8'h7f;
				2'h3: digit4=ddata & 8'h7f;
			endcase
		end
		else if ( !w & !ce3 )					   
		begin					
			case(daddr)
				2'h0: digit11=ddata & 8'h7f;
				2'h1: digit10=ddata & 8'h7f;
				2'h2: digit9=ddata & 8'h7f;
				2'h3: digit8=ddata & 8'h7f;
			endcase	
		end
		else if ( !w & !ce4 )					   
		begin					
			case(daddr)
				2'h0: digit15=ddata & 8'h7f;
				2'h1: digit14=ddata & 8'h7f;
				2'h2: digit13=ddata & 8'h7f;
				2'h3: digit12=ddata & 8'h7f;
			endcase		
		end
		else if ( !w & !ce5)				   
		begin					
			case(daddr)
				2'h0: digit19=ddata & 8'h7f;
				2'h1: digit18=ddata & 8'h7f;
				2'h2: digit17=ddata & 8'h7f;
				2'h3: digit16=ddata & 8'h7f;
			endcase
		end
	end
end
// synopsys translate_on
endmodule
