module channel_switch(cs_Clk,cs_Rst,cs_En,cs_s);

	input cs_Clk;
	input cs_Rst;
	input cs_En;
	output reg [3:0] cs_s;
	
	initial
		cs_s <= 4'd2;
		
	always@(posedge cs_Clk or negedge cs_Rst)
		begin
			if(!cs_Rst)
				cs_s <= 4'd2;
			else if(!cs_En)
				cs_s <= 4'd2;
			else
				begin
					case(cs_s)
						4'd2:
							begin
								cs_s <= 4'd6;
							end
						4'd6:
							begin
								cs_s <= 4'd10;
							end
						4'd10:
							begin
								cs_s <= 4'd13;
							end
						4'd13:
							begin
								cs_s <= 4'd2;
							end
						default:;
					endcase
				end
		end
endmodule
