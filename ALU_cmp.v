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