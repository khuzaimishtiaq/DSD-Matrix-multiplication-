module PulseGenerator (
    input  wire clk,        // System clock
    input  wire rst,        // Reset signal
    input  wire signal_in,  // Input signal
    output reg  pulse_out   // Two-clock-cycle pulse output
);
    reg signal_in_d;        // Delayed version of the input signal for edge detection
    reg [1:0] pulse_counter; // Counter to hold the pulse for two clock cycles

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            signal_in_d <= 1'b0;
            pulse_out <= 1'b0;
            pulse_counter <= 2'b0; // Reset the pulse counter
        end else begin
            // Detect the rising edge of the input signal
            signal_in_d <= signal_in;
            if (signal_in & ~signal_in_d) begin
                pulse_out <= 1'b1;         // Start the pulse
                pulse_counter <= 2'b10;   // Set counter for 2 clock cycles
            end else if (pulse_counter > 0) begin
                pulse_counter <= pulse_counter - 1'b1; // Decrement the counter
                pulse_out <= 1'b1;         // Hold the pulse
            end else begin
                pulse_out <= 1'b0;         // End the pulse
            end
        end
    end
endmodule
