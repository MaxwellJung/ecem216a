// least_strip.v
// Given 3 strip IDs and their corresponding widths, output the strip ID with the smallest width
module least_strip (
    input  wire [3:0] strip_id_i_0,
    input  reg  [7:0] strip_width_i_0,

    input  wire [3:0] strip_id_i_1,
    input  reg  [7:0] strip_width_i_1,
    
    input  wire [3:0] strip_id_i_2,
    input  reg  [7:0] strip_width_i_2,

    output reg  [3:0] strip_id_o,
    output reg  [7:0] strip_width_o
);

    always @(*) begin
        if ((strip_width_i_0 <= strip_width_i_1) && (strip_width_i_0 <= strip_width_i_2)) begin
            strip_id_o <= strip_id_i_0;
            strip_width_o <= strip_width_i_0;
        end else if ((strip_width_i_1 <= strip_width_i_0) && (strip_width_i_1 <= strip_width_i_2)) begin
            strip_id_o <= strip_id_i_1;
            strip_width_o <= strip_width_i_1;
        end else if ((strip_width_i_2 <= strip_width_i_0) && (strip_width_i_2 <= strip_width_i_1)) begin
            strip_id_o <= strip_id_i_2;
            strip_width_o <= strip_width_i_2;
        end else begin
            strip_id_o <= 4'bXXXX;
            strip_width_o <= 8'bXXXXXXXX;
        end
    end

endmodule
