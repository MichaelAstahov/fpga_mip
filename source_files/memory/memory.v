module memory (	
//	Inputs
	input	rstn,
	input	i_vga_clk,
	input	[18:0] i_vga_addr,
//	Read Outside
	output reg [7:0] o_red,
	output reg [7:0] o_green,
	output reg [7:0] o_blue
	);
	
//	Internal Registers/Wires
	reg  [2:0] addr_dly_reg1;
	reg  [2:0] addr_dly_reg2;
	wire [7:0] rom_data;

//	Logic Blocks
	always @(posedge i_vga_clk or negedge rstn) begin
		if(!rstn) begin
			o_red			<=	0;
			o_green			<=	0;
			o_blue			<=	0;
			addr_dly_reg1	<=	0;
			addr_dly_reg2	<=	0;
		end else begin
			addr_dly_reg1	<=	i_vga_addr[2:0];
			addr_dly_reg2	<=	~addr_dly_reg1;
			o_red	  		<=	rom_data[addr_dly_reg2]   ? 8'hff : 8'b0;
			o_green			<=	rom_data[addr_dly_reg2]	  ? 8'hff : 8'b0;
			o_blue			<=	rom_data[addr_dly_reg2]   ? 8'hff : 8'b0;
		end
	end

//	Instantiation	
	img_rom	img_rom_inst (
		.address (i_vga_addr[18:3]),
		.clock 	 (i_vga_clk),
		.q 		 (rom_data)
	);

endmodule