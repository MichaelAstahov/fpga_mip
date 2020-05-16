module memory (	
//*	Inputs
	input			  rst,
	input			  clk,
	input	   [18:0] vga_addr,
//*	Read Outside
	output reg [7:0]  o_red,
	output reg [7:0]  o_green,
	output reg [7:0]  o_blue
	);
	

	reg  [2:0] addr_dly_reg1;
	reg  [2:0] addr_dly_reg2;
	wire [7:0] rom_data;


//* vga_addr is 19bit number created from the vga block:
//* vga_addr = coord_x + coord_y*640.
//* 15 MSB bits going to the ROM address
//* if ROM address=2, we read from row 2 in the ROM.
//* 3 LSB bits controlling the fetching of the 8bit data 
//* from every ROM row.
//* example:

//*       rom	 dly
//*      ----- ------
//* 0  :    0  |  0
//* 1  :    0  |  1
//* 2  :    0  |  2
//* 3  :    0  |  3
//* 4  :    0  |  4
//* 5  :    0  |  5
//* 6  :    0  |  6
//* 7  :    0  |  7

//* 8  : 	1  |  0
//* 9  : 	1  |  1
//* 10 : 	1  |  2
//* 11 : 	1  |  3
//* 12 : 	1  |  4
//* 13 : 	1  |  5
//* 14 : 	1  |  6
//* 15 : 	1  |  7

//* 16 : 	2  |  0
//* 17 : 	2  |  1
//* 18 : 	2  |  2
//* 19 : 	2  |  3
//* 20 : 	2  |  4
//* 21 : 	2  |  5
//* 22 : 	2  |  6
//* 23 : 	2  |  7

	always @(posedge clk or posedge rst) begin
		if(rst) begin
			o_red			<=	0;
			o_green			<=	0;
			o_blue			<=	0;
			addr_dly_reg1	<=	0;
			addr_dly_reg2	<=	0;
		end else begin
			addr_dly_reg1	<=	vga_addr[2:0];
			addr_dly_reg2	<=	~addr_dly_reg1;
			o_red	  		<=	rom_data[addr_dly_reg2]   ? 8'hff : 8'b0;
			o_green			<=	rom_data[addr_dly_reg2]	  ? 8'hff : 8'b0;
			o_blue			<=	rom_data[addr_dly_reg2]   ? 8'hff : 8'b0;
		end
	end


	img_rom	img_rom_inst (
		.address (vga_addr[18:3]),
		.clock 	 (clk),
		.q 		 (rom_data)
	);

endmodule