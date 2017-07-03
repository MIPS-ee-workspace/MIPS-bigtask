module top(sysclk,switch,UART_RX,led,digi,UART_TX);
	input sysclk,UART_RX;
	input[7:0] switch;
	output UART_TX;
	output[10:0] led;
	output[11:0] digi;

	reg clk;
	reg[2:0] clk_state;
	always@(posedge sysclk)
	begin
		if(clk_state==0)
			clk <= ~clk;
		clk_state <= (clk_state==5)?0:clk_state+1;	//100M/9600/16=651.04
	end

	wire[11:0] digi2;
	assign digi=~digi2;
	Processor processor(sysclk,clk,led,switch,digi2,UART_RX,UART_TX);

endmodule
