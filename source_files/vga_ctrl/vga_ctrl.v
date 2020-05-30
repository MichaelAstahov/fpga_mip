
module vga_ctrl(
	input clk, 			// 25.2 MHz clock
	input rst,
	input [7:0] i_red,
	input [7:0] i_green,
	input [7:0] i_blue,
	input 		enable,
	
//	pixel coordinates
	output [19-1:0] vga_addr,
	
//	VGA Side
    output  [7:0] vga_r,
    output  [7:0] vga_g,
    output  [7:0] vga_b,
    output reg vga_h_sync,
    output reg vga_v_sync,
    output vga_sync,
    output vga_blank
	);

	reg [9:0] h_count;
	reg [9:0] v_count;
	wire video_h_on;
	wire video_v_on;
	wire video_on;
	
	
	assign vga_blank	=	vga_h_sync & vga_v_sync;
	assign vga_sync		=	1'b0;


	assign vga_addr = v_count*640 + h_count;   // 640x480
//	assign vga_addr = v_count*1024 + h_count;  // 1024x768


//! Generate Horizontal and Vertical Timing Signals for Video Signal
	//* Horizontal sync
	//*
	//* Resolution: 640x480@60Hz:
	//* clk=25.2MHz [PLL]
	//* Horizontal: Display=640, Front_Porch=16, Sync_Pulse=64, Back_Porch=48
	//?---------------------
	//? Actual Parameters:
	//?---------------------
	//? H_SYNC_TOTAL = 769 [Display+Front_Porch+Sync_Pulse+Back_Porch]
	//? H_PIXELS     = 640 [Display]
	//? H_SYNC_START = 656 [Display+Front_Porch]
	//? H_SYNC_WIDTH = 64  [Sync_Pulse]
	//?---------------------
	//? Reality:
	//?---------------------
	//? H_SYNC_TOTAL = 800; [Display+Front_Porch+Sync_Pulse+Back_Porch+32]
	//? H_PIXELS     = 640 [Display]
	//? H_SYNC_START = 659 [Display+Front_Porch+3]
	//? H_SYNC_WIDTH = 96  [Sync_Pulse+32]
	//* Resolution: 1024x768@60Hz:
	//* clk=65MHz [PLL]
	//* Horizontal: Display=1024, Front_Porch=24, Sync_Pulse=136, Back_Porch=160
	//? Actual Parameters:
	//? H_SYNC_TOTAL = 1344 [Display+Front_Porch+Sync_Pulse+Back_Porch]
	//? H_PIXELS     = 1024 [Display]
	//? H_SYNC_START = 1048 [Display+Front_Porch]
	//? H_SYNC_WIDTH = 136  [Sync_Pulse]
	//? Reality:
	//? H_SYNC_TOTAL = 1376 [Display+Front_Porch+Sync_Pulse+Back_Porch+32]
	//? H_PIXELS     = 1024 [Display]
	//? H_SYNC_START = 1051 [Display+Front_Porch+3]
	//? H_SYNC_WIDTH = 168  [Sync_Pulse+32]
	//* h_count counts pixels (640 + extra time for sync signals)
	//* 
	//*  horiz_sync  ------------------------------------__________--------
	//*  h_count       0                640             659       755    799

//	Working 640x480@60Hz
	localparam H_SYNC_TOTAL = 800;
	localparam H_PIXELS 	= 640;
	localparam H_SYNC_START = 659;
	localparam H_SYNC_WIDTH =  96;

	// // Testing  1024x768@60Hz
	// localparam H_SYNC_TOTAL = 1376;
	// localparam H_PIXELS 	= 1024;
	// localparam H_SYNC_START = 1051;
	// localparam H_SYNC_WIDTH =  168;

	always @(posedge clk or posedge rst) begin
		if(rst) begin
			h_count <= 10'h000;
			vga_h_sync <= 1'b0;
		end else begin
      // H_Sync Counter
	  		if (enable) begin
				if (h_count < H_SYNC_TOTAL-1) begin
					h_count <= h_count + 1'b1;
				end else begin
					h_count <= 10'h0000;
				end
		
				if (h_count >= H_SYNC_START && h_count < H_SYNC_START+H_SYNC_WIDTH) begin
					vga_h_sync = 1'b0;
				end else begin
					vga_h_sync <= 1'b1;
				end
			end
		end
	end

	//* Vertical sync
	//*
	//* Resolution: 640x480@60Hz:
	//* clk=25.2MHz [PLL]
	//* Vertical:   Display=480, Front_Porch=10, Sync_Pulse=2,  Back_Porch=33
	//?---------------------
	//? Actual Parameters:
	//?---------------------
	//? V_SYNC_TOTAL = 525 [Display+Front_Porch+Sync_Pulse+Back_Porch]
	//? V_PIXELS     = 480 [Display]
	//? V_SYNC_START = 490 [Display+Front_Porch]
	//? V_SYNC_WIDTH = 2   [Sync_Pulse]
	//? H_START 	 = 668 [H_SYNC_TOTAL-101]
	//?---------------------
	//? Reality:
	//?---------------------
	//? V_SYNC_TOTAL = 525;
	//? V_PIXELS     = 480 [Display]
	//? V_SYNC_START = 493 [Display+Front_Porch+3]
	//? V_SYNC_WIDTH = 2   [Sync_Pulse]
	//? H_START 	 = 699 [H_SYNC_TOTAL-101]
	//* Resolution: 1024x768@60Hz:
	//* clk=65MHz [PLL]
	//* Vertical:   Display=768, Front_Porch=3, Sync_Pulse=6,  Back_Porch=29
	//? Actual Parameters:
	//? V_SYNC_TOTAL = 806  [Display+Front_Porch+Sync_Pulse+Back_Porch]
	//? V_PIXELS     = 768  [Display]
	//? V_SYNC_START = 771  [Display+Front_Porch]
	//? V_SYNC_WIDTH = 6   [Sync_Pulse]
	//? H_START 	 = 1243 [H_SYNC_TOTAL-101]
	//? Reality:
	//? V_SYNC_TOTAL = 806  [Display+Front_Porch+Sync_Pulse+Back_Porch]
	//? V_PIXELS     = 768  [Display]
	//? V_SYNC_START = 774  [Display+Front_Porch+3]
	//? V_SYNC_WIDTH = 6    [Sync_Pulse]
	//? H_START 	 = 1275 [H_SYNC_TOTAL-101]

	//*  vertical_sync      -----------------------------------------------_______------------
	//*  v_count             0                                      480    493-494          524

//	Working 640x480@60Hz
	localparam V_SYNC_TOTAL = 525;
	localparam V_PIXELS     = 480;
	localparam V_SYNC_START = 493;
	localparam V_SYNC_WIDTH =   2;
	localparam H_START 	    = 699;

	// // Testing  1024x768@60Hz
	// localparam V_SYNC_TOTAL = 806;
	// localparam V_PIXELS     = 768;
	// localparam V_SYNC_START = 774;
	// localparam V_SYNC_WIDTH =   6;
	// localparam H_START 	    = 1275;	

	always @(posedge clk or posedge rst) begin
		if (rst) begin
			v_count <= 10'h0000;
			vga_v_sync <= 1'b0;
		end else if (enable) begin
			if (h_count == H_START) begin
			// V_Sync Counter
				if (v_count < V_SYNC_TOTAL-1) begin
					v_count <= v_count + 1'b1;
				end else begin
					v_count <= 10'h0000;
				end

				if (v_count >= V_SYNC_START && v_count < V_SYNC_START+V_SYNC_WIDTH) begin
					vga_v_sync = 1'b0;
				end else begin
					vga_v_sync <= 1'b1;
				end
			end
		end
	end
   

	assign video_h_on = (h_count<H_PIXELS);
	assign video_v_on = (v_count<V_PIXELS);
	assign video_on   = video_h_on & video_v_on;

	assign vga_r = video_on ? i_red   : 8'b0;
	assign vga_g = video_on ? i_green : 8'b0;
	assign vga_b = video_on ? i_blue  : 8'b0;

   
endmodule