module erosion_filter (
	input				clk,
	input				rst,
	input				enable,
	input		[8-1:0]	input_data,
	output	reg			done,
	output	reg	[8-1:0]	output_data
);

    wire [8-1:0] linebuffer0;
    wire [8-1:0] linebuffer1;
    wire [8-1:0] linebuffer2;
    reg  [8-1:0] Pixel_1, Pixel_2, Pixel_3, Pixel_4, Pixel_5, Pixel_6, Pixel_7, Pixel_8, Pixel_9;

    linebuffer lb_erosion   (
        .clken      (enable),
        .clock      (clk),
        .shiftin    (input_data),
        .taps0x     (linebuffer0),
        .taps1x     (linebuffer1),
        .taps2x     (linebuffer2)
    );

    always@(posedge clk, posedge rst) begin
        if(rst) begin
            Pixel_1 <=    0;
            Pixel_2 <=    0;
            Pixel_3 <=    0;
            Pixel_4 <=    0;
            Pixel_5 <=    0;
            Pixel_6 <=    0;
            Pixel_7 <=    0;
            Pixel_8 <=    0;
            Pixel_9 <=    0;
            done    <=    1'b0;
        end else begin        
            Pixel_1    <= Pixel_2;
		    Pixel_2    <= Pixel_3;
		    Pixel_3    <= linebuffer2;
		    Pixel_4    <= Pixel_5;
		    Pixel_5    <= Pixel_6;
		    Pixel_6    <= linebuffer1;
		    Pixel_7    <= Pixel_8;
		    Pixel_8    <= Pixel_9;
		    Pixel_9    <= linebuffer0;
		    done       <= enable;
		
            if (enable)
                output_data <= (Pixel_9 | Pixel_8 | Pixel_7 | Pixel_6 | Pixel_5 | Pixel_4 | Pixel_3 | Pixel_2 | Pixel_1);
            else
                output_data <= 1'b0;  
        end
    end

endmodule

