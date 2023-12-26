module PreAdder #(parameter USE_DPORT = 0,
                            DREG      = 1,  //Number of pipeline stages for input D
                            ADREG     = 1  //Number of pipeline stages for  AD register
)(
	input             clk,
	input             RSTD, //synchronous rst
    input             CED,
    input             CEAD,
    input      [24:0] D,
    input      [2:0]  INMODE,  //INMODE[3:1]
    input      [24:0] AMULT_REGA,
    output     [24:0] AMULT
);

  reg  [24:0] D_in, AD,AD_in;
  wire [24:0] D_MUX_OUT, AD_MUX_OUT; 
  /*------------ D REG -------------*/
  always @(posedge clk) begin
      if (RSTD || DREG == 'b0) begin
          D_in <= 'b0;
      end
      else if (CED) begin
              D_in <= D;
      end
  end
  
  assign D_MUX_OUT = (DREG) ? D_in : D;
  
  /*---------Pre-adder operation---------*/
  always @(*) begin
      case (INMODE)
          'b000 : AD_in = AMULT_REGA;
          'b001 : AD_in = 'b0;
          'b010 : AD_in = D_MUX_OUT + AMULT_REGA;
          'b011 : AD_in = D_MUX_OUT;
          'b100 : AD_in = -AMULT_REGA;
          'b101 : AD_in = 'b0;
          'b110 : AD_in = D_MUX_OUT - AMULT_REGA;
          'b111 : AD_in = D_MUX_OUT;
          default : ; //null
      endcase
  end
  
  /*------------ AD REG -------------*/
  always @(posedge clk) begin
      if (RSTD || ADREG == 'b0) begin
          AD <= 'b0;
      end
      else if (CEAD) begin
          AD <= AD_in; //PRE_ADDER OUT
      end
  end
  
  assign AD_MUX_OUT = ADREG ? AD:AD_in;
  /*--------A MULT OUT ------*/
  assign AMULT      = USE_DPORT? AD_MUX_OUT: (INMODE[0])? 0:AMULT_REGA;
  	
endmodule 
