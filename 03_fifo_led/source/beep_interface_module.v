module beep_interface_module(
    clk,
    rst_n,
    write_req,
    fifo_write_data,
    full_sig,
    pin_out
    );
    
    input clk;
    input rst_n;
    
    input write_req;
    input [7:0]fifo_write_data;
    output full_sig;
    output [7:0]pin_out;
    
    /***********************/
    
    wire empty_sig;
    wire read_req_sig;
    wire [7:0]fifo_read_data;
    wire func_done_sig;
    wire [1:0]func_start_sig;
    
    /*
    // spartan6
    fifo_ip u1 (
        .clk(clk), // input clk
        .rst(!rst_n), // input rst
        .din(fifo_write_data), // input [7 : 0] din
        .wr_en(write_req), // input wr_en
        .rd_en(read_req_sig), // input rd_en
        .dout(fifo_read_data), // output [7 : 0] dout
        .full(full_sig), // output full
        .empty(empty_sig) // output empty
    );
    */
    
    // LCMOX3LF
    fifo_ip u1(
        .Data(fifo_write_data),
        .WrClock(clk),
        .RdClock(clk),
        .WrEn(write_req),
        .RdEn(read_req_sig),
        .Reset(!rst_n),
        .RPReset(),
        .Q(fifo_read_data),
        .Empty(empty_sig),
        .Full(full_sig),
        .AlmostEmpty(),
        .AlmostFull()
    );
    
    
    beep_control_module u2(
        .clk(clk),
        .rst_n(rst_n),
        .fifo_read_data(fifo_read_data),
        .empty_sig(empty_sig),
        .read_req_sig(read_req_sig),
        .func_done_sig(func_done_sig),      //input from u3
        .func_start_sig(func_start_sig)     //output to u3
    );
    
    beep_function_module u3(
        .clk(clk),
        .rst_n(rst_n),
        .start_sig(func_start_sig),
        .done_sig(func_done_sig),
        .pin_out(pin_out)
    );
    
endmodule

