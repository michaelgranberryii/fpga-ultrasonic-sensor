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
    output logic [3:0] led
);


typedef enum { pause, trigger, wait_for_echo, echo, distance } state;
state currstate;

integer pause_delay = 7_500_000;
integer trig_pulse_delay = 10*clk_freq/1_000_000;
integer distance_delay = 125;

logic trig_pulse;
logic echo_no_object = 4_750_000;


logic [31:0] trig_count;
logic [31:0] echo_count;
logic [31:0] pause_count;
logic [31:0] distance_count;

logic [13:0] range;
logic tens;
logic ones;

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
    end
    else begin
        case(currstate)
            pause: begin
                pause_count = pause_count + 1;
                if (pause_count < pause_delay) begin
                    currstate = pause;
                    led = 4'hf;
                end
                else begin
                    currstate = trigger;
                    pause_count = 0;
                    led = 4'h0;
                end
            end

            trigger: begin
                currstate = trigger;
                trig_count = trig_count + 1;
                led = 4'h6;
                if(trig_count < trig_pulse_delay) begin
                    trig_pulse = 1;
                end
                else begin
                    trig_pulse = 0;
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
                end
            end

            echo: begin
                led = 4'h9;
                echo_count = echo_count + 1;
                if (echo_count == (distance_delay-1)) begin
                    echo_count = 0;
                    distance_count = distance_count + 1;
                end

                if(ech == 0) begin
                    currstate = distance;
                end
                else begin
                    currstate = echo;
                end
            end

            distance: begin
                if (distance_count >= 116) begin
                    range = distance_count/58;
                    if (range < 10) begin
                        ssd_in = range;
                        currstate = pause;
                    end
                    else begin

                    end
                end;
            end

        endcase
    end
end
    
assign trig = trig_pulse;
assign ssd = seg_out_wire;
asign chip_sel = 1;

endmodule