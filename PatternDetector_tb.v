module PatternDetector_tb#(parameter PREG = 1,  //number of output register (0,1)
                                   AUTORESET_PATDET = 0, //NO_RESET -> default
                                                         // automatically reset P Reg 
                                                         // if pattern is found (RESET_MATCH -> 1)
                                                         // or not found (RESET_NOT_MATCH -> 2) 
                                   MASK = 48'h3FFFFFFFFFFF, 
                                         //when a MASK bit is set to 1 that bit is ignored
                                   PATTERN = 48'b0,
                                   SEL_MASK = 0, //can be the static field MASK (0) or input C (1)
                                                 //or  ROUNDING_MODE1 (2)(C' << 1)
                                                 //  or ROUNDING_MODE1 (3)(C' << 2)
                                   SEL_PATTERN = 1, //can either be the PATTERN (0) or input C (1)
                                   USE_PATTERN_DETECT = 1 //NO_PATDET (0) , PATDET (1)
);
  reg        clk,        RSTP,        CEP;
  reg [47:0] C, P;
  wire       OVERFLOW,       UNDERFLOW,
            PATTERNDETECT, // = 1 -> match , &((P == Pattern)||MASK)
           PATTERNBDETECT; // = 1 -> matches the complement of the pattern , &((P == ~Pattern)||MASK)
  reg       OVERFLOW_exp,       UNDERFLOW_exp, PATTERNDETECT_exp, PATTERNBDETECT_exp;
  
  localparam CLK_PERIOD = 100;
      
  always #(CLK_PERIOD/2) clk = ~clk;
  
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
    .C(C),
    .P(P),
    .OVERFLOW(OVERFLOW),
    .UNDERFLOW(UNDERFLOW),
    .PATTERNDETECT(PATTERNDETECT),
    .PATTERNBDETECT(PATTERNBDETECT)
);

    initial begin 
    clk    = 1;
//    P      = 0;
//    C      = 0;
    RSTP   = 0;
    @(negedge clk) RSTP = 1;
    #CLK_PERIOD    RSTP = 0; 
    @(posedge clk)
    repeat(5) begin
    CEP    = 1;
    P = $random;
    C = $random; 
    @(posedge clk)    
    PATTERNDETECT_exp  = USE_PATTERN_DETECT? (&(~(P ^ C) | MASK)) : 0;
    PATTERNBDETECT_exp = USE_PATTERN_DETECT? (&(~(P ^ ~C) | MASK)): 0;
    OVERFLOW_exp = (PatternDetector_instance.PATTERNDETECT_PAST  && ~PATTERNDETECT_exp && ~PATTERNBDETECT_exp);
    UNDERFLOW_exp = (PatternDetector_instance.PATTERNBDETECT_PAST  && ~PATTERNDETECT_exp && ~PATTERNBDETECT_exp);
//    #CLK_PERIOD;
    @(posedge clk)   
    $display("P: %0b, Pattern: %0b, overflow: %0b ,  expected overflow : %0b", P,C,OVERFLOW,OVERFLOW_exp);
    $display("underflow: %0b , expected underflow: %0b", UNDERFLOW,UNDERFLOW_exp);
    $display("Pattern detect: %0b , expected     : %0b", PATTERNDETECT,PATTERNDETECT_exp);
    $display("PatternB detect: %0b , expected    : %0b", PATTERNBDETECT,PATTERNBDETECT_exp);
    end
    end
	
endmodule 
