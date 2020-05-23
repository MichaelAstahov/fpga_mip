module mip_control
(
//* System Signals
    input                clk,           // VGA_CTRL_CLK
    input                rst,           // RST = SW[0]
    input  [18-1 : 0] 	 sw ,		    // Toggle switch[17:0]
    output [9 -1 : 0]  	 led_g,  	    // LED Green[8:0]
	output [18-1 : 0] 	 led_r,  	    // LED Red[17:0]
//* Input Flags	
    input                pll_lock,      // PLL Done
    input                dilation_done, // Dilation Filter Done
    input                erosion_done,  // Erosion Filter Done
//* Output Flags
    output reg           rom_flag,      // Indicator to start read from ROM
    output reg           dilation_en,   // Indicator to start using Filter Blocks
    output reg           erosion_en,    // Indicator to start using Filter Blocks
    output reg           ram_flag,      // Indicator to start write to RAM
    output reg           vga_flag       // Indicator to start read from RAM and VGA block enable
);

    localparam IDLE   = 5'b00001;
    localparam ROM    = 5'b00010;
    localparam FILTER = 5'b00100;
    localparam RAM    = 5'b01000;
    localparam VGA    = 5'b10000;

    reg [6-1 : 0] state;
    reg           fltr_en;

    //* Initial State for Registers
    initial begin
       state       = IDLE;
       rom_flag    = 1'b0;
       fltr_en     = 1'b0;
       dilation_en = 1'b0;
       erosion_en  = 1'b0;
       ram_flag    = 1'b0;
       vga_flag    = 1'b0;
    end

    //* Send switches to red leds.
    assign led_r 	   = sw;
    //* Turn off unused green leds.
	assign led_g[8:6]  = 3'b0;

    //* indicator for reset.
	assign led_g[0] = rst; 
	//* indicator for pll working properly.
    assign led_g[1] = pll_lock;
    //* indicator that rom reading start working.
    assign led_g[2] = rom_flag; 
    //* indicator that the filter start working.
    assign led_g[3] = fltr_en; 
    //* indicator that ram writing start working.
    assign led_g[4] = ram_flag; 
    //* indicator that vga start working.
    assign led_g[5] = vga_flag;


    //* State Machine
    always @(posedge clk, posedge rst) begin
        if (rst) begin
            state    <= IDLE;
            rom_flag <= 1'b0;
            fltr_en  <= 1'b0;
            ram_flag <= 1'b0;
            vga_flag <= 1'b0;
        end else begin
            case (state)

                IDLE: begin
                    if (pll_lock)
                        state    <= ROM;
                end

                ROM: begin
                    rom_flag <= 1'b1;
                    state    <= FILTER;
                end

                FILTER: begin
                    fltr_en <= 1'b1;
                    if (dilation_done || erosion_done) begin
                        //TODO: Fix the logic here.
                        state    <= RAM;
                    end
                end

                RAM: begin
                    ram_flag <= 1'b1;
                    state    <= VGA;
                end
                VGA: begin
                    vga_flag <= 1'b1;
                end

                default: begin
                    state <= IDLE;
                end

            endcase
        end 
    end

    wire [3-1 : 0] filter_ctrl;

    //TODO: Understand why Dilation and Erosion seems to be opposite

    assign filter_ctrl = {fltr_en, sw[17], sw[16]};

    always @(posedge clk, posedge rst) begin
        if (rst) begin
            dilation_en <= 1'b0;
            erosion_en  <= 1'b0;
        end else begin
            case (filter_ctrl)
                3'b0xx: begin
                    dilation_en <= 1'b0;
                    erosion_en  <= 1'b0;
                end
                3'b101: begin
                    dilation_en <= 1'b0;
                    erosion_en  <= 1'b1;
                end
                3'b110: begin
                    dilation_en <= 1'b1;
                    erosion_en  <= 1'b0;
                end
                3'b111: begin
                    dilation_en <= 1'b0;
                    erosion_en  <= 1'b0;  
                end
                default: begin
                    dilation_en <= 1'b0;
                    erosion_en  <= 1'b0; 
                end
            endcase
        end
    end





endmodule