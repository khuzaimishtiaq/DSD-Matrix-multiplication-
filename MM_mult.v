`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    18:34:19 12/25/2024 
// Design Name: 
// Module Name:    TMM 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module matrix_mult_top (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [7:0] a11, a12, a13,
    input wire [7:0] a21, a22, a23,
    input wire [7:0] a31, a32, a33,
    input wire [7:0] b11, b12, b13,  // First row of matrix B
    input wire [7:0] b21, b22, b23,  // Second row of matrix B
    input wire [7:0] b31, b32, b33,  // Third row of matrix B
    output reg [15:0] c11, c12, c13, // First row of resultant matrix C
    output reg [15:0] c21, c22, c23, // Second row of resultant matrix C
    output reg [15:0] c31, c32, c33, // Third row of resultant matrix C
    output reg done
);

    // Wires to connect outputs of matrix_mult instances
    wire [15:0] c1_col1, c2_col1, c3_col1;
    wire [15:0] c1_col2, c2_col2, c3_col2;
    wire [15:0] c1_col3, c2_col3, c3_col3;

    wire done_col1, done_col2, done_col3;
    reg start_col;

    // FSM for managing computation states
    reg [1:0] state;
    parameter IDLE = 2'b00;
    parameter COMPUTE = 2'b01;
    parameter FINISH = 2'b10;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            start_col <= 0;
            done <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= COMPUTE;
                        start_col <= 1; // Start all columns
                        done <= 0;
                    end
                end
                COMPUTE: begin
                    if (done_col1 && done_col2 && done_col3) begin
                        state <= FINISH;
                        start_col <= 0;
                    end
                end
                FINISH: begin
                    done <= 1;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
        end
    end

    // Instantiate matrix_mult for each column of the resultant matrix
    matrix_mult col1 (
        .clk(clk),
        .rst(rst),
        .start(start_col),
        .a11(a11), .a12(a12), .a13(a13),
        .a21(a21), .a22(a22), .a23(a23),
        .a31(a31), .a32(a32), .a33(a33),
        .b1(b11), .b2(b21), .b3(b31),
        .c1(c1_col1), .c2(c2_col1), .c3(c3_col1),
        .done(done_col1)
    );

    matrix_mult col2 (
        .clk(clk),
        .rst(rst),
        .start(start_col),
        .a11(a11), .a12(a12), .a13(a13),
        .a21(a21), .a22(a22), .a23(a23),
        .a31(a31), .a32(a32), .a33(a33),
        .b1(b12), .b2(b22), .b3(b32),
        .c1(c1_col2), .c2(c2_col2), .c3(c3_col2),
        .done(done_col2)
    );

    matrix_mult col3 (
        .clk(clk),
        .rst(rst),
        .start(start_col),
        .a11(a11), .a12(a12), .a13(a13),
        .a21(a21), .a22(a22), .a23(a23),
        .a31(a31), .a32(a32), .a33(a33),
        .b1(b13), .b2(b23), .b3(b33),
        .c1(c1_col3), .c2(c2_col3), .c3(c3_col3),
        .done(done_col3)
    );

    // Collect results from column computations
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            {c11, c12, c13, c21, c22, c23, c31, c32, c33} <= 0;
        end else if (state == FINISH) begin
            c11 <= c1_col1; c12 <= c1_col2; c13 <= c1_col3;
            c21 <= c2_col1; c22 <= c2_col2; c23 <= c2_col3;
            c31 <= c3_col1; c32 <= c3_col2; c33 <= c3_col3;
        end
    end

endmodule

