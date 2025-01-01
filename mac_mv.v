module mac_matrix_vector (
    input wire [7:0] a11, a12, a13, 
    input wire [7:0] a21, a22, a23,
    input wire [7:0] a31, a32, a33,
    input wire [7:0] b1, b2, b3,
    output reg [15:0] c1, c2, c3,
    input wire clk,
    input wire reset
);
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset the output results
            c1 <= 16'd0;
            c2 <= 16'd0;
            c3 <= 16'd0;
        end else begin
            // Perform multiply-accumulate operations
            c1 <= (a11 * b1) + (a12 * b2) + (a13 * b3);
            c2 <= (a21 * b1) + (a22 * b2) + (a23 * b3);
            c3 <= (a31 * b1) + (a32 * b2) + (a33 * b3);
        end
    end
endmodule
