// least_strip.v
// Given 3 strip IDs and their corresponding widths, output the strip ID with the smallest width
module least_strip (
    input  wire [3:0] strip_id_0_i,
    input  reg  [7:0] strip_width_0_i,

    input  wire [3:0] strip_id_1_i,
    input  reg  [7:0] strip_width_1_i,
    
    input  wire [3:0] strip_id_2_i,
    input  reg  [7:0] strip_width_2_i,

    output reg  [3:0] strip_id_o,
    output reg  [7:0] strip_width_o
);

    always @(*) begin
        if ((strip_width_0_i <= strip_width_1_i) && (strip_width_0_i <= strip_width_2_i)) begin
            strip_id_o <= strip_id_0_i;
            strip_width_o <= strip_width_0_i;
        end else if ((strip_width_1_i <= strip_width_0_i) && (strip_width_1_i <= strip_width_2_i)) begin
            strip_id_o <= strip_id_1_i;
            strip_width_o <= strip_width_1_i;
        end else if ((strip_width_2_i <= strip_width_0_i) && (strip_width_2_i <= strip_width_1_i)) begin
            strip_id_o <= strip_id_2_i;
            strip_width_o <= strip_width_2_i;
        end else begin
            strip_id_o <= 4'bXXXX;
            strip_width_o <= 8'bXXXXXXXX;
        end
    end

endmodule
