module led1
(
    input clk_x1,
    input rst_n,
    output reg [7:0]led1
    
    // output mspi_clk,
    // input mspi_si,
    // output mspi_so,
    // output mspi_css
);

    wire clk;
    
    assign clk = clk_x1;

    parameter T1S = 24'd12_000_000;
    
    reg [23:0]count;
    
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            count <= 24'd0;
        else if(count == T1S)
            count <= 24'd0;
        else
            count <= count + 1'b1;
    end
    
    
    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            led1 <= 8'b1111_1111;
        else if(count == T1S)
            led1 <= {led1[7:1],~led1[0]};
    end
    
endmodule
