module CPU_Control(Instruct,IRQ,Interrupt,Exception,PCSrc,RegDst,RegWr,ALUSrc1,ALUSrc2,ALUFun,
                   Sign,MemWr,MemRd,MemToReg,EXTOp,LUOp);

input[31:0] Instruct;
input IRQ,PC_high;//PC[31]
input Interrupt,Exception;
output[2:0] PCSrc;
output[1:0] RegDst, MemToReg;
output[5:0] ALUFun;
output RegWr,ALUSrc1,ALUSrc2,Sign,MemWr,MemRd,EXTOp,LUOp;
wire[5:0] opcode;
wire Branch,I;

//部分指令直接翻译控制信号
assign opcode=Instruct[31:26];
assign Funct=Instruct[5:0];
assign I=(opcode==6'hf||opcode==6'h8||opcode==6'h9||opcode==6'hc||opcode==6'ha||opcode==6'hb);//判断是否是I型指令

assign PCSrc[0]=(Branch||(opcode==6'h0&&Funct==6'h8)||(opcode==6'h0&&Funct==6'h9));//分支,jr,jalr
assign PCSrc[1]=(opcode==6'h2||opcode==6'h3||(opcode==6'h0&&Funct==6'h8)||(opcode==6'h0&&Funct==6'h9));	//j,jal,jr,jalr
assign RegDst[0]=(Interrupt||Exception||I);//中断，异常，I型
assign RegDst[1]=(Interrupt||Exception||opcode==6'h3||(opcode==6'h0&&Funct==6'h9));//中断,异常,jal,jalr

assign Branch=(opcode==6'h1||opcode==6'h4||opcode==6'h5||opcode==6'h6||opcode==6'h7)?1:0;
assign RegWrite=(opcode==6'h2b||opcode==6'h04||opcode==6'h02||(opcode==6'b0&&Funct==6'h08))?0:1;
assign RegDst=(opcode==6'h03)?2'b10:(opcode==6'b0)?2'b01:2'b00;
assign MemRead=(opcode==6'h23)?1:0;
assign MemWrite=(opcode==6'h2b)?1:0;
assign MemtoReg=(opcode==6'h03||(opcode==6'b0&&Funct==6'h09))?2'b10:(opcode==6'h23)?1:0;
assign ALUSrc1=(opcode==6'b0&&(Funct==6'b0||Funct==6'h02||Funct==6'h03))?1:0;
assign ALUSrc2=(opcode==6'b0||opcode==6'h04)?0:1;
assign ExtOp=(opcode==6'h08||opcode==6'h09||opcode==6'h0c||opcode==6'h0a||opcode==6'h04)?1:0;
assign LuOp=(opcode==6'h0f)?1:0; 


endmodule

