`timescale 1ns/1ps

module Processor(sysclk,clk,led,switch,digi,UART_RX,UART_TX);

//set switch link

input clk,sysclk,UART_RX;
output [10:0] led;
input [7:0] switch;
output [11:0] digi;
output UART_TX;

wire reset;
assign reset=switch[0];
//

//Interrupt,Exception
reg[31:0] PC;
wire Interrupt,Exception;

wire timer,uart_send;
assign Interrupt=(timer || uart_send) && (PC[31]==0);

reg core_hazard;
wire PC_overflow,ALU_overflow;
assign Exception=(core_hazard || PC_overflow) && (PC[31]==0);

reg[2:0] led_exce;

assign led[10]=led_exce[2];
assign led[9]=led_exce[1];
assign led[8]=led_exce[0];

always@(posedge sysclk or negedge reset) begin
	if(~reset)begin
		led_exce[2:0] <= 3'b000;
	end
	else begin
		if(core_hazard) led_exce[2] <= 1'b1;
		if(PC_overflow) led_exce[1] <= 1'b1;
		if(ALU_overflow) led_exce[0] <= 1'b1;
	end
end

//

//PC, core_hazard
reg[31:0] PC_next;
wire[31:0] PC4;

always@(negedge reset or posedge clk) begin
	if(~reset)begin
		PC<=0;
		core_hazard<=0;
	end
	else begin
		PC<=((PC[31]==0 && Exception) || (PC_next[31]==1 && PC[31]==0))?32'h80000008:
			(PC[31]==0 && Interrupt)?32'h80000004:
			PC_next;
		core_hazard<=(PC_next[31]==1 && PC[31]==0)?1:0;	//only as a warning
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
assign JT={PC4[31:28],Instruction[25:0],2'b00};
//

//control, Inte,Exce,zero,nega
wire[1:0] PCSrc;
wire[1:0] RegDst;
wire[1:0] MemToReg;
wire[5:0] ALUFun;
wire RegWr,ALUSrc1,ALUSrc2,Sign,MemWr,MemRd,EXTOp,LUOp;

CPU_Control control(Instruction[31:26],Instruction[5:0],Interrupt,Exception,PCSrc,RegDst,RegWr,ALUSrc1,ALUSrc2,ALUFun,Sign,MemWr,MemRd,MemToReg,EXTOp,LUOp);

//

//Register File
reg[4:0] AddrC;
wire[31:0] DatabusA;
wire[31:0] DatabusB;
reg[31:0] DatabusC;

always@(*)
begin
	case(RegDst)
		2'b01:AddrC<=Rt;
		2'b10:AddrC<=5'd31;
		2'b11:AddrC<=5'd26;
		default:AddrC<=Rd;
	endcase
end

RegFile register_file(reset,clk,Rs,DatabusA,Rt,DatabusB,RegWr,AddrC,DatabusC, uart_send);
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

ALU ALU_mod(ALUIn1,ALUIn2,ALUFun,Sign,ALUOut,ALU_overflow);

assign Offset={ImmExt[29:0],2'b00};
assign ConBA=Offset+PC4;
//

//Data Memory
wire[31:0] rdata1;
wire[31:0] rdata2;
wire[31:0] ReadData;
wire MemRd1,MemRd2,MemWr1,MemWr2;

assign {MemRd2,MemRd1,MemWr2,MemWr1}=(ALUOut < 32'h40000000)?{MemRd,1'b0,MemWr,1'b0}:{1'b0,MemRd,1'b0,MemWr};

Peripheral peripheral(reset,sysclk,clk,MemRd1,MemWr1,ALUOut,DatabusB,rdata1, led[7:0],switch,digi,timer, UART_RX,UART_TX,uart_send);
DataMem data_memory(reset,clk,MemRd2,MemWr2,ALUOut,DatabusB,rdata2);

assign ReadData= rdata1 | rdata2;

always@(*)
begin
	case(MemToReg)
		2'b00:DatabusC<=ALUOut;
		2'b01:DatabusC<=ReadData;
		default:DatabusC<=PC4;
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
