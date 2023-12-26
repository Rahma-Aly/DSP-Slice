module RegC #(parameter CREG = 1)(
	input         clk,
	input         RSTC,
	input         CEC,
	input  [47:0] C,
	output [47:0] C_out
);
   
   reg [47:0] C_Reg;
   
   always @(posedge clk) begin
       if (RSTC || CREG == 'b0) begin
           C_Reg <= 'b0;
       end
       else if (CEC) begin
           C_Reg <= C;
       end    
   end
    
	assign C_out = CREG ? C_Reg: C;
	
endmodule 
