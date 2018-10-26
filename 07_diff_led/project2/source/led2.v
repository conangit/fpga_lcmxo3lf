module led2
(
    input clk_x1,
    input rst_n,
    output reg [7:0]led2
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
            led2 <= 8'b1111_1111;
        else if(count == T1S)
            led2 <= {~led2[7:2],led2[1:0]};
    end
    
endmodule
