module control(clk, finish, value, able, direc, clea, led, to_fin, state,twice_play);

input clk;
input [3:0] value;
input finish;
output reg able;
output reg direc;
output reg clea;
output reg to_fin;
output reg twice_play;
output reg [5:0] led;
output reg [2:0] state;

parameter [7:0] initi = 8'b00000001;
parameter [7:0] recording = 8'b00000010;
parameter [7:0] record_pause = 8'b00000100;
parameter [7:0] record_finish = 8'b00001000;
parameter [7:0] playing = 8'b00010000;
parameter [7:0] play_pause = 8'b00100000;
parameter [7:0] move_forward = 8'b01000000;
parameter [7:0] move_backward = 8'b10000000;
reg [7:0] current_state = initi;
reg [7:0] next_state = initi;

parameter [3:0] i_on = 4'b0001;//开始/结束键
parameter [3:0] i_pause = 4'b0010;//暂停/继续键
parameter [3:0] i_clear = 4'b0011;//清除/快进键
parameter [3:0] i_back = 4'b0100;//倒退键
reg valid_val;

initial
begin
	current_state <= initi;
	next_state <= initi;
	valid_val <= 0;
end

always@(negedge clk)//状态方程
begin
	current_state = next_state;
end

always@(posedge clk)//驱动方程
begin
	if(value == 4'b1111)
		valid_val = 0;//防止重复读键，仅当valid_val=0时有效
	case(current_state)
	initi://初始状态
	begin
		if(value == i_on && valid_val == 0)
		begin
			next_state = recording;
			valid_val = 1;
		end
	end
	recording://正在录音
	begin
		if(value == i_on && valid_val == 0 )
		begin
			next_state = record_finish;
			valid_val = 1;
		end
		else if(value == i_pause && valid_val == 0)
		begin
			next_state = record_pause;
			valid_val = 1;
		end
	end
	record_pause://录音暂停
	begin
		if(value == i_on || value == i_pause && valid_val == 0)
		begin
			next_state = recording;
			valid_val = 1;
		end
	end
	record_finish://录音完成
	begin
		if(value == i_on && valid_val == 0)
		begin
			next_state = playing;
			valid_val = 1;
		end
		else if(value == i_clear || value == i_back && valid_val == 0)
		begin
			next_state = initi;
			valid_val = 1;
		end
	end	
	playing://正在播放
	begin
		if(finish == 1 || value == i_on && valid_val == 0)
		begin
			next_state = record_finish;
			valid_val = 1;
		end
		else if(value == i_pause && valid_val == 0)
		begin
			next_state = play_pause;
			valid_val = 1;
		end
		else if(value == i_clear && valid_val == 0)
		begin
			next_state = move_forward;
			valid_val =1;
		end
		else if(value == i_back && valid_val == 0)
		begin
			next_state = move_backward;
			valid_val =1;
		end
	end
	play_pause://播放暂停
	begin
		if(value == i_on || value == i_pause && valid_val == 0)
		begin
			next_state = playing;
			valid_val = 1;
		end
	end
	move_forward://二倍速快进
	begin
		if(value == i_on && valid_val ==0)
		begin
			next_state = playing;
			valid_val = 1;
		end
		else if(finish == 1 && valid_val == 0)
		begin
			next_state = record_finish;
			valid_val =1;
		end
	end
	move_backward://二倍速倒退
	begin
		if(value == i_on && valid_val ==0)
		begin
			next_state = playing;
			valid_val = 1;
		end
		else if(finish == 1 && valid_val == 0)
		begin
			next_state = record_finish;
			valid_val =1;
		end
	end
	default:
		next_state = initi;
	endcase
end
	
always@(posedge clk)//输出方程
begin
	case(current_state)
	initi:
	begin
		state = 3'b000;		//表示当前状态
		able = 0;				//使能端，为1时读写文件，开始计时
		direc = 0;				//方向指示，direc为0时为正向，即录音或倒退；direc为1时为负向，即播放或快进
		clea = 1;				//异步清零端，clea为1时清除所有录音文件
		to_fin = 0;				//播放完成指示，to_fin为1时播放录音完成
		twice_play=0;			//倍速指示，twice_play为1时为二倍速，否则为正常速率
	end
	recording:
	begin
		state = 3'b001;
		able = 1;
		direc = 0;
		clea = 0;
		to_fin = 0;
		twice_play=0;
	end
	record_pause:
	begin
		state = 3'b010;
		able = 0;
		direc = 0;
		clea = 0;
		to_fin = 0;
		twice_play=0;
	end
	record_finish:
	begin
		state = 3'b011;
		able = 0;
		direc = 0;
		clea = 0;
		to_fin = 1;
		twice_play=0;
	end
	playing:
	begin
		state = 3'b100;
		able = 1;
		direc = 1;
		clea = 0;
		to_fin = 0;
		twice_play=0;
	end
	play_pause:
	begin
		state = 3'b101;
		able = 0;
		direc = 1;
		clea = 0;
		to_fin = 0;
		twice_play=0;
	end
	move_forward:
	begin
		state = 3'b110;
		able = 1;
		direc = 1;
		clea = 0;
		to_fin = 0;
		twice_play=1;
	end
	move_backward:
	 begin
		state = 3'b111;
		able = 1;
		direc = 0;
		clea = 0;
		to_fin = 0;
		twice_play=1;
	end
	default:
	begin
		state = 3'b111;
		able = 0;
		direc = 0;
		clea = 0;
		to_fin = 0;
		twice_play=0;
	end
	endcase
end

always@(posedge clk)
begin
	case(current_state)
	initi: begin
			led = 6'b000001;
			end
	recording: begin
			led = 6'b000010;
			end
	record_pause:begin
			led = 6'b000100;
			end
	record_finish:	begin
			led = 6'b001000;
				end
	playing: begin
			led = 6'b010000;
				end
	play_pause: begin
			led = 6'b100000;
				end
	move_forward:begin
			led = 6'b110000;
				end
	move_backward:begin
			led = 6'b111000;
            end					
	default:
		begin 
			led = 6'b111111;
		end 	
	endcase
end

endmodule