module freq_divider2(clk, out);//250Hz时钟，数码管显示电路

input clk;
output reg out;

reg [16:0] count;
always@(posedge clk)
begin
	if(count < 100000)
		count = count + 1;
	else if(count == 100000)
	begin
		count = 0;
		out = ~out;
	end
end

endmodule