module dilation_filter (
	input			 clk,
	input			 rst,
	input 	   [7:0] input_data,
	output reg [7:0] output_data
);

	wire [7:0] linebuffer0;
	wire [7:0] linebuffer1;
	wire [7:0] linebuffer2;
	reg  [7:0] Pixel_1, Pixel_2, Pixel_3, Pixel_4, Pixel_5, Pixel_6, Pixel_7, Pixel_8, Pixel_9;

	linebuffer b0 (
		.clken		(1'b1),
		.clock		(clk),
		.shiftin	(input_data),
		.taps0x		(linebuffer0),
		.taps1x		(linebuffer1),
		.taps2x		(linebuffer2)
	);

	always@(posedge clk, posedge rst) 
	begin
		if(rst) begin
			Pixel_1 <= 8'hff;
			Pixel_2 <= 8'hff;
			Pixel_3 <= 8'hff;
			Pixel_4 <= 8'hff;
			Pixel_5 <= 8'hff;
			Pixel_6 <= 8'hff;
			Pixel_7 <= 8'hff;
			Pixel_8 <= 8'hff;
			Pixel_9 <= 8'hff;
		end else begin    
			Pixel_1 <= Pixel_2;
			Pixel_2 <= Pixel_3;
			Pixel_3 <= linebuffer2;
			Pixel_4 <= Pixel_5;
			Pixel_5 <= Pixel_6;
			Pixel_6 <= linebuffer1;
			Pixel_7 <= Pixel_8;
			Pixel_8 <= Pixel_9;
			Pixel_9 <= linebuffer0;
			output_data <= (Pixel_9 & Pixel_8 & Pixel_7 & Pixel_6 & Pixel_5 & Pixel_4 & Pixel_3 & Pixel_2 & Pixel_1);
		end
	end
endmodule

