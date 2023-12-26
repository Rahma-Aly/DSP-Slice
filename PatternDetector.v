module PatternDetector #(parameter PREG = 1,  //number of output register (0,1)
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
                                   SEL_PATTERN = 0, //can either be the PATTERN (0) or input C (1)
                                   USE_PATTERN_DETECT = 0 //NO_PATDET (0) , PATDET (1)
)(
  input        clk,
  input        RSTP,
  input        CEP,
  input [47:0] C,
  input [47:0] P,
  output       OVERFLOW,
  output       UNDERFLOW,
  output   PATTERNDETECT, // = 1 -> match , &((P == Pattern)||MASK)
  output   PATTERNBDETECT // = 1 -> matches the complement of the pattern , &((P == ~Pattern)||MASK)
);

    wire [47:0] Pattern_IN, Mask_IN;
    reg PATTERNDETECT_reg, PATTERNBDETECT_reg;
    reg PATTERNDETECT_PAST, PATTERNBDETECT_PAST;
    wire PATTERNDETECT_val, PATTERNBDETECT_val;
    /*---------used pattern and mask -------------------*/
    assign Pattern_IN = (SEL_PATTERN)? C:PATTERN;
    assign Mask_IN    = (SEL_MASK == 'b0)? MASK : 
                        ((SEL_MASK == 'b1)? C: (SEL_MASK == 'b10)? (~C<<1) :(SEL_MASK == 'b11)? (~C<<2): MASK);
    
    /*---------------- Pattern Detect logic --------------- */
    assign PATTERNDETECT_val  = USE_PATTERN_DETECT? (&(~(P ^ Pattern_IN) | Mask_IN)) : 1'b0;
    assign PATTERNBDETECT_val = USE_PATTERN_DETECT? (&(~(P ^ ~Pattern_IN) | Mask_IN)): 1'b0;
    
    always @(posedge clk) begin
        if (RSTP) begin
            PATTERNDETECT_reg  <= 'b0;
            PATTERNBDETECT_reg <= 'b0;
        end
        else if (CEP) begin
            PATTERNDETECT_reg  <= PATTERNDETECT_val;
            PATTERNBDETECT_reg <= PATTERNBDETECT_val;
        end    
    end
    
    always @(posedge clk) begin
        if (RSTP) begin
            PATTERNDETECT_PAST  <= 'b0;
            PATTERNBDETECT_PAST <= 'b0;
        end
        else if (CEP) begin
                PATTERNDETECT_PAST  <= PATTERNDETECT;
                PATTERNBDETECT_PAST <= PATTERNBDETECT;
        end    
    end
    
    assign PATTERNDETECT  = PREG ? PATTERNDETECT_val  : PATTERNDETECT_reg;
    assign PATTERNBDETECT = PREG ? PATTERNBDETECT_val : PATTERNBDETECT_reg;
     /*---------------- Overflow and underflow logic ------------ */
    assign OVERFLOW  = (PATTERNDETECT_PAST  && ~PATTERNDETECT && ~PATTERNBDETECT);
    assign UNDERFLOW = (PATTERNBDETECT_PAST && ~PATTERNDETECT && ~PATTERNBDETECT);
    
endmodule