// strip_id_to_y.v
// Maps strip ID to y position on the compute array (f: strip_id -> y_position)
// Combinational logic for now, but might be faster to hardcode lookup table idk
module id_to_y (
    input  wire [3:0] strip_id_i, // 4 bits to encode strip ID in range [1,13].
    output reg  [7:0] y_o // 8 bits to encode y position in range [0,128]. "reg" instead of "wire" because otherwise compiler complains
);
    always @(*) begin
        if ((1 <= strip_id_i) && (strip_id_i <= 11)) begin // heights 9~12
            if (strip_id_i[0] == 1'b1) begin // odd numbered strip ID
                y_o = 8 * (strip_id_i - 1);
            end else begin
                y_o = 8 * (strip_id_i) - (9 - (strip_id_i >> 1));
            end
        end else begin
            y_o = 16 * strip_id_i + 92;
        end
    end
endmodule
