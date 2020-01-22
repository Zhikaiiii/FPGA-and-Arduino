module decoder7448(EN,A,OUT);
	input [3:0] A;
	input EN;
	output [6:0]OUT;
	reg [6:0]OUT;
	always @(A or EN)
	begin
		if(~EN)
			OUT=7'b0000000;
		else
			case(A)
			4'd0:  OUT=7'b0111111;
			4'd1:  OUT=7'b0000110;
			4'd2:  OUT=7'b1011011;
			4'd3:  OUT=7'b1001111;
			4'd4:  OUT=7'b1100110;
			4'd5:  OUT=7'b1101101;
			4'd6:  OUT=7'b1111100;
			4'd7:  OUT=7'b0000111;
			4'd8:  OUT=7'b1111111;
			4'd9:  OUT=7'b1100111;
			4'd10: OUT=7'b1011000;
			4'd11: OUT=7'b1001100;
			4'd12: OUT=7'b1100010;
			4'd13: OUT=7'b1101001;
			4'd14: OUT=7'b1111000;
			4'd15: OUT=7'b0000000;
			endcase
	end
endmodule