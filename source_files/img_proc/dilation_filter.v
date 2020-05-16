module dilation_filter (
	input			   clk,
	input			   rst,
	input			   enable,
	input 	   [8-1:0] input_data,
	output reg		   done,
	output reg [8-1:0] output_data
);

	wire [8-1:0] linebuffer0;
	wire [8-1:0] linebuffer1;
	wire [8-1:0] linebuffer2;
	reg  [8-1:0] Pixel_1, Pixel_2, Pixel_3, Pixel_4, Pixel_5, Pixel_6, Pixel_7, Pixel_8, Pixel_9;

	linebuffer lb_dilation (
		.clken		(enable),
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
			done    <= 1'b0;
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
			done       <= enable;

       		if (enable)
            	output_data <= (Pixel_9 & Pixel_8 & Pixel_7 & Pixel_6 & Pixel_5 & Pixel_4 & Pixel_3 & Pixel_2 & Pixel_1);
        	else
            	output_data <= 8'b0;  
    	end	
	end

endmodule

