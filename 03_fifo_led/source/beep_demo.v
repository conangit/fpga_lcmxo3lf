`timescale 1ns/1ps

module beep_demo(
    input clk,
    input rst_n,
    output [7:0]pin_out
    );

    reg write_req;
    reg [7:0]fifo_write_data;
    wire full_sig;
    
    
    beep_interface_module u1(
        .clk(clk),
        .rst_n(rst_n),
        .write_req(write_req),
        .fifo_write_data(fifo_write_data),
        .full_sig(full_sig),
        .pin_out(pin_out)
    );
    
    reg [3:0]i;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i <= 4'd0;
            write_req <= 1'b0;
            fifo_write_data <= 8'd0;
        end
        else
            case(i)
            
                0:
                if (!full_sig) begin
                    i <= i + 1'b1;
                    write_req <= 1'b1;
                    fifo_write_data <= 8'h1B;
                end
                
                1:
                if (!full_sig) begin
                    i <= i + 1'b1;
                    fifo_write_data <= 8'h44;
                end
                
                2:
                if (!full_sig) begin
                    i <= i + 1'b1;
                    write_req <= 1'b1;
                    fifo_write_data <= 8'h1B;
                end
                
                3:
                begin
                    i <= i + 1'b1;
                    write_req <= 1'b0;
                end
                
                4:
                    i <= 4'd4;
            
            endcase
    end
    
endmodule

