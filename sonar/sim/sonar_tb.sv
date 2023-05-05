`timescale 1ns/1ps
module sonar_tb;
    parameter clk_freq = 125_000_000;
    logic clk;
    logic rst;
    logic trig;
    logic ech;

    integer HP = 4;
    integer CP = 2*HP;

sonar
#(
    .clk_freq(clk_freq)
)
uut
(
    .clk(clk),
    .rst(rst),
    .trig(trig),
    .ech(ech)
);

always #HP clk = ~ clk;

initial begin
    clk = 0;
    rst = 1;
    ech = 0;
    #CP;
    rst = 0;
    #CP;

    #60_011_000;
    ech = 1;
    #120_000;
    ech = 0;

    #10000000;
end

endmodule