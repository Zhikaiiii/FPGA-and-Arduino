module freq_divider(clk, out);//1Hz时钟

input clk;
reg temp;
output reg out;
reg [24:0] count;
reg [24:0] count2;

always@(posedge clk)
begin
	if(count < 25000000)
		count = count + 1;
	else if(count == 25000000)
	begin
		count = 0;
		out = ~out;
	end
end

endmodule