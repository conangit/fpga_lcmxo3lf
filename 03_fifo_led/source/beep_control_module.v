module beep_control_module(
    clk,
    rst_n,
    fifo_read_data,
    empty_sig,
    read_req_sig,
    func_done_sig,
    func_start_sig
    );
    
    input           clk;
    input           rst_n;
    
    input   [7:0]   fifo_read_data;
    
    input           empty_sig;
    output          read_req_sig;
    
    input           func_done_sig;
    output  [1:0]   func_start_sig;

    /**************************************/
    
    reg read_req;
    reg [1:0] func_start; //[1]S [0]O
    
    reg [3:0]i;
    reg [1:0]cmd;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i <= 4'd0;
            read_req <= 1'b0;
            func_start <= 2'b00;
            cmd <= 2'b00;
        end
        else
        
            case(i)
                
                0: //判断FIFO是否为空
                if (!empty_sig)
                    i <= i + 1'b1;
                    
                1: //从FIFO取得一个深度数据
                begin
                    i <= i + 1'b1;
                    read_req <= 1'b1;
                end
                
                2:
                begin
                    i <= i + 1'b1;
                    read_req <= 1'b0;
                end
                
                3:
                begin
                    if (fifo_read_data == 8'h1B)
                        cmd <= 2'b10; //S
                    else if(fifo_read_data == 8'h44)
                        cmd <= 2'b01; //O
                    else
                        cmd <= 2'b00;
                        
                    i <= i + 1'b1;
                end
                
                4:
                if (cmd == 2'b00)
                    i <= 4'd0;
                else
                    i <= i + 1'b1;
                    
                5:
                if (func_done_sig) begin
                    i <= 4'd0;
                    cmd <= 2'b00;
                    func_start <= 2'b00;
                end
                else
                    func_start <= cmd;

            endcase
    end
    
    assign read_req_sig = read_req;
    assign func_start_sig = func_start;
    
endmodule

