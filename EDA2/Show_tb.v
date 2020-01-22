`timescale 1ms/1us
module Show_tb();
	reg clk1;
	reg [15:0]allnum;
	wire [6:0]out;
	wire [3:0]select;
	
Show s(.All(allnum),.Clk1(clk1),.Out(out),.Select(select));
	
initial begin
	allnum=16'b0001001000110100;//1 2 3 4
	clk1=0;
	#30 $stop;
	end
always
	#1 clk1=~clk1;
	
endmodule