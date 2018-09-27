//   ==================================================================
//   >>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
//   ------------------------------------------------------------------
//   Copyright (c) 2014 by Lattice Semiconductor Corporation
//   ALL RIGHTS RESERVED 
//   ------------------------------------------------------------------
//
//   Permission:
//
//      Lattice SG Pte. Ltd. grants permission to use this code
//      pursuant to the terms of the Lattice Reference Design License Agreement. 
//
//
//   Disclaimer:
//
//      This VHDL or Verilog source code is intended as a design reference
//      which illustrates how these types of functions can be implemented.
//      It is the user's responsibility to verify their design for
//      consistency and functionality through the use of formal
//      verification methods.  Lattice provides no warranty
//      regarding the use or functionality of this code.
//
//   --------------------------------------------------------------------
//
//                  Lattice SG Pte. Ltd.
//                  101 Thomson Road, United Square #07-02 
//                  Singapore 307591
//
//
//                  TEL: 1-800-Lattice (USA and Canada)
//                       +65-6631-2000 (Singapore)
//                       +1-503-268-8001 (other locations)
//
//                  web: http://www.latticesemi.com/
//                  email: techsupport@latticesemi.com
//
// --------------------------------------------------------------------
//
//  Project:           CommonFunctionLibrary
//  File:              heartbeat.v
//  Title:             Heartbeat generator
//  Description:       Produces 1 Hz output, 50% duty cycle.
//                      pass the clock frequency in Hz as a parameter
//
// --------------------------------------------------------------------
//
//------------------------------------------------------------
// Notes:
//  260Mhz clk input maximum
//
//------------------------------------------------------------
// Development History:
//
//   __DATE__ _BY_ _REV_ _DESCRIPTION___________________________
//   04/22/10  SH  0.00  Initial Design
//
//------------------------------------------------------------
// Dependencies:
//
// -none-
//
//------------------------------------------------------------


// ---------- Design Unit Header ---------- //
`timescale 1ps / 1ps

//----------------------------------------------------------------------------
//                                                                          --
//                         ENTITY DECLARATION                               --
//                                                                          --
//----------------------------------------------------------------------------
module heartbeat (
        // inputs
        input   wire        clk,		
        input   wire        rst,        // asynchronous reset
        // outputs
        output  reg         heartbeat
        );

//----------------------------------------------------------------------------
//                                                                          --
//                       ARCHITECTURE DEFINITION                            --
//                                                                          --
//----------------------------------------------------------------------------
//------------------------------
// INTERNAL SIGNAL DECLARATIONS: 
//------------------------------
// parameters (constants)
parameter clk_freq = 27'd25000000;  // in Hz

// wires (assigns)

// regs (always)
reg		[26:0]	count;	        // enough bits for clk_freq =< 260Mhz

//-------------------------------------//
//-- assign (non-process) operations --//
//-------------------------------------//


//-------------------------------------//
//---- always (process) operations ----//
//-------------------------------------//


//   counter 
//
always @ (posedge clk or posedge rst)
	if (rst) begin 
        count <= 0;
        heartbeat <= 0;
	end else begin
        if (count >= (clk_freq/2)) begin
            count <= 0;
            heartbeat <= !heartbeat;
        end else                        
            count <= count + 1;
    end

//-------------------------------------//
//-------- output assignments  --------//
//-------------------------------------//

// outputs should be registered!!


endmodule
