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

    // register outputs
    reg [7:0] index_x_o_reg;
    reg [7:0] index_y_o_reg;
    reg [3:0] strike_o_reg;

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
