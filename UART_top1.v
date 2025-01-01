module UART_Top #(
    parameter CLOCK_RATE = 100_000_000, // 100 MHz clock
    parameter BAUD_RATE = 9600         // 9600 baud rate
)(
    input  wire clk,       // System clock 
    input  wire rst,       // Reset 
    input  wire rx,        // UART receive input 
    input  wire tx_start_input,  // External signal to start UART transmission 
	 input wire tx_en,
    output wire tx,        // UART transmit output 
    output reg [3:0] state,  // Data received
    output wire rx_done,   // Indicates a byte has been received 
    output wire tx_done,   // Indicates a byte has been transmitted 
    output wire rx_busy,   // UART receiver is busy 
    output wire tx_busy,   // UART transmitter is busy 
    output wire rx_err     // Indicates a receive error 
); 

    // Internal signals for baud rate clocks 
    wire rx_baud_clk; 
    wire tx_baud_clk; 
    wire tx_start; // Single-cycle pulse for tx_start 
    reg [7:0] tx_data_in; // Data to transmit 
    wire [7:0] rx_data_out;

    reg [7:0] matrix_a [0:8]; // 3x3 matrix A 
    reg [7:0] matrix_b [0:8]; // 3x3 matrix B 
    reg [7:0] matrix_c [0:8]; // 3x3 result matrix C 
    reg mul_done;

    // FSM States 
    parameter RECEIVE_A = 4'd1, 
              RECEIVE_B = 4'd2, 
              COMPUTE = 4'd3, 
              SEND_C = 4'd4; 

    // Instantiate the Baud Rate Generator 
    BaudRateGenerator #(
        .CLOCK_RATE(CLOCK_RATE), 
        .BAUD_RATE(BAUD_RATE) 
    ) baud_gen ( 
        .clk(clk), 
        .rxClk(rx_baud_clk), 
        .txClk(tx_baud_clk) 
    ); 

    // Instantiate the Pulse Generator for tx_start 
    PulseGenerator pulse_gen ( 
        .clk(tx_baud_clk), 
        .rst(rst), 
        .signal_in(tx_start_input), 
        .pulse_out(tx_start) // Single-cycle pulse for tx_start 
    ); 

    // Instantiate the UART Receiver 
    Uart8Receiver uart_rx ( 
        .clk(rx_baud_clk), // Baud rate clock for RX 
        .en(1'b1),         // Enable always on 
        .in(rx),           // UART RX input 
        .out(rx_data_out), // Received data output 
        .done(rx_done),    // Receive complete 
        .busy(rx_busy),    // UART RX busy 
        .err(rx_err)       // Receive error 
    ); 

    // Instantiate the UART Transmitter 
    Uart8Transmitter uart_tx ( 
        .clk(tx_baud_clk), // Baud rate clock for TX 
        .en(tx_en),         // Enable always on 
        .start(tx_start),  // Start transmission (single-cycle pulse) 
        .in(tx_data_in),   // Data to transmit 
        .out(tx),          // UART TX output 
        .done(tx_done),    // Transmit complete 
        .busy(tx_busy)     // UART TX busy 
    ); 

    integer k; 

    initial begin
        state = RECEIVE_A;
        mul_done = 0;
    end 

    integer i; 
    // FSM for handling UART-based matrix computation 
    always @(posedge clk or posedge rst) begin  
        if (rst) begin
            // Reset state and internal variables
            state <= RECEIVE_A;
            mul_done <= 0;
            i <= 0;
        end else begin
            case (state) 
                RECEIVE_A: begin 
                    if (rx_done) begin 
                        matrix_a[i] <= rx_data_out; 
                        if (i == 8) begin 
                            state <= RECEIVE_B; 
                            i <= 0; 
                        end 
								else begin
								i <= i + 1;
								end
                    end 
                end 
                RECEIVE_B: begin 
                    if (rx_done) begin 
                        matrix_b[i] <= rx_data_out;
                        if (i == 8) begin 
                            state <= COMPUTE; 
                            i <= 0; 
                        end
								else begin
								i <= i + 1;
								end								
                    end 
                end 
                COMPUTE: begin 
                    if (!mul_done) begin 
                        matrix_c[0] <= matrix_a[0] * matrix_b[0] + matrix_a[1] * matrix_b[3] + matrix_a[2] * matrix_b[6];
                        matrix_c[1] <= matrix_a[0] * matrix_b[1] + matrix_a[1] * matrix_b[4] + matrix_a[2] * matrix_b[7];
                        matrix_c[2] <= matrix_a[0] * matrix_b[2] + matrix_a[1] * matrix_b[5] + matrix_a[2] * matrix_b[8];

                        matrix_c[3] <= matrix_a[3] * matrix_b[0] + matrix_a[4] * matrix_b[3] + matrix_a[5] * matrix_b[6];
                        matrix_c[4] <= matrix_a[3] * matrix_b[1] + matrix_a[4] * matrix_b[4] + matrix_a[5] * matrix_b[7];
                        matrix_c[5] <= matrix_a[3] * matrix_b[2] + matrix_a[4] * matrix_b[5] + matrix_a[5] * matrix_b[8];

                        matrix_c[6] <= matrix_a[6] * matrix_b[0] + matrix_a[7] * matrix_b[3] + matrix_a[8] * matrix_b[6];
                        matrix_c[7] <= matrix_a[6] * matrix_b[1] + matrix_a[7] * matrix_b[4] + matrix_a[8] * matrix_b[7];
                        matrix_c[8] <= matrix_a[6] * matrix_b[2] + matrix_a[7] * matrix_b[5] + matrix_a[8] * matrix_b[8];
                        state <= SEND_C; 
                        i <= 0; 
                        mul_done <= 1;
                    end 
                end 
                SEND_C: begin 
                    if (tx_done) begin 
                        tx_data_in <= matrix_c[i];
                        if (i == 8) state <= RECEIVE_A; 
                    end 
						  else begin
								i <= i + 1;
								end
                end 
                default: state <= RECEIVE_A; 
            endcase 
        end
    end 
endmodule 
