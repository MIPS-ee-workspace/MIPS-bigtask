module CPU_Control(Instruct,IRQ,JT,Imm16,Shamt,Rd,Rt,Rs,
                   PCSrc,RegDst,RegWr,ALUSrc1,ALUSrc2,ALUFun,
                   Sign,MemWr,MemRd,MemToReg,EXTOp,LUOp);

input[31:0] Instruct;
input IRQ,PC_high;//PC[31]
output[25:0] JT;
output[15:0] Imm16;
output[4:0] Shamt, Rd, Rt, Rs;
output[2:0] PCSrc;
output[1:0] RegDst, MemToReg;
output[5:0] ALUFun;
output RegWr,ALUSrc1,ALUSrc2,Sign,MemWr,MemRd,EXTOp,LUOp;
wire[5:0] opcode;
wire Branch;

//部分指令直接翻译控制信号
assign opcode=Instruct[31:26];
assign Rs=Instruct[25:21]; 
assign Rt=Instruct[20:16];
assign Rd=Instruct[15:11];
assign Shamt=Instruct[10:6];
assign Funct=Instruct[5:0];
assign Imm16=Instruct[15:0];
assign JT=Instruct[25:0];


assign PCSrc[0]=(Branch||(opcode==6'h0&&Funct==6'h8)||XADR);
assign PCSrc[1]=(opcode==6'h3)|(opcode==6'h0&&Funct==6'h8);
assign PCSrc[2]=(~PC_high&IRQ)|XADR;


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

