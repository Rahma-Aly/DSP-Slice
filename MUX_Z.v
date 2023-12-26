module MUX_Z(
	input [47:0] in1, //0
	input [47:0] in2, //PCIN
	input [47:0] in3, //P
	input [47:0] in4, //C
	input [47:0] in5, // P
	input [47:0] in6, // 
	input [47:0] in7, // 
	input [6:0]  sel,
	output reg [47:0] mux_out
);
	always @(*) begin
	    if (sel[6:4] == 'b0) begin
	        mux_out = in1;
	    end
	    else if (sel[6:4] == 'b001)begin
	         mux_out = in2;   
	    end
	    else if (sel[6:4] == 'b010) begin
	         mux_out = in3;
	    end
	    else if (sel[6:4] == 'b011) begin
	         mux_out = in4;
	    end
	    else if (sel == 'b1001000) begin
             mux_out = in5;
        end
         else if (sel[6:4] == 'b101) begin
             mux_out = in6;
        end
        else if (sel[6:4] == 'b110) begin
             mux_out = in7;
        end
	    else begin
	         mux_out = in1;
	    end
	end
	
endmodule 
