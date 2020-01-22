module Collect(Clk,State,Clk1,ClkAD,ClkDA);
input Clk;
input [2:0]State;
reg [11:0]Count;//8kHz采样时钟
output reg Clk1;
output reg ClkAD;
output reg ClkDA;
always @(posedge Clk)
begin
		if(State==3'b001 || State==3'b100 || State==3'b110 || State==3'b111)//录音或者播放或快进 或倒退状态
		begin
			if(Count==12'd3125)begin
				Count=0;
				Clk1=~Clk1;
			end
			else
				Count=Count+1;
		end
		else
			Count=Count;
end

always @(Clk1)
begin
	if(State==3'b001)
		ClkAD=Clk1;
	else if(State==3'b100)//启动DA转换
		ClkDA=Clk1;
end
endmodule