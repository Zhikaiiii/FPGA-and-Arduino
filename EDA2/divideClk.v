module divideClk(Clk,Clk1);
input Clk;
output reg Clk1;
reg [17:0]Count;

always @(posedge Clk)
	begin
		if (Count == 18'd100000)begin
			Clk1=~Clk1;
			Count=0;
			end
		else 
			Count=Count+1;
	end
	
endmodule