module memory (	
//*	System Signals
	input			     rst,
	input			     clk,
//* Input Flags
    input                rom_flag,
    input                ram_flag,
    input                vga_flag,
//* Input Data
    input 	   [8-1:0]	 fltr_img,
	input	   [19-1:0]  vga_addr,
//* Output Data
    output     [8-1:0]   orig_img,
	output reg [8-1:0]   red,
	output reg [8-1:0]   green,
	output reg [8-1:0]   blue
	);
	

//! Read the input image from ROM.
    reg  [16-1:0]  rom_addr;
    wire [8-1:0]   rom_data;
    reg  [8-1:0]   rom_row;
    initial begin
        rom_addr = 16'b0;
        rom_row  = 8'b0;
    end        

    always @(posedge clk or posedge rst) begin
		if(rst) begin
			rom_addr	<=	16'b0;
		end else begin
            if (rom_flag) begin
			    rom_addr	<=	rom_addr+1'b1;
            end
		end
	end

    always @(posedge clk or posedge rst) begin
		if(rst) begin
			rom_row		<=	8'b0;
		end else begin
            if (rom_flag) begin
			    rom_row	  	<=	rom_data;
            end
		end
	end

    //* Output 8bit pack of data to filter
    assign orig_img = rom_row;
    
	img_rom	img_rom_inst (
		.address (rom_addr),
		.clock 	 (clk),
		.q 		 (rom_data)
	);

//!


//! Write&Read RAM.
    //* Write the fetched ROM data to RAM, 
    //* next Read from RAM the data to VGA Block.

    //* Write to RAM Signals
    reg  [16-1:0]  ram_write_addr;
    reg  [8-1:0]   ram_row;
    //* Read from RAM Signals
    wire [8-1:0]   ram_data;
    reg  [3-1:0]   addr_dly_reg1;
	reg  [3-1:0]   addr_dly_reg2;

    initial begin
        ram_write_addr    = 16'b0;
        ram_row           = 8'b0;
        addr_dly_reg1     = 3'b0;
        addr_dly_reg2     = 3'b0;
    end  



    always @(posedge clk or posedge rst) begin
		if(rst) begin
			ram_write_addr	<=	16'b0;
		end else begin
            if (ram_flag)
			    ram_write_addr	<=	ram_write_addr+1'b1;
		end
	end


    always @(posedge clk or posedge rst) begin
		if(rst) begin
			ram_row		<=	8'b0;
		end else begin
            if (ram_flag)
			    ram_row	  	<=	fltr_img;
		end
	end



    //* Read from RAM to VGA Block:
	always @(posedge clk or posedge rst) begin
		if(rst) begin
			red			    <=	0;
			green			<=	0;
			blue			<=	0;
			addr_dly_reg1	<=	0;
			addr_dly_reg2	<=	0;
		end else begin
            if (vga_flag) begin
		    	addr_dly_reg1	<=	vga_addr[2:0];
			    addr_dly_reg2	<=	~addr_dly_reg1;
			    red	  		    <=	ram_data[addr_dly_reg2]   ? 8'hff : 8'b0;
			    green			<=	ram_data[addr_dly_reg2]	  ? 8'hff : 8'b0;
			    blue			<=	ram_data[addr_dly_reg2]   ? 8'hff : 8'b0;
            end
		end
	end


    img_ram	img_ram_inst (
	    .clock      (clk),
	    .data       (ram_row),
	    .rdaddress  (vga_addr[18:3]),
	    .rden       (vga_flag),
	    .wraddress  (ram_write_addr),
	    .wren       (ram_flag),
	    .q          (ram_data)
	);
//!


endmodule