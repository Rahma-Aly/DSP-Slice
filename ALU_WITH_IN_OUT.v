module ALU_WITH_IN_OUT #(parameter WIDTH=48,OPMODE_REG_Control=1, ALUMODE_REG_CONTROL=1,CARRYINSEL_REG_CONTROL=1,
                                   USE_MULT= "multiply",CARRYINREG = 1
)(
	input wire [6:0] OPMODE,
	input wire [3:0] ALUMODE,
	input wire [2:0]CARRYINSEL,
	input wire [WIDTH-1:0] X,Y,Z,
	input wire clk,
	input wire RSTCTRL,RSTALLCARRYIN,RSTP,
	input wire CECTRL, CECARRYIN,CEM,multiply_sign_in,
	input wire CARRYIN,PCIN,CARRYCASCIN,CIN6, //PCIN[47]
	input wire RSTALUMODE,CEALUMODE,CEP,
	output [WIDTH-1:0] OUT_REG ,
	output [WIDTH-1:0] OUT, //ALU OUT
	output [3:0] CARRYOUT,
	output multiply_sign_out_reg
);

wire [6:0] OPMODE_REG,OPMODE_int;
wire [3:0] ALUMODE_REG,ALUMODE_int;
wire [2:0] CARRYINSEL_REG,CARRYINSEL_int;
wire CARRYIN_int,CARRYIN_REG,CIN6_REG;
wire CIN_int,COUT,multiply_sign_out;
wire COUT_REG_int,CIN6_int;


register # (.WIDTH(7))R1(
	.clk(clk),
	.rst(RSTCTRL),
	.enable(CECTRL),
	.in(OPMODE),
	.out(OPMODE_REG)
);

MUX2 # (.WIDTH(7))M1(
	.IN1(OPMODE),
	.IN2(OPMODE_REG),
	.sel(OPMODE_REG_Control),
	.out(OPMODE_int)
);

register # (.WIDTH(4))R2(
	.clk(clk),
	.rst(RSTALUMODE),
	.enable(CEALUMODE),
	.in(ALUMODE),
	.out(ALUMODE_REG)
);

MUX2 # (.WIDTH(4))M2(
	.IN1(ALUMODE),
	.IN2(ALUMODE_REG),
	.sel(ALUMODE_REG_CONTROL),
	.out(ALUMODE_int)
);

register # (.WIDTH(3))R3(
	.clk(clk),
	.rst(RSTCTRL),
	.enable(CECTRL),
	.in(CARRYINSEL),
	.out(CARRYINSEL_REG)
);

MUX2 # (.WIDTH(3))M3(
	.IN1(CARRYINSEL),
	.IN2(CARRYINSEL_REG),
	.sel(CARRYINSEL_REG_CONTROL),
	.out(CARRYINSEL_int)
);

register # (.WIDTH(1))CARRYIN_R(
    .clk(clk),
    .rst(RSTALLCARRYIN),
    .enable(CECARRYIN),
    .in(CARRYIN),
    .out(CARRYIN_REG)
);

MUX2 # (.WIDTH(1))CARRYIN_MUX(
    .IN1(CARRYIN),
    .IN2(CARRYIN_REG),
    .sel(CARRYINREG),
    .out(CARRYIN_int)
);

register # (.WIDTH(1))CIN6REG(
    .clk(clk),
    .rst(RSTALLCARRYIN),
    .enable(CEM),
    .in(CIN6),
    .out(CIN6_REG)
);

MUX2 # (.WIDTH(1))CIN6MUX(
    .IN1(CIN6),
    .IN2(CIN6_REG),
    .sel(CARRYINREG),
    .out(CIN6_int)
);

MUX8 #(.WIDTH(1))M4(
	.IN0(CARRYIN_int),
	.IN1(PCIN),
	.IN2(CARRYCASCIN),
	.IN3(~PCIN),
	.IN4(COUT_REG_int),
	.IN5(~OUT_REG[47]),
	.IN6(CIN6_int),
	.IN7(OUT_REG[47]),
	.sel(CARRYINSEL_int),
	.out(CIN_int)
);
register  #(.WIDTH(48))R4(
	.clk(clk),
	.rst(RSTP),
	.enable(CEP),
	.in(OUT),
	.out(OUT_REG)
);
register #(.WIDTH(1))R5(
	.clk(clk),
	.rst(RSTP),
	.enable(CEP),
	.in(COUT),
	.out(COUT_REG_int)
);

register #(.WIDTH(1))R6(
	.clk(clk),
	.rst(RSTP),
	.enable(CEP),
	.in(multiply_sign_out),
	.out(multiply_sign_out_reg)
);


ALU #(.WIDTH(WIDTH),.USE_MULT_ATTR(USE_MULT))U1(
	.OPMODE(OPMODE_int),
	.ALUMODE(ALUMODE_int),
	.X(X),
	.Y(Y),
	.Z(Z),
	.CIN(CIN_int),
	.multiply_sign_in(multiply_sign_in),
	.OUT(OUT),
	.COUT(COUT),
	.multiply_sign_out(multiply_sign_out)
);

assign CARRYOUT[3]=COUT_REG_int;
assign CARRYOUT[2:0]='b0;

endmodule 
