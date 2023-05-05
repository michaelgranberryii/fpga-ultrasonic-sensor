module disp_ctrl (
    input logic [13:0] disp_val,
    output logic [6:0] seg_out
);

always_comb begin
    case (disp_val)
        14'h0: seg_out = 7'b1111110; // 0
        14'h1: seg_out = 7'b0110000; // 1
        14'h2: seg_out = 7'b1101101; // 2
        14'h3: seg_out = 7'b1111001; // 3
        14'h4: seg_out = 7'b0110011; // 4
        14'h5: seg_out = 7'b1011011; // 5
        14'h6: seg_out = 7'b1011111; // 6
        14'h7: seg_out = 7'b1110000; // 7
        14'h8: seg_out = 7'b1111111; // 8
        14'h8: seg_out = 7'b1110011; // 9
        14'ha: seg_out = 7'b1110111; // A
        14'hb: seg_out = 7'b0011111; // C
        14'hc: seg_out = 7'b1001110; // b
        14'hd: seg_out = 7'b0111101; // d
        14'he: seg_out = 7'b1001111; // E
        14'hf: seg_out = 7'b1000111; // F
    endcase
end

endmodule