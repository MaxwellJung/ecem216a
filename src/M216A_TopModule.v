`timescale 1ns / 100ps

//Do NOT Modify This Module
module P1_Reg_8_bit (DataIn, DataOut, rst, clk);

    input [7:0] DataIn;
    output [7:0] DataOut;
    input rst;
    input clk;
    reg [7:0] DataReg;
   
    always @(posedge clk)
  	if(rst)
            DataReg <= 8'b0;
        else
            DataReg <= DataIn;
    assign DataOut = DataReg;
endmodule

//Do NOT Modify This Module
module P1_Reg_5_bit (DataIn, DataOut, rst, clk);

    input [4:0] DataIn;
    output [4:0] DataOut;
    input rst;
    input clk;
    reg [4:0] DataReg;
    
    always @(posedge clk)
        if(rst)
            DataReg <= 5'b0;
        else
            DataReg <= DataIn;
    assign DataOut = DataReg;
endmodule

//Do NOT Modify This Module
module P1_Reg_4_bit (DataIn, DataOut, rst, clk);

    input [3:0] DataIn;
    output [3:0] DataOut;
    input rst;
    input clk;
    reg [3:0] DataReg;
    
    always @(posedge clk)
        if(rst)
            DataReg <= 4'b0;
        else
            DataReg <= DataIn;
    assign DataOut = DataReg;
endmodule

//Do NOT Modify This Module's I/O Definition
module M216A_TopModule(
    input  wire       clk_i,
    input  wire       rst_i,

    input  wire [4:0] width_i,
    input  wire [4:0] height_i,
    
    output wire [7:0] index_x_o,
    output wire [7:0] index_y_o,
    output wire [3:0] strike_o
);

//Add your code below 
//Make sure to Register the outputs using the Register modules given above

// [TODO] implement flowchart
// 1. Check allowed strips and choose the least occupied strip
// 2. Check if occupied width + width_i <= 128.
// If yes, go to 3a. If no, go to 3b.
// 3a (width + width_i <= 128). Place program, provide output index, update occupied widths
// 3b (width + width_i > 128). strike_o++, index_x_o = 128, index_y_o = 128

    localparam MAX_WIDTH = 128;
    localparam MAX_HEIGHT = 128;

    // register outputs
    reg [7:0] index_x_o_reg;
    reg [7:0] index_y_o_reg;
    reg [3:0] strike_o_reg;

    // create an array to track strip widths
    reg [7:0] strip_widths [12:0]; // 8 bits required to encode width in range [0,128], total 13 width registers

    wire [3:0] strip_id_h0; // 4 bits to encode strip ID in range [1,13]
    wire [3:0] strip_id_h1; // 4 bits to encode strip ID in range [1,13]
    wire [3:0] zstrip_id_h0 = strip_id_h0 - 1; // 4 bits to encode zero-indexed strip ID (zstrip_id) in range [0,12]
    wire [3:0] zstrip_id_h1 = strip_id_h1 - 1; // 4 bits to encode zero-indexed strip ID (zstrip_id) in range [0,12]

    // map height y to strip ID
    height_to_id hti_0 (
        .program_height_i(height_i),
        .strip_id_o(strip_id_h0)
    );
    // map height y+1 to strip ID
    height_to_id hti_1 (
        .program_height_i(height_i + 5'b1),
        .strip_id_o(strip_id_h1)
    );

    // [TODO] compare widths of allowed strips and choose best one
    wire [7:0] occupied_width_h0 = strip_widths[zstrip_id_h0];
    wire [7:0] occupied_width_h1 = strip_widths[zstrip_id_h1];
    wire [7:0] least_occupied_strip = (occupied_width_h0 <= occupied_width_h1) ? strip_id_h0 : strip_id_h1;
    wire [3:0] least_occupied_zstrip = least_occupied_strip - 1; // 4 bits to encode zero-indexed strip ID (zstrip_id) in range [0,12]

    always @(posedge clk_i)
        if(rst_i) begin
            for (integer i = 0; i < 13; i=i+1) begin
                strip_widths[i] <= 8'b0;
            end
        end else begin
            strip_widths[least_occupied_zstrip] <= strip_widths[least_occupied_zstrip] + width_i;
        end

    always @(posedge clk_i)
        if(rst_i) begin
            index_x_o_reg <= 8'b0;
            index_y_o_reg <= 8'b0;
            strike_o_reg <= 4'b0;
        end else begin
            index_x_o_reg <= 8'b0;
            index_y_o_reg <= 8'b0;
            strike_o_reg <= 4'b0;
        end

    assign index_x_o = index_x_o_reg;
    assign index_y_o = index_y_o_reg;
    assign strike_o = strike_o_reg;

endmodule

module height_to_id (
    input  wire [4:0] program_height_i, // 5 bits to encode program height in range [4,16]
    output reg [3:0] strip_id_o // 4 bits to encode strip ID in range [1,13]. "reg" instead of "wire" because otherwise compiler complains
);
    // Implement function f: height_i -> strip_id
    // Combinational logic for now, but might be faster to hardcode lookup table idk

    always @(*) begin
        if ((9 <= program_height_i) && (program_height_i <= 12)) begin // heights 9~12
            strip_id_o = 2*program_height_i-15; // strip ID 3,5,7,9
        end else if ((4 <= program_height_i) && (program_height_i <= 7)) begin // heights 4~7
            strip_id_o = -2*program_height_i+18; // strip ID 10,8,6,4
        end else begin // heights 8 and 13
            strip_id_o = 0; // strip ID 1,2,11,12,13 (for heights 8 and 13) are exceptions (handle later)
        end
    end
endmodule
