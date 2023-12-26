module DSPSlice_tb#(parameter WIDTH     = 48,
                             BREG      = 1,  //Number of pipeline stages for reg B (BREG = 1 -> B2 is used)
                             BCASCREG  = 1, //Number of pipeline stages for BCOUT cascade datapath (<= BREG)
                             B_INPUT   = "Direct", // B is used , "Cascade" -> use BCIN
                             AREG      = 1,  //Number of pipeline stages for reg A (AREG = 1 -> A2 is used)
                             ACASCREG  = 1, //Number of pipeline stages for ACOUT cascade datapath (<= AREG)
                             A_INPUT   = "Direct", // A is used , "Cascade" -> use ACIN
                             USE_DPORT = 1, //default 0
                             USE_MULT  = "none", //multiply, none
                             USE_SIMD  = 0, //ONE48 (0), TWO24(1),FOUR12 (2)
                             ADREG     = 1,  //Number of pipeline stages for  AD register
                             DREG      = 1,  //Number of pipeline stages for reg D
                             CREG      = 1,
                             CARRYINREG= 1,
                             INMODEREG = 0,
                             ALUMODEREG= 1,
                             CARRYINSELREG = 1,
                             OPMODEREG = 0,
                             PREG      = 1,  //number of wire register (0,1)
                             MREG      = 1,  //number of wire register (0,1)
                             AUTORESET_PATDET = 0, //NO_RESET -> default
                                                         // automatically reset P Reg 
                                                         // if pattern is found (RESET_MATCH -> 1)
                                                         // or not found (RESET_NOT_MATCH -> 2) 
                             MASK = 48'b001111111111111111111111111111111111111111111111, 
                                         //when a MASK bit is set to 1 that bit is ignored
                             PATTERN = 48'b0,
                             SEL_MASK = 0, //can be the static field MASK (0) or reg C (1)
                                                 //or  ROUNDING_MODE1 (2)(C' << 1)
                                                 //  or ROUNDING_MODE1 (3)(C' << 2)
                             SEL_PATTERN = 1, //can either be the PATTERN (0) or reg C (1)
                             USE_PATTERN_DETECT = 1 //NO_PATDET (0) default , PATDET (1)
                             
                             
);
    localparam CLK_PERIOD = 100;
    
    reg         clk, RSTA, RSTB, RSTC,RSTD,RSTM,RSTP,RSTCTRL, RSTALLCARRYIN, RSTALUMODE,RSTINMODE; 
    reg  [29:0] A,ACIN;
    reg  [17:0] B,BCIN;
    reg  [24:0] D;
    reg  [47:0] C;
    reg  [47:0] PCIN;
    reg  [6:0]  OPMODE;
    reg  [3:0]  ALUMODE;
    reg  [4:0]  INMODE; 
    reg         CARRYIN;
    reg  [2:0]  CARRYINSEL;
    reg         CEA1,CEA2,CEB1,CEB2,CEC,CED,CEAD,CEM,CEP,CEALUMODE,CECTRL,CECARRYIN,CEINMODE;
    reg         CARRYCASCIN;
    reg         MULTSIGNIN;
    wire [29:0] ACOUT;
    wire [17:0] BCOUT;
    wire [47:0] PCOUT;
    wire [47:0] P;
    wire [3:0]  CARRYOUT;
    wire        CARRYCASCOUT;
    wire        MULTSIGNOUT;
    wire        OVERFLOW;
    wire        UNDERFLOW;
    wire        PATTERNDETECT; // = 1 -> match
    wire        PATTERNBDETECT; // = 1 -> matches the complement of the pattern    
    
    reg signed [24:0] AMULT_EXP;
    reg signed [42:0] MULT_OUT_EXP;
    reg signed [48:0] mult_out_after_alu;
    reg               OVERFLOW_exp,UNDERFLOW_exp, PATTERNDETECT_exp, PATTERNBDETECT_exp;
    reg        [48:0] alu_out;
    
    DSP_Slice #(
        .WIDTH(WIDTH),
        .BREG(BREG),
        .BCASCREG(BCASCREG),
        .B_INPUT(B_INPUT),
        .AREG(AREG),
        .ACASCREG(ACASCREG),
        .A_INPUT(A_INPUT),
        .USE_DPORT(USE_DPORT),
        .USE_MULT(USE_MULT),
        .USE_SIMD(USE_SIMD),
        .ADREG(ADREG),
        .DREG(DREG),
        .CREG(CREG),
        .CARRYINREG(CARRYINREG),
        .INMODEREG(INMODEREG),
        .ALUMODEREG(ALUMODEREG),
        .CARRYINSELREG(CARRYINSELREG),
        .OPMODEREG(OPMODEREG),
        .PREG(PREG),
        .MREG(MREG),
        .AUTORESET_PATDET(AUTORESET_PATDET),
        .MASK(MASK),
        .PATTERN(PATTERN),
        .SEL_MASK(SEL_MASK),
        .SEL_PATTERN(SEL_PATTERN),
        .USE_PATTERN_DETECT(USE_PATTERN_DETECT)
    ) DUT(
        .clk(clk),
        .RSTA(RSTA),
        .RSTB(RSTB),
        .RSTC(RSTC),
        .RSTD(RSTD),
        .RSTM(RSTM),
        .RSTP(RSTP),
        .RSTCTRL(RSTCTRL),
        .RSTALLCARRYIN(RSTALLCARRYIN),
        .RSTALUMODE(RSTALUMODE),
        .RSTINMODE(RSTINMODE),
        .A(A),
        .B(B),
        .D(D),
        .C(C),
        .ACIN(ACIN),
        .BCIN(BCIN),
        .PCIN(PCIN),
        .OPMODE(OPMODE),
        .ALUMODE(ALUMODE),
        .INMODE(INMODE),
        .CARRYIN(CARRYIN),
        .CARRYINSEL(CARRYINSEL),
        .CEA1(CEA1),
        .CEA2(CEA2),
        .CEB1(CEB1),
        .CEB2(CEB2),
        .CEC(CEC),
        .CED(CED),
        .CEAD(CEAD),
        .CEM(CEM),
        .CEP(CEP),
        .CEALUMODE(CEALUMODE),
        .CECTRL(CECTRL),
        .CECARRYIN(CECARRYIN),
        .CEINMODE(CEINMODE),
        .CARRYCASCIN(CARRYCASCIN),
        .MULTSIGNIN(MULTSIGNIN),
        .ACOUT(ACOUT),
        .BCOUT(BCOUT),
        .PCOUT(PCOUT),
        .P(P),
        .CARRYOUT(CARRYOUT),
        .CARRYCASCOUT(CARRYCASCOUT),
        .MULTSIGNOUT(MULTSIGNOUT),
        .OVERFLOW(OVERFLOW),
        .UNDERFLOW(UNDERFLOW),
        .PATTERNDETECT(PATTERNDETECT),
        .PATTERNBDETECT(PATTERNBDETECT)
    );
    
    always  #(CLK_PERIOD/2) clk = ~clk;
    
    initial begin
        clk           = 1;
        RSTA          = 0;
        RSTB          = 0; 
        RSTC          = 0;
        RSTD          = 0;
        RSTM          = 0;
        RSTP          = 0;
        RSTCTRL       = 0;
        RSTALLCARRYIN = 0;
        RSTALUMODE    = 0;
        RSTINMODE     = 0;
        A             = $random;
        ACIN          = 0;
        B             = $random;
        BCIN          = 0;
        D             = $random;
        C             = $random;
        PCIN          = 0;
        OPMODE        = 0;
        ALUMODE       = 0;
        INMODE        = 0;
        CARRYIN       = 0;
        CARRYINSEL    = 0;
        CEA1          = 1;
        CEA2          = 1;
        CEB1          = 1;
        CEB2          = 1;
        CEC           = 1;
        CED           = 1;
        CEAD          = 1;
        CEM           = 1;
        CEP           = 1;
        CEALUMODE     = 1;
        CECTRL        = 1;
        CECARRYIN     = 1;
        CEINMODE      = 1;
        CARRYCASCIN   = 0;
        MULTSIGNIN    = 0;
        /*------------------SYS RST---------------------*/
        @(negedge clk) 
        RSTA          = 1;
        RSTB          = 1; 
        RSTC          = 1;
        RSTD          = 1;
        RSTM          = 1;
        RSTP          = 1;
        RSTCTRL       = 1;
        RSTALLCARRYIN = 1;
        RSTALUMODE    = 1;
        RSTINMODE     = 1;
        #CLK_PERIOD 
        RSTA          = 0;
        RSTB          = 0; 
        RSTC          = 0;
        RSTD          = 0;
        RSTM          = 0;
        RSTP          = 0;
        RSTCTRL       = 0;
        RSTALLCARRYIN = 0;
        RSTALUMODE    = 0;
        RSTINMODE     = 0;
        /*---------------------CASE 1: multiply operation ( USE_MULT = "multiply") --------------------------*/
        if (USE_MULT ==  "multiply") begin
            //run multiply_test task
            multiply_test();
        end 
        else if (USE_MULT == "none") begin
             //run alu_test task
            alu_test();
        end
        
    end
    
    
    task multiply_test(); begin : multiply_test
        integer i;
        OPMODE     = 'b0101; 
        @(posedge clk);
             for (i = 0; i < 'd17; i = i + 1) begin
                 INMODE = i;
                     if (USE_DPORT) begin
                         @(posedge clk);
                         AMULT_EXP = AMULT_exp(INMODE);
                     end
                     else begin
                             if (INMODE[1]) AMULT_EXP = 0 ;
                             else AMULT_EXP = A;  
                     end
                     MULT_OUT_EXP = $signed(B)* AMULT_EXP;       
                     #(CLK_PERIOD)
                     @(negedge clk) 
                     $display("---------------------------Test # %0d-----------------------------------",i);
                     if (DUT.AMULT == AMULT_EXP)  
                     $display("Passed: A: %0b, D: %0b, AMULT: %0b , expected AMULT = %0b", A,D,DUT.AMULT,AMULT_EXP);
                     else $error(" preadder output failed : AMULT (%0b) != AMULT_EXP (%0b)", DUT.AMULT,AMULT_EXP);
                     if (MULT_OUT_EXP == DUT.mult_signed_instance.PP1 + DUT.mult_signed_instance.PP2) begin
                          $display(" MULT_OUT Passed : mult out val = %0b, expected val = %0b",DUT.mult_signed_instance.PP1 + DUT.mult_signed_instance.PP2,MULT_OUT_EXP);
                     end
                     else begin
                         $error("MULT_OUT Failed : MULT_OUT_EXP(%0b) != mult_out_val (%0b)",MULT_OUT_EXP,DUT.mult_signed_instance.PP1 + DUT.mult_signed_instance.PP2);        
                     end   
                     mult_out_after_alu = DUT.MUX_X.mux_out + DUT.MUX_Y.mux_out;
                     #(CLK_PERIOD)
                     if ({MULTSIGNOUT,P} == mult_out_after_alu) begin
                         $display(" MULT_OUT (after) Passed : mult out val = %0b, expected val = %0b",{MULTSIGNOUT,P},mult_out_after_alu);
                     end
                     else begin
                         $error("MULT_OUT Failed : MULT_OUT_EXP(%0b) != mult_out_val (%0b)",MULT_OUT_EXP,DUT.mult_signed_instance.PP1 + DUT.mult_signed_instance.PP2);        
                     end
                     /*---Pattern detector--*/
                     pattern_detector_check();
            end
    end
    endtask
    
    task alu_test(); begin :alu_test
        integer i;
        OPMODE = 'b0110011; //Z = C , X = A:B
        @(posedge clk)
             for (i = 0; i < 'd17; i = i + 1) begin
                 ALUMODE = i;
                 C     = $random;
                 OPMODE[3:2] = (i%2)<<1; //0,2 
                     MULT_OUT_EXP = 0; // USE_MULT = none      
                     #(CLK_PERIOD)
                     @(negedge clk) 
                     /*--------------Print test number-------------*/
                     $display("---------------------------Test # %0d-----------------------------------",i);
                     /*------MULT CHECK-------*/
                     if (MULT_OUT_EXP == DUT.mult_signed_instance.PP1 + DUT.mult_signed_instance.PP2) begin
                          $display(" MULT_OUT Passed : mult out val = %0b, expected val = %0b",DUT.mult_signed_instance.PP1 + DUT.mult_signed_instance.PP2,MULT_OUT_EXP);
                     end
                     else begin
                         $error("MULT_OUT Failed : MULT_OUT_EXP(%0b) != mult_out_val (%0b)",MULT_OUT_EXP,DUT.mult_signed_instance.PP1 + DUT.mult_signed_instance.PP2);        
                     end   
                     /*---------ALU_Check--------*/
                     alu_out = ALU_out(ALUMODE,OPMODE);
                     #(CLK_PERIOD)
                     if ({CARRYOUT[3],P} == alu_out) begin
                         $display(" ALU_OUT Passed : out val = %0b, expected val = %0b",{CARRYOUT[3],P}, alu_out);
                         $display("ALUMODE: %0b, OPMODE: %0b",ALUMODE,OPMODE);
                     end
                     else begin
                         $error("ALU_OUT Failed : OUT_EXP(%0b) != out_val (%0b)",alu_out,{CARRYOUT[3],P});        
                         $display("ALUMODE: %0b, OPMODE: %0b",ALUMODE,OPMODE);
                     end
                     /*---Pattern detector--*/
                     pattern_detector_check();
                 
            end 
        end
    endtask
   
   task pattern_detector_check();
       begin
         PATTERNDETECT_exp  = USE_PATTERN_DETECT? (&(~(P ^ DUT.PatternDetector_instance.Pattern_IN)  | MASK)) : 0;
         PATTERNBDETECT_exp = USE_PATTERN_DETECT? (&(~(P ^ ~DUT.PatternDetector_instance.Pattern_IN) | MASK)) : 0;
         OVERFLOW_exp = (DUT.PatternDetector_instance.PATTERNDETECT_PAST  && ~PATTERNDETECT_exp && ~PATTERNBDETECT_exp);
         UNDERFLOW_exp = (DUT.PatternDetector_instance.PATTERNBDETECT_PAST  && ~PATTERNDETECT_exp && ~PATTERNBDETECT_exp);
         @(posedge clk)   
         if (PATTERNDETECT_exp == PATTERNDETECT && PATTERNBDETECT_exp == PATTERNBDETECT && OVERFLOW_exp == OVERFLOW && UNDERFLOW_exp == UNDERFLOW) begin
         $display("Pattern detector passed: P: %0b, Pattern: %0b, overflow: %0b ,  expected overflow : %0b", P,DUT.PatternDetector_instance.Pattern_IN,OVERFLOW,OVERFLOW_exp);
         $display("underflow: %0b , expected underflow: %0b", UNDERFLOW,UNDERFLOW_exp);
         $display("Pattern detect: %0b , expected     : %0b", PATTERNDETECT,PATTERNDETECT_exp);
         $display("PatternB detect: %0b , expected    : %0b", PATTERNBDETECT,PATTERNBDETECT_exp);
         end else begin
                $error("Pattern detector failed");
         end  
       end
   endtask
 
     
    function reg [24:0] AMULT_exp (input [3:0] INMODE);
        begin
        casex (INMODE)
          'b000? :  AMULT_exp = A[24:0];
          'b001? :  AMULT_exp = 'b0; 
          'b010? :  AMULT_exp = D + A[24:0];
          'b011? :  AMULT_exp = D ;
          'b100? :  AMULT_exp = -A[24:0]; 
          'b101? :  AMULT_exp = 0;
          'b110? :  AMULT_exp = D - A[24:0];
          'b111? :  AMULT_exp = D ;
          default : ; //null
      endcase
    end
    endfunction
    
    function reg [48:0] ALU_out (input [3:0] ALUMODE, [6:0]  OPMODE);
        begin
           casex({OPMODE[3:2],ALUMODE})
                'b??0000: ALU_out = DUT.MUX_Z_instance.mux_out + DUT.MUX_X.mux_out + DUT.MUX_Y.mux_out + DUT.ALU_WITH_IN_OUT_instance.M4.out;
                'b??0001: ALU_out = (~DUT.MUX_Z_instance.mux_out) + DUT.MUX_X.mux_out + DUT.MUX_Y.mux_out + DUT.ALU_WITH_IN_OUT_instance.M4.out;
                'b??0010: ALU_out = ~ (DUT.MUX_Z_instance.mux_out + DUT.MUX_X.mux_out + DUT.MUX_Y.mux_out + DUT.ALU_WITH_IN_OUT_instance.M4.out);  
                'b??0011: ALU_out = DUT.MUX_Z_instance.mux_out - (DUT.MUX_X.mux_out + DUT.MUX_Y.mux_out + DUT.ALU_WITH_IN_OUT_instance.M4.out);
                'b000100: ALU_out = {1'b0,  DUT.MUX_X.mux_out ^ DUT.MUX_Z_instance.mux_out} ;
                'b000101: ALU_out = {1'b0,~(DUT.MUX_X.mux_out ^ DUT.MUX_Z_instance.mux_out)};
                'b000110: ALU_out = {1'b0,~(DUT.MUX_X.mux_out ^ DUT.MUX_Z_instance.mux_out)};
                'b000111: ALU_out = {1'b0,  DUT.MUX_X.mux_out ^ DUT.MUX_Z_instance.mux_out };
                'b001100: ALU_out = {1'b0,  DUT.MUX_X.mux_out & DUT.MUX_Z_instance.mux_out };
                'b001101: ALU_out = {1'b0,  DUT.MUX_X.mux_out & ~DUT.MUX_Z_instance.mux_out};
                'b001110: ALU_out = {1'b0,~(DUT.MUX_X.mux_out & DUT.MUX_Z_instance.mux_out)};
                'b001111: ALU_out = {1'b0, ~DUT.MUX_X.mux_out | DUT.MUX_Z_instance.mux_out };
                'b100100: ALU_out = {1'b0,~(DUT.MUX_X.mux_out ^ DUT.MUX_Z_instance.mux_out)};
                'b100101: ALU_out = {1'b0,  DUT.MUX_X.mux_out ^ DUT.MUX_Z_instance.mux_out };
                'b100110: ALU_out = {1'b0,  DUT.MUX_X.mux_out ^ DUT.MUX_Z_instance.mux_out };
                'b100111: ALU_out = {1'b0,~(DUT.MUX_X.mux_out ^ DUT.MUX_Z_instance.mux_out)};
                'b101100: ALU_out = {1'b0,  DUT.MUX_X.mux_out | DUT.MUX_Z_instance.mux_out };
                'b101101: ALU_out = {1'b0,  DUT.MUX_X.mux_out | ~DUT.MUX_Z_instance.mux_out};
                'b101110: ALU_out = {1'b0,~(DUT.MUX_X.mux_out | DUT.MUX_Z_instance.mux_out)};
                'b101111: ALU_out = {1'b0, ~DUT.MUX_X.mux_out & DUT.MUX_Z_instance.mux_out};
                default : ALU_out = 0;
            endcase
        end
    endfunction
    
  
endmodule