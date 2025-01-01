module mac_matrix_vector_pipeline_10x10 (
    input wire clk,
    input wire reset,
    input wire [79:0] a_flat,    // Flattened 10 scalar inputs (10 x 8 bits = 80 bits)
    input wire [79:0] b_flat,    // Flattened 10 scalar inputs (10 x 8 bits = 80 bits)
    output reg [159:0] c_flat    // Flattened 10 scalar outputs (10 x 16 bits = 160 bits)
);

    // Temporary registers for unflattened inputs/outputs
    reg [7:0] a [0:9];   // Unflattened version of input a_flat
    reg [7:0] b [0:9];   // Unflattened version of input b_flat
    reg [15:0] c [0:9];  // Unflattened version of output c_flat

    integer i, j;

    // Flatten-to-array unpacking
    always @(*) begin
        for (i = 0; i < 10; i = i + 1) begin
            a[i] = a_flat[i * 8 +: 8];  // Extract 8 bits for each input element
            b[i] = b_flat[i * 8 +: 8];  // Extract 8 bits for each input element
        end
    end

    // Main computation for matrix multiplication
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 10; i = i + 1) begin
                c[i] <= 16'd0; // Reset output
            end
        end else begin
            for (i = 0; i < 10; i = i + 1) begin
                c[i] <= 16'd0;  // Reset each row result
                for (j = 0; j < 10; j = j + 1) begin
                    c[i] <= c[i] + (a[i] * b[j * 8 +: 8]); // Matrix multiplication
                end
            end
        end
    end

    // Array-to-flattened packing
    always @(*) begin
        for (i = 0; i < 10; i = i + 1) begin
            c_flat[i * 16 +: 16] = c[i]; // Pack 16 bits for each output element
        end
    end

endmodule
