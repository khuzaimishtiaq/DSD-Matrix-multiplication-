module MatrixMultiplierWithSwitchesAndLEDs(
    input wire clk,                 // System clock
    input wire rst,                 // Reset signal
    input wire btn,                 // Button to move through inputs/outputs
    input wire [7:0] switches,      // 8-bit switches for matrix input
    output reg [7:0] leds           // LEDs to display result
);

    // 3x3 matrix variables
    reg [7:0] matrix_a [0:8];       // 3x3 matrix A
    reg [7:0] matrix_b [0:8];       // 3x3 matrix B
    reg [7:0] matrix_c [0:8];       // 3x3 result matrix C

    // FSM states
    reg [3:0] state;
    parameter RECEIVE_A = 4'd1,
              RECEIVE_B = 4'd2,
              COMPUTE   = 4'd3,
              DISPLAY_C = 4'd4;

    reg [3:0] i; // Index variable
    reg btn_last; // To detect button press
    reg [31:0] delay_counter; // Counter for 2-second delay

    initial begin
        state = RECEIVE_A;
        i = 0;
        delay_counter = 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset everything
            state <= RECEIVE_A;
            i <= 0;
            delay_counter <= 0;
            leds <= 8'd0;
        end else begin
            case (state)
                // Receiving inputs for matrix A
                RECEIVE_A: begin
                    if (btn && !btn_last) begin // Detect button press
                        matrix_a[i] <= switches; // Assign switch value to matrix A
                        if (i == 8) begin
                            state <= RECEIVE_B; // Move to next state
                            i <= 0;             // Reset index
                        end else begin
                            i <= i + 1;         // Increment index
                        end
                    end
                end

                // Receiving inputs for matrix B
                RECEIVE_B: begin
                    if (btn && !btn_last) begin // Detect button press
                        matrix_b[i] <= switches; // Assign switch value to matrix B
                        if (i == 8) begin
                            state <= COMPUTE;    // Move to computation state
                            i <= 0;              // Reset index
                        end else begin
                            i <= i + 1;          // Increment index
                        end
                    end
                end

                // Computing matrix C
                COMPUTE: begin
                    matrix_c[0] <= matrix_a[0] * matrix_b[0] + matrix_a[1] * matrix_b[3] + matrix_a[2] * matrix_b[6];
                    matrix_c[1] <= matrix_a[0] * matrix_b[1] + matrix_a[1] * matrix_b[4] + matrix_a[2] * matrix_b[7];
                    matrix_c[2] <= matrix_a[0] * matrix_b[2] + matrix_a[1] * matrix_b[5] + matrix_a[2] * matrix_b[8];

                    matrix_c[3] <= matrix_a[3] * matrix_b[0] + matrix_a[4] * matrix_b[3] + matrix_a[5] * matrix_b[6];
                    matrix_c[4] <= matrix_a[3] * matrix_b[1] + matrix_a[4] * matrix_b[4] + matrix_a[5] * matrix_b[7];
                    matrix_c[5] <= matrix_a[3] * matrix_b[2] + matrix_a[4] * matrix_b[5] + matrix_a[5] * matrix_b[8];

                    matrix_c[6] <= matrix_a[6] * matrix_b[0] + matrix_a[7] * matrix_b[3] + matrix_a[8] * matrix_b[6];
                    matrix_c[7] <= matrix_a[6] * matrix_b[1] + matrix_a[7] * matrix_b[4] + matrix_a[8] * matrix_b[7];
                    matrix_c[8] <= matrix_a[6] * matrix_b[2] + matrix_a[7] * matrix_b[5] + matrix_a[8] * matrix_b[8];
                    
                    state <= DISPLAY_C; // Move to display state
                    i <= 0;             // Reset index
                end

                // Displaying results on LEDs
                DISPLAY_C: begin
                    leds <= matrix_c[i]; // Display current matrix C value on LEDs
                    if (delay_counter == 100_000_000) begin // 2-second delay at 50 MHz clock
                        delay_counter <= 0;
                        if (i == 8) begin
                            state <= RECEIVE_A; // Go back to input state
                            i <= 0;             // Reset index
                        end else begin
                            i <= i + 1;         // Move to next matrix C element
                        end
                    end else begin
                        delay_counter <= delay_counter + 1; // Increment delay counter
                    end
                end

                default: state <= RECEIVE_A;
            endcase

            // Update button state
            btn_last <= btn;
        end
    end

endmodule
