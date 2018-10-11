
module i2c_slave_top
(
    input clk,
    input rst_n,
    inout scl,
    inout sda
);


    wire rx_dong_sig;
    wire [7:0]rx_data;
    reg [87:0]tx_data_buf;

    i2c_slave #(.I2C_SLAVE_ADDR(7'h25)) u1
    (
        .clk(clk),
        .rstn_in(rst_n),
        .scl(scl),
        .sda(sda),
        .rx_dong_sig(rx_dong_sig), //用于压FIFO
        .rx_data(rx_data),
        .tx_start_sig(),
        .tx_data_buf(tx_data_buf)
    );
    
    
    //11个字节的回环测试loopback test
    //由于使用FIFO 发送数据:byte0~byte10
    reg [3:0]i;
    reg [7:0]rData;
    reg [3:0]rx_cnt;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            i <= 4'd0;
            rData <= 8'd0;
            rx_cnt <= 4'd0;
            tx_data_buf <= 88'd0;
        end
        else
            case(i)
            
                0:
                if(rx_dong_sig) begin
                    i <= 1;
                    rData <= rx_data;
                    rx_cnt <= rx_cnt + 1'b1;
                end
                
                1:
                begin
                    i <= 2;
                    
                    case (rx_cnt)
                    
                        1:  tx_data_buf[7:0] <= rData;
                        2:  tx_data_buf[15:8] <= rData;
                        3:  tx_data_buf[23:16] <= rData;
                        4:  tx_data_buf[31:24] <= rData;
                        5:  tx_data_buf[39:32] <= rData;
                        6:  tx_data_buf[47:40] <= rData;
                        7:  tx_data_buf[55:48] <= rData;
                        8:  tx_data_buf[63:56] <= rData;
                        9:  tx_data_buf[71:64] <= rData;
                        10: tx_data_buf[79:72] <= rData;
                        11: tx_data_buf[87:80] <= rData;
                
                    endcase
                end
                
                2:
                begin
                    i <= 3;
                    if(rx_cnt == 11) rx_cnt <= 0;
                end
                
                3:
                    i <= 0;
            
            endcase
    end
    
    
    
endmodule

