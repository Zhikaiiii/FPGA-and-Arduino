module FSM(Clk1,Flag,NumIn,NumTime,NumMoney);
input Clk1;
input Flag;
input [3:0]NumIn;//矩阵键盘输入
output reg [7:0]NumTime;//输出8位二进制时间
output reg [7:0]NumMoney;//输出8位二进制投币数
reg [1:0]Current_State;
reg [1:0]Next_State;
reg Clk2;//1Hz的时钟
reg Mark;//表示重新有新的输入
reg Confirm;//确认
reg Clear;//清零
reg Start;//开始
reg [4:0]NowNum;//投币数
reg [5:0]DouNum;//时间
reg [9:0]Count; //分频为1Hz的时钟的计数变量
reg [3:0]Count2;//10秒无反应回初始状态
reg [9:0]Count1;//倒计时状态
reg Enable2;//回初始状态计数器使能端
reg Enable1;//充电倒计时计数器使能端
reg Count2Done;//10s无反应回初始状态计数完成
reg Count1Done;//倒计时计数完成
reg Count3Done;
initial
begin
	NumMoney=8'b11111111;
	NumTime=8'b11111111;
	Current_State=2'b00;
	Enable2=1'b0;
	Enable1=1'b0;
	Mark=1'b0;
	Confirm=1'b0;
	Clear=1'b0;
	Start=1'b0;
	Count2Done=1'b0;
	Count1Done=1'b0;
end

always @(posedge Clk1)//分频得到1Hz的时钟
	begin
		if(Count == 10'd250)begin
			Clk2=~Clk2;
			Count=0;
			end
		else
			Count=Count+1;
	end

always @(posedge Clk2)
	begin
	if(Enable2==1'b1)begin
		if(Count2==4'd5)begin
			Count2=0;
			Count2Done=1;
		end
		else begin
		Count2=Count2+1;
		Count2Done=0;
		end	
	end
	else	begin
		Count2Done=0;
		Count2=0;
		end
	end	
	
always @(posedge Clk1 or posedge Mark)//如果有输入就赋值 没输入就倒计时
begin
	if(Mark==1'b1) begin
		if(Confirm!=1'b1)
		DouNum=2*NowNum;
		end
	else begin
		if(Enable1==1'b1)begin
			if(Count1 == 10'd250)begin
				DouNum=DouNum-1;
				Count1=10'd0;
			end
			else begin
				Count1=Count1+1;
				end
			if(DouNum==6'd0)
				Count1Done=1'b1;
		end
		else	begin
			Count1Done=1'b0;
			Count1=10'd0;
		end
	end		
end

always@(negedge Flag or posedge Count2Done or posedge Count1Done)begin//根据按键输入和计数是否完成决定状态
	if(Count2Done)begin//回到熄灭状态
		Start=1'b0;
		Confirm=1'b0;
		Clear=1'b0;
		Mark=1'b0;
		end
	else if(Count1Done)begin//回到开始状态
		Start=1'b0;
		Confirm=1'b0;
		Clear=1'b0;
		Mark=1'b0;
		NowNum=5'd0;
		end
	else begin
		if(NumIn==4'd10)begin//按下开始键
			Start=1'b1;
			Confirm=1'b0;
			Clear=1'b0;
			Mark=1'b0;
			end
		else if(NumIn==4'd11)begin//按下清零键
			Start=1'b0;
			Confirm=1'b0;
			Clear=1'b1;
			Mark=1'b0;
			NowNum=5'd0;
			end
		else if(NumIn==4'd12)begin//按下确认键
			Start=1'b0;
			Confirm=1'b1;
			Clear=1'b0;
			Mark=1'b0;
			end
		else begin//输入数字
			if(!Confirm)begin
			Start=1'b0;
			//Confirm=1'b0;
			Clear=1'b0;	
			Mark=1'b1;
				if(NowNum!=5'd0)begin//根据输入数字更新投币数
					if(NowNum>=5'd2)
						NowNum=5'd20;
					else 
						NowNum=5'b01010+NumIn;
				end
				else
					NowNum=NumIn;
			end
		end
		end
	end


always@(Clk2 or Current_State or Clear or Start or Confirm or NumTime or Mark)//输出方程
	begin
	case(Current_State)
	2'b00:begin//熄灭状态
	NumMoney=8'b11111111;
	NumTime=8'b11111111;
	Enable2=1'b0;
	Enable1=1'b0;
	end
	2'b01:begin//开始状态  回初始状态的计数器开始工作 
	Enable1=1'b0;
	NumMoney=8'b00000000;
	NumTime=8'b00000000;
	Enable2=1'b1;
	end
	2'b10:begin//输入状态 回初始状态的计数器停止工作
	//Enable1=1'b0;
	Enable2=1'b0;
	if(Mark==1'b1)begin
		NumMoney[7:4]=NowNum/10;
		NumMoney[3:0]=NowNum%10;
		NumTime[7:4]=(DouNum)/10;
		NumTime[3:0]=(DouNum)%10;
		end
	end
	2'b11:begin//倒计时
	Enable1=1'b1;
	NumTime[7:4]=DouNum/10;
	NumTime[3:0]=DouNum%10;
	end
	endcase	
	end

always@(Current_State or Clear or Start or Confirm or Count2 or NumTime or Mark)//驱动方程
	begin
	case(Current_State)
	2'b00:begin
	if(Start==1)
		Next_State<=2'b01;
	else
		Next_State<=2'b00;
	end
	2'b01:begin
	if(Mark==1)
		Next_State<=2'b10;
	else if(Count2Done==1)
		Next_State<=2'b00;
	else
		Next_State<=2'b01;
	end
	2'b10:begin
	if(Confirm==1)
		Next_State<=2'b11;
	else if(Clear==1)
		Next_State<=2'b01;
	else	
		Next_State<=2'b10;
	end
	2'b11:begin
	if(NumTime==0)
		Next_State<=2'b01;
	else
		Next_State<=2'b11;
	end
	endcase
	end
		
always@(posedge Clk1)
	begin
		Current_State<=Next_State;
	end

endmodule