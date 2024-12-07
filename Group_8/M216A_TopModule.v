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
    localparam OUTPUT_LATENCY = 8;

    wire valid_program = (width_i > 0) && (height_i > 0);
    wire output_valid;
    latency #(
        .LENGTH(OUTPUT_LATENCY),
        .WIDTH(1)
    ) latency_output_valid (
        .clk(clk_i),
        .rst(rst_i),
        .in(valid_program),
        .out(output_valid)
    );

    wire active = valid_program | output_valid;

    // counter cycles from 0 to (CYCLES_PER_PROGRAM - 1)
    reg [2:0] counter;
    // program_cycle cycles from 1 to CYCLES_PER_PROGRAM
    // only when the module is active
    wire [2:0] program_cycle = counter + active;
    always @(posedge clk_i) begin
        if(rst_i) begin
            counter <= 0;
        end else if (active) begin
            counter <= (counter >= CYCLES_PER_PROGRAM - 1) ? 0 : counter + 1;
        end
    end

    // Register inputs
    reg [4:0] width_i_reg, height_i_reg;

    always @(posedge clk_i) begin
        if(rst_i) begin
            width_i_reg <= 5'b0;
            height_i_reg <= 5'b0;
        end else if (program_cycle == 1) begin
            width_i_reg <= width_i;
            height_i_reg <= height_i;
        end
    end

    // Add extra latency to input to satisfy total 8 clock cycle latency requirement
    wire [4:0] delayed_width_i_reg, delayed_height_i_reg;
    latency #(
        .LENGTH(2),
        .WIDTH(10)
    ) latency_width_i (
        .clk(clk_i),
        .rst(rst_i),
        .in({width_i_reg, height_i_reg}),
        .out({delayed_width_i_reg, delayed_height_i_reg})
    );
    // hold width until needed later
    wire [4:0] extra_delayed_width_i_reg;
    latency #(
        .LENGTH(1),
        .WIDTH(5)
    ) latency_delayed_width_i_reg (
        .clk(clk_i),
        .rst(rst_i),
        .in(delayed_width_i_reg),
        .out(extra_delayed_width_i_reg)
    );

    // Array of registers to track all 13 strip widths + extra register to store MAX_WIDTH
    // width of strip i is tracked by strip_widths[i]
    // strip_widths[0] = MAX_WIDTH
    reg [7:0] strip_widths [13:0];

    // Map program height h to 3 potential strip IDs
    wire [3:0] strip_id_0, strip_id_1, strip_id_2;
    reg  [3:0] strip_id_0_reg, strip_id_1_reg, strip_id_2_reg; // 1 cycle latency
    program_height_to_id program_height_to_id_0 (
        .program_height_i(delayed_height_i_reg),
        .strip_id_0_o(strip_id_0),
        .strip_id_1_o(strip_id_1),
        .strip_id_2_o(strip_id_2)
    );

    always @(posedge clk_i) begin
        if(rst_i) begin
            strip_id_0_reg <= 4'b0;
            strip_id_1_reg <= 4'b0;
            strip_id_2_reg <= 4'b0;
        end else if (program_cycle == 4) begin
            strip_id_0_reg <= strip_id_0;
            strip_id_1_reg <= strip_id_1;
            strip_id_2_reg <= strip_id_2;
        end
    end

    // Choose best strip ID
    wire [3:0] chosen_strip_id_reg;
    wire [7:0] chosen_strip_width_reg;

    least_strip #(
        .MAX_WIDTH(MAX_WIDTH)
    ) least_strip_0 (
        .clk_i(clk_i),
        .rst_i(rst_i),

        .strip_id_0_i(strip_id_0_reg),
        .strip_width_0_i(strip_widths[strip_id_0_reg]),

        .strip_id_1_i(strip_id_1_reg),
        .strip_width_1_i(strip_widths[strip_id_1_reg]),

        .strip_id_2_i(strip_id_2_reg),
        .strip_width_2_i(strip_widths[strip_id_2_reg]),

        // registered output
        .strip_id_o(chosen_strip_id_reg),
        .strip_width_o(chosen_strip_width_reg)
    );

    wire [7:0] new_width = chosen_strip_width_reg + extra_delayed_width_i_reg;
    reg  [7:0] new_width_reg;
    always @(posedge clk_i) begin
        if(rst_i) begin
            new_width_reg <= MAX_WIDTH;
        end else if (program_cycle == 3) begin
            new_width_reg <= new_width;
        end
    end
    wire place_program = (chosen_strip_id_reg != 0) & (new_width_reg <= MAX_WIDTH);

    // Add program to chosen strip and update its width
    integer i;
    always @(posedge clk_i) begin
        if(rst_i) begin
            for (i = 1; i <= 13; i=i+1) begin
                strip_widths[i] <= 8'b0;
            end
            // Assign MAX_WIDTH to illegal strip ID (when ID = 0)
            strip_widths[0] <= MAX_WIDTH[7:0];
        end else if (program_cycle == 4) begin
            if (place_program) begin
                strip_widths[chosen_strip_id_reg] <= new_width_reg;
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
        end else if (program_cycle == 4) begin
            if (place_program) begin
                index_x_o_reg <= chosen_strip_width_reg;
                index_y_o_reg <= strip_y_position;
            end else if (chosen_strip_id_reg != 0) begin
                index_x_o_reg <= MAX_WIDTH;
                index_y_o_reg <= MAX_HEIGHT;
                strike_o_reg <= strike_o_reg + 1;
            end
        end
    end

    assign index_x_o = index_x_o_reg;
    assign index_y_o = index_y_o_reg;
    assign strike_o = strike_o_reg;

endmodule
