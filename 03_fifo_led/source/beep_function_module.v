module beep_function_module(
    clk,
    rst_n,
    start_sig,
    done_sig,
    pin_out
    );
    
    input clk;
    input rst_n;
    
    input [1:0]start_sig;
    
    output done_sig;
    output [7:0]pin_out;
    
    /**********************************/
    
    reg isDone;
    reg [7:0]pin;
    
    // 12MHz 0.5s
    parameter T0P5S = 24'd5_999_999;
    
    reg [23:0]count;
    reg isCount;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= 24'd0;
        else if (count == T0P5S)
            count <= 24'd0;
        else if(isCount)
            count <= count + 1'b1;
        else
            count <= 24'd0;
    end
    
    reg [8:0]count_s;
    reg [8:0]rTime;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count_s <= 9'd0;
        else if (count_s == rTime)
            count_s <= 9'd0;
        else if (count == T0P5S)
            count_s <= count_s + 1'b1;
    end
    
    
    reg [3:0]i;
    
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i <= 4'd0;
            isCount <= 1'b0;
            isDone <= 1'b0;
            pin <= 8'hff;
            rTime <= 9'h1ff;
        end
        else if (start_sig[1]) //S码 1s 亮D2
            
            case(i)
            
                0,2,4:
                if (count_s == rTime) begin
                    i <= i + 1'b1;
                    isCount <= 1'b0;
                    pin <= 8'hff;
                end
                else begin
                    isCount <= 1'b1;
                    rTime <= 9'd2;
                    pin <= 8'b1111_1110;
                end
                
                1,3,5: //0.5
                if (count_s == rTime) begin
                    i <= i + 1'b1;
                    isCount <= 1'b0;
                end
                else begin
                    isCount <= 1'b1;
                    rTime <= 9'd1;
                end
                
                6:
                begin
                    i <= i + 1'b1;
                    isDone <= 1'b1;
                end
                
                7:
                begin
                    i <= 4'd0;
                    isDone <= 1'b0;
                end
            
            endcase
        
        else if (start_sig[0]) //O码 2s 亮D6 D7 D8 D9
        
            case(i)
            
                0,2,4:
                if (count_s == rTime) begin
                    i <= i + 1'b1;
                    isCount <= 1'b0;
                    pin <= 8'hff;
                end
                else begin
                    isCount <= 1'b1;
                    rTime <= 9'd4;
                    pin <= 8'b0000_1111;
                end
                
                1,3,5: //0.5s
                if (count_s == rTime) begin
                    i <= i + 1'b1;
                    isCount <= 1'b0;
                end
                else begin
                    isCount <= 1'b1;
                    rTime <= 9'd1;
                end
                
                6:
                begin
                    i <= i + 1'b1;
                    isDone <= 1'b1;
                end
                
                7:
                begin
                    i <= 4'd0;
                    isDone <= 1'b0;
                end
            
            endcase
    end
    
    
    assign done_sig = isDone;
    assign pin_out = pin;
    
endmodule

