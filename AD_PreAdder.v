module AD_PreAdder#(parameter  AREG      = 1,  //Number of pipeline stages for input A (AREG = 1 -> A2 is used)
                               ACASCREG  = 1, //Number of pipeline stages for ACOUT cascade datapath (<= AREG)
                               A_INPUT   = "Direct", // A is used , "Cascade" -> use ACIN
                               USE_DPORT = 0,
                               DREG      = 1,  //Number of pipeline stages for input D
                               ADREG     = 1  //Number of pipeline stages for  AD register
                            
)(
	input         clk,
	input         RSTA, //synchronous rst
	input         RSTD, //synchronous rst
    input         CEA1,
    input         CEA2,
    input         CED,
    input         CEAD,
    input  [3:0]  INMODE, 
    input  [29:0] A,
    input  [29:0] ACIN,
    input  [24:0] D,
    output [29:0] ACOUT,
    output [29:0] XMUX,
    output [24:0] AMULT
);

    wire [29:0] AMULT_DualReg;
    
	DualRegA #(
	    .AREG(AREG),
	    .ACASCREG(ACASCREG),
	    .A_INPUT(A_INPUT)
	) DualRegA_instance(
	    .clk(clk),
	    .RSTA(RSTA),
	    .CEA1(CEA1),
	    .CEA2(CEA2),
	    .INMODE(INMODE[0]),
	    .A(A),
	    .ACIN(ACIN),
	    .ACOUT(ACOUT),
	    .XMUX(XMUX),
	    .AMULT(AMULT_DualReg)
	);
	
	PreAdder #(
	    .USE_DPORT(USE_DPORT),
	    .DREG(DREG),
	    .ADREG(ADREG)
	) PreAdder_instance(
	    .clk(clk),
	    .RSTD(RSTD),
	    .CED(CED),
	    .CEAD(CEAD),
	    .D(D),
	    .INMODE(INMODE[3:1]),
	    .AMULT_REGA(AMULT_DualReg[24:0]),
	    .AMULT(AMULT)
	);
endmodule 
