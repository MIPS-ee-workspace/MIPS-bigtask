module CPU_Control(opcode,Funct,pchigh,Interrupt,Exception,PCSrc,RegDst,RegWr,ALUSrc1,ALUSrc2,ALUFun,
                   Sign,MemWr,MemRd,MemToReg,EXTOp,LUOp);

input Interrupt,Exception,pchigh;
output[1:0] PCSrc;
output[1:0] RegDst, MemToReg;
output[5:0] ALUFun;
output RegWr,ALUSrc1,ALUSrc2,Sign,MemWr,MemRd,EXTOp,LUOp;
input[5:0] opcode,Funct;
wire I,slt_temp,branch_temp;

//部分指令直接翻译控制信号
assign I=(opcode==6'hf||opcode==6'h8||opcode==6'h9||opcode==6'hc||opcode==6'ha||opcode==6'hb||opcode==6'h2b||opcode==6'h23||opcode==6'hd);//lui,addi,addiu,andi,slti,sltiu,sw,lw,ori
assign branch_temp=(opcode==6'h4)||(opcode==6'h5)||(opcode==6'h6)||(opcode==6'h7)||(opcode==6'h1);  //beq,bne,blez,bgtz,bltz
assign slt_temp=(opcode==6'h0&&Funct==6'h2a)||(opcode==6'ha)||(opcode==6'hb);  //slt,slti,sltiu
assign RegWr=(opcode==6'h2b||branch_temp||opcode==6'h2||opcode==6'h0&&Funct==6'h8)?0:1;//sw,beq,bne,blez,bgtz,bltz,j,jr

assign PCSrc[0]=(branch_temp||(opcode==6'h0&&Funct==6'h8)||(opcode==6'h0&&Funct==6'h9));//分支,jr,jalr
assign PCSrc[1]=(opcode==6'h2||opcode==6'h3||(opcode==6'h0&&Funct==6'h8)||(opcode==6'h0&&Funct==6'h9));	//j,jal,jr,jalr
assign RegDst[0]=((Interrupt&&~pchigh)||(Exception&&~pchigh)||I);//中断，异常，I型
assign RegDst[1]=((Interrupt&&~pchigh)||(Exception&&~pchigh)||opcode==6'h3||(opcode==6'h0&&Funct==6'h9));//中断,异常,jal,jalr
assign EXTOp=(opcode!=6'hc&&opcode!=6'hd);//andi,ori为0扩展，addi,addiu,slti,sltiu为符号扩展
assign LUOp=(opcode==6'hf);//lui
assign ALUSrc1=(opcode==6'h00&&Funct==6'h00)||(opcode==6'h00&&Funct==6'h02);//sll,srl
assign ALUSrc2=(I==1);//lui,addi,addiu,andi,slti,sltiu,sw,lw,ori

assign ALUFun[0]=branch_temp||slt_temp||(opcode==6'h0&&(Funct==6'h2||Funct==6'h3||Funct==6'h22||Funct==6'h23||Funct==6'h27));
//sub,subu,nor,srl,sra,slt,slti,sltiu,beq,bne,blez,bgtz,bltz
assign ALUFun[1]=(opcode==6'h0&&Funct==6'h25)||(opcode==6'h0&&Funct==6'h26)||(opcode==6'h0&&Funct==6'h3)||(opcode==6'h4)||(opcode==6'h7)||(opcode==6'h1)||(opcode==6'hd);
//or,xor,sra,beq,bgtz,bltz,ori
assign ALUFun[2]=(opcode==6'h0&&Funct==6'h25)||(opcode==6'h0&&Funct==6'h26)||slt_temp||(opcode==6'h6)||(opcode==6'h7)||(opcode==6'hd);
//or,xor,slt,slti,sltiu,blez,bgtz,ori
assign ALUFun[3]=(opcode==6'h0&&Funct==6'h24)||(opcode==6'hc)||(opcode==6'h0&&Funct==6'h25)||(opcode==6'h6)||((opcode==6'h1)||(opcode==6'h7))||(opcode==6'hd);
//and,andi,or,blez,bltz,bgtz,ori
assign ALUFun[4]=(opcode==6'h0&&Funct==6'h24)||(opcode==6'hc)||(opcode==6'h0&&Funct==6'h25)||(opcode==6'h0&&Funct==6'h26)||(opcode==6'h0&&Funct==6'h27)||branch_temp||slt_temp||(opcode==6'hd);
//and,andi,or,xor,nor,beq,bne,slt,slti,sltiu,blez,bltz,bgtz,ori
assign ALUFun[5]=(opcode==6'h0&&Funct==6'h0)||(opcode==6'h0&&Funct==6'h2)||(opcode==6'h0&&Funct==6'h3)||branch_temp||slt_temp;
//sll,srl,sra,beq,bne,slt,slti,sltiu,blez,bltz,bgtz

assign Sign=((opcode==6'h00&&Funct==6'h21)||(opcode==6'h00&&Funct==6'h23)||(opcode==6'h9)||(opcode==6'h9))?0:1;//addu,subu,addiu,sltiu
assign MemWr=(opcode==6'h2b);//sw
assign MemRd=(opcode==6'h23);//lw
assign MemToReg[0]=(opcode==6'h23);//lw
assign MemToReg[1]=((Interrupt&&~pchigh)||(Exception&&~pchigh)||opcode==6'h3||(opcode==6'h0&&Funct==6'h9));//中断,异常,jal,jalr

endmodule

