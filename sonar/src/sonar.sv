// Ultrasonic Ranging Module HC - SR04 

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

// Define the states for the state machine
typedef enum { pause, trigger, wait_for_echo, echo, distance, ran, mag, less, div,  sub} state;
state currstate;

parameter [31:0]  pause_delay = clk_freq/2; // 500 mSec
parameter [31:0]  trig_pulse_delay = clk_freq/41_666; // 24 uSec
parameter [31:0]  distance_delay = clk_freq/1_000_000; // 1 uSec
logic trig_pulse;


logic [31:0] trig_count; // couunts to 24 uSec
logic [31:0] echo_count; // counts to 1 uSec
logic [31:0] pause_count; // 500 mSec
logic [31:0] distance_count; // each count = 1 uSec
logic [18:0] c_sel_count; // rollover counter

logic [13:0] range; // stores the distance
logic [13:0] tens; // stores the tens place digit
logic [13:0] ones; // stores the ones place digit
logic c_sel; // SSD chip select
logic [13:0] ssd_in; // port input to display controller
logic [6:0] seg_out_wire; // stores digit to be displayed

// display controller
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

            // pause for 500 mSec
            // set distance count [uSec] = 0
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

             // set Trig pin HIGH for 10 uSec (I had to set it HIGH for 24 uSec due to slew rate issues)
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

            // wait for ECHO pin to go HIGH
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

            // while ECHO is HIGH, count is't pulse width in uSec
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

            // calculate the distance
            // the ECHO pulse width and the range is proportional by: Distance[cm] = (Echo pulse width in uSec) / 58
            distance: begin
                led = 4'h1;
                // if (distance_count >= 116) begin
                    led8 = distance_count[7:0];
                    range = distance_count/58; // Distance[cm] = (Echo pulse width in uSec) / 58
                    currstate = mag;
                // end;
            end

            // determine if distanse is a single or double digit number
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

            // display single digit number
            // goto PAUSE state
            less: begin
                led = 4'h5;
                ones = range;
                tens = 0;
                currstate = pause;
            end

            // find the tens places digit
            div: begin
                tens = range/10;
                currstate = sub;
                
            end

            // find the ones places digit
            // goto PAUSE state
            sub: begin
                ones = range - (tens*10);
                currstate = pause;
            end

        endcase
    end
end

// always block for SSD
// alternate between each SSD display with  CS (chip select)
always_ff @( posedge clk, posedge rst ) begin
    if(rst) begin
        c_sel = 0;
        c_sel_count = 0;
    end
    else begin
        c_sel_count = c_sel_count + 1; // rollover counter = every 4 mSec
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


assign trig = trig_pulse; // TRIG pin
assign ssd = seg_out_wire; // SSD display
assign chip_sel = c_sel; // SSD chip select

endmodule