module DSP_Slice#(parameter  WIDTH     = 48,
                             BREG      = 1,  //Number of pipeline stages for input B (BREG = 1 -> B2 is used)
                             BCASCREG  = 1, //Number of pipeline stages for BCOUT cascade datapath (<= BREG)
                             B_INPUT   = "Direct", // B is used , "Cascade" -> use BCIN
                             AREG      = 1,  //Number of pipeline stages for input A (AREG = 1 -> A2 is used)
                             ACASCREG  = 1, //Number of pipeline stages for ACOUT cascade datapath (<= AREG)
                             A_INPUT   = "Direct", // A is used , "Cascade" -> use ACIN
                             USE_DPORT = 1, //default 0
                             USE_MULT  = "multiply", //multiply, none
                             USE_SIMD  = 0, //ONE48 (0), TWO24(1),FOUR12 (2)
                             ADREG     = 1,  //Number of pipeline stages for  AD register
                             DREG      = 1,  //Number of pipeline stages for input D
                             CREG      = 1,
                             CARRYINREG= 1,
                             INMODEREG = 1,
                             ALUMODEREG= 1,
                             CARRYINSELREG = 1,
                             OPMODEREG = 1,
                             PREG      = 1,  //number of output register (0,1)
                             MREG      = 1,  //number of output register (0,1)
                             AUTORESET_PATDET = 0, //NO_RESET -> default
                                                         // automatically reset P Reg 
                                                         // if pattern is found (RESET_MATCH -> 1)
                                                         // or not found (RESET_NOT_MATCH -> 2) 
                             MASK = 48'b001111111111111111111111111111111111111111111111, 
                                         //when a MASK bit is set to 1 that bit is ignored
                             PATTERN = 48'b0,
                             SEL_MASK = 0, //can be the static field MASK (0) or input C (1)
                                                 //or  ROUNDING_MODE1 (2)(C' << 1)
                                                 //  or ROUNDING_MODE1 (3)(C' << 2)
                             SEL_PATTERN = 1, //can either be the PATTERN (0) or input C (1)
                             USE_PATTERN_DETECT = 1 //NO_PATDET (0) default , PATDET (1)
                             
                             
)(
    input         clk,
    input         RSTA, //synchronous rst
    input         RSTB, //synchronous rst
    input         RSTC,
    input         RSTD, //synchronous rst
    input         RSTM, //synchronous rst
    input         RSTP, //synchronous rst
    input         RSTCTRL, //synchronous rst
    input         RSTALLCARRYIN, //synchronous rst
    input         RSTALUMODE, //synchronous rst
    input         RSTINMODE, 
    input  [29:0] A,
    input  [17:0] B,
    input  [24:0] D,
    input  [47:0] C,
    input  [29:0] ACIN,
    input  [17:0] BCIN,
    input  [47:0] PCIN,
    input  [6:0]  OPMODE,
    input  [3:0]  ALUMODE,
    input  [4:0]  INMODE, 
    input         CARRYIN,
    input  [2:0]  CARRYINSEL,
    input         CEA1,
    input         CEA2,
    input         CEB1,
    input         CEB2,
    input         CEC,
    input         CED,
    input         CEAD,
    input         CEM,
    input         CEP,
    input         CEALUMODE,
    input         CECTRL,
    input         CECARRYIN,
    input         CEINMODE,
    input         CARRYCASCIN,
    input         MULTSIGNIN,
    output [29:0] ACOUT,
    output [17:0] BCOUT,
    output [47:0] PCOUT,
    output [47:0] P,
    output [3:0]  CARRYOUT,
    output        CARRYCASCOUT,
    output        MULTSIGNOUT,
    output        OVERFLOW,
    output        UNDERFLOW,
    output        PATTERNDETECT, // = 1 -> match
    output        PATTERNBDETECT // = 1 -> matches the complement of the pattern    
    
);
    wire [17:0] XMUX_B,BMULT;
    wire [29:0] XMUX_A;
    wire [24:0] AMULT;
    wire [47:0] C_out,X,Y,Z,OUT,OUT_REG;
    wire [4:0]  INMODE_out;
    wire signed [42:0] PP1,PP2;

	DualRegB #(
	    .BREG(BREG),
	    .BCASCREG(BCASCREG),
	    .B_INPUT(B_INPUT)
	) DualRegB_instance(
	    .clk(clk),
	    .RSTB(RSTB),
	    .CEB1(CEB1),
	    .CEB2(CEB2),
	    .INMODE(INMODE_out[4]),
	    .B(B),
	    .BCIN(BCIN),
	    .BCOUT(BCOUT),
	    .XMUX(XMUX_B),
	    .BMULT(BMULT)
	);
	
	
	AD_PreAdder #(
	    .AREG(AREG),
	    .ACASCREG(ACASCREG),
	    .A_INPUT(A_INPUT),
	    .USE_DPORT(USE_DPORT),
	    .DREG(DREG),
	    .ADREG(ADREG)
	) AD_PreAdder_instance(
	    .clk(clk),
	    .RSTA(RSTA),
	    .RSTD(RSTD),
	    .CEA1(CEA1),
	    .CEA2(CEA2),
	    .CED(CED),
	    .CEAD(CEAD),
	    .INMODE(INMODE_out[3:0]),
	    .A(A),
	    .ACIN(ACIN),
	    .D(D),
	    .ACOUT(ACOUT),
	    .XMUX(XMUX_A),
	    .AMULT(AMULT)
	);
	
	RegC #(
	    .CREG(CREG)
	) RegC_instance(
	    .clk(clk),
	    .RSTC(RSTC),
	    .CEC(CEC),
	    .C(C),
	    .C_out(C_out)
	);
	
	INMODE_REG #(
	    .INMODEREG(INMODEREG)
	) INMODE_REG_instance(
	    .clk(clk),
	    .RSTINMODE(RSTINMODE),
	    .CEINMODE(CEINMODE),
	    .INMODE(INMODE),
	    .INMODE_out(INMODE_out)
	);
    
    mult_signed #(
        .MREG(MREG),
        .USE_MULT(USE_MULT)
    ) mult_signed_instance(
        .A(AMULT),
        .B(BMULT),
        .CLK(clk),
        .RSTM(RSTM),
        .CEM(CEM),
        .PP1(PP1),
        .PP2(PP2)
    );	
	
	MUX_4X1 MUX_X(
	    .in1(48'b0),
	    .in2({{5{PP1[42]}},PP1}),
	    .in3(P),
	    .in4({XMUX_A,XMUX_B}),
	    .sel({OPMODE[1:0],OPMODE[3:2]}),
	    .mux_out(X)
	);
	
	MUX_4X1 MUX_Y(
        .in1(48'b0),
        .in2({{5{PP2[42]}},PP2}),
        .in3(48'hFFFFFFFFFFFF),
        .in4(C_out),
        .sel(OPMODE[3:0]),
        .mux_out(Y)
    );
	
	MUX_Z MUX_Z_instance(
	    .in1(48'b0),
	    .in2(PCIN),
	    .in3(P),
	    .in4(C_out),
	    .in5(P),
	    .in6(PCIN>>17),
	    .in7(P>>17),
	    .sel(OPMODE),
	    .mux_out(Z)
	);
	
	ALU_WITH_IN_OUT #(
	    .WIDTH(WIDTH),
	    .OPMODE_REG_Control(OPMODEREG),
	    .ALUMODE_REG_CONTROL(ALUMODEREG),
	    .CARRYINSEL_REG_CONTROL(CARRYINSELREG),
	    .USE_MULT(USE_MULT),
	    .CARRYINREG(CARRYINREG)
	) ALU_WITH_IN_OUT_instance(
	    .OPMODE(OPMODE),
	    .ALUMODE(ALUMODE),
	    .CARRYINSEL(CARRYINSEL),
	    .X(X),
	    .Y(Y),
	    .Z(Z),
	    .clk(clk),
	    .RSTCTRL(RSTCTRL),
	    .RSTALLCARRYIN(RSTALLCARRYIN),
	    .RSTP(RSTP),
	    .CECTRL(CECTRL),
	    .CECARRYIN(CECARRYIN),
	    .CEM(CEM),
	    .multiply_sign_in(MULTSIGNIN),
	    .CARRYIN(CARRYIN),
	    .PCIN(PCIN[47]),
	    .CARRYCASCIN(CARRYCASCIN),
	    .CIN6(~(AMULT[24]^ BMULT[17])), // use ?
	    .RSTALUMODE(RSTALUMODE),
	    .CEALUMODE(CEALUMODE),
	    .CEP(CEP),
	    .OUT_REG(OUT_REG),
	    .OUT(OUT),
	    .CARRYOUT(CARRYOUT),
	    .multiply_sign_out_reg(MULTSIGNOUT)
	);
	
	PatternDetector #(
	    .PREG(PREG),
	    .AUTORESET_PATDET(AUTORESET_PATDET),
	    .MASK(MASK),
	    .PATTERN(PATTERN),
	    .SEL_MASK(SEL_MASK),
	    .SEL_PATTERN(SEL_PATTERN),
	    .USE_PATTERN_DETECT(USE_PATTERN_DETECT)
	) PatternDetector_instance(
	    .clk(clk),
	    .RSTP(RSTP),
	    .CEP(CEP),
	    .C(C_out),
	    .P(OUT),
	    .OVERFLOW(OVERFLOW),
	    .UNDERFLOW(UNDERFLOW),
	    .PATTERNDETECT(PATTERNDETECT),
	    .PATTERNBDETECT(PATTERNBDETECT)
	);
	
	MUX2 #(
	    .WIDTH(WIDTH)
	) PMUX(
	    .IN1(OUT),
	    .IN2(OUT_REG),
	    .sel(PREG),
	    .out(P)
	);
	
	assign PCOUT = P;
	assign CARRYCASCOUT = CARRYOUT[3];
endmodule 
