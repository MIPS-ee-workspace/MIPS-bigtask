`timescale 1ns/1ps

module Peripheral (reset,sysclk,clk,rd,wr,addr,wdata,rdata, led,switch,digi,timer, UART_RX,UART_TX,uart_send);
input reset,sysclk,clk;
input rd,wr;
input [31:0] addr;
input [31:0] wdata;
output [31:0] rdata;
reg [31:0] rdata;

output [7:0] led;
reg [7:0] led;

input [7:0] switch;
output [11:0] digi;
reg [11:0] digi;
output timer,uart_send;

input UART_RX;
output UART_TX;
reg UART_TX;

reg[7:0] UART_RXD;
reg[7:0] UART_TXD;
reg[4:0] UART_CON;
assign uart_send=UART_CON[4];
//assign led[4:0]=UART_CON;

//timer + other display
reg [31:0] TH,TL;
reg [2:0] TCON;
assign timer = TCON[2];
//assign led[2:0] = TCON[2:0];

always@(*) begin
	if(rd) begin
		case(addr)
			32'h40000000: rdata <= TH;
			32'h40000004: rdata <= TL;
			32'h40000008: rdata <= {29'b0,TCON};
			32'h4000000C: rdata <= {24'b0,led};
			32'h40000010: rdata <= {24'b0,switch};
			32'h40000014: rdata <= {20'b0,digi};
			32'h40000018: rdata <= {24'b0,UART_TXD};
			32'h4000001C: rdata <= {24'b0,UART_RXD};
			32'h40000020: rdata <= {27'b0,UART_CON};
			default: rdata <= 32'b0;
		endcase
	end
	else
		rdata <= 32'b0;
end

always@(negedge reset or posedge clk) begin
	if(~reset) begin
		TH <= 32'b0;
		TL <= 32'b0;
		TCON <= 3'b0;	

		led <= 8'h00;
		digi <= 12'h000;

		UART_TXD <= 8'h00;
		UART_CON[1:0] <= 2'b11;
	end
	else begin
		if(TCON[0]) begin	//timer is enabled
			if(TL==32'hffffffff) begin
				TL <= TH;
				if(TCON[1]) TCON[2] <= 1'b1;		//irq is enabled
			end
			else begin
				TL <= TL + 1;
			end
		end

		if(wr) begin
			case(addr)
				32'h40000000: TH <= wdata;
				32'h40000004: TL <= wdata;
				32'h40000008: TCON <= wdata[2:0];		
				32'h4000000C: led <= wdata[7:0];	
				32'h40000014: digi <= wdata[11:0];
				32'h40000018: UART_TXD <= wdata[7:0];
				32'h40000020: UART_CON[1:0] <= wdata[1:0];
				default: ;
			endcase
		end
	end
end
//

//uart receiver, UART_CON[3]
wire baud_x16;

baud_rate_generator baud(reset,sysclk,baud_x16);

reg[7:0] rdata_state;
reg receive_state;

always@(posedge sysclk or negedge reset)
begin
	if(~reset) begin
		receive_state <= 1'b0;
		UART_RXD <= 8'h00;
		UART_CON[3] <= 1'b0;
	end
	else begin
		if(rd && addr==32'h4000001C)
			UART_CON[3] <= 1'b0;
		else if(UART_CON[1] && receive_state) begin
			case(rdata_state)
				24:begin UART_RXD[0] <= UART_RX;end
				40:begin UART_RXD[1] <= UART_RX;end
				56:begin UART_RXD[2] <= UART_RX;end
				72:begin UART_RXD[3] <= UART_RX;end
				88:begin UART_RXD[4] <= UART_RX;end
				104:begin UART_RXD[5] <= UART_RX;end
				120:begin UART_RXD[6] <= UART_RX;end
				136:begin UART_RXD[7] <= UART_RX;end
				160:begin
					receive_state <= 1'b0;
					UART_CON[3] <= 1'b1;
					end
				default:;
			endcase
		end
		else begin
			receive_state <= ~UART_RX;
		end
	end
end

always@(posedge baud_x16 or negedge receive_state)
begin
	if(~receive_state) begin
		rdata_state <= 8'h00;
	end
	else begin
		rdata_state <= rdata_state+1;
	end
end
//

//uart sender, UART_CON[2,4]
reg[7:0] wdata_state;

always@(posedge clk or negedge reset)
begin
	if(~reset) begin
		UART_TX <= 1;
		UART_CON[2] <= 0;
		UART_CON[4] <= 0;
	end
	else begin

		if(wr && addr==32'h40000018)
			UART_CON[4] <= 1;
		else if(rd && addr==32'h40000018) begin
			UART_CON[2] <= 0;
		end
		else if(~UART_CON[4]) begin
			UART_TX <= 1;
		end
		else if(UART_CON[0]) begin
			case(wdata_state)
				1:begin UART_TX <= 0;end
				17:begin UART_TX <= UART_TXD[0];end
				33:begin UART_TX <= UART_TXD[1];end
				49:begin UART_TX <= UART_TXD[2];end
				65:begin UART_TX <= UART_TXD[3];end
				81:begin UART_TX <= UART_TXD[4];end
				97:begin UART_TX <= UART_TXD[5];end
				113:begin UART_TX <= UART_TXD[6];end
				129:begin UART_TX <= UART_TXD[7];end
				145:begin UART_TX <= 1;end
				161:begin UART_TX <= 1;
					UART_CON[4] <= 0;
					UART_CON[2] <= 1;
					end
				default:;
			endcase
		end
	end
end

	always@(posedge baud_x16 or negedge UART_CON[4])
	begin
		if(~UART_CON[4]) begin
			wdata_state <= 0;
		end
		else begin
			wdata_state <= wdata_state+1;
		end
	end
//

endmodule

module baud_rate_generator(reset,sys_clk,baud_clk_16);
	input reset,sys_clk;
	output baud_clk_16;
	reg baud_clk_16;
	reg[8:0] baud_state;

	always@(posedge sys_clk or negedge reset)
	begin
		if(~reset) begin
			baud_clk_16 <= 0;
			baud_state <= 0;
		end
		else begin
			if(baud_state==0)
				baud_clk_16 <= ~baud_clk_16;
			baud_state <= (baud_state==324)?0:baud_state+1;	//100M/9600/16=651.04
		end
	end
endmodule
