module ALU_adder(input[31:0] A, 
		   input[31:0] B, 
		   input[5:0] ALUFun,
		   input Sign,
		   output reg[31:0]S,
		   output reg V,
		   output reg N,
		   output reg Z);
reg[31:0] _B;
reg[32:0] carry;//记录进位情况
integer i;
always @(A, B, ALUFun, Sign) begin
_B=B;
if(ALUFun[3]==1) _B=0;

case(ALUFun[0])
	1'b0:begin
		S=A+_B;

		if(Sign==1) begin
			carry=0;//初始化
			for(i=0;i<32;i=i+1)
				carry[i+1]=(A[i]&_B[i])|(A[i]&carry[i])|(_B[i]&carry[i]);
			V=(carry[31])^(carry[32]);//判断是否溢出
		end
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
			carry=0;//初始化
			for(i=0;i<32;i=i+1)
				carry[i+1]=(A[i]&_B[i])|(A[i]&carry[i])|(_B[i]&carry[i]);
			V=(carry[31])^(carry[32]);//判断是否溢出
		end
		else V=0;

		Z=(S==0)?1:0;//结果是否为0
		if(Sign==1)//结果是否为负
			N=S[31];
		else 
			N=~carry[32];
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