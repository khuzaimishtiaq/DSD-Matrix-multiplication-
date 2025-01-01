module top_matrix_matrix_10x10_pipelined (
    input wire clk,
    input wire reset,
    input wire [799:0] matrix_a,  // Flattened input matrix A (10x10, 8-bit elements)
    input wire [799:0] matrix_b,  // Flattened input matrix B (10x10, 8-bit elements)
    output wire [1599:0] result   // Flattened output result matrix (10x10, 16-bit elements)
);

    genvar i, j;
    wire [159:0] row_result [0:9]; // Intermediate results for each row (10 rows, each 10x16 bits)

    // Instantiate MAC modules for each row of the result matrix
    generate
        for (i = 0; i < 10; i = i + 1) begin : mac_row_generate
            mac_matrix_vector_pipeline_10x10 mac_row (
                .clk(clk),
                .reset(reset),
                .a_flat(matrix_a[i * 80 +: 80]),   // Extract 10 elements (80 bits) for row i of matrix_a
                .b_flat({
                    matrix_b[0 * 80 + i * 8 +: 8], // Extract column i of matrix_b
                    matrix_b[1 * 80 + i * 8 +: 8],
                    matrix_b[2 * 80 + i * 8 +: 8],
                    matrix_b[3 * 80 + i * 8 +: 8],
                    matrix_b[4 * 80 + i * 8 +: 8],
                    matrix_b[5 * 80 + i * 8 +: 8],
                    matrix_b[6 * 80 + i * 8 +: 8],
                    matrix_b[7 * 80 + i * 8 +: 8],
                    matrix_b[8 * 80 + i * 8 +: 8],
                    matrix_b[9 * 80 + i * 8 +: 8]
                }),
                .c_flat(row_result[i]) // Flattened result row i
            );

            // Assign row_result to the flattened result matrix
            for (j = 0; j < 10; j = j + 1) begin : result_assign
                assign result[i * 160 + j * 16 +: 16] = row_result[i][j * 16 +: 16];
            end
        end
    endgenerate

endmodule
