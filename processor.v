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
reg[31:0] PC_IF;
wire Interrupt,Exception;

wire timer,uart_send;
assign Interrupt=(timer || uart_send) && (PC_IF[31]==0);

reg core_hazard;
wire PC_overflow,ALU_overflow;
assign Exception=(core_hazard || PC_overflow) && (PC_IF[31]==0);

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


//IF
	//PC,core_hazard
wire[31:0] PC_next;
wire[31:0] PC4_IF;
assign PC4_IF=PC_IF+4;
always@(negedge reset or posedge clk) begin
	if(~reset)begin
		PC_IF<=0;
		core_hazard<=0;
	end
	else begin
		PC_IF<=(Exception || (PC_next[31]==1 && PC_IF[31]==0))?32'h80000008:
				(Interrupt)?32'h80000004:
				PC_next;
		core_hazard<=(PC_next[31]==1 && PC_IF[31]==0)?1:0;	//only as a warning
	end
end

	//

	//Instruction Memory
wire[31:0] Instruction_IF;
ROM instruction_memory(PC_IF[30:0],Instruction_IF,PC_overflow);
	//

	//control_IF, Inte,Exce
wire[1:0] RegDst_IF;
wire[1:0] MemToReg_IF;
wire RegWr_IF,MemWr_IF;
CPU_Control_IF control_IF(Instruction_IF[31:26],Instruction_IF[5:0],Interrupt,Exception,RegDst_IF,RegWr_IF,MemWr_IF,MemToReg_IF);
	//

	//PC_next
wire[31:0] JT_ID;
wire[31:0] ConBA_EX;
wire[31:0] DatabusA_ID;
wire[1:0] PCSrc_ID;
reg[1:0] PCSrc_2;
assign PC_next=(PCSrc_2==2'b01 && ALUOut_EX[0])?ConBA_EX:
				(PCSrc_ID==2'b10)?JT_ID:
				(PCSrc_ID==2'b11)?DatabusA_ID:
				PC4_IF;
	//

//	IF/ID
reg[31:0] Instruction_1;
reg[31:0] PC4_1;
reg[1:0] RegDst_1;
reg[1:0] MemToReg_1;
reg RegWr_1,MemWr_1;
always@(negedge reset or posedge clk) begin
	if(~reset)begin
		Instruction_1 <= 32'd0;
		PC4_1 <= 32'd0;
		RegDst_1 <= 2'd0;
		MemToReg_1 <= 2'd0;
		RegWr_1 <= 1'd0;
		MemWr_1 <= 1'd0;
	end
	else begin
		RegDst_1 <= RegDst_IF;
		MemToReg_1 <= MemToReg_IF;
		RegWr_1 <= RegWr_IF;
		if(PCSrc_2==2'b01 && ALUOut_EX[0]) begin
			Instruction_1 <= 32'd0;
			PC4_1 <= PC4_2;			//since branch\j and interrupt may happen at the same time
			MemWr_1 <= 1'd0;		//this must be change when branch\j happen
		end
		else if(PCSrc_ID[1]) begin
			Instruction_1 <= 32'd0;
			PC4_1 <= PC4_1;
			MemWr_1 <= 1'd0;
		end
		else begin
			Instruction_1 <= Instruction_IF;
			PC4_1 <= PC4_IF;
			MemWr_1 <= MemWr_IF;
		end
	end
end

//ID
wire[4:0] Rt_ID;
assign Rt_ID[4:0]=Instruction_1[20:16];
wire[4:0] Rd_ID;
assign Rd_ID[4:0]=Instruction_1[15:11];
wire[4:0] Shamt;
assign Shamt[4:0]=Instruction_1[10:6];
wire[15:0] Imm16;
assign Imm16[15:0]=Instruction_1[15:0];

assign JT_ID={PC4_1[31:28],Instruction_1[25:0],2'b00};	//for j-type, to change pc_next in IF

	//control_ID, Inte,Exce
wire[5:0] ALUFun_ID;
wire ALUSrc1,ALUSrc2,Sign_ID,MemRd_ID,EXTOp,LUOp;
CPU_Control_ID control_ID(Instruction_1[31:26],Instruction_1[5:0],PCSrc_ID,ALUSrc1,ALUSrc2,ALUFun_ID,Sign_ID,MemRd_ID,EXTOp,LUOp);
	//

	//Register File
reg[4:0] AddrC;
reg[31:0] DatabusC;
reg RegWr_3;
wire[31:0] DatabusB_ID;
RegFile register_file(reset,clk,Instruction_1[25:21],DatabusA_ID,Rt_ID,DatabusB_ID,RegWr_3,AddrC,DatabusC, uart_send);//change RegWr
	//
wire[31:0] ALUIn1_ID;
wire[31:0] ALUIn2_ID;
wire[31:0] Imm32;
wire[31:0] ImmExt_ID;
assign ALUIn1_ID=(ALUSrc1)?{27'd0,Shamt[4:0]}:DatabusA_ID;
assign ImmExt_ID=(EXTOp && Imm16[15])?{16'hffff,Imm16}:{16'h0000,Imm16};
assign Imm32=(LUOp)?{Imm16,16'h0000}:ImmExt_ID;
assign ALUIn2_ID=(ALUSrc2)?Imm32:DatabusB_ID;

//	ID/EX
reg[31:0] PC4_2;
reg[31:0] ALUIn1_2;
reg[31:0] ALUIn2_2;
reg[31:0] DatabusB_2;
reg[31:0] ImmExt_2;
reg[5:0] ALUFun_2;
reg[1:0] RegDst_2;
reg[1:0] MemToReg_2;
reg[4:0] Rt_2;
reg[4:0] Rd_2;
reg Sign_2,RegWr_2,MemWr_2,MemRd_2;
always@(negedge reset or posedge clk) begin
	if(~reset)begin
		PCSrc_2 <= 2'd0;
		PC4_2 <= 32'd0;
		ALUIn1_2 <= 32'd0;
		ALUIn2_2 <= 32'd0;
		DatabusB_2 <= 32'd0;
		ImmExt_2 <= 32'd0;
		Rt_2 <= 5'd0;
		Rd_2 <= 5'd0;
		ALUFun_2 <= 6'd0;
		RegDst_2 <= 2'd0;
		MemToReg_2 <= 2'd0;
		Sign_2 <= 1'd0;
		RegWr_2 <= 1'd0;
		MemWr_2 <= 1'd0;
		MemRd_2 <= 1'd0;
	end
	else begin
		PC4_2 <= PC4_1;
		ALUIn1_2 <= ALUIn1_ID;
		ALUIn2_2 <= ALUIn2_ID;
		DatabusB_2 <= DatabusB_ID;
		ImmExt_2 <= ImmExt_ID;
		Rt_2 <= Rt_ID;
		Rd_2 <= Rd_ID;
		ALUFun_2 <= ALUFun_ID;
		RegDst_2 <= RegDst_1;
		MemToReg_2 <= MemToReg_1;
		Sign_2 <= Sign_ID;
		MemRd_2 <= MemRd_ID;
		if(PCSrc_2==2'b01 && ALUOut_EX[0]) begin
			PCSrc_2 <= 2'b00;
			RegWr_2 <= 1'b0;
			MemWr_2 <= 1'b0;
		end
		else begin
			PCSrc_2 <= PCSrc_ID;
			RegWr_2 <= RegWr_1;
			MemWr_2 <= MemWr_1;
		end
	end
end

//EX
	//ALU
wire[31:0] ALUOut_EX;
ALU ALU_mod(ALUIn1_2,ALUIn2_2,ALUFun_2,Sign_2,ALUOut_EX,ALU_overflow);

wire[31:0] Offset;
assign Offset={ImmExt_2[29:0],2'b00};
assign ConBA_EX=Offset+PC4_2;
	//

//	EX/MEM
reg[31:0] PC4_3;
reg[31:0] ALUOut_3;
reg[31:0] DatabusB_3;
reg[1:0] RegDst_3;
reg[1:0] MemToReg_3;
reg[4:0] Rt_3;
reg[4:0] Rd_3;
reg MemWr_3,MemRd_3;
always@(negedge reset or posedge clk) begin
	if(~reset)begin
		PC4_3 <= 32'd0;
		ALUOut_3 <= 32'd0;
		DatabusB_3 <= 32'd0;
		Rt_3 <= 5'd0;
		Rd_3 <= 5'd0;
		RegDst_3 <= 2'd0;
		MemToReg_3 <= 2'd0;
		RegWr_3 <= 1'd0;
		MemWr_3 <= 1'd0;
		MemRd_3 <= 1'd0;
	end
	else begin
		PC4_3 <= PC4_2;
		ALUOut_3 <= ALUOut_EX;
		DatabusB_3 <= DatabusB_2;
		Rt_3 <= Rt_2;
		Rd_3 <= Rd_2;
		RegDst_3 <= RegDst_2;
		MemToReg_3 <= MemToReg_2;
		RegWr_3 <= RegWr_2;
		MemWr_3 <= MemWr_2;
		MemRd_3 <= MemRd_2;
	end
end

//MEM
	//Data Memory
wire[31:0] rdata1;
wire[31:0] rdata2;
wire[31:0] ReadData;
wire MemRd1,MemRd2,MemWr1,MemWr2;
assign {MemRd2,MemRd1,MemWr2,MemWr1}=(ALUOut < 32'h40000000)?{MemRd_3,1'b0,MemWr_3,1'b0}:{1'b0,MemRd_3,1'b0,MemWr_3};
Peripheral peripheral(reset,sysclk,clk,MemRd1,MemWr1,ALUOut_3,DatabusB_3,rdata1, led[7:0],switch,digi,timer, UART_RX,UART_TX,uart_send);
DataMem data_memory(reset,clk,MemRd2,MemWr2,ALUOut_3,DatabusB_3,rdata2);
assign ReadData = rdata1 | rdata2;

always@(*)
begin
	case(MemToReg_3)
		2'b00:DatabusC<=ALUOut_3;
		2'b01:DatabusC<=ReadData;
		default:DatabusC<=PC4_3;
	endcase
end

always@(*)
begin
	case(RegDst_3)
		2'b01:AddrC<=Rt_3;
		2'b10:AddrC<=5'd31;
		2'b11:AddrC<=5'd26;
		default:AddrC<=Rd_3;
	endcase
end
	//
//MEM

endmodule
