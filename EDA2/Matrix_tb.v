`timescale 1ms/1us
module Matrix_tb();
	wire [3:0] row;
	reg clk;
	reg [3:0]column;
	wire [3:0] value;
	wire Flag;
	Matrix m(.Row(row),.Clk1(clk),.Column(column),.Value(value),.flag(Flag));
	initial	begin
	clk=0;
	column=4'b1111;
	end
	always
		#1 clk=~clk;
	initial
		begin
		#10 column=4'b0111;//长按键、前防抖
		#100 column=4'b1111;
		#2	column=4'b0111;//后防抖
		#6	column=4'b1111;//松开
		#50 column=4'b1011;
		#2	column=4'b1111;//前防抖
		#50 column=4'b1011;//第二次赋值
		#23 column=4'b1111;
		#4 column=4'b1011;
		#60 column=4'b1111;
		#30 $stop;
		end
endmodule