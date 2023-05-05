module sonar 
#(
    parameter clk_freq = 125_000_000
)
(
    input logic clk,
    input logic rst,
    output logic trig,
    input logic ech,
    output logic [6:0] ssd,
    output logic chip_sel,
    output logic [3:0] led,
    output logic led6_r,
    output logic led6_g,
    output logic [7:0] led8
);


typedef enum { pause, trigger, wait_for_echo, echo, distance, ran, mag, less, div,  sub} state;
state currstate;

parameter [31:0]  pause_delay = clk_freq/2;
parameter [31:0]  trig_pulse_delay = clk_freq/41_666;
parameter [31:0]  distance_delay = clk_freq/1_000_000;
logic trig_pulse;


logic [31:0] trig_count;
logic [31:0] echo_count;
logic [31:0] pause_count;
logic [31:0] distance_count;
logic [18:0] c_sel_count;

logic [13:0] range;
logic [13:0] tens;
logic [13:0] ones;
logic c_sel;
logic [13:0] ssd_in;
logic [6:0] seg_out_wire;

disp_ctrl disp_i(
    .disp_val(ssd_in),
    .seg_out(seg_out_wire)
);

always_ff @( posedge clk, posedge rst ) begin
    if(rst) begin
        currstate = pause;
        trig_pulse = 0;
        pause_count = 0;
        trig_count = 0;
        echo_count = 0;
        distance_count = 0;
        led = 4'h0;
        led6_r = 0;
        led6_g = 0;
    end
    else begin
        case(currstate)
            pause: begin
                led = 4'hf;
                pause_count = pause_count + 1;
                distance_count = 0;
                if (pause_count < pause_delay) begin
                    currstate = pause;
                    led6_r = ~ led6_r;
                end
                else begin
                    currstate = trigger;
                    pause_count = 0;
                    led = 4'h0;
                    led6_r = ~ led6_r;
                end
            end

            trigger: begin
                trig_count = trig_count + 1;
                led = 4'h6;
                if(trig_count < trig_pulse_delay) begin
                    trig_pulse = 1;
                    currstate = trigger;
                    
                end
                else begin
                    trig_pulse = 0;
                    trig_count = 0;
                    currstate = wait_for_echo;
                end
            end

            wait_for_echo: begin
                led = 4'h8;
                
                if(ech) begin
                    currstate = echo;
                end
                else begin
                    currstate = wait_for_echo;
                    // currstate = pause;
                end
            end

            echo: begin
                echo_count = echo_count + 1;
                if(ech == 1) begin
                    led = 4'h9;
                    if (echo_count == (distance_delay-1)) begin
                        led6_g = 1;
                        distance_count = distance_count + 1;
                        echo_count = 0;
                        currstate = echo;
                    end
                end
                else if (ech == 0) begin
                    currstate = distance;
                    led = 4'h0;
                    led6_g = 0;
                    echo_count = 0;
                end
            end

            distance: begin
                led = 4'h1;
                // if (distance_count >= 116) begin
                    led8 = distance_count[7:0];
                    range = distance_count/58;
                    currstate = mag;
                // end;
            end

            mag: begin
                if (range < 10) begin
                    led = 4'h5;
                    ones = range;
                    currstate = less;
                end
                else begin
                    currstate = div;
                end
            end

            less: begin
                led = 4'h5;
                ones = range;
                tens = 0;
                currstate = pause;
            end

            div: begin
                tens = range/10;
                currstate = sub;
                
            end

            sub: begin
                ones = range - (tens*10);
                currstate = pause;
            end

        endcase
    end
end

always_ff @( posedge clk, posedge rst ) begin
    if(rst) begin
        c_sel = 0;
        c_sel_count = 0;
    end
    else begin
        c_sel_count = c_sel_count + 1;
        if (c_sel_count == 0) begin
            c_sel = ~ c_sel;
            if (c_sel) begin
                ssd_in = tens;
            end
            else begin
                ssd_in = ones;
            end
        end
    end
end


assign trig = trig_pulse;
assign ssd = seg_out_wire;
assign chip_sel = c_sel;

endmodule