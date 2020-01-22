//行扫描列输出
module Matrix(Clk1,Row,Column,Value,flag);
input [3:0] Column;
input Clk1;
output [3:0]Row;
output [3:0] Value;
output reg flag;//表示是否有按键按下
reg [3:0] Row;
reg [3:0] Value;
reg [17:0] Count;//分频计数
reg [5:0] Count2;//按下防抖计数
reg [5:0] Count3;//释放防抖计数
reg Enable1;//按下防抖计数使能端
reg Enable2;//释放防抖计数使能端
reg [3:0] State;
reg [3:0] now_Column;
reg [3:0] now_Row;

always @(posedge Clk1)
	begin
		if(Enable1 && Count2!=6'd10)
		Count2=Count2+1;
		else
		Count2=0;
	end
always @(posedge Clk1)
	begin
		if(Enable2 && Count3!=6'd10)
		Count3=Count3+1;
		else
		Count3=0;
	end
always @(posedge Clk1)
	begin
	case(State)
	4'd0: 
		begin
			Enable1<=1'b0;
			Row<=4'b0000;
			flag<=1'b0;
			if(Column!=4'b1111) begin
			State<=4'd1;
			Enable1<=1'b1;//开始进行防抖
			end
			else State<=4'd0;
		end
	4'd1://按下防抖
		begin
			if(Count2>=6'd10&&Column!=4'b1111) begin
			State<=4'd2;
			Enable1<=1'b0;//防抖结束
			Row<=4'b1110;
			end
			else if(Count2<6'd10&&Column!=4'b1111)begin
			State<=4'd1;
			end
			else begin
			State<=4'd0;
			Enable1<=1'b0;
			end
		end		
	4'd2:
		begin
			if(Column!=4'b1111) 
			State<=4'd6;
			else begin
			State<=4'd3;
			Row<=4'b1101;
			end
		end
	4'd3:
		begin
			if(Column!=4'b1111)
			State<=4'd6;
			else begin
			State<=4'd4;
			Row<=4'b1011;
			end
		end
	4'd4:
		begin
			if(Column!=4'b1111)
			State<=4'd6;
			else begin
			State<=4'd5;
			Row<=4'b0111;
			end
		end
	4'd5:
		begin
			if(Column!=4'b1111)
			State<=4'd6;
			else
			State<=4'd0;
		end
	4'd6://存数输出状态
		begin
			if(Column!=4'b1111) begin
			now_Column<=Column;
			now_Row<=Row;
			if(Column!=4'b0111&&Row==4'b1110)
			flag=1'b0;
			else begin
			flag=1'b1;//有按键按下
			State<=4'd7;
			end
			end
			else 
			State<=4'd0;
		end
	4'd7://等待释放状态
		begin
			if(Column==4'b1111)begin
			State<=4'd8;
			end
			else
			State<=4'd7;
		end
	4'd8:
		begin
			Enable2<=1'b1;
			if(Count3==6'd10&&Column==4'b1111) begin
			State<=4'd0;
			Enable2<=1'b0;//防抖结束
			Row<=4'b0000;
			end
			else if(Count3<6'd10&&Column==4'b1111)begin
			State<=4'd8;
			end
			else begin
			State<=4'd7;
			Enable2<=1'b0;
			end
		end		
	endcase
	end

always @(now_Column or now_Row)
	begin
		if(flag==1'b1)
			begin
			case({now_Column,now_Row})
			8'b01110111: Value<=4'd1;
			8'b10110111: Value<=4'd2;
			8'b11010111: Value<=4'd3;
			8'b01111011: Value<=4'd4;	
			8'b10111011: Value<=4'd5;
			8'b11011011: Value<=4'd6;
			8'b01111101: Value<=4'd7;
			8'b10111101: Value<=4'd8;
			8'b11011101: Value<=4'd9;
			8'b01111110: Value<=4'd0;
			8'b11100111: Value<=4'd10;
			8'b11101011: Value<=4'd11;
			8'b11101101: Value<=4'd12;
			default: Value<=Value;
			endcase
		end
	end
endmodule	