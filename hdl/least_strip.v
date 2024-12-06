// least_strip.v
// Given 3 strip IDs and their corresponding widths, output the strip ID with the smallest width
// In case of tie, choose lower indexed ID/width (i.e. id/width_0 < id/width_1 < id/width_2)
// IMPORTANT: Latency from input to output is 2 clock cycles (output is valid 2 clock cycles after input)
module least_strip #(
    parameter MAX_WIDTH = 128
) (
    input  wire       clk_i,
    input  wire       rst_i,

    input  wire [3:0] strip_id_0_i,
    input  wire [7:0] strip_width_0_i,

    input  wire [3:0] strip_id_1_i,
    input  wire [7:0] strip_width_1_i,
    
    input  wire [3:0] strip_id_2_i,
    input  wire [7:0] strip_width_2_i,

    output reg [3:0] strip_id_o,
    output reg [7:0] strip_width_o
);
    reg id_0_smallest_reg, id_1_smallest_reg, id_2_smallest_reg;

    always @(posedge clk_i) begin
        if(rst_i) begin
            id_0_smallest_reg <= 1'b0;
            id_1_smallest_reg <= 1'b0;
            id_2_smallest_reg <= 1'b0;

            strip_id_o <= 4'b0;
            strip_width_o <= MAX_WIDTH;
        end else begin
            id_0_smallest_reg <= (strip_width_0_i <= strip_width_1_i) && (strip_width_0_i <= strip_width_2_i);
            id_1_smallest_reg <= (strip_width_1_i <= strip_width_0_i) && (strip_width_1_i <= strip_width_2_i);
            id_2_smallest_reg <= (strip_width_2_i <= strip_width_0_i) && (strip_width_2_i <= strip_width_1_i);

            if (id_0_smallest_reg) begin
                strip_id_o <= strip_id_0_i;
                strip_width_o <= strip_width_0_i;
            end else if (id_1_smallest_reg) begin
                strip_id_o <= strip_id_1_i;
                strip_width_o <= strip_width_1_i;
            end else if (id_2_smallest_reg) begin
                strip_id_o <= strip_id_2_i;
                strip_width_o <= strip_width_2_i;
            end else begin
                strip_id_o <= 4'b0; // set to 4'b0 if not synthesizable
                strip_width_o <= MAX_WIDTH; // set to 8'b11111111 if not synthesizable
            end
        end
    end

endmodule
