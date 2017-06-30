`timescale 1ns/1ns
module tb;

reg[31:0] _A;
reg[31:0] _B;
reg[5:0] _ALUFun;
reg _Sign;
wire[31:0]_S;
wire _Z;
wire _V;
wire _N;

ALU_adder adder(.A(_A), 
		   .B(_B), 
		   .ALUFun(_ALUFun), 
		   .Sign(_Sign),
		   .S(_S),
		   .V(_V),
		   .N(_N),
		   .Z(_Z));

initial begin
	_ALUFun=0;
	_A=-1;
	_B=1;
	_Sign=1;
	#100 _ALUFun=1;
	#300 
	_ALUFun=0;
	_A=32'b1000_0000_0000_0000_0000_0000_0000_0001;
	_B=32'b1000_0000_0000_0000_0000_0000_0000_0001;
	#300
	_Sign=0;
end
endmodule