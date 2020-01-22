`timescale 100ns/1ns
//#include"decoder7448.v"
module decoder7448_tb();
	reg [3:0]a;
	reg en;
	wire [6:0]out;
	decoder7448 D7448(.A(a),.EN(en),.OUT(out));
	initial
		begin
		a=4'd0;
		en=1'b1;
		for(a=4'd0;a<=4'd15;a=a+1)begin
			#2;	
		end
		end
endmodule