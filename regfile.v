`timescale 1ns/1ps

module RegFile (reset,clk,addr1,data1,addr2,data2,wr,addr3,data3, uart);
input reset,clk;
input wr;
input [4:0] addr1,addr2,addr3;
output [31:0] data1,data2;
input [31:0] data3;
input uart;

reg [31:0] RF_DATA[31:1];
integer i;

assign data1=(addr1==5'b0)?32'b0:RF_DATA[addr1];	//$0 MUST be all zeros
assign data2=(addr2==5'b0)?32'b0:RF_DATA[addr2];

always@(negedge reset or posedge clk) begin
	if(~reset) begin
		for(i=1;i<32;i=i+1) RF_DATA[i]<=32'b0;
	end
	else begin
		if(wr && addr3) RF_DATA[addr3] <= data3;
		else if(uart==1) RF_DATA[27][0]<= 1'b1;	//$k1 is to save condition code, here con[0]=1 means that the interrupt is uart_send

	end
end
endmodule
