`timescale 1ns / 1ps

module tb_matrix_pipeline_mac_top;

    // Inputs
    reg clk;
    reg rst;
    reg start;
    reg [7:0] a11, a12, a13;
    reg [7:0] a21, a22, a23;
    reg [7:0] a31, a32, a33;
    reg [7:0] b11, b12, b13;
    reg [7:0] b21, b22, b23;
    reg [7:0] b31, b32, b33;

    // Outputs
    wire [15:0] c11, c12, c13;
    wire [15:0] c21, c22, c23;
    wire [15:0] c31, c32, c33;
    wire done;

    // Instantiate the Unit Under Test (UUT)
    matrix_pipeline_mac_top uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .a11(a11), .a12(a12), .a13(a13),
        .a21(a21), .a22(a22), .a23(a23),
        .a31(a31), .a32(a32), .a33(a33),
        .b11(b11), .b12(b12), .b13(b13),
        .b21(b21), .b22(b22), .b23(b23),
        .b31(b31), .b32(b32), .b33(b33),
        .c11(c11), .c12(c12), .c13(c13),
        .c21(c21), .c22(c22), .c23(c23),
        .c31(c31), .c32(c32), .c33(c33),
        .done(done)
    );

    // Clock generation
    always #5 clk = ~clk; // 10 ns clock period

    initial begin
        // Initialize Inputs
        clk = 0;
        rst = 1;
        start = 0;
        a11 = 0; a12 = 0; a13 = 0;
        a21 = 0; a22 = 0; a23 = 0;
        a31 = 0; a32 = 0; a33 = 0;
        b11 = 0; b12 = 0; b13 = 0;
        b21 = 0; b22 = 0; b23 = 0;
        b31 = 0; b32 = 0; b33 = 0;

        // Reset the system
        #20;
        rst = 0;

        // Apply test vectors
        #10;
        a11 = 8'd1; a12 = 8'd2; a13 = 8'd3;
        a21 = 8'd4; a22 = 8'd5; a23 = 8'd6;
        a31 = 8'd7; a32 = 8'd8; a33 = 8'd9;

        b11 = 8'd9; b12 = 8'd8; b13 = 8'd7;
        b21 = 8'd6; b22 = 8'd5; b23 = 8'd4;
        b31 = 8'd3; b32 = 8'd2; b33 = 8'd1;

        start = 1;

        // Wait for the operation to complete
        wait(done);

        // Display results
        #50;
        $display("Resultant Matrix C:");
        $display("C11 = %d, C12 = %d, C13 = %d", c11, c12, c13);
        $display("C21 = %d, C22 = %d, C23 = %d", c21, c22, c23);
        $display("C31 = %d, C32 = %d, C33 = %d", c31, c32, c33);

        // Finish simulatio
        #10;
        $finish;
    end

endmodule
