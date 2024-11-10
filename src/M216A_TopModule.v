// M216A_TopModule.v
// Implement flowchart
// 1. Check allowed strips and choose the least occupied strip
// 2. Check if occupied width + width_i <= 128.
// If yes, go to 3a. If no, go to 3b.
// 3a (width + width_i <= 128). Place program, provide output index, update occupied widths
// 3b (width + width_i > 128). strike_o++, index_x_o = 128, index_y_o = 128
//
// Do NOT Modify This Module's I/O Definition
module M216A_TopModule(
    input  wire       clk_i,
    input  wire       rst_i,

    input  wire [4:0] width_i,
    input  wire [4:0] height_i,
    
    output wire [7:0] index_x_o,
    output wire [7:0] index_y_o,
    output wire [3:0] strike_o
);
    localparam MAX_WIDTH = 128;
    localparam MAX_HEIGHT = 128;
    localparam CYCLES_PER_PROGRAM = 4;

    wire valid_program = (width_i > 0) && (height_i > 0);

    // Cycle counter from 0 to (CYCLES_PER_PROGRAM - 1)
    reg [2:0] counter;
    always @(posedge clk_i) begin
        if(rst_i) begin
            counter <= 2'd0;
        end else if (valid_program) begin
            counter <= (counter >= CYCLES_PER_PROGRAM - 1) ? 0 : counter + 1;
        end
    end

    // Register inputs
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

    // Array of registers to track all 13 strip widths
    reg [7:0] strip_widths [12:0];

    // Map program height h to 3 potential strip IDs
    wire [3:0] strip_id_0, strip_id_1, strip_id_2;
    program_height_to_id program_height_to_id_0 (
        .program_height_i(height_i_reg),
        .strip_id_0_o(strip_id_0),
        .strip_id_1_o(strip_id_1),
        .strip_id_2_o(strip_id_2)
    );

    // Choose best strip ID
    wire [7:0] chosen_strip_width;
    wire [3:0] chosen_strip_id;
    // Registered versions of the wires above
    reg  [7:0] chosen_strip_width_reg;
    reg  [3:0] chosen_strip_id_reg;

    least_strip least_strip_0 (
        .strip_id_0_i(strip_id_0),
        // Assign MAX_WIDTH to illegal strip ID (when ID = 0) so it never gets chosen
        .strip_width_0_i((strip_id_0 == 0) ? MAX_WIDTH[7:0] : strip_widths[strip_id_0 - 1]),

        .strip_id_1_i(strip_id_1),
        // Assign MAX_WIDTH to illegal strip ID (when ID = 0) so it never gets chosen
        .strip_width_1_i((strip_id_1 == 0) ? MAX_WIDTH[7:0] : strip_widths[strip_id_1 - 1]),

        .strip_id_2_i(strip_id_2),
        // Assign MAX_WIDTH to illegal strip ID (when ID = 0) so it never gets chosen
        .strip_width_2_i((strip_id_2 == 0) ? MAX_WIDTH[7:0] : strip_widths[strip_id_2 - 1]),

        .strip_id_o(chosen_strip_id),
        .strip_width_o(chosen_strip_width)
    );

    // Register chosen strip id and width
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

    // Add program to chosen strip and update its width
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

    // Convert chosen strip ID to y position on compute array
    wire [7:0] strip_y_position;
    id_to_y ity_0 (
        .strip_id_i(chosen_strip_id_reg),
        .y_o(strip_y_position)
    );

    // Register outputs
    reg [7:0] index_x_o_reg;
    reg [7:0] index_y_o_reg;
    reg [3:0] strike_o_reg;

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

    // Add extra latency to output to satisfy total 8 clock cycle latency requirement
    localparam extra_latency = 4;

    latency #(
        .LENGTH(extra_latency),
        .WIDTH(8)
    ) latency_x_o (
        .clk(clk_i),
        .rst(rst_i),
        .in(index_x_o_reg),
        .out(index_x_o)
    );

    latency #(
        .LENGTH(extra_latency),
        .WIDTH(8)
    ) latency_y_o (
        .clk(clk_i),
        .rst(rst_i),
        .in(index_y_o_reg),
        .out(index_y_o)
    );

    latency #(
        .LENGTH(extra_latency),
        .WIDTH(4)
    ) latency_strike_o (
        .clk(clk_i),
        .rst(rst_i),
        .in(strike_o_reg),
        .out(strike_o)
    );

endmodule
