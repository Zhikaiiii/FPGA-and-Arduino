module timer(able, direc, clk1, clear, to_fin, play_twice, minute1, minute0, second1, second0, finish);
//计时模块
input able;
input direc;
input clk1;
input clear;
input to_fin;
input play_twice;
output reg [3:0] minute1;
output reg [3:0] minute0;
output reg [3:0] second1;
output reg [3:0] second0;
output reg finish = 1;
reg [7:0] minute;
reg [7:0] second;
reg [15:0] lasttime;

		

always@(posedge clk1)
begin	
	if(clear == 1)
	begin
		lasttime = 0;
		minute = 0;
		second = 0;
		finish = 0;
	end
	else 
	begin
		if(able == 0)
		begin
			finish = 0;
			if(to_fin == 1)
			begin
				minute = lasttime/100;
				second = lasttime - minute*100;
			end
		end
		else if(able == 1 && finish == 0)
		begin
			if(direc == 0 && play_twice == 0)
			begin
				if(second < 59)
					second = second + 1;
				else if(second == 59)
				begin
					second = 0;
					minute = minute + 1;
				end
				lasttime = minute*100+second;
			end
			else if(direc == 0 && play_twice == 1)
			begin
				if(lasttime == minute*100 + second )
					finish = 1;
				else if(second == 59)
				begin
					second = 0;
					minute = minute + 1;
				end
				else
					second = second + 1;
			end
			else if(direc == 1)
			begin
				if(minute == 0 && second == 0)
				begin
					finish = 1;
					minute = lasttime/100;
					second = lasttime - minute*100;
				end
				else if(second == 0)
				begin
					second = 59;
					minute = minute - 1;
				end
				else 
					second = second - 1;
			end
		end
	end
end

always@(minute)
begin
	minute1 = minute/10;
	minute0 = minute-10*minute1;
end

always@(second)
begin
	second1 = second/10;
	second0 = second-10*second1;
end

endmodule


