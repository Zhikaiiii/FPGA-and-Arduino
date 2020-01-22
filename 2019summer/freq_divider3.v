module freq_divider3(clk, out2);//2Hz时钟

input clk;
output reg out2;
//output reg out2;
//reg [12:0] count2;
reg [23:0] count2;

always@(posedge clk)
begin
	if(count2 < 12500000)
		count2 = count2 + 1;
	else if(count2 == 12500000)
	begin
		count2 = 0;
		out2 = ~out2;
	end
end

endmodule