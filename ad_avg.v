module ad_avg(
          input ad_clk,
			 input signed [11:0] ad_ch1_in,
			 input [3:0] cs_now,
 			 
			 output reg set_data,
			 
			 output reg [15:0] ad_data,
			 output reg [3:0] runinhere,//debug
			 output reg [3:0] ad_num,//单周期内ad采样次数
			 output reg [11:0] avg_data
    );
	 
	 //reg [11:0] ad_ch1;
	 reg signed[15:0] sum;
	 reg [3:0] cs_bef;
	 
	initial
		begin
			sum <= 0;
			cs_bef <= 4'd2;
			set_data <= 0;
			ad_num <= 4'b0;
		end
	 
	always@(posedge ad_clk)	//处理ch2时在同一块内重写
	begin
	/* 数据位是反的  这里为了一步到位 我直接改引脚定义了
		ad_ch1[11] <= ad_ch1_in[0];  
		ad_ch1[10] <= ad_ch1_in[1];  
		ad_ch1[9] <= ad_ch1_in[2];  
		ad_ch1[8] <= ad_ch1_in[3];  
		ad_ch1[7] <= ad_ch1_in[4];  
		ad_ch1[6] <= ad_ch1_in[5];  
		ad_ch1[5] <= ad_ch1_in[6];  
		ad_ch1[4] <= ad_ch1_in[7];  
		ad_ch1[3] <= ad_ch1_in[8];  
		ad_ch1[2] <= ad_ch1_in[9]; 
		ad_ch1[1] <= ad_ch1_in[10];
		ad_ch1[0] <= ad_ch1_in[11];
		*/
		runinhere = 4'd3;
		if(cs_bef == cs_now)
			begin
			runinhere = 4'd1;
			case(ad_num) //有多少case取决于 CLK_AD/CLK_CS 这里最多选5个case 多了也轮不到 采样率上去直接加
					4'd0:	
						begin
							sum <= $signed(sum) + $signed(ad_ch1_in); //完成片选之后的第二个数据
							ad_num <= 4'd1;
							set_data <= 1'b0;
						end
					4'd1:	
						begin
							sum <= $signed(sum) + $signed(ad_ch1_in);
							ad_num <= 4'd2;
							set_data <= 1'b0;
						end
					4'd2:
						begin
							sum <= $signed(sum) + $signed(ad_ch1_in);
							ad_num <= 4'd3;
							set_data <= 1'b0;
						end
					4'd3:
						begin
							sum <= $signed(sum) + $signed(ad_ch1_in);
							ad_num <= 4'd4;
							set_data <= 1'b0;
						end
					4'd4:
						begin
							sum <= $signed(sum) + $signed(ad_ch1_in);
							ad_num <= 4'd5;
							set_data <= 1'b0;
						end
					4'd5:
						begin
							sum <= $signed(sum) + $signed(ad_ch1_in);
							ad_num <= 4'd6;
							set_data <= 1'b0;
						end
					default:
						begin
							sum <=16'b1010101010101010;
							ad_data <= 16'b1010101010101010;
						end
				endcase
			end	//end if
		else if(cs_bef != cs_now)
			begin
				runinhere = 4'd2;
				case(ad_num) //看切换后的第一个周期 到底计了多少次
					4'd0:
						begin
							sum <= {4'b0,ad_ch1_in[11:0]}; //完成片选之后的第一个时钟沿数据
							//sum <= 16'b0; //选择丢弃第一个数据 这里我AD时钟做了延时 不知道会不会撞到
							ad_data <= {cs_bef[3:0],sum[11:0]};
							ad_num <= 4'd0;
							cs_bef <= cs_now;
							set_data <= 1'b1;
						end
					4'd1:	
						begin
							sum <= {4'b0,ad_ch1_in[11:0]}; 
							//sum <= 16'b0; //选择丢弃第一个数据 这里我AD时钟做了延时 不知道会不会撞到
							ad_data <= {cs_bef[3:0],sum[12:1]};
							ad_num <= 4'd0;
							cs_bef <= cs_now;
							set_data <= 1'b1;
						end
					4'd2:
						begin
							sum <= {4'b0,ad_ch1_in[11:0]};
							//sum <= 16'b0; //选择丢弃第一个数据 这里我AD时钟做了延时 不知道会不会撞到
							ad_data <= {cs_bef[3:0],sum[15:0]/3}; // = sum/2
							ad_num <= 4'd0;
							cs_bef <= cs_now;
							set_data <= 1'b1;
						end
					4'd3:
						begin
							sum <= $signed(ad_ch1_in); //完成片选之后的第一个时钟沿数据 此时 ad_num <= 4'd0
							//sum <= 16'b0; 
							ad_data <= {cs_bef[3:0],sum[13:2]}; 	//= sum/4
							avg_data <= ad_data[11:0];
							ad_num <= 4'd0;
							cs_bef <= cs_now;
							set_data <= 1'b1;
						end
					4'd4:
						begin
							sum <= {4'b0,ad_ch1_in[11:0]};
							//sum <= 16'b0; 
							ad_data <= {cs_bef[3:0],sum[15:0]/5}; 
							ad_num <= 4'd0;
							cs_bef <= cs_now;
							set_data <= 1'b1;
						end
					4'd5:
						begin
							sum <= {4'b0,ad_ch1_in[11:0]};
							//sum <= 16'b0; //选择丢弃第一个数据 这里我AD时钟做了延时 不知道会不会撞到
							ad_data <= {cs_bef[3:0],sum[15:0]/6};
							ad_num <= 4'd0;
							cs_bef <= cs_now;
							set_data <= 1'b1;
						end
					4'd6:
						begin
							sum <= {4'b0,ad_ch1_in[11:0]};
							//sum <= 16'b0; //选择丢弃第一个数据 这里我AD时钟做了延时 不知道会不会撞到
							ad_data <= {cs_bef[3:0],sum[15:0]/7};
							ad_num <= 4'd0;
							cs_bef <= cs_now;
							set_data <= 1'b1;
						end
					default: 
						begin
							sum <=16'b1010101010101010;
							ad_data <= 16'b1010101010101010;
						end
				endcase
			end	//end else
	end 	//end always

endmodule