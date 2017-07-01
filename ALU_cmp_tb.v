module ALU_cmp_tb;

reg[5:0] _ALUFun;
wire _Z,_V,_N;
reg _Sign;
wire[31:0] _S_adder;
wire[31:0] _S_cmp;

ALU_adder adder(.ALUFun(_ALUFun),.Sign(_Sign),
		   		.S(_S_adder),.V(_V),.N(_N),.Z(_Z));
ALU_cmp cmp(.ALUFun(_ALUFun),.Z(_Z),.V(_V),.N(_N),.S(_S_cmp));

initial begin
	_Sign=1;
	_ALUFun=6'b110011;
	_A=32'b1000_0000_0000_0000_0000_0000_0000_0001;
	_B=32'b1000_0000_0000_0000_0000_0000_0000_0001;
	#100 
	_ALUFun=6'b110001;
	_A=32'b1000_0000_0000_0000_0000_0000_0000_0001;
	_B=32'b1000_0000_0000_0000_0000_0000_0000_0001;
	#100 
	_ALUFun=6'b110101;
	_A=32'b0000_0000_0000_0000_0000_0000_0000_0001;
	_B=32'b0000_0000_0000_0000_0000_0000_0000_0010;
	#100 
	_ALUFun=6'b111101;
	_A=32'b1000_0000_0000_0000_0000_0000_0000_0001;
	_B=32'b0000_0000_0000_0000_0000_0000_0000_0010;
end

endmodule