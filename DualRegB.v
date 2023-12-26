module DualRegB #(parameter  BREG     = 1,  //Number of pipeline stages for input B (BREG = 1 -> B2 is used)
                             BCASCREG = 1, //Number of pipeline stages for BCOUT cascade datapath (<= BREG)
                             B_INPUT  = "Direct" // B is used , "Cascade" -> use BCIN
)(
	input         clk,
	input         RSTB, //synchronous rst
	input         CEB1,
	input         CEB2,
	input         INMODE, //INMODE[4] considered when BREG = 1,2: 0 -> BMULT = B2 , 1-> BMULT = B1
	input  [17:0] B,
	input  [17:0] BCIN,
	output [17:0] BCOUT,
	output [17:0] XMUX,
	output signed [17:0] BMULT // ?
);
    
    reg  [17:0] B1,B2;
    wire [17:0] B1_In, B2_In, B2_MUX_OUT;
    //Reg B1
    assign B1_In = (B_INPUT == "Direct")? B:(B_INPUT == "Cascade")? BCIN : B;
    
    always @(posedge clk) begin 
        if (RSTB || BREG == 'b0) begin
            B1 <= 'b0;
        end
        else if (CEB1) begin
                B1 <= B1_In;
        end     
    end
    
    //Reg B2
    assign B2_In = (BREG == 'b10)? B1:B1_In;
    
    always @(posedge clk) begin 
        if (RSTB || BREG == 'b0) begin
            B2 <= 'b0;
        end
        else if (CEB2) begin
            B2 <= B2_In;    
        end     
    end    
	
	assign B2_MUX_OUT = (BREG == 'b0)? B2_In:B2;
	
	assign BMULT = INMODE ? B1:B2_MUX_OUT; 
	assign XMUX  = B2_MUX_OUT;
	assign BCOUT = (BCASCREG == BREG)? B2_MUX_OUT: B1;
	
endmodule
