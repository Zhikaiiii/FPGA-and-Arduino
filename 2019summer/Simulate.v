module Simulate(Clk,OutCome);//模拟A/D输入
input Clk;
output reg[7:0]OutCome;
initial
	OutCome=8'd0;
always @(posedge Clk)
begin
	if(OutCome != 8'b11111111)begin
		OutCome = OutCome+1;
	end
	else
		OutCome = 0;
end
endmodule
	