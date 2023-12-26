`timescale 1ns/1ns

module DualReg_tb #(parameter  BREG     = 'b1,  //Number of pipeline stages for input B (BREG = 1 -> B2 is used)
                               BCASCREG = 'b1, //Number of pipeline stages for BCOUT cascade datapath (<= BREG)
                               B_INPUT  = "Direct" // B is used , "Cascade" -> use BCIN
);

    localparam CLK_PERIOD = 10;
    reg clk, RSTB, CEB1,CEB2,INMODE;
    reg [17:0] B,BCIN;
    
    wire [17:0] BCOUT,XMUX,BMULT;
    
    always #(CLK_PERIOD/2) clk = ~clk;
     
	DualRegB #(
	    .BREG(BREG),
	    .BCASCREG(BCASCREG),
	    .B_INPUT(B_INPUT)
	) DualRegB_instance(
	    .clk(clk),
	    .RSTB(RSTB),
	    .CEB1(CEB1),
	    .CEB2(CEB2),
	    .INMODE(INMODE),
	    .B(B),
	    .BCIN(BCIN),
	    .BCOUT(BCOUT),
	    .XMUX(XMUX),
	    .BMULT(BMULT)
	);
	
	initial begin 
	clk    = 1;
	INMODE = 1;
    CEB1   = 1;
    CEB2   = 1;
    B      = 0;
	RSTB   = 0;
	BCIN   = 0;
	@(negedge clk) RSTB = 1;
	#CLK_PERIOD RSTB = 0;
	@(posedge clk) B = $random;
	//expected output: XMUX -> 1 cycle delay of B
	@(posedge clk)
	if (XMUX == B) $display("Module operated as expeted : XMUX = B after 1 clk cycle");
	else $error("wrong value");
	end
	
endmodule 
