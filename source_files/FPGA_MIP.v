module FPGA_MIP (
//*	Clock Input
	input 				clk_50,		  // 50 MHz for TOP
	input 				clk_50_pll,   // 50 MHz for PLL
//*	Push Button
	input [3:0] 		key,      	  // Pushbutton[3:0]
//*	Pull Switch
	input [17:0] 		sw ,		  // Toggle switch[17:0]
//*	LED
	output [8:0]  		led_g,  	  // LED Green[8:0]
	output [17:0] 		led_r,  	  // LED Red[17:0]	
//*	VGA
	output 				vga_clk,   	  // VGA Clock
   	output 				vga_hs,		  // VGA H_SYNC
   	output 				vga_vs,		  // VGA V_SYNC
  	output 				vga_blank,	  // VGA BLANK
   	output 				vga_sync,	  // VGA SYNC
   	output [7:0] 		vga_r,  	  // VGA Red[7:0]
   	output [7:0] 		vga_g,	  	  // VGA Green[7:0]
   	output [7:0] 		vga_b   	  // VGA Blue[7:0]
);



	 wire   rst;
	 assign rst = sw[0];	// active high reset controlled by sw[0].


//!	Main Control Block.
	//* State Machine for the workflow of the filter.
	//* General logic.

	wire rom_flag;
	wire dilation_en;
	wire erosion_en;
	wire ram_flag;
	wire vga_flag;

	mip_control MIP_Control_Inst (
		//* System Signals
		.clk		   (vga_ctrl_clk),
		.rst		   (rst),
		.sw			   (sw),
		.led_g		   (led_g),
		.led_r		   (led_r),
		//* Input Flags
		.pll_lock      (pll_lock),
		.dilation_done (dilation_done),
		.erosion_done  (erosion_done),
		//* Output Flags
		.rom_flag      (rom_flag),
		.dilation_en   (dilation_en),
		.erosion_en    (erosion_en),
		.ram_flag      (ram_flag),
		.vga_flag      (vga_flag)
	);
//!


//!	PLL Block.
	//* PLL creates suitable vga_ctrl_clk for the design
	//* 640x480 = 25.2MHz
		// TODO: change resolution to 1024x768, the clock will be 65MHz.
	wire vga_ctrl_clk;
	wire pll_lock;

	pll	PLL_Inst (
		.areset   (rst),
		.inclk0   (clk_50_pll),
		.c0 	  (vga_ctrl_clk),	// main clock - 25.2MHz: 640x480
	//	.c1		  (vga_ctrl_clk),	// main clock - 65MHz  : 1024x768
		.locked   (pll_lock)
	);
//!


//!	DDR Block.
	//*	DDR creates clock for the DAC output
	ddr_output	DDR_Output_Inst (
		.aclr 		(rst),
		.datain_h   (1'b1),
		.datain_l   (1'b0),
		.outclock   (vga_ctrl_clk),
		.dataout    (vga_clk)	  // DAC output clock
	);
//!


//!	Memory Block.
	//*	handles the input image rom read output
	//*	handle the filtered image ram.
	wire [8-1:0]	red;
	wire [8-1:0]	green;
	wire [8-1:0]	blue;
	wire [19-1:0]   vga_addr;  // handles setting the display pixels.
	wire [8-1:0]    orig_img;

	memory Memory_Inst(
		//*	System Signals
		.rst		(rst),
		.clk		(vga_ctrl_clk),
		//* Input Flags
		.rom_flag   (rom_flag),
		.ram_flag   (ram_flag),
		.vga_flag	(vga_flag),
		//* Input Data
		.fltr_img   (fltr_img),
		.vga_addr	(vga_addr),
		//* Output Data
		.orig_img   (orig_img),
		.red		(red),
		.green		(green),
		.blue		(blue)
	);
//!


//!	VGA Controller.
	//TODO: Rewrite for generic vga_ctrl block.

	vga_ctrl VGA_Ctrl_Inst (
		.clk		(vga_ctrl_clk),
		.rst		(rst),
		.enable 	(vga_flag),

		.i_red		(red),
		.i_green	(green),
		.i_blue		(blue),
		
	//	.px			(coord_x),
	//	.py			(coord_y),
		.vga_addr   (vga_addr),

		.vga_r		(vga_r),
		.vga_g		(vga_g),
		.vga_b		(vga_b),
		.vga_h_sync	(vga_hs),
		.vga_v_sync	(vga_vs),
		.vga_sync	(vga_sync),
		.vga_blank	(vga_blank)
	);
//!
	
//! Image Processing

	//TODO: Understand why Dilation and Erosion seems to be opposite

	//*  Dilation Filter Block.
	wire [8-1:0] 	dil_fltr_img;  // image bits after dilation filter
	wire 			dilation_done_w;

	dilation_filter Dilation_Inst (
		.clk			(vga_ctrl_clk),
		.rst			(rst),
		.enable         (dilation_en),
		.input_data		(orig_img),
		.done 			(dilation_done_w),
		.output_data	(dil_fltr_img)
	);
	//*

	//*  Erosion Filter Block.
	wire [8-1:0] 	ero_fltr_img;  // image bits after erosion filter
	wire 			erosion_done_w;

	erosion_filter Erosion_Inst (
		.clk			(vga_ctrl_clk),
		.rst			(rst),
		.enable         (erosion_en),
		.input_data		(orig_img),
		.done 			(erosion_done_w),
		.output_data	(ero_fltr_img)
	);
	//*

	//* choose the right input to ram
	reg [8-1:0]    fltr_img;
	reg 		   dilation_done;
	reg			   erosion_done;
	wire [2-1 : 0] img_data_ctrl;

	initial begin
		fltr_img      = 8'b0;
		dilation_done = 1'b0;
		erosion_done  = 1'b0;
	end

	assign img_data_ctrl = {dilation_en, erosion_en};

	    always @(posedge vga_ctrl_clk, posedge rst) begin
        if (rst) begin
            fltr_img      <= 8'b0;

        end else begin
            case (img_data_ctrl)
                2'b00: begin
                    fltr_img <= orig_img;
                end
                2'b01: begin
                    fltr_img <= ero_fltr_img;
                end
                2'b10: begin
                    fltr_img <= dil_fltr_img;
                end
				2'b11: begin
                    fltr_img <= orig_img;
                end

                default: begin
                    fltr_img <= orig_img;
                end
            endcase
        end
    end

	always @(posedge vga_ctrl_clk, posedge rst) begin
		if (rst) begin
			dilation_done <= 1'b0;
			erosion_done  <= 1'b0;
		end else begin
			dilation_done <= dilation_done_w;
			erosion_done  <= erosion_done_w;
		end		
	end
	//*

//!


endmodule






