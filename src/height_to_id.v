// height_to_id.v
// Maps strip height to corresponding strip id (function f: strip_height -> strip_id)
// Heights corresponding to multiple strip IDs will output strip ID 0 (considered as error)
// Combinational logic for now, but might be faster to hardcode lookup table idk
module height_to_id (
    input  wire [4:0] strip_height_i, // 5 bits to encode program height in range [4,16]
    output reg  [3:0] strip_id_o // 4 bits to encode strip ID in range [1,13]. "reg" instead of "wire" because otherwise compiler complains
);
    always @(*) begin
        if ((9 <= strip_height_i) && (strip_height_i <= 12)) begin // heights 9~12
            strip_id_o = 2*strip_height_i-15; // strip ID 3,5,7,9
        end else if ((4 <= strip_height_i) && (strip_height_i <= 7)) begin // heights 4~7
            strip_id_o = -2*strip_height_i+18; // strip ID 10,8,6,4
        end else begin // heights 8 and 13~16 are exceptions
            strip_id_o = 4'd0; // throw error; handled by outer module
        end
    end
endmodule
