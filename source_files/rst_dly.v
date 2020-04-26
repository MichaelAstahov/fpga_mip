module rst_dly (
	input clk,
	input irst,
	output reg orst
	);

	reg	[19:0] count;

	always@(posedge clk or negedge irst) begin
		if(!irst) begin
			count	<=	20'b0;
			orst	<=	1'b0;
		end else begin
			if(count!=20'hFFFFF)
				count	<=	count+1;
			if(count>=32'hFFFFF)
				orst	<=	1;
		end
	end

endmodule