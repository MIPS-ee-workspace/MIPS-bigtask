`timescale 1ns/1ps

module top();


endmodule

module Processor(reset,clk,led,switch,digi);
input reset,clk;

reg[31:0] condition;

//Interrupt,Exception
wire Interrupt,Exception;

wire irq,uart;
assign Interrupt=irq || uart;

reg core_hazard;
wire PC_overflow,data_overflow;
assign Exception=core_hazard || PC_overflow || data_overflow;
//

//PC, core_hazard
reg[31:0] PC;
wire[31:0] PC_next;
wire[31:0] PC4;

always@(negedge reset or posedge clk) begin
	if(~reset)begin
		PC<=0;
		core_hazard<=0;
	end
	else
		PC<=(Exception || (PC_next[31]==1 && PC[31]==0))?32'h80000008:
			(Interrupt)?32'h80000004:
			PC_next;
		core_hazard<=(PC_next[31]==1 && PC[31]==0)?1:0;
	end
end

assign PC4=PC+4;
//

//Instruction Memory
wire[31:0] Instruction;
ROM instruction_memory(PC[30:0],Instruction,PC_overflow);

wire[4:0] Rs;
assign Rs[4:0]=Instruction[25:21];

wire[4:0] Rt;
assign Rt[4:0]=Instruction[20:16];

wire[4:0] Rd;
assign Rd[4:0]=Instruction[15:11];

wire[4:0] Shamt;
assign Shamt[4:0]=Instruction[10:6];

wire[15:0] Imm16;
assign Imm16[15:0]=Instruction[15:0];

wire[31:0] JT;
assign JT[1:0]=2'b00;
assign JT[27:2]=Instruction[25:0];
assign JT[31:28]=PC4[31:28];
//

//control
wire[1:0] PCSrc;
wire[1:0] RegDst;
wire[1:0] MemToReg;
wire[5:0] ALUFun;
wire RegWr,ALUSrc1,ALUSrc2,Sign,MemWr,MemRd,EXTOp,LUOp;
//

//Register File
wire[4:0] AddrC;
wire[31:0] DatabusA;
wire[31:0] DatabusB;
wire[31:0] DatabusC;
always@(*)
begin
	case(RegDst)
		2'b01:AddrC<=Rt;
		2'b10:AddrC<=31;
		2'b11:AddrC<=26;
		default:AddrC<=Rd;
	endcase
end

RegFile register_file(reset,clk,PC_next,Rs,DatabusA,Rt,DatabusB,RegWr,AddrC,DatabusC);
//

//ALU
wire[31:0] ConBA;
wire[31:0] ALUOut;
wire[31:0] ALUIn1;
wire[31:0] ALUIn2;
wire[31:0] Imm32;
wire[31:0] ImmExt;
wire[31:0] Offset;

assign ALUIn1=(ALUSrc1)?{27'd0,Shamt[4:0]}:DatabusA;
assign ImmExt=(EXTOp && Imm16[15])?{16'hffff,Imm16}:{16'h0000,Imm16};
assign Imm32=(LUOp)?{Imm16,16'h0000}:ImmExt;
assign ALUIn2=(ALUSrc2)?Imm32:DatabusB;

ALU ALU_mod(ALUIn1,ALUIn2,ALUFun,Sign,ALUOut);

assign Offset={ImmExt[29:0],2'b00};
assign ConBA=Offset+PC4;
//

//Data Memory
wire[31:0] ReadData;

DataMem data_memory(reset,clk,MemRd,MemWr,ALUOut,DatabusB,ReadData,data_overflow);

always@(*)
begin
	case(MemToReg)
		2'b01:DatabusC<=ReadData;
		2'b10:DatabusC<=PC4;
		default:DatabusC<=ALUOut;
	endcase
end
//

//PC_next
wire[31:0] ConBA2;
assign ConBA2=(ALUOut[0])?ConBA:PC4;

always@(*)
begin
	case(PCSrc)
		2'b01:PC_next<=ConBA2;
		2'b10:PC_next<=JT;
		2'b11:PC_next<=DatabusA;
		default:PC_next<=PC4;
	endcase
end
//


endmodule
