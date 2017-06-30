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
