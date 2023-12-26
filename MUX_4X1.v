module MUX_4X1(
    input        [47:0] in1, // 0
    input        [47:0] in2, // M
    input        [47:0] in3, // 48'hFFFFFFFFFFFF
    input        [47:0] in4, // C
    input        [3:0]  sel,
    output reg   [47:0] mux_out
);
    always @(*) begin
        if (sel[3:2] == 'b0) begin
            mux_out = in1;
        end
        else if (sel[3:0] == 'b0101)begin
             mux_out = in2;   
        end
        else if (sel[3:2] == 'b10) begin
             mux_out = in3;
        end
        else if (sel[3:2] == 'b11) begin
             mux_out = in4;
        end
        else begin
             mux_out = in1;
        end
    end
    
endmodule