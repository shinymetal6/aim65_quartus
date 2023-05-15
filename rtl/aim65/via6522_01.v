//-----------------------------------------------------------------------------
//
// Title       : via6522_01
// Design      : Naim65
// Author      : fil
// Company     : mycomp
//
//-----------------------------------------------------------------------------

`timescale 1 ns / 1 ps

module via6522 (
	input 			cs,        	// Chip select.
	input 			clk,       	// clock
	input 			reset,     	// Reset (active high)
	input 			rw,         // write (low) / read (high)
	input 	[3:0]	addr,      	// Address
	input 	[7:0]	dataIn,
	output reg [7:0]dataOut,
	input  [7:0]	paIn,   	// Peripheral data port A input
	output reg [7:0]paOut,  	// Peripheral data port A
	input  [7:0]	pbIn,   	// Peripheral data port B input
	output reg [7:0]pbOut,  	// Peripheral data port B
	input           ca1_in,
	output reg      ca2_out,
	input           ca2_in,
	output reg      cb1_out,
	input           cb1_in,
	output reg      cb2_out,
	input           cb2_in,
	output reg 		irq   		// Interrupt request	
);

/// Registers

reg	[7:0] ORB;  
reg	[7:0] ORA;  
reg	[7:0] DDRB;  
reg	[7:0] DDRA;  
reg	[7:0] T1C_L;  
reg	[7:0] T1C_H;  
reg	[7:0] T1L_L;  
reg	[7:0] T1L_H;  
reg	[7:0] T2C_L;  
reg	[7:0] T2C_H;  
reg	[7:0] SR;  
reg	[7:0] ACR;  
reg	[7:0] PCR;  
reg	[7:0] IFR;  
reg	[7:0] IER;  

parameter	ORB_ADDR	=	4'h0;
parameter	ORA_ADDR	=	4'h1;
parameter	DDRB_ADDR	=	4'h2;
parameter	DDRA_ADDR	=	4'h3;
parameter	T1C_L_ADDR	=	4'h4;
parameter	T1C_H_ADDR	=	4'h5;
parameter	T1L_L_ADDR	=	4'h6;
parameter	T1L_H_ADDR	=	4'h7;
parameter	T2C_L_ADDR	=	4'h8;
parameter	T2C_H_ADDR	=	4'h9;
parameter	SR_ADDR		=	4'ha;
parameter	ACR_ADDR	=	4'hb;
parameter	PCR_ADDR	=	4'hc;
parameter	IFR_ADDR	=	4'hd;
parameter	IER_ADDR	=	4'he;
parameter	ORA1_ADDR	=	4'hf;

parameter   T2_IFR = 5;
parameter   T1_IFR = 6;

/// Timers

reg [15:0] timer_1;	
reg [15:0] timer_2;	

reg	timer_1_overflow;
reg	timer_2_overflow;

reg t2_enable;
always@(posedge clk)
begin
	if (reset==1)
	begin 
		ORB = 0;
		ORA  = 0;
		DDRB = 0;
		DDRA = 0;
		T1C_L = 0;
		T1C_H = 0;
		T1L_L = 0;
		T1L_H = 0;
		T2C_L = 0;
		T2C_H = 0;
		SR = 0;
		ACR = 0;
		PCR = 0;
		IFR = 8'h0;
		IER = 0;
		t2_enable = 0;
		irq = 0;
        timer_1 <= 16'h0;
		timer_1_overflow <= 0;
        timer_2 <= 16'h0;
		timer_2_overflow <= 0;	
	end	  
	else				
	begin
		paOut =	ORA & DDRA;
		pbOut =	ORB & DDRB;

		/// timers processing
        timer_1 <= timer_1 - 1'b1;			  
		if ( timer_1 ==  16'h0 )
		begin
			timer_1 <= {T1L_H , T1L_L};
			timer_1_overflow <= 1;
			IFR[T1_IFR] = 1;
		end						 
		else
		begin
			timer_1_overflow <= 0;
		end	
		
		if ( t2_enable == 1 )
		begin
	        timer_2 <= timer_2 - 1'b1;			  
			if ( timer_2 ==  16'h0 )
			begin
				timer_2_overflow <= 1;
				IFR[T2_IFR] = 1;
				t2_enable = 0;
			end	
			else
			begin
				timer_2_overflow <= 0;
				IFR[T2_IFR] = 0;
			end
		end
		else
		begin
			timer_2_overflow <= 0;
		end	 
		
		/// registers processing
	
		if ( cs == 1 )
		begin
			if ( rw == 0 )
			begin
				case(addr)
					ORB_ADDR: ORB=dataIn; 
					ORA_ADDR: ORA=dataIn; 
					DDRB_ADDR: DDRB=dataIn; 
					DDRA_ADDR: DDRA=dataIn; 
					T1C_L_ADDR:	T1L_L=dataIn; 
					T1C_H_ADDR: begin T1L_H=dataIn;	timer_1 <= {dataIn,T1L_L}; IFR[T1_IFR] = 0; end
					T1L_L_ADDR: begin T1C_L=dataIn; T1L_L=dataIn; end
					T1L_H_ADDR: T1L_H=dataIn; 
					T2C_L_ADDR: begin T2C_L=dataIn; end
					T2C_H_ADDR: begin T2C_H=dataIn; IFR[T2_IFR] = 0; timer_2 <= {dataIn , T2C_L};t2_enable = 1;  end
					SR_ADDR: SR=dataIn; 
					ACR_ADDR: ACR=dataIn; 
					PCR_ADDR: PCR=dataIn; 
					IFR_ADDR: IFR=dataIn; 
					IER_ADDR: IER=dataIn[7] ? (IER | dataIn[6:0]) : (IER & ~dataIn[6:0]);
					ORA1_ADDR: ORA=dataIn; 
					default: ORA=dataIn; 
				endcase
			end
			else
			begin
				case(addr)
					ORB_ADDR: dataOut=pbIn;
					ORA_ADDR: dataOut=paIn;
					DDRB_ADDR: dataOut=DDRB;
					DDRA_ADDR: dataOut=DDRA;
					T1C_L_ADDR: begin dataOut=timer_1[7:0]; IFR[T1_IFR] = 0;;end
					T1C_H_ADDR: begin dataOut=timer_1[15:8];end
					T1L_L_ADDR: dataOut=T1L_L;
					T1L_H_ADDR: dataOut=T1L_H;
					T2C_L_ADDR: begin dataOut=timer_2[7:0]; IFR[T2_IFR] = 0;end
					T2C_H_ADDR: begin dataOut=timer_2[15:8];end
					SR_ADDR: dataOut=SR;
					ACR_ADDR: dataOut=ACR;
					PCR_ADDR: dataOut=PCR;
					IFR_ADDR: dataOut=IFR;
					IER_ADDR: dataOut={1'b1, IER};
					ORA1_ADDR: dataOut=paIn;
					default: dataOut=paIn;
				endcase	
			end			
		end
	end
end	
endmodule

