module Show(Clk1,All,Out,Select);
	input Clk1;
	input [15:0]All;
	output [6:0]Out;
	output [3:0]Select;
	wire [27:0]Temp;
	reg [17:0]Count;
	reg [6:0]Out;
	reg [3:0]Select;
	decoder7448 D74481(.A(All[3:0]),.EN(Select[0]),.OUT(Temp[6:0]));
	decoder7448 D74482(.A(All[7:4]),.EN(Select[1]),.OUT(Temp[13:7]));
	decoder7448 D74483(.A(All[11:8]),.EN(Select[2]),.OUT(Temp[20:14]));
	decoder7448 D74484(.A(All[15:12]),.EN(Select[3]),.OUT(Temp[27:21]));
	reg [1:0]Sel;
	
	always @(posedge Clk1)
		begin 
			if(Sel == 2'b11)
				Sel = 2'b00;
			else 
				Sel = Sel+1;
		end
	always 
		begin
		if(Sel == 2'b00)begin
			Out=Temp[6:0];
			Select=4'b0001;
			end
		else if(Sel == 2'b01)begin	
			Out=Temp[13:7];
			Select=4'b0010;
			end
		else if(Sel == 2'b10)begin	
			Out=Temp[20:14];
			Select=4'b0100;
			end
		else begin
			Out=Temp[27:21];
			Select=4'b1000;
			end
	end
endmodule