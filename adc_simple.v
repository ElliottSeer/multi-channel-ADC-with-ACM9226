/*
CLK_CS 决定整个系统运行的最高频率（高于这个频率的波都会被过滤）
ADCA_CLK/CLK_CS 在每个周期的采样次数
*/

module adc_simple(
	input CLK_50M,
	
	//物理引脚
	output [3:0] CS_S,
	
	input [11:0] ADCA_IN,
	output [15:0] DATA_OUT,
	output DATA_SET,
	
	output ADCA_CLK,
	output CLK_CS
);
	
	pll pll (
		.inclk0(CLK_50M),
		.c0(ADCA_CLK),	//40 20ns delay
		.c1(CLK_CS),	//10
		//.c2(CLK_CS),	//5  15 
		//.c3(CLK_FIFO), //1M  25 30
		.locked(locked)
		);

	channel_switch cs(
		.cs_Clk(CLK_CS),
		.cs_s(CS_S),
		.cs_En(1'b1),
		.cs_Rst(1'b1)
		);
		
	ad_avg AD1(
		.ad_ch1_in(ADCA_IN),
		.ad_clk(ADCA_CLK),
		.cs_now(CS_S),
		.set_data(DATA_SET),
		.ad_data(DATA_OUT)
    );

endmodule

		