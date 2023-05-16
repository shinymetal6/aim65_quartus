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

module riot6532 (
    input cs,           	// Chip select.
    input clk,         		// clock
    input reset,       		// Reset (active low)
    input rw,          		// write (low) / read (high)
    input rs,          		// register select high / ram select low
    input [6:0]addr,      	// Address
    input [7:0]dataIn,
    output reg [7:0]dataOut,
    input  [7:0]paIn,   	// Peripheral data port A input
    output reg [7:0]paOut,  // Peripheral data port A
    input  [7:0]pbIn,   	// Peripheral data port B input
    output reg [7:0]pbOut,  // Peripheral data port B
    output reg irq	   		// Interrupt request	
);

/*
register map 
	0	DRA
	1	DDRA
	2	DRB
	3	DDRB
	4	EDCND
	5	EDCPD
	6	EDCNE
	7	EDCPE
	8	unused
	9	unused
	a	unused
	b	unused
	c	read timer ( enables interrupt )
	d	unused
	e	unused
	f	unused
	10	unused
	11	unused
	12	unused
	13	unused
	14	T1TD	( disables interrupt )
	15	T8TD	( disables interrupt )
	16	T64TD	( disables interrupt )
	17	T1024TD	( disables interrupt )
	18	unused
	19	unused
	1a	unused
	1b	unused
	1c	T1TE	( enables interrupt )
	1d	T8TE	( enables interrupt )
	1e	T64TE	( enables interrupt )
	1f	T1024TE	( enables interrupt )
*/
reg	[7:0] DRA;  
reg	[7:0] DDRA;  
reg	[7:0] DRB;
reg	[7:0] DDRB;
reg	EDCN;
reg	EDCP;
reg	[7:0] T1TD;
reg	[7:0] T8TD;
reg	[7:0] T64TD;
reg	[7:0] T1024TD;
reg	[7:0] T1TE;
reg	[7:0] T8TE;
reg	[7:0] T64TE;
reg	[7:0] T1024TE;
reg	[7:0] scratch;
reg	TIE;
reg	PA7FLAG;
reg	TIMERFLAG;
reg	PA7IE;

reg	[9:0] timer;

reg [7:0] memory_array [0:127]; 

integer cnt;

always@(posedge clk)
begin
	if (reset==1)
	begin 
		for (cnt = 0; cnt < 128; cnt = cnt + 1)
			memory_array[cnt] <= 8'h00;	
	end
	else
	begin
		if (( rs == 0 ) && (cs == 1 ) && (rw == 0 ))
		begin
			memory_array[addr] <= dataIn;
		end
	end
end

always@(posedge clk)	
begin
	if (( cs == 1 ) && ( rw == 1 ))
	begin
		if ( rs == 0 )
			dataOut = memory_array[addr];
		else
		begin
			case(addr)
				7'h0: begin dataOut=((paIn & ~DDRA) | (DRA & DDRA)); end
				7'h1: begin dataOut=DDRA ; end
				7'h2: begin dataOut=((pbIn & ~DDRB) | (DRB & DDRB)); end
				7'h3: begin dataOut=DDRB ; end	
				7'h4: begin dataOut=timer[7:0] ; end
				7'h5: begin dataOut={6'b000000,timer[9:8]} ; end
				7'h6: begin dataOut=timer[7:0] ; end
				7'h7: begin dataOut={6'b000000,timer[9:8]} ; end
				7'h14: begin dataOut=T1TD ; end
				7'h15: begin dataOut=T8TD ; end
				7'h16: begin dataOut=T64TD ; end
				7'h17: begin dataOut=T1024TD ; end
				7'h1c: begin dataOut=T1TE ; end
				7'h1d: begin dataOut=T8TE ; end
				7'h1e: begin dataOut=T64TE ; end
				7'h1f: begin dataOut=T1024TE ; end
				default: begin dataOut=scratch ; end
			endcase	
		end
	end
end


always@(negedge clk)
	begin
		if (reset==1)
		begin 
			DRA = 0;
			DRB = 0;
			DDRA = 0;
			DDRB = 0;
			EDCN = 8'hff;
			EDCP = 8'hff;
			T1TD = 0;
			T8TD = 0;
			T64TD = 0;
			T1024TD = 0;
			T1TE = 0;
			T8TE = 0;
			T64TE = 0;
			T1024TE = 0;
			scratch = 8'h5a;
			TIE = 0;
			PA7FLAG = 0;
			TIMERFLAG = 0;
			PA7IE = 0;
			timer = 0;
		end
		else
		begin 
			paOut = DRA;
			pbOut = DRB;
			if (( rs == 1 ) && ( cs == 1 ))
			begin
				if ( rw == 0 )
				begin
					case(addr)
						5'h0: begin DRA=dataIn; end
						5'h1: begin DDRA=dataIn; end
						5'h2: begin DRB=dataIn; end
						5'h3: begin DDRB=dataIn; end
						5'h4: begin EDCN=0; end
						5'h5: begin EDCP=0; PA7FLAG = 0; end
						5'h6: begin EDCN=1; end
						5'h7: begin EDCP=1; end
						5'h14: begin T1TD=dataIn; 	TIE=0;end
						5'h15: begin T8TD=dataIn; 	TIE=0;end
						5'h16: begin T64TD=dataIn; 	TIE=0;end
						5'h17: begin T1024TD=dataIn;TIE=0;end
						5'h1c: begin T1TE=dataIn; 	TIE=1;end
						5'h1d: begin T8TE=dataIn; 	TIE=1;end
						5'h1e: begin T64TE=dataIn; 	TIE=1;end
						5'h1f: begin T1024TE=dataIn;TIE=1;end 
						default:begin scratch=dataIn; end 
					endcase	
					end
			end
			/* timers */
			T1TD = T1TD - 8'b1;
			timer = timer + 10'b1;
			if ( timer[2:0] == 3'h4 )
				T8TD = T8TD - 8'b1;
			if ( timer[5:0] == 7'h20 )
				T64TD = T64TD - 8'b1;
			if ( timer == 10'h200 )
				T1024TD = T1024TD - 8'b1; 
			if (( T1024TD == T1024TE ) && ( TIE == 1 ))
			begin
				irq = 1;
				
			end
			else
				irq = 0;
			if (( T64TD == T64TE ) && ( TIE == 1 ))
				irq = 1;
			else
				irq = 0;
			if (( T8TD == T8TE ) && ( TIE == 1 ))
				irq = 1;
			else
				irq = 0;
			
		end
	end


endmodule
