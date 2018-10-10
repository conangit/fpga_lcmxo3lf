
module i2c_slave #(parameter I2C_SLAVE_ADDR = 7'h30)
(
    input clk,      //I2C driving clock
    input rstn_in,
    
    inout scl,      //Serial clock
    inout sda       //Serial data
);

/*****************************************************************************************************/
    
    
    reg scl_isIn;
    reg sda_isIn;

    initial begin
        scl_isIn = 1'b1;
        sda_isIn = 1'b1;
    end
    
    assign scl = scl_isIn ? 1'bz : 0; //SCL方向为ouput且为0,那么将起到Clock Stretching作用(同步主机从机速度)
    assign sda = sda_isIn ? 1'bz : 0; //SDA方向为ouput且为0,即为ACK(由于外部上拉的存在,故NAK无需"动作")
    
    
/*****************************************************************************************************/
    
    
    //异步复位同步释放
    reg reset_1;
    reg reset_2;
    wire rst_n;
    
    always @(posedge clk or negedge rstn_in) begin
        if(!rstn_in) begin
            reset_1 <= 1'b0;
            reset_2 <= 1'b0;
        end
        else begin
            reset_1 <= 1'b1;
            reset_2 <= reset_1;
        end
    end
    
    assign rst_n = reset_2;
    
    
/*****************************************************************************************************/
    
    
    //假设50MHz时钟下,经测SCL(SDA)的上升沿(下降沿)时间为180ns
    //延时10个clock=10*20ns=200ns
    parameter DEB_I2C_LEN = 4'd10;
    
    reg [DEB_I2C_LEN-1:0] sclPipe;
    reg [DEB_I2C_LEN-1:0] sdaPipe;
    
    reg scl_flitered;
    reg sda_flitered;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sclPipe <= {DEB_I2C_LEN{1'b1}};
            scl_flitered <= 1'b1;
            
            sdaPipe <= {DEB_I2C_LEN{1'b1}};
            sda_flitered <= 1'b1;
        end
        else begin
            sclPipe <= {sclPipe[DEB_I2C_LEN-2:0], scl};
            sdaPipe <= {sdaPipe[DEB_I2C_LEN-2:0], sda};
            
            if(&sclPipe[DEB_I2C_LEN-1:1] == 1'b1)
                scl_flitered <= 1'b1;
            else if(|sclPipe[DEB_I2C_LEN-1:1] == 1'b0)
                scl_flitered <= 1'b0;
                
            if(&sdaPipe[DEB_I2C_LEN-1:1] == 1'b1)
                sda_flitered <= 1'b1;
            else if(|sdaPipe[DEB_I2C_LEN-1:1] == 1'b0)
                sda_flitered  <= 1'b0;
        end
    end
    
    //利用防抖后的信号来做边沿检测
    //sclDelayed用作采样时钟
    //sdaDelayed用作start/stop条件判断
    parameter SCL_DEL_LEN = 4'd10;
    parameter SDA_DEL_LEN = 4'd4;
    
    reg [SCL_DEL_LEN-1:0] sclDelayed;
    reg [SDA_DEL_LEN-1:0] sdaDelayed;
    
    wire scl_negedge;
    wire scl_posedge;
    
    wire sda_negedge;
    wire sda_posedge;
    
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            sclDelayed <= {SCL_DEL_LEN{1'b1}};
            sdaDelayed <= {SDA_DEL_LEN{1'b1}};
        end
        else begin
            sclDelayed <= {sclDelayed[SCL_DEL_LEN-2:0], scl_flitered};
            sdaDelayed <= {sdaDelayed[SDA_DEL_LEN-2:0], sda_flitered};
        end
    end
    
    assign scl_negedge = (sclDelayed[SCL_DEL_LEN-1] == 1'b1 && sclDelayed[SCL_DEL_LEN-2] == 1'b0);
    assign scl_posedge = (sclDelayed[SCL_DEL_LEN-1] == 1'b0 && sclDelayed[SCL_DEL_LEN-2] == 1'b1);
    
    assign sda_negedge = (sdaDelayed[SDA_DEL_LEN-1] == 1'b1 && sdaDelayed[SDA_DEL_LEN-2] == 1'b0);
    assign sda_posedge = (sdaDelayed[SDA_DEL_LEN-1] == 1'b0 && sdaDelayed[SDA_DEL_LEN-2] == 1'b1);
    
    assign start = (scl_flitered == 1'b1) && sda_negedge;
    assign stop  = (scl_flitered == 1'b1) && sda_posedge;
    
/*****************************************************************************************************/

    reg [4:0]i;                 //"步骤",指示状态
    reg [3:0]n_bit;             //每次Read或者Transmit的bit位计数
    reg dir;                    //地址所带的方向信息1-Read,0-Write
    
    //有关主机写(从机读)操作
    reg [7:0]recv_addr;         //主机发送的地址信息
    reg [7:0]recv_data;         //接收写操作的数据
    
    //有关主机读操作
    reg [7:0]send_data;         //主机读返回的数据
    reg [7:0]trans_buf;         //从机发送数据移位寄存器


    always@(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i <= 5'd1;
            n_bit <= 4'd8;
            dir <= 1'b0;
            recv_addr <= 8'd0;
            recv_data <= 8'd0;
            send_data <= 8'hF5;
            trans_buf <= 8'd0;
        end
        else
            case(i)
            
                0:
                begin : Wait_For_Stop
                    sda_isIn <= 1'b1;
                    scl_isIn <= 1'b1;
                    
                    if(stop) i <= 1;
                end
                
                1:
                begin : Wait_For_Start
                    sda_isIn <= 1'b1;
                    scl_isIn <= 1'b1;
                    
                    if(start) begin
                        n_bit <= 4'd8; //准备接收主机发送的从机地址信息:7bit(addr)+1bit(R/W)
                        i <= 2;
                    end
                end
                
                //
                //start or stop态
                //
                
                2:
                begin : Read_Slave_Address
                    if(n_bit == 4'd0) begin
                        if(recv_addr[7:1] == I2C_SLAVE_ADDR) begin
                            dir <= recv_addr[0];
                            n_bit <= 4'd8;
                            i <= 3;
                        end
                        else
                            i <= 0;
                    end
                    else if(scl_posedge) begin
                        recv_addr <= {recv_addr[6:0], sda_flitered};
                        n_bit <= n_bit - 1'b1;
                    end
                end
                
                3:
                begin : Send_Address_Ack
                    if(scl_negedge) begin
                        sda_isIn <= 1'b0;
                        i <= 4;
                    end
                end
                
                4:
                begin : Release_Address_Ack
                    if(scl_negedge) begin
                        sda_isIn <= 1'b1;
                        i <= 5;
                    end
                end
                
                //
                //首次从机地址应答态
                //
                
                5:
                begin : Determine_Read_or_Write
                    if(dir == 1'b0)
                        i<= 6;
                    else if(dir == 1'b1)
                        i <= 12;
                end
                
                //
                //读写方向决定态
                //
                
                6:
                begin : Master_Write_Operation
                    if(stop) begin
                        sda_isIn <= 1'b1;
                        n_bit <= 4'd8;
                        i <= 1;
                    end
                    if(start) begin
                        sda_isIn <= 1'b1;
                        n_bit <= 4'd8;
                        i <= 9;
                    end
                    else if (n_bit == 0) begin //本字节数据接收完成
                        n_bit <= 4'd8;
                        i <= 7; //本字节数据应答
                    end
                    else if (scl_posedge) begin //接收由主机发送的本字节数据
                        recv_data <= {recv_data[6:0], sda_flitered};
                        n_bit <= n_bit - 1'b1;
                    end
                end
                
                7:
                begin : Send_Data_Writen_Ack
                    if (scl_negedge) begin
                        sda_isIn <= 1'b0;
                        i <= 8;
                    end
                end
                
                8:
                begin : Release_Data_Written_Ack
                    if (scl_negedge) begin
                        sda_isIn <= 1'b1;
                        i <= 6; //<1>结束传输<2>改变方向,继而R-S,<3>继续读取数据
                    end
                end
                
                //
                //主机写数据态
                //
                
                9:
                begin : Read_Slave_Address_Again
                    if(n_bit == 4'd0) begin
                        n_bit <= 4'd8;
                        if((recv_addr[7:1] == I2C_SLAVE_ADDR) && (recv_addr[0] == 1'b1))
                            i <= 10;
                        else
                            i <= 0;
                    end
                    else if (scl_posedge) begin
                        recv_addr <= {recv_addr[6:0], sda_flitered};
                        n_bit <= n_bit - 1'b1;
                    end
                end
                
                10:
                begin : Send_Second_Address_Ack
                    if (scl_negedge) begin
                        sda_isIn <= 1'b0;
                        i <= 11;
                    end
                end
                
                11:
                begin : Release_Send_Second_Address_Ack__Wait_For_Negative_Edge_To_Transmit__Release_More_Data_Ack
                    if (scl_negedge) begin
                        sda_isIn <= 1'b1;
                        i <= 12;
                    end
                end
                
                //
                //R-S信号从机地址应答态
                //
                
                12:
                begin : Load_Data_to_Transmit_Register
                    sda_isIn <= 1'b1;
                    n_bit <= 4'd8;
                    trans_buf <= send_data; //将要发送的数据加载到发送移位寄存器
                    send_data <= send_data + 1'b1;
                    i <= 13;
                end
                
                13:
                begin : Transmit_Most_Significant_Bit
                    sda_isIn <= trans_buf[7]; //MSB(首先发送最高位),且在第1个上降沿来之前准备好数据(bit7)
                    i <= 14;
                end
                
                14:
                begin : Left_Shift_Transmit_Reg //Master_Read_bit6~bit0_Operation
                    if(stop)
                        i <= 1;
                    else if(n_bit == 0) begin
                        sda_isIn <= 1'b1;
                        n_bit <= 4'd8;
                        i <= 15;
                    end 
                    else if(scl_negedge) begin
                        trans_buf <= {trans_buf[6:0], 1'b1};
                        n_bit <= n_bit - 1'b1;
                        i <= 13;
                    end
                end
                
                15:
                begin : Master_Send_NAK_to_Stop_or_Continue_Reading
                    if (scl_posedge)
                        if (sda)
                            i <= 0;
                        else
                            i <= 11;
                end
                
                default:
                begin : Others_or_Exception
                    sda_isIn <= 1'b1;
                    scl_isIn <= 1'b1;
                    n_bit <= 4'd8;
                    i <= 1;
                end
                
            endcase
    end
    
    
endmodule

