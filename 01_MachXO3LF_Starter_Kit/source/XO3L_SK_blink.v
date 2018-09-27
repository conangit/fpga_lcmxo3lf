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
//  Project:           XO3L Starter Kit shipping pattern
//  File:              XO3L_SK_blink.v
//  Title:             Blink pattern
//  Description:       Blinks the LEDs in a pattern determined by DIPSW input
//
// --------------------------------------------------------------------
//
//------------------------------------------------------------
// Notes:
//
//
//------------------------------------------------------------
// Development History:
//
//   __DATE__ _BY_ _REV_ _DESCRIPTION___________________________
//   10/20/14  SH  0.00  Initial Design
//
//------------------------------------------------------------
// Dependencies:
//
// 
//
//------------------------------------------------------------



//----------------------------------------------------------------------------
//                                                                          --
//                         ENTITY DECLARATION                               --
//                                                                          --
//----------------------------------------------------------------------------
module XO3L_SK_blink (
        // inputs
        input   wire        clk_x1,         // 12M clock from FTDI/X1 crystal
        input   wire        rstn,           // from SW1 pushbutton
        input   wire  [3:0] DIPSW,          // from SW2 DIP switches
        
        // outputs
        output  wire  [7:0] LED             // to LEDs (D2-D9)
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

// wires (assigns)
wire          osc_clk;        // Internal OSCILLATOR clock
wire          clk12M;         // 12MHz logic clock
wire          rst;            //
wire    [7:0] LED_array;      // kitcar output


// regs (always)
reg     [7:0] LED_i;          // selector output

//-------------------------------------//
//-- assign (non-process) operations --//
//-------------------------------------//

assign rst = ~rstn;
assign clk12M = DIPSW[3] ? osc_clk : clk_x1;    // select clock source int/ext pin-N1


//-------------------------------------//
//---- always (process) operations ----//
//-------------------------------------//


//   select LED behavior
//
always @ (DIPSW[2:0], heartbeat, LED_array)
    begin
            case (DIPSW[2:0])
                3'b001 : begin      // insert kitcar
                      LED_i <= LED_array;
                    end
                3'b011 : begin      // left-right
                      LED_i <= heartbeat ? 8'b11110000 : 8'b00001111 ;
                    end
                3'b111 : begin      // heartbeat
                      LED_i <= heartbeat ? 8'b11111111 : 8'b00000000 ;
                    end
                default : begin     // alternate
                      LED_i <= heartbeat ? 8'b01010101 : 8'b10101010 ;
                    end
            endcase
    end

   //--------------------------------------------------------------------
   //--  module instances
   //--------------------------------------------------------------------

defparam OSCH_inst.NOM_FREQ = "12.09";  
OSCH OSCH_inst( 
    .STDBY(1'b0), // 0=Enabled, 1=Disabled
    .OSC(osc_clk),
    .SEDSTDBY()
    );

heartbeat #(.clk_freq (12000000))
    heartbeat_inst (
        .clk        (clk12M),
        .rst        (rst),
        .heartbeat  (heartbeat)
        );
        
kitcar #(.clk_freq (12000000))
    kitcar_inst (
        .clk        (clk12M),
        .rst        (rst),
        .LED_array  (LED_array)
        );



//-------------------------------------//
//-------- output assignments  --------//
//-------------------------------------//

assign LED = ~LED_i;


endmodule