module erosion_filter (
	input						CLOCK,
	input						RESET_N,
	input						iDVAL,
	input				[9:0]	input_data,
	output	reg			oDVAL,
	output	reg	[9:0]	output_data
);

wire [9:0] Line0;
wire [9:0] Line1;
wire [9:0] Line2;
reg  [9:0] Pixel_1, Pixel_2, Pixel_3, Pixel_4, Pixel_5, Pixel_6, Pixel_7, Pixel_8, Pixel_9;

LineBuffer_dilation b0    (
  .clken(iDVAL),
  .clock(CLOCK),
  .shiftin(input_data),
  .taps0x(Line0),
  .taps1x(Line1),
  .taps2x(Line2)
);

always@(posedge CLOCK, negedge RESET_N) begin
    if(!RESET_N) begin
        Pixel_1 <=    0;
        Pixel_2 <=    0;
        Pixel_3 <=    0;
        Pixel_4 <=    0;
        Pixel_5 <=    0;
        Pixel_6 <=    0;
        Pixel_7 <=    0;
        Pixel_8 <=    0;
        Pixel_9 <=    0;
        oDVAL <= 1'b0;
    end
    else begin        
        Pixel_1    <= Pixel_2;
		Pixel_2    <= Pixel_3;
		Pixel_3    <= Line2;
		Pixel_4    <= Pixel_5;
		Pixel_5    <= Pixel_6;
		Pixel_6    <= Line1;
		Pixel_7    <= Pixel_8;
		Pixel_8    <= Pixel_9;
		Pixel_9    <= Line0;
		oDVAL <= iDVAL;
		
    if (iDVAL)
        output_data <= (Pixel_9 | Pixel_8 | Pixel_7 | Pixel_6 | Pixel_5 | Pixel_4 | Pixel_3 | Pixel_2 | Pixel_1);
    else
        output_data <= 1'b0;  
    end
end

endmodule

