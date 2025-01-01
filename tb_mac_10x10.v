`timescale 1ns / 1ps

module tb_top_matrix_matrix_10x10_pipelined;

    reg clk;
    reg reset;
    reg [799:0] matrix_a;  // Flattened 10x10 matrix A
    reg [799:0] matrix_b;  // Flattened 10x10 matrix B
    wire [1599:0] result;  // Flattened 10x10 result matrix

    // Instantiate the top-level module
    top_matrix_matrix_10x10_pipelined uut (
        .clk(clk),
        .reset(reset),
        .matrix_a(matrix_a),
        .matrix_b(matrix_b),
        .result(result)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end

    // Test procedure
    integer i, j; // Declare loop variables at the top
    initial begin
        // Reset the module
        reset = 1;
        #10 reset = 0;

        // Initialize matrix_a (row 1 has all 1s, row 2 has all 2s, ...)
        for (i = 0; i < 10; i = i + 1) begin
            for (j = 0; j < 10; j = j + 1) begin
                matrix_a[i * 80 + j * 8 +: 8] = i + 1; // Row i has all values of (i+1)
            end
        end

        // Initialize matrix_b (column 1 has all 1s, column 2 has all 2s, ...)
        for (i = 0; i < 10; i = i + 1) begin
            for (j = 0; j < 10; j = j + 1) begin
                matrix_b[j * 80 + i * 8 +: 8] = i + 1; // Column i has all values of (i+1)
            end
        end

        // Wait for computation
        #200;

        // Display the result matrix
        $display("Result Matrix:");
        for (i = 0; i < 10; i = i + 1) begin
            for (j = 0; j < 10; j = j + 1) begin
                $write("%d ", result[i * 160 + j * 16 +: 16]);
            end
            $display();
        end

        $stop;
    end

endmodule
