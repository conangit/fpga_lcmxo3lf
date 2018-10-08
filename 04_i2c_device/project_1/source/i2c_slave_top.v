
module i2c_slave_top
(
    input clk,
    input rst_n,
    inout scl,
    inout sda
);

    /*****************************************************************************************************/

    //依据系统的整体设计而选择
    //异步复位同步释放
    reg reset_1, reset_2;
    wire reset_in;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            reset_1 <= 1'b0;
            reset_2 <= 1'b0;
        end
        else begin
            reset_1 <= 1'b1;
            reset_2 <= reset_1;
        end
    end
    
    assign reset_in = reset_2;

    /*****************************************************************************************************/

    //PLL IP Core输出clk
    //使用50MHz时钟�    
    i2c_slave #(.I2C_SLAVE_ADDR(7'h66)) u2
    (
        .clk(clk),
        .rst_n(reset_in),
        .scl(scl),
        .sda(sda)
    );
    
    
endmodule

