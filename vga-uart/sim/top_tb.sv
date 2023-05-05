`timescale 1ns/1ps
module top_tb;
    parameter N_tb = 11;
    parameter DATA_WIDTH_tb = 8;
    parameter FIFO_W_tb = 0;

    logic clk_tb;
    logic rst_tb;

    logic led8_tb;
    logic tx_tb;
    logic rx_tb;

    logic VGA_HS_O_tb;
    logic VGA_VS_O_tb;
    logic VGA_R_tb;
    logic VGA_G_tb;
    logic VGA_B_tb;

    logic half_cycle = 4;
    logic CP = half_cycle*2;

    top
    #(
        .N(N),
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_W(FIFO_W_tb)
    )
    uut
    (
        .clk(clk_tb),
        .rst(rst_tb),
        .led8(led8_tb),
        .tx(tx_tb),
        .rx(rx_tb),
        .VGA_HS_O(VGA_HS_O_tb),
        .VGA_VS_O(VGA_VS_O_tb),
        .VGA_R(VGA_R_tb),
        .VGA_G(VGA_G_tb),
        .VGA_B(VGA_B_tb)
    );

    always #half_cycle clk_tb = ~ clk_tb;

    initial begin
        
    end


endmodule