module MUX2#(parameter WIDTH=1)(
	input wire [WIDTH-1:0] IN1,
input wire [WIDTH-1:0] IN2,
input wire sel,
output wire [WIDTH-1:0] out
);

assign out=(sel?IN2:IN1); 

endmodule 
