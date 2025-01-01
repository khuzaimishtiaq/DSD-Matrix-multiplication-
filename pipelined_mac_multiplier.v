module MAC_MatrixMultiplierWithSwitchesAndLEDs(
    input wire clk,                 // System clock
    input wire rst,                 // Reset signal
    input wire btn,                 // Button to move through inputs/outputs
    input wire [7:0] switches,      // 8-bit switches for matrix input
    output reg [7:0] leds           // LEDs to display result
);

    // 3x3 matrix variables
    reg [7:0] matrix_a [0:8];       // 3x3 matrix A
    reg [7:0] matrix_b [0:8];       // 3x3 matrix B
    reg [15:0] matrix_c [0:8];      // 3x3 result matrix C (16-bit to handle larger values)

    // FSM states
    reg [3:0] state;
    parameter RECEIVE_A = 4'd1,
              RECEIVE_B = 4'd2,
              COMPUTE   = 4'd3,
              WAIT_DONE = 4'd4,
              DISPLAY_C = 4'd5;

    reg [3:0] i;            // Index variable
    reg btn_last;           // To detect button press
    reg [31:0] delay_counter; // Counter for 2-second delay

    // Signals for `matrix_pipeline_mac_top`
    reg start_compute;      // Start signal for computation
    wire done_compute;      // Done signal from computation
    wire [15:0] c11, c12, c13, c21, c22, c23, c31, c32, c33; // Result matrix outputs

    initial begin
        state = RECEIVE_A;
        i = 0;
        delay_counter = 0;
    end

    // Instantiate the matrix_pipeline_mac_top module
    matrix_pipeline_mac_top matrix_pipeline (
        .clk(clk),
        .rst(rst),
        .start(start_compute),
        .a11(matrix_a[0]), .a12(matrix_a[1]), .a13(matrix_a[2]),
        .a21(matrix_a[3]), .a22(matrix_a[4]), .a23(matrix_a[5]),
        .a31(matrix_a[6]), .a32(matrix_a[7]), .a33(matrix_a[8]),
        .b11(matrix_b[0]), .b12(matrix_b[1]), .b13(matrix_b[2]),
        .b21(matrix_b[3]), .b22(matrix_b[4]), .b23(matrix_b[5]),
        .b31(matrix_b[6]), .b32(matrix_b[7]), .b33(matrix_b[8]),
        .c11(c11), .c12(c12), .c13(c13),
        .c21(c21), .c22(c22), .c23(c23),
        .c31(c31), .c32(c32), .c33(c33),
        .done(done_compute)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // Reset everything
            state <= RECEIVE_A;
            i <= 0;
            delay_counter <= 0;
            leds <= 8'd0;
            start_compute <= 0;
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

                // Start computation
                COMPUTE: begin
                    start_compute <= 1; // Trigger computation
                    state <= WAIT_DONE; // Move to waiting state
                end

                // Wait for computation to finish
                WAIT_DONE: begin
                    start_compute <= 0; // Clear start signal
                    if (done_compute) begin
                        // Store results in matrix_c
                        matrix_c[0] <= c11; matrix_c[1] <= c12; matrix_c[2] <= c13;
                        matrix_c[3] <= c21; matrix_c[4] <= c22; matrix_c[5] <= c23;
                        matrix_c[6] <= c31; matrix_c[7] <= c32; matrix_c[8] <= c33;

                        state <= DISPLAY_C; // Move to display state
                        i <= 0;             // Reset index
                    end
                end

                // Displaying results on LEDs
                DISPLAY_C: begin
                    leds <= matrix_c[i][7:0]; // Display lower 8 bits of matrix C value on LEDs
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
