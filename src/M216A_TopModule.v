`timescale 1ns / 100ps

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
    localparam CYCLES_PER_PROGRAM = 4;

    wire valid_program = (width_i > 0) && (height_i > 0);

    // count from 0 to (CYCLES_PER_PROGRAM - 1)
    reg [2:0] counter;
    always @(posedge clk_i) begin
        if(rst_i) begin
            counter <= 2'd0;
        end else if (valid_program) begin
            counter <= (counter >= CYCLES_PER_PROGRAM - 1) ? 0 : counter + 1;
        end
    end

    // register inputs
    reg [4:0] width_i_reg;
    reg [4:0] height_i_reg;

    always @(posedge clk_i) begin
        if(rst_i) begin
            width_i_reg <= 5'b0;
            height_i_reg <= 5'b0;
        end else if (counter == 0) begin
            width_i_reg <= width_i;
            height_i_reg <= height_i;
        end
    end

    // create an array to keep track of strip widths
    reg [7:0] strip_widths [12:0];
    
    // strip IDs corresponding to height h
    wire [3:0] strip_id_0, strip_id_1, strip_id_2;

    // map program height h to eligible strip IDs
    program_height_to_id phti (
        .program_height_i(height_i_reg),
        .strip_id_0_o(strip_id_0),
        .strip_id_1_o(strip_id_1),
        .strip_id_2_o(strip_id_2)
    );

    wire [7:0] chosen_strip_width;
    wire [3:0] chosen_strip_id;
    // registered versions of the wires above
    reg  [7:0] chosen_strip_width_reg;
    reg  [3:0] chosen_strip_id_reg;

    least_strip ls_0 (
        .strip_id_0_i(strip_id_0),
        .strip_width_0_i((strip_id_0 == 0) ? MAX_WIDTH[7:0] : strip_widths[strip_id_0 - 1]),

        .strip_id_1_i(strip_id_1),
        .strip_width_1_i((strip_id_1 == 0) ? MAX_WIDTH[7:0] : strip_widths[strip_id_1 - 1]),

        .strip_id_2_i(strip_id_2),
        .strip_width_2_i((strip_id_2 == 0) ? MAX_WIDTH[7:0] : strip_widths[strip_id_2 - 1]),

        .strip_id_o(chosen_strip_id),
        .strip_width_o(chosen_strip_width)
    );

    // register chosen strip id and width
    always @(posedge clk_i) begin
        if(rst_i) begin
            chosen_strip_id_reg <= 4'b0;
            chosen_strip_width_reg <= 8'b0;
        end else if (counter == 1) begin
            chosen_strip_id_reg <= chosen_strip_id;
            chosen_strip_width_reg <= chosen_strip_width;
        end
    end

    wire place_program = (chosen_strip_width_reg + width_i_reg) <= MAX_WIDTH;

    // add program to strip and update strip width
    always @(posedge clk_i) begin
        if(rst_i) begin
            for (integer i = 0; i < 13; i=i+1) begin
                strip_widths[i] <= 8'b0;
            end
        end else if (counter == 2) begin
            if (place_program) begin
                strip_widths[chosen_strip_id - 1] <= chosen_strip_width_reg + width_i_reg;
            end
        end
    end

    // register outputs
    reg [7:0] index_x_o_reg;
    reg [7:0] index_y_o_reg;
    reg [3:0] strike_o_reg;
    wire [7:0] strip_y_position;

    id_to_y ity_0 (
        .strip_id_i(chosen_strip_id_reg),
        .y_o(strip_y_position)
    );

    always @(posedge clk_i) begin
        if(rst_i) begin
            index_x_o_reg <= 8'b0;
            index_y_o_reg <= 8'b0;
            strike_o_reg <= 4'b0;
        end else if (counter == 3) begin
            if (place_program) begin
                index_x_o_reg <= chosen_strip_width_reg;
                index_y_o_reg <= strip_y_position;
            end else begin
                index_x_o_reg <= MAX_WIDTH;
                index_y_o_reg <= MAX_HEIGHT;
                strike_o_reg <= strike_o_reg + 1;
            end
        end
    end

    localparam additional_latency = 4;

    latency #(
        .LENGTH(additional_latency),
        .WIDTH(8)
    ) delay_x_o (
        .clk(clk_i),
        .rst(rst_i),
        .in(index_x_o_reg),
        .out(index_x_o)
    );

    latency #(
        .LENGTH(additional_latency),
        .WIDTH(8)
    ) delay_y_o (
        .clk(clk_i),
        .rst(rst_i),
        .in(index_y_o_reg),
        .out(index_y_o)
    );

    latency #(
        .LENGTH(additional_latency),
        .WIDTH(4)
    ) delay_strike_o (
        .clk(clk_i),
        .rst(rst_i),
        .in(strike_o_reg),
        .out(strike_o)
    );

endmodule
