// height_to_id.v
// Maps strip height to corresponding strip IDs (function f: strip_height -> strip_id)
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

// Maps program height to maximum of three elligible strip IDs (function f: strip_height -> {strip_id_0, strip_id_1, strip_id_2})
module program_height_to_id (
    input  wire [4:0] program_height_i, // 5 bits to encode program height in range [4,16]
    output reg  [3:0] strip_id_0_o, // 4 bits to encode strip ID in range [1,13]. "reg" instead of "wire" because otherwise compiler complains
    output reg  [3:0] strip_id_1_o, // 4 bits to encode strip ID in range [1,13]. "reg" instead of "wire" because otherwise compiler complains
    output reg  [3:0] strip_id_2_o // 4 bits to encode strip ID in range [1,13]. "reg" instead of "wire" because otherwise compiler complains
);
    // strip ID corresponding to height h
    wire [3:0] strip_id_h0;
    // strip ID corresponding to height (h+1)
    wire [3:0] strip_id_h1;

    // map height h to strip ID
    height_to_id hti_0 (
        .strip_height_i(program_height_i),
        .strip_id_o(strip_id_h0)
    );
    // map height h+1 to strip ID
    height_to_id hti_1 (
        .strip_height_i(program_height_i + 5'b1),
        .strip_id_o(strip_id_h1)
    );

    always @(*) begin
        if (program_height_i == 8) begin // height 8
            strip_id_0_o = 4'd1; // priority rule 3
            strip_id_1_o = 4'd2;
            strip_id_2_o = strip_id_h1;
        end else if (program_height_i == 7) begin // height 7
            strip_id_0_o = strip_id_h0; // priority rule 4
            strip_id_1_o = 4'd1; // priority rule 3
            strip_id_2_o = 4'd2;
        end else if (program_height_i >= 13) begin // heights 13~16
            strip_id_0_o = 4'd13; // priority rule 2
            strip_id_1_o = 4'd12;
            strip_id_2_o = 4'd11;
        end else begin
            strip_id_0_o = strip_id_h0; // priority rule 2
            strip_id_1_o = (program_height_i == 12) ? 4'd0 : strip_id_h1; // priority rule 1,2
            strip_id_2_o = 4'd0; // empty
        end
    end
endmodule
