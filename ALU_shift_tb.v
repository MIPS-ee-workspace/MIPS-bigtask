module ALU_shift_tb;

reg[31:0] _A;
reg[31:0] _B;
reg[5:0] _ALUFun;
wire[31:0] _S;

ALU_shift shift(.A(_A),.B(_B),.ALUFun(_ALUFun),.S(_S));

initial begin
	_ALUFun=6'b100000;
	_A[4:0]=5'b00100;
	_B=32'b1111_1111_1111_1111_1111_1111_1111_1111;
	#100
	_ALUFun=6'b100001;
	_A[4:0]=5'b00100;
	_B=32'b1111_1111_1111_1111_1111_1111_1111_1111;
	#100
	_ALUFun=6'b100011;
	_A[4:0]=5'b00100;
	_B=32'b1111_1111_1111_1111_1111_1111_1111_1111;
	#100
	_ALUFun=6'b100011;
	_A[4:0]=5'b00100;
	_B=32'b0111_1111_1111_1111_1111_1111_1111_1111;
end



endmodule