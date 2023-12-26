module register #( parameter WIDTH=1)(
	input wire clk,rst,enable,
	input wire [WIDTH-1:0] in,
	output reg [WIDTH-1:0] out
);

always @(posedge clk )
begin
	if( rst)
	begin
	out ='b0;

	end
	else if(enable)
	begin
	out =in;

	end

end
endmodule 