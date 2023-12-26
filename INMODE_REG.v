module INMODE_REG#(parameter INMODEREG = 1)(
    input         clk,
    input         RSTINMODE,
    input         CEINMODE,
    input  [4:0]  INMODE,
    output [4:0]  INMODE_out
);
   reg [4:0] INMODE_Rg;
   
   always @(posedge clk) begin
       if (RSTINMODE || INMODEREG == 'b0) begin
           INMODE_Rg <= 'b0;
       end
       else if (CEINMODE) begin
           INMODE_Rg <= INMODE;
       end    
   end
    
    assign INMODE_out = INMODEREG ? INMODE_Rg: INMODE;
    	
endmodule
