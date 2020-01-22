module matrix_in(C, R, i_clk, value);//矩阵键盘

input i_clk;
output reg [3:0] R;
input [3:0] C;
output reg [3:0] value = 4'b1111;

reg [18:0] cnt = 19'b0;
always@(posedge i_clk)		//50MHz
begin
	if(cnt > 50004)
	begin
		cnt = 0;
	end
	
	else	if(cnt == 50000)		//1ms
	begin
		cnt = cnt + 1;
		R = 4'b0111;	//第一行
	end
	else	if(cnt == 50004)
	begin
		cnt = cnt + 1;
		if(C == 4'b0111)
			value = 4'b0001;	//1
		else if(C == 4'b1011)
			value = 4'b0010; 	//2
		else if(C == 4'b1101) 
			value = 4'b0011;	//3
		else if(C == 4'b1110)
			value = 4'b0100;
		else
			value = 4'b1111;
	end
	else 
	begin
		cnt = cnt + 1;
	end
end

endmodule
