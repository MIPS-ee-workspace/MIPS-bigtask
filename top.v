module top(sysclk,switch,UART_RX,led,digi,UART_TX);
	input sysclk,UART_RX;
	input[7:0] switch;
	output UART_TX;
	output[7:0] led;
	output[11:0] digi;

	reg clk;
	reg[2:0] clk_state;
	always@(posedge sysclk)
	begin
		if(clk_state==0)
			clk <= ~clk;
		clk_state <= (clk_state==5)?0:clk_state+1;	//100M/9600/16=651.04
	end

	Processor processor(sysclk,clk,led,switch,digi,UART_RX,UART_TX)

endmodule
