`timescale 1ns/1ps

module ROM (addr,data,overflow);
input [30:0] addr;
output [31:0] data;
output overflow;

localparam ROM_SIZE = 160;
(* rom_style = "distributed" *) reg [31:0] ROM_DATA[ROM_SIZE-1:0];

assign data=(addr[30:2] < ROM_SIZE)?ROM_DATA[addr[30:2]]:32'b0;
assign overflow=(addr[30:2] >= ROM_SIZE)?1:0;

integer i;
initial begin
ROM_DATA[0] = 32'h08000003;
ROM_DATA[1] = 32'h08000022;
ROM_DATA[2] = 32'h0800002c;
ROM_DATA[3] = 32'h3c104000;
ROM_DATA[4] = 32'h2408ffff;
ROM_DATA[5] = 32'hae080004;
ROM_DATA[6] = 32'h24080003;
ROM_DATA[7] = 32'hae080008;
ROM_DATA[8] = 32'h0c00000f;
ROM_DATA[9] = 32'h8e04001c;
ROM_DATA[10] = 32'h0c00000f;
ROM_DATA[11] = 32'h8e05001c;
ROM_DATA[12] = 32'h00808020;
ROM_DATA[13] = 32'h00a08820;
ROM_DATA[14] = 32'h08000013;
ROM_DATA[15] = 32'h8e080020;
ROM_DATA[16] = 32'h31080008;
ROM_DATA[17] = 32'h1008fffd;
ROM_DATA[18] = 32'h03e00008;
ROM_DATA[19] = 32'h0211082a;
ROM_DATA[20] = 32'h10010003;
ROM_DATA[21] = 32'h02308823;
ROM_DATA[22] = 32'h10110004;
ROM_DATA[23] = 32'h08000013;
ROM_DATA[24] = 32'h02118023;
ROM_DATA[25] = 32'h10100003;
ROM_DATA[26] = 32'h08000013;
ROM_DATA[27] = 32'h02001021;
ROM_DATA[28] = 32'h0800001e;
ROM_DATA[29] = 32'h02201021;
ROM_DATA[30] = 32'h3c104000;
ROM_DATA[31] = 32'hae02000c;
ROM_DATA[32] = 32'hae020018;
ROM_DATA[33] = 32'h08000021;
ROM_DATA[34] = 32'hafbf000c;
ROM_DATA[35] = 32'h0c000036;
ROM_DATA[36] = 32'h27bd0010;
ROM_DATA[37] = 32'h3c104000;
ROM_DATA[38] = 32'h0c00003f;
ROM_DATA[39] = 32'h27bdfff0;
ROM_DATA[40] = 32'h0c00003a;
ROM_DATA[41] = 32'h8fbf000c;
ROM_DATA[42] = 32'h275afffc;
ROM_DATA[43] = 32'h03400008;
ROM_DATA[44] = 32'hafbf000c;
ROM_DATA[45] = 32'h0c000036;
ROM_DATA[46] = 32'h27bd0010;
ROM_DATA[47] = 32'h3c104000;
ROM_DATA[48] = 32'h0c000042;
ROM_DATA[49] = 32'h27bdfff0;
ROM_DATA[50] = 32'h0c00003a;
ROM_DATA[51] = 32'h8fbf000c;
ROM_DATA[52] = 32'h275afffc;
ROM_DATA[53] = 32'h03400008;
ROM_DATA[54] = 32'hafb00000;
ROM_DATA[55] = 32'hafb10004;
ROM_DATA[56] = 32'hafb20008;
ROM_DATA[57] = 32'h03e00008;
ROM_DATA[58] = 32'h8fb00000;
ROM_DATA[59] = 32'hafb10004;
ROM_DATA[60] = 32'hafb20008;
ROM_DATA[61] = 32'h03e00008;
ROM_DATA[62] = 32'h03e00008;
ROM_DATA[63] = 32'h33710001;
ROM_DATA[64] = 32'h10110005;
ROM_DATA[65] = 32'h08000088;
ROM_DATA[66] = 32'h8e110010;
ROM_DATA[67] = 32'h32310002;
ROM_DATA[68] = 32'h1411fff9;
ROM_DATA[69] = 32'h08000042;
ROM_DATA[70] = 32'h8e120008;
ROM_DATA[71] = 32'h2411fff9;
ROM_DATA[72] = 32'h02519024;
ROM_DATA[73] = 32'hae120008;
ROM_DATA[74] = 32'h2412003f;
ROM_DATA[75] = 32'hafb20000;
ROM_DATA[76] = 32'h24120006;
ROM_DATA[77] = 32'hafb20004;
ROM_DATA[78] = 32'h2412005b;
ROM_DATA[79] = 32'hafb20008;
ROM_DATA[80] = 32'h2412004f;
ROM_DATA[81] = 32'hafb2000c;
ROM_DATA[82] = 32'h24120066;
ROM_DATA[83] = 32'hafb20010;
ROM_DATA[84] = 32'h2412006d;
ROM_DATA[85] = 32'hafb20014;
ROM_DATA[86] = 32'h2412007d;
ROM_DATA[87] = 32'hafb20018;
ROM_DATA[88] = 32'h24120007;
ROM_DATA[89] = 32'hafb2001c;
ROM_DATA[90] = 32'h2412007f;
ROM_DATA[91] = 32'hafb20020;
ROM_DATA[92] = 32'h2412006f;
ROM_DATA[93] = 32'hafb20024;
ROM_DATA[94] = 32'h2412006f;
ROM_DATA[95] = 32'hafb20028;
ROM_DATA[96] = 32'h2412007c;
ROM_DATA[97] = 32'hafb2002c;
ROM_DATA[98] = 32'h24120039;
ROM_DATA[99] = 32'hafb20030;
ROM_DATA[100] = 32'h2412005e;
ROM_DATA[101] = 32'hafb20034;
ROM_DATA[102] = 32'h2412007b;
ROM_DATA[103] = 32'hafb20038;
ROM_DATA[104] = 32'h24120071;
ROM_DATA[105] = 32'hafb2003c;
ROM_DATA[106] = 32'h8e120014;
ROM_DATA[107] = 32'h32520f00;
ROM_DATA[108] = 32'h00128a42;
ROM_DATA[109] = 32'h14110001;
ROM_DATA[110] = 32'h24110008;
ROM_DATA[111] = 32'h24120001;
ROM_DATA[112] = 32'h1251000c;
ROM_DATA[113] = 32'h00129040;
ROM_DATA[114] = 32'h12510007;
ROM_DATA[115] = 32'h00129040;
ROM_DATA[116] = 32'h12510003;
ROM_DATA[117] = 32'h309200f0;
ROM_DATA[118] = 32'h00129102;
ROM_DATA[119] = 32'h0800007e;
ROM_DATA[120] = 32'h3092000f;
ROM_DATA[121] = 32'h0800007e;
ROM_DATA[122] = 32'h30b200f0;
ROM_DATA[123] = 32'h00129102;
ROM_DATA[124] = 32'h0800007e;
ROM_DATA[125] = 32'h30b2000f;
ROM_DATA[126] = 32'h00129080;
ROM_DATA[127] = 32'h03b29020;
ROM_DATA[128] = 32'h8e520000;
ROM_DATA[129] = 32'h00118a00;
ROM_DATA[130] = 32'h02328820;
ROM_DATA[131] = 32'hae110014;
ROM_DATA[132] = 32'h8e110008;
ROM_DATA[133] = 32'h36310002;
ROM_DATA[134] = 32'hae110008;
ROM_DATA[135] = 32'h0800003e;
ROM_DATA[136] = 32'h8e110020;
ROM_DATA[137] = 32'h32310004;
ROM_DATA[138] = 32'h1011fffd;
ROM_DATA[139] = 32'h8e110018;
ROM_DATA[140] = 32'h2011fffe;
ROM_DATA[141] = 32'h0371d824;
ROM_DATA[142] = 32'h0800003e;

	for (i=143;i<ROM_SIZE;i=i+1) begin
		ROM_DATA[i] <= 32'h0;
	end

end
endmodule
