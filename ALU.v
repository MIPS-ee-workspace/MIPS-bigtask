module ALU(input[31:0] A, 
		   input[31:0] B, 
		   input[5:0] ALUFun,
		   input Sign,
		   output reg[31:0]Z,
		   output reg V);

wire[31:0] S_adder;
wire[31:0] S_logic;
wire[31:0] S_shift;
wire[31:0] S_cmp;
wire _V,_N,_Z;

reg zero,negative;

ALU_adder adder(.A(A),.B(B),.ALUFun(ALUFun),.Sign(Sign),.S(S_adder),.V(_V),.N(_N),.Z(_Z));
ALU_logic logic(.A(A),.B(B),.ALUFun(ALUFun),.S(S_logic));
ALU_shift shift(.A(A),.B(B),.ALUFun(ALUFun),.S(S_shift));
ALU_cmp cmp(.ALUFun(ALUFun),.S(S_cmp),.V(_V),.N(_N),.Z(_Z));

always @(*) begin
	zero=_Z;
	negative=_N;
	V=_V;
	case(ALUFun[5:4])
		2'b00:Z=S_adder;
		2'b01:Z=S_logic;
		2'b10:Z=S_shift;
		2'b11:Z=S_cmp;
	endcase
end 
endmodule

module ALU_adder(input[31:0] A, 
		   input[31:0] B, 
		   input[5:0] ALUFun,
		   input Sign,
		   output reg[31:0]S,
		   output reg V,
		   output reg N,
		   output reg Z);
reg[31:0] _B;
//reg[32:0] carry;//记录进位情况
integer i;
always @(A, B, ALUFun, Sign) begin
_B=B;
if(ALUFun[3]==1) _B=0;

case(ALUFun[0])
	1'b0:begin
		S=A+_B;

		if(Sign==1)
			/*carry=0;//初始化
			for(i=0;i<32;i=i+1)
				carry[i+1]=(A[i]&_B[i])|(A[i]&carry[i])|(_B[i]&carry[i]);
			V=(carry[31])^(carry[32]);//判断是否溢出*/
			if(A[31]==0&&_B[31]==0)
				V=S[31];
			else if(A[31]==1&&_B[31]==1)
				V=~S[31];
			else
				V=0;
		else V=0;

		Z=(S==0)?1:0;//结果是否为0
		if(Sign==1)//结果是否为负
			N=S[31];
		else 
			N=0;
	end
	1'b1:begin
		_B=~_B+1;
		S=A+_B;

		if(Sign==1)begin
			/*carry=0;//初始化
			for(i=0;i<32;i=i+1)
				carry[i+1]=(A[i]&_B[i])|(A[i]&carry[i])|(_B[i]&carry[i]);
			V=(carry[31])^(carry[32]);//判断是否溢出*/
			if(A[31]==0&&_B[31]==0)
				V=S[31];
			else if(A[31]==1&&_B[31]==1)
				V=~S[31];
			else
				V=0;
		end
		else V=0;

		Z=(S==0)?1:0;//结果是否为0
		if(Sign==1)//结果是否为负
			N=S[31];
		else 
			N=S[31];
	end 
	default:begin
		S=0;
		V=0;
		N=0;
		Z=0;
	end

endcase 
end
endmodule

module ALU_cmp(	input[5:0] ALUFun,
				input Z,
				input V,
				input N,
				output reg[31:0] S);
always @(ALUFun,Z,V,N)begin
	case(ALUFun)
	6'b110011:S=(Z==1)?32'd1:32'd0;
	6'b110001:S=(Z==1)?32'd0:32'd1;
	6'b110101:S=N?32'd1:32'd0;
	6'b111101:S=(Z|N)?32'd1:32'd0;
	6'b111011:S=(N)?32'd1:32'd0;
	6'b111111:S=(~N)?32'd1:32'd0;
	default:S=0;
	endcase
end
endmodule

module ALU_logic(input[31:0] A, 
		   input[31:0] B, 
		   input[5:0] ALUFun,
		   output reg[31:0] S);

always @(A,B,ALUFun)
case(ALUFun)
	6'b011000:S=A&B;
	6'b011110:S=A|B;
	6'b010110:S=A^B;
	6'b010001:S=~(A|B);
	6'b011010:S=A;
	default:S=0;
endcase

endmodule

module ALU_shift(input[31:0] A, 
		   input[31:0] B, 
		   input[5:0] ALUFun,
		   output reg[31:0] S);

always @(A,B,ALUFun) begin

	case(ALUFun[1:0])
	2'b00:S=B<<A[4:0];
	2'b01:S=B>>A[4:0];

	2'b11:begin//移位操作拆分为 16位移位、8位移位、4位移位、2位移位、1位移位，然后级联形成最后的运算结果。 
		S=A[4]?{{16{B[31]}},B[31:16]}:B;
		S=A[3]?{{8{B[31]}},B[31:8]}:S;
		S=A[2]?{{4{B[31]}},B[31:4]}:S;
		S=A[1]?{{2{B[31]}},B[31:2]}:S;
		S=A[0]?{B[31],B[31:1]}:S;
	end
	endcase
end

endmodule
