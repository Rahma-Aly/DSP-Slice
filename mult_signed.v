module mult_signed #(parameter MREG = 1, parameter USE_MULT = "multiply" )(
input signed    [24:0]  A,
input signed    [17:0]  B,
input           CLK,
input           RSTM,
input           CEM,
output reg signed [42:0] PP1,PP2
);
reg signed [24:0] x;
reg signed [24:0] y;
reg signed [85:0] D;
reg signed [85:0] M;

always @(*) begin
    if (USE_MULT != "none") begin
        x = {7'b0,A[17:0]};
        y = ({A[24:18],18'b0});
        D[85:43] = x*B;
        D[42:0]  = y*B;
    end
    else begin
        x = 0;
        y = 0;
        D = 86'b0;
    end
end

always @(posedge CLK) begin
    if (RSTM) M <= 86'b0;
    else if ( MREG && CEM ) M <= D;
    else M <= 86'b0;
end

always @(*) begin
    case( MREG )
    1'b0:   begin
        PP1 = D[85:43];
        PP2 = D[42:0];
        end
    1'b1:   begin
        PP1 = M[85:43];
        PP2 = M[42:0];      
        end
    endcase
end
endmodule