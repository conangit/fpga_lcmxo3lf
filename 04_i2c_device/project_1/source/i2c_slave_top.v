
module i2c_slave_top
(
    input clk,
    input rst_n,
    inout scl,
    inout sda
);



    i2c_slave #(.I2C_SLAVE_ADDR(7'h66)) u1
    (
        .clk(clk),
        .rstn_in(rst_n),
        .scl(scl),
        .sda(sda)
    );
    
    
endmodule

