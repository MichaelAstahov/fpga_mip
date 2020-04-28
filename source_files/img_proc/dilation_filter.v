module dilation_filter (
	input			 clk,
	input			 rst,
	input 	  [9:0]  input_data,
	output reg [9:0] output_data
);

	wire [9:0] linebuffer0;
	wire [9:0] linebuffer1;
	wire [9:0] linebuffer2;
	reg  [9:0] Pixel_1, Pixel_2, Pixel_3, Pixel_4, Pixel_5, Pixel_6, Pixel_7, Pixel_8, Pixel_9;

	linebuffer b0 (
		.clken(1'b1),
		.clock(clk),
		.shiftin(input_data),
		.taps0x(linebuffer0),
		.taps1x(linebuffer1),
		.taps2x(linebuffer2)
	);

	always@(posedge clk, posedge rst) 
	begin
		if(rst) begin
			Pixel_1 <= 10'b1111111111;
			Pixel_2 <= 10'b1111111111;
			Pixel_3 <= 10'b1111111111;
			Pixel_4 <= 10'b1111111111;
			Pixel_5 <= 10'b1111111111;
			Pixel_6 <= 10'b1111111111;
			Pixel_7 <= 10'b1111111111;
			Pixel_8 <= 10'b1111111111;
			Pixel_9 <= 10'b1111111111;
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

