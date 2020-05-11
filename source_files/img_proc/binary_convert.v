module binary_convert (
	input				clk,
	input				rst,
	input	   [7:0]	input_data,
	input	   [7:0]	thresh,
	output reg [7:0]	output_data
);

	always @(posedge clk, posedge rst) begin
		if (rst) begin
			output_data <= 8'h00;
		end else begin
			output_data <= (input_data > thresh) ? 255 : 0;
		end
	end
endmodule
