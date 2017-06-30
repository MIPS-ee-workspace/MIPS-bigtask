module ALU(input[31:0] A, 
		   input[31:0] B, 
		   input[5:0] ALUFun,
		   input Sign,
		   output reg[31:0]Z,
		   output reg zero,
		   output reg negative);

wire[31:0] S_adder;
wire[31:0] S_logic;
wire[31:0] S_shift;
wire[31:0] S_cmp;
wire _V,_N,_Z;

ALU_adder adder(.A(A),.B(B),.ALUFun(ALUFun),.Sign(Sign),.S(S_adder),.V(_V),.N(_N),.Z(_Z));
ALU_logic logic(.A(A),.B(B),.ALUFun(ALUFun),.S(S_logic));
ALU_shift shift(.A(A),.B(B),.ALUFun(ALUFun),.S(S_shift));
ALU_cmp cmp(.ALUFun(ALUFun),.S(S_cmp),.V(_V),.N(_N),.Z(_Z));

always @(*) begin
	zero=_Z;
	negative=_N;
	case(ALUFun[5:4])
		2'b00:Z=S_adder;
		2'b01:Z=S_logic;
		2'b10:Z=S_shift;
		2'b11:Z=S_cmp;
	endcase
end 
endmodule