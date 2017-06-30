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