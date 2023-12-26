module DualRegA#(parameter   AREG     = 1,  //Number of pipeline stages for input A (AREG = 1 -> A2 is used)
                             ACASCREG = 1, //Number of pipeline stages for ACOUT cascade datapath (<= AREG)
                             A_INPUT  = "Direct" // A is used , "Cascade" -> use ACIN
)(
    input         clk,
    input         RSTA, //synchronous rst
    input         CEA1,
    input         CEA2,
    input         INMODE, //INMODE[4] considered when AREG = 1,2: 0 -> AMULT = B2 , 1-> AMULT = B1
    input  [29:0] A,
    input  [29:0] ACIN,
    output [29:0] ACOUT,
    output [29:0] XMUX,
    output [29:0] AMULT
);
    
    reg  [29:0] A1,A2;
    wire [29:0] A1_In, A2_In, A2_MUX_OUT;
    //Reg B1
    assign A1_In = (A_INPUT == "Direct")? A:(A_INPUT == "Cascade")? ACIN : A;
    
    always @(posedge clk) begin 
        if (RSTA || AREG == 'b0) begin
            A1 <= 'b0;
        end
        else if (CEA1) begin
                A1 <= A1_In;
        end     
    end
    
    //Reg B2
    assign A2_In = (AREG == 'b10)? A1:A1_In;
    
    always @(posedge clk) begin 
        if (RSTA || AREG == 'b0) begin
            A2 <= 'b0;
        end
        else if (CEA2) begin
            A2 <= A2_In;    
        end     
    end    
    
    assign A2_MUX_OUT = (AREG == 'b0)? A2_In:A2;
    
    assign AMULT = INMODE ? A1:A2_MUX_OUT; 
    assign XMUX  = A2_MUX_OUT;
    assign ACOUT = (ACASCREG == AREG)? A2_MUX_OUT: A1;
    
endmodule 
