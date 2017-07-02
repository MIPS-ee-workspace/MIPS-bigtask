`timescale 1ns/1ps

module ROM (addr,data,overflow);
input [30:0] addr;
output [31:0] data;
output overflow;

localparam ROM_SIZE = 32;
(* rom_style = "distributed" *) reg [31:0] ROM_DATA[ROM_SIZE-1:0];

assign data=(addr < ROM_SIZE)?ROM_DATA[addr[30:2]]:32'b0;
assign overflow=(addr >= ROM_SIZE)?1:0;

integer i;
initial begin

ROM_DATA[0] = 32'hac000010;
ROM_DATA[1] = 32'h8c080010;
ROM_DATA[2] = 32'h3c09000f;

		ROM_DATA[3] <= 32'hae200000;
		ROM_DATA[4] <= 32'h08100000;
		ROM_DATA[5] <= 32'h0c000000;
		ROM_DATA[6] <= 32'h00000000;
		ROM_DATA[7] <= 32'h3402000a;
		ROM_DATA[8] <= 32'h0000000c;
		ROM_DATA[9] <= 32'h0000_0000;
		ROM_DATA[10]<= 32'h0274_8825;
		ROM_DATA[11] <= 32'h0800_0015;
		ROM_DATA[12] <= 32'h0274_8820;
		ROM_DATA[13] <= 32'h0800_0015;
		ROM_DATA[14] <= 32'h0274_882A;
		ROM_DATA[15] <= 32'h1011_0002;
		ROM_DATA[16] <= 32'h0293_8822;
		ROM_DATA[17] <= 32'h0800_0015;
		ROM_DATA[18] <= 32'h0274_8822;
		ROM_DATA[19] <= 32'h0800_0015; 
		ROM_DATA[20] <= 32'h0274_8824;
		ROM_DATA[21] <= 32'hae11_0003;
		ROM_DATA[22] <= 32'h0800_0001;
        
	    for (i=23;i<ROM_SIZE;i=i+1) begin
            ROM_DATA[i] <= 32'b0;
        end
end
endmodule
