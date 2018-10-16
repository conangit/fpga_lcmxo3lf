

module test_module
(
    input clk,
    input rst_n,
    
    output clkop,
    output clkos,
    output clkos2,
    output clkos3,
    output clk_lock
);


    pll_ip u1
    (
        .CLKI(clk),         //12M
        .RST(!rst_n),
        .CLKOP(clkop),      //12M clk_fb
        .CLKOS(clkos),      //5M
        .CLKOS2(clkos2),    //2M
        .CLKOS3(clkos3),    //1M
        .LOCK(clk_lock)     //lock
    );
    
    
endmodule

