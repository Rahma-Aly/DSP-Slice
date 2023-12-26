module MUX8#(parameter WIDTH=1)(
input wire [WIDTH-1:0] IN0,
	input wire [WIDTH-1:0] IN1,
input wire [WIDTH-1:0] IN2,
input wire [WIDTH-1:0] IN3,
input wire [WIDTH-1:0] IN4,
input wire [WIDTH-1:0] IN5,
input wire [WIDTH-1:0] IN6,
input wire [WIDTH-1:0] IN7,
input wire [2:0]sel,
output reg [WIDTH-1:0] out
);

always @(*)
begin
	case (sel)
	'd0: out=IN0;
    'd1: out=IN1;
    'd2: out=IN2;
    'd3: out=IN3;
    'd4: out=IN4;
    'd5: out=IN5;
    'd6: out=IN6;
    'd7: out=IN7;
	endcase
end

endmodule 
