`timescale 1ns/1ns

module PreAdder_tb #(parameter  AREG      = 1,  //Number of pipeline stages for input A (AREG = 1 -> A2 is used)
                               ACASCREG  = 1, //Number of pipeline stages for ACOUT cascade datapath (<= AREG)
                               A_INPUT   = "Direct", // A is used , "Cascade" -> use ACIN
                               USE_DPORT = 1, //default 0
                               DREG      = 1,  //Number of pipeline stages for input D
                               ADREG     = 1  //Number of pipeline stages for  AD register
                            
);

    localparam CLK_PERIOD = 10;
    reg clk, RSTD,RSTA, CED,CEAD,CEA1,CEA2;
    reg [3:0] INMODE;
    reg [24:0] D;
    reg [29:0] A,ACIN;
    reg [24:0] AMULT_EXP;
    
    wire [29:0] ACOUT,XMUX;
    wire [24:0] AMULT;
    
    
    always #(CLK_PERIOD/2) clk = ~clk;
     
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
    .INMODE(INMODE),
    .A(A),
    .ACIN(ACIN),
    .D(D),
    .ACOUT(ACOUT),
    .XMUX(XMUX),
    .AMULT(AMULT)
);
    integer i;
    initial begin 
    clk    = 1;
    INMODE = 0;
    CEA1   = 1;
    CEA2   = 1;
//    D      = 0;
//    A      = 0;
    A = $random;
    D = $random;
    CED    = 1;
    CEAD   = 1;
    RSTA   = 0;
    RSTD   = 0;
    ACIN   = 0;
    @(negedge clk) RSTA = 1; RSTD = 1;
    #CLK_PERIOD    RSTA = 0; RSTD = 0;
    @(posedge clk) 
//    A = $random;
//    D = $random;
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
//         #CLK_PERIOD;
        @(posedge clk)   
        $display("A: %0b, D: %0b, AMULT: %0b , expected AMULT = %0b", A,D,AMULT,AMULT_EXP);      
    end
    
    end

    function reg [24:0] AMULT_exp (input [3:0] INMODE);
        begin
        casex (INMODE)
          'b000? :  AMULT_exp = A[24:0];
          'b001? :  AMULT_exp = 'b0; 
          'b010? :  AMULT_exp = D + A[24:0];
          'b011? :  AMULT_exp = D ;
          'b100? :  AMULT_exp = -A; 
          'b101? :  AMULT_exp = 0;
          'b110? :  AMULT_exp = D - A;
          'b111? :  AMULT_exp = D ;
          default : ; //null
      endcase
      end
    endfunction
        
endmodule 
