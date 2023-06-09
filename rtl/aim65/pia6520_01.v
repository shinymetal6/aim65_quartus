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

module pia6520 ( 
	input 			cs,     // Chip select.
	input 			clk,    // clock
	input 			reset,	// Reset (active low)
	input 			rw,     // write (low) / read (high)
	input [1:0]		addr,   // Address
	input [7:0]		dataIn,
	output reg [7:0]dataOut,
	input  [7:0]	paIn,   // Peripheral data port A input
	output reg [7:0]paOut,  // Peripheral data port A
	input  [7:0]	pbIn,   // Peripheral data port B input
	output reg [7:0]pbOut,  // Peripheral data port B
	input           ca1_in,
	output reg      ca2_out,
	input           ca2_in,
	input           cb1_in,
	output reg      cb2_out,
	input           cb2_in,	
	output reg 		irqa,   // Interrupt request	
	output reg 		irqb	// Interrupt request	
);

/*
register map 
	0	ORA	/ DDRA
	1	CRA
	2	ORB / DDRB
	3	CRB
*/
reg	[7:0] ORA;  
reg	[7:0] DDRA;  
reg	[7:0] CRA;
reg	[7:0] ORB;
reg	[7:0] DDRB;
reg	[7:0] CRB;

//always@(addr | rw | CRA | CRB)
always@(posedge clk)	
begin
	if (( rw == 1 ) && (cs == 1 ))
	begin
		case(addr)
			2'h0:  
				if ( CRA[2] == 1 )
					dataOut=ORA; 
				else
					dataOut=DDRA;
			2'h1: dataOut=CRA;
			2'h2: if ( CRB[2] == 1 ) 
					dataOut=ORB; 
				else
					dataOut=DDRB;
			2'h3: dataOut=CRB;
		endcase	
	end			
end

always@(posedge clk)
	begin
		if (reset==1)
		begin 
			ORA = 0;
			DDRA = 0;
			CRA = 0;
			ORB = 0;
			DDRB = 0;
			CRB = 0;
			irqa = 0;
			irqb = 0;
		end
		else
		begin 
			paOut = ORA;
			pbOut = ORB;
			if ( cs == 1 )
			begin
				if ( rw == 0 )
				begin
					case(addr)
						2'h0:  
							if ( CRA[2] == 1 )
								ORA=dataIn; 
							else
								DDRA=dataIn;
						2'h1: CRA=dataIn;
						2'h2: if ( CRB[2] == 1 ) 
								ORB=dataIn; 
							else
								DDRB=dataIn;
						2'h3: CRB=dataIn;
					endcase	
				end			
			end
		end
end

endmodule
