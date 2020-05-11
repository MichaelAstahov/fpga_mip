module FPGA_MIP (
//	Clock Input
	input 				clk_50,				// 50 MHz for TOP
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
	
//	VGA
	wire			 vga_ctrl_clk;
	wire 			 pll_lock;
	wire [7:0]	     i_red;
	wire [7:0]	     i_green;
	wire [7:0]	     i_blue;
	wire [9:0]	     coord_x;
	wire [9:0]	     coord_y;
	wire [18:0]	  	 vga_addr;
	
//	Binary
	wire [7:0] 		bin_threshold;
	wire			mvalue_Binary;
	wire [7:0] 		Bin_image;
//	Dilation from binary
	wire 			mvalue_dilation;
	wire [9:0] 		fDilation;


//////////////////////////////////////////////////////////////////	
// Continuous Assignments
//////////////////////////////////////////////////////////////////	

	assign rst 			 = sw[0];					    //active high reset controlled by sw[0].
	assign led_g[0] 	 = rst; 						//indicator for reset.
	assign led_g[1]      = pll_lock;					//indicator for pll working properly.

	assign led_r 	     = sw;							// Send switches to red leds.
	assign led_g[8:2]    = 6'b0;				   		// Turn off unused green leds.
	
	assign vga_addr     = coord_y*640 + coord_x;    	// handles setting the display pixels.
	
	assign bin_threshold = 8'b10000111;

//////////////////////////////////////////////////////////////////	
// Modules Instantiation
//////////////////////////////////////////////////////////////////	

//  PLL creates suitable vga_ctrl_clk for the design
//  640x480 = 25.2MHz
//  TODO: change resolution to 1024x768, the clock will be 65MHz.
	pll	pll_inst (
		.areset   (rst),
		.inclk0   (clk_50_pll),
		.c0 	  (vga_ctrl_clk),		//main clock
		.locked   (pll_lock)
	);

//	DDR creates clock for the DAC output
	ddr_output	ddr_output_inst (
		.aclr 		(rst),
		.datain_h   (1'b1),
		.datain_l   (1'b0),
		.outclock   (vga_ctrl_clk),
		.dataout    (vga_clk)	//DAC output clock
	);

			
//	handles the input image rom read output
//	later will handle the filtered image ram.
	memory memory_inst(
		.rst		(rst),
		.clk		(vga_ctrl_clk),
		.vga_addr	(vga_addr),
		
		.o_red		(i_red),
		.o_green	(i_green),
		.o_blue		(i_blue)
	);
	
			
// //	vga controller
// 	vga_ctrl vga_ctrl_inst (
// 		.clk		(vga_ctrl_clk),
// 		.rst		(rst),	
// 		.i_red		(i_red),
// 		.i_green	(i_green),
// 		.i_blue		(i_blue),
		
// 		.px			(coord_x),
// 		.py			(coord_y),
// 		.vga_r		(vga_r),
// 		.vga_g		(vga_g),
// 		.vga_h_sync	(vga_hs),
// 		.vga_v_sync	(vga_vs),
// 		.vga_sync	(vga_sync),
// 		.vga_b		(vga_b),
// 		.vga_blank	(vga_blank)
// 	);
	
	
//	binary
	binary_convert binary_inst (
		.clk			(vga_ctrl_clk),
		.rst			(rst),
		.input_data		(i_green),
		.thresh			(bin_threshold),
		.output_data	(Bin_image)
	);
		
//  morphological dilation filter
	dilation_filter dilation_inst (
		.clk			(vga_ctrl_clk),
		.rst			(rst),
		.input_data		(Bin_image),
		.output_data	(fDilation)
	);


	reg [15:0] wr_addr;
	reg [15:0] rd_addr;
	reg        wren;
	reg	  	   rden;
	reg [7:0]  filter_image;
	reg [2:0]  dly_reg;

	reg  [2:0] addr_dly_reg1;
	reg  [2:0] addr_dly_reg2;
	wire [7:0] ram_data;

	
	initial	wr_addr        = 0;
	initial	rd_addr        = 0;
	initial	wren           = 0;
	initial	rden           = 0;
	initial	filter_image   = 0;
	initial	dly_reg        = 0;
	initial	addr_dly_reg1  = 0;
	initial	addr_dly_reg2  = 0;

	always @(posedge clk or posedge rst) begin
		if(rst) begin
			dly_reg  <= 3'b0;
		end else begin
			dly_reg[0] <= 1'b1;
			dly_reg[1] <= dly_reg[0];
			dly_reg[2] <= dly_reg[1];
		end
	end

	always @(posedge clk or posedge rst) begin
		if(rst)  begin
			wr_addr  <=	16'b0;
			wren     <= 1'b0;
		end else begin
			if (dly_reg[1]) begin
				wr_addr <= wr_addr+1'b1;
				wren    <= 1'b1;
			end
		end
	end

	always @(posedge clk or posedge rst) begin
		if(rst) begin
			rd_addr  <=	16'b0;
			rden     <= 1'b0;
		end else begin
			if (dly_reg[2]) begin
				rd_addr <= rd_addr+1'b1;
				rden    <= 1'b1;
			end
		end
	end


	always @(posedge clk or posedge rst) begin
		if(rst) begin
			filter_image	<=	0;
			addr_dly_reg1	<=	0;
			addr_dly_reg2	<=	0;
		end else begin
			if (rden) begin
				addr_dly_reg1	<=	vga_addr[2:0];
				addr_dly_reg2	<=	~addr_dly_reg1;
				filter_image	<=	ram_data[addr_dly_reg2]   ? 8'hff : 8'b0;
			end
		end
	end

	img_ram	img_ram_inst (
		.clock 		(clk),
		.data 		(fDilation),
		.rdaddress 	(vga_addr[18:3]),
		.rden 		(rden),
		.wraddress 	(wr_addr),
		.wren 		(wren),
		.q 			(ram_data)
	);

	//	vga controller
	vga_ctrl vga_ctrl_inst (
		.clk		(vga_ctrl_clk),
		.rst		(rst),	
		.i_red		(filter_image),
		.i_green	(filter_image),
		.i_blue		(filter_image),
		.enable		(rden),
		
		.px			(coord_x),
		.py			(coord_y),
		.vga_r		(vga_r),
		.vga_g		(vga_g),
		.vga_h_sync	(vga_hs),
		.vga_v_sync	(vga_vs),
		.vga_sync	(vga_sync),
		.vga_b		(vga_b),
		.vga_blank	(vga_blank)
	);


endmodule
