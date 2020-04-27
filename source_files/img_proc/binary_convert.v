module binary_convert (
	input					clk,
	input					rstn,
	input	     [9:0]	input_data,
	input		  [9:0]	thresh,
	output reg [9:0]	output_data
);

	always @ (posedge clk, negedge rstn) begin
		if (!rstn) begin
			output_data <= 10'h0000000000;
		end else begin
			output_data <= (input_data > thresh) ? 1023 : 0;
		end
	end
endmodule
