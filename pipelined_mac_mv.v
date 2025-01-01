module mac_matrix_vector_pipeline (
    input wire [7:0] a11, a12, a13, 
    input wire [7:0] a21, a22, a23,
    input wire [7:0] a31, a32, a33,
    input wire [7:0] b1, b2, b3,
    output reg [15:0] c1, c2, c3,
    input wire clk,
    input wire reset
);
    // Stage 1: Multiplication results
    reg [15:0] m11, m12, m13;
    reg [15:0] m21, m22, m23;
    reg [15:0] m31, m32, m33;
    
    // Stage 2: Accumulation results
    reg [15:0] add1_stage2, add2_stage2;
    reg [15:0] add1_stage3, add2_stage3, add3_stage3;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset the outputs and pipeline registers
            c1 <= 16'd0;
            c2 <= 16'd0;
            c3 <= 16'd0;
            m11 <= 16'd0; m12 <= 16'd0; m13 <= 16'd0;
            m21 <= 16'd0; m22 <= 16'd0; m23 <= 16'd0;
            m31 <= 16'd0; m32 <= 16'd0; m33 <= 16'd0;
            add1_stage2 <= 16'd0; add2_stage2 <= 16'd0;
            add1_stage3 <= 16'd0; add2_stage3 <= 16'd0; add3_stage3 <= 16'd0;
        end else begin
            // Stage 1: Perform multiplications
            m11 <= a11 * b1; m12 <= a12 * b2; m13 <= a13 * b3;
            m21 <= a21 * b1; m22 <= a22 * b2; m23 <= a23 * b3;
            m31 <= a31 * b1; m32 <= a32 * b2; m33 <= a33 * b3;

            // Stage 2: Perform additions
            add1_stage2 <= m11 + m12;
            add2_stage2 <= m21 + m22;

            add1_stage3 <= add1_stage2 + m13;
            add2_stage3 <= add2_stage2 + m23;
            add3_stage3 <= m31 + m32 + m33;

            // Final stage: Assign outputs
            c1 <= add1_stage3;
            c2 <= add2_stage3;
            c3 <= add3_stage3;
        end
    end
endmodule
