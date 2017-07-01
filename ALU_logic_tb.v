`timescale 1ns/1ns
module ALU_logic_tb;

reg[31:0] _A;
reg[31:0] _B;
reg[5:0] _ALUFun;
wire[31:0] _S;

ALU_logic logic(.A(_A),.B(_B),.ALUFun(_ALUFun),.S(_S));

initial begin

	_A=32'b1000_0000_0000_0000_0000_0000_0000_0101;
	_B=32'b1000_0000_0000_0000_0000_0000_0000_0011;
	_ALUFun=6'b011000;
	#100
	_A=32'b1000_0000_0000_0000_0000_0000_0000_0101;
	_B=32'b1000_0000_0000_0000_0000_0000_0000_0011;
	_ALUFun=6'b011110;
	#100
	_A=32'b1000_0000_0000_0000_0000_0000_0000_0101;
	_B=32'b1000_0000_0000_0000_0000_0000_0000_0011;
	_ALUFun=6'b010110;
	#100
	_A=32'b1000_0000_0000_0000_0000_0000_0000_0101;
	_B=32'b1000_0000_0000_0000_0000_0000_0000_0011;
	_ALUFun=6'b010001;
	#100 
	_A=32'b1000_0000_0000_0000_0000_0000_0000_0101;
	_B=32'b1000_0000_0000_0000_0000_0000_0000_0011;
	_ALUFun=6'b011010;


end


endmodule