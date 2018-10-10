module dip_led_test(
    clk,
    rst_n,
    dips_in,
    leds_out
    );
    
    input clk;
    input rst_n;
    input [3:0]dips_in;
    output [7:0]leds_out;
    
    /******************************/
    
    reg [7:0]leds;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            leds <= 8'b0111_1111;
        else
            leds <= {4'b1111, dips_in};
    end
    
    assign leds_out = leds;

endmodule

