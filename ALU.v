module ALU #(parameter WIDTH=48, parameter USE_MULT_ATTR= "multiply")(
	input wire [6:0]  OPMODE,
	input wire [3:0]  ALUMODE,
	input wire [WIDTH-1:0] X,Y,Z,
	input wire        CIN,multiply_sign_in,
	output reg [WIDTH-1:0] OUT,
	output reg	  COUT,multiply_sign_out
);

localparam NONE= "none";
localparam USE_MULT= "multiply"; 

always @(*)
begin
if(USE_MULT_ATTR==USE_MULT)
begin
 {multiply_sign_out,OUT}=  Y + X;
COUT=0;
	
end
else
begin
	multiply_sign_out=0;
	case (ALUMODE)
	'b0000: {COUT,OUT}=  Z + X + Y + CIN;
	'b0001: {COUT,OUT}= (~Z) + X + Y + CIN;
	'b0010: {COUT,OUT}= ~ (Z + X + Y + CIN) ;	
	'b0011: {COUT,OUT}= Z - (X + Y + CIN);
	'b0100: begin
			COUT=0;
			if(OPMODE[3:2]=='b00)
			begin
			OUT= X ^ Z;
			end
			else if(OPMODE[3:2]=='b10)
			begin
			OUT=~( X ^ Z);
			end
			else 
			begin
			OUT='b0;
			end

		end
	'b0101: begin
			COUT=0;
			if(OPMODE[3:2]=='b00)
			begin
			OUT= ~( X ^ Z);
			end
			else if(OPMODE[3:2]=='b10)
			begin
			OUT=( X ^ Z);
			end
			else 
			begin
			OUT='b0;
			end
		end
	'b0110: begin
			COUT=0;
			if(OPMODE[3:2]=='b00)
			begin
			OUT= ~( X ^ Z);
			end
			else if(OPMODE[3:2]=='b10)
			begin
			OUT=( X ^ Z);
			end
			else 
			begin
			OUT='b0;
			end
		end
	'b0111: begin
			COUT=0;
			if(OPMODE[3:2]=='b00)
			begin
			OUT= ( X ^ Z);
			end
			else if(OPMODE[3:2]=='b10)
			begin
			OUT=~( X ^ Z);
			end
			else 
			begin
			OUT='b0;
			end
		end
	'b1000: begin
			COUT=0;
			OUT='b0;
		end
	'b1001: begin
			COUT=0;
			OUT='b0;
		end
	'b1010: begin
			COUT=0;
			OUT='b0;
		end
	'b1011: begin
			COUT=0;
			OUT=0;
		end
	'b1100: begin
			COUT=0;
			if(OPMODE[3:2]=='b00)
			begin
			OUT= X & Z;
			end
			else if(OPMODE[3:2]=='b10)
			begin
			OUT=X |Z ;
			end
			else 
			begin
			OUT='b0;
			end
		end
	'b1101: begin
			COUT=0;
			if(OPMODE[3:2]=='b00)
			begin
			OUT= X &( ~Z);
			end
			else if(OPMODE[3:2]=='b10)
			begin
			OUT=X |(~ Z) ;
			end
			else 
			begin
			OUT='b0;
			end
		end
	'b1110: begin
			COUT=0;
			if(OPMODE[3:2]=='b00)
			begin
			OUT= ~ (X & Z);
			end
			else if(OPMODE[3:2]=='b10)
			begin
			OUT=~ (X | Z );
			end
			else 
			begin
			OUT='b0;
			end
		end
	'b1111: begin
			COUT=0;
			if(OPMODE[3:2]=='b00)
			begin
			OUT= (~ X) | Z;
			end
			else if(OPMODE[3:2]=='b10)
			begin
			OUT=(~ X) & Z ;
			end
			else 
			begin
			OUT='b0;
			end
		end
	default: begin
		COUT=0;
		OUT ='b0;
		end
	endcase

end
end

endmodule 
