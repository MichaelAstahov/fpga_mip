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


	assign vga_addr = v_count*640 + h_count; 



//! Generate Horizontal and Vertical Timing Signals for Video Signal
	//* Horizontal sync

	//* h_count counts pixels (640 + extra time for sync signals)
	//* 
	//*  horiz_sync  ------------------------------------__________--------
	//*  h_count       0                640             659       755    799

	localparam H_SYNC_TOTAL = 800;
	localparam H_PIXELS 	   = 640;
	localparam H_SYNC_START = 659;
	localparam H_SYNC_WIDTH =  96;

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
  
	//*  vertical_sync      -----------------------------------------------_______------------
	//*  v_count             0                                      480    493-494          524


	localparam V_SYNC_TOTAL = 525;
	localparam V_PIXELS     = 480;
	localparam V_SYNC_START = 493;
	localparam V_SYNC_WIDTH =   2;
	localparam H_START 	   = 699;

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

