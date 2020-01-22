`timescale 1ms/1us
module FSM_tb();
	reg clk1;
	reg flag;
	reg [3:0]numin;
	wire [7:0]tim;
	wire [7:0]money;
	FSM f(.Clk1(clk1),.Flag(flag),.NumIn(numin),.NumTime(tim),.NumMoney(money));
	
	initial begin
		clk1=0;
		flag=0;
		end
	always
	#1 clk1=~clk1;
	
	initial begin
		#40 numin=4'd10;flag=1;//按下开始键
		#10 flag=0;
		#40 numin=4'd6;flag=1;//输入数字6
	   #60 flag=0;
		#40 numin=4'd11;flag=1;//清零
		#10 flag=0;
		#40 numin=4'd5;flag=1;//重新输入数字5
	   #10 flag=0;
		#120 numin=4'd12;flag=1;//开始倒计时
		#40  flag=0;
		#15000 numin=4'd10;flag=1;//重新按下开始键
		#10 flag=0;
		#40 numin=4'd9;flag=1;//输入数字9
		#10 flag=0;
		#40 numin=4'd3;flag=1;//输入数字3
		#10 flag=0;
		#40 numin=4'd12;flag=1;//开始倒计时
		#40  flag=0;
		#3000 $stop;//停止仿真
		end

endmodule	