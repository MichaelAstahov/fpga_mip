module FPGA_MIP (
//	Clock Input
	input 				clk_50 ,			// 50 MHz for TOP
	input 				clk_50_pll,     	// 50 MHz for PLL
//	Push Button
	input [3:0] 		key,      	 		// Pushbutton[3:0]
//	Pull Switch
	input [17:0] 		sw ,			 	// Toggle switch[17:0]
//	LED
	output [8:0]  		led_g,  			// LED Green[8:0]
	output [17:0] 		led_r,  			// LED Red[17:0]	
//	VGA
	output 				vga_clk,   		    // VGA Clock
   	output 				vga_hs,				// VGA H_SYNC
   	output 				vga_vs,				// VGA V_SYNC
  	output 				vga_blank,		  	// VGA BLANK
   	output 				vga_sync,			// VGA SYNC
   	output [7:0] 		vga_r,  			// VGA Red[7:0]
   	output [7:0] 		vga_g,	  			// VGA Green[7:0]
   	output [7:0] 		vga_b   	  		// VGA Blue[7:0]
	);

//////////////////////////////////////////////////////////////////	
// Wires & Registers
//////////////////////////////////////////////////////////////////

	wire 			 rst;
	wire 			 dly_rst;
	
//	VGA
	wire			 vga_ctrl_clk;
	wire 			 pll_lock;
	wire [7:0]	     i_red;
	wire [7:0]	     i_green;
	wire [7:0]	     i_blue;
	wire [9:0]	     coord_x;
	wire [9:0]	     coord_y;
	wire [18:0]	  	 mVGA_ADDR;
	
//	Binary
	wire [9:0] 		BIN_THRESHOLD;
	wire			mvalue_Binary;
	wire [9:0] 		Bin_image;
//	Dilation from binary
	wire 			mvalue_dilation;
	wire [9:0] 		fDilation;


//////////////////////////////////////////////////////////////////	
// Continuous Assignments
//////////////////////////////////////////////////////////////////	

	assign rst 			= sw[0];					//active high reset controlled by sw[0].
	assign led_g[0] 	= dly_rst; 					//indicator for reset_delay block.
	assign led_g[1]     = pll_lock;					//indicator for pll working properly

	assign led_r = sw;								// Send switches to red leds 
	assign led_g[8:2] = 8'b0;				   		// Turn off unused green leds
	
	assign mVGA_ADDR = coord_y*640 + coord_x;    	// handles setting the display pixels
	
	assign BIN_THRESHOLD = 10'b0001010100;

//////////////////////////////////////////////////////////////////	
// Modules Instantiation
//////////////////////////////////////////////////////////////////	

//	PLL creates suitable vga_clk for the design
	pll	pll_inst (
		.areset (rst),
		.inclk0 (clk_50_pll),
		.c0 	(vga_ctrl_clk),
		.locked (pll_lock)
	);

//	DDR creates clock for the DAC output
	ddr	ddr_inst (
		.aclr 		(rst),
		.datain_h   (1'b1),
		.datain_l   (1'b0),
		.outclock   (vga_ctrl_clk),
		.dataout    (vga_clk)
	);


//	Reset Delay gives some time for peripherals to initialize
	rst_dly reset_delay_inst (
		.clk	(clk_50),
		.irst	(rst),
		.orst	(dly_rst)
	);


			
//	handles the input image rom read output
//	later will handle the filtered image ram.
	memory memory_inst(
		.rstn		(~dly_rst),
		.i_vga_clk	(vga_ctrl_clk),
		.i_vga_addr	(mVGA_ADDR),
		
		.o_red		(i_red),
		.o_green	(i_green),
		.o_blue		(i_blue)
	);
	
			
//	vga controller
	vga_ctrl vga_ctrl_inst (
		.clk		(vga_ctrl_clk),
		.rstn		(~dly_rst),	
		.i_red		(i_red),
		.i_green	(i_green),
		.i_blue		(i_blue),
		
		.px			(coord_x),
		.py			(coord_y),
		.vga_r		(vga_r),
		.vga_g		(vga_g),
		.vga_b		(vga_b),
		.vga_h_sync	(vga_hs),
		.vga_v_sync	(vga_vs),
		.vga_sync	(vga_sync),
		.vga_blank	(vga_blank)
	);
	
	
//	binary
	binary_convert binary_inst (
		.clk			(vga_ctrl_clk),
		.rstn			(~dly_rst),
		.input_data		(i_green),
		.thresh			(BIN_THRESHOLD),
		.output_data	(Bin_image)
	);
		
	
	dilation_filter dilation_inst (
		.clk			(vga_ctrl_clk),
		.rstn			(~dly_rst),
		.input_data		(Bin_image),
		.output_data	(fDilation)
	);


endmodule
