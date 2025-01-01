module matrix_mult (
    input wire clk,
    input wire rst,
    input wire start,
    input wire [7:0] a11, a12, a13,
    input wire [7:0] a21, a22, a23,
    input wire [7:0] a31, a32, a33,
    input wire [7:0] b1, b2, b3,
    output reg [15:0] c1, c2, c3,
    output reg done
);

    // Internal registers and FSM state
    reg [2:0] state;
    reg [15:0] temp_c1, temp_c2, temp_c3;

    // State definitions
    parameter IDLE = 3'b000;
    parameter ROW1 = 3'b001;
    parameter ROW2 = 3'b010;
    parameter ROW3 = 3'b011;
    parameter FINISH = 3'b100;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            done <= 0;
            {c1, c2, c3, temp_c1, temp_c2, temp_c3} <= 0;
        end else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= ROW1;
                        done <= 0;
                    end
                end

                ROW1: begin
                    temp_c1 <= a11 * b1 + a12 * b2 + a13 * b3;
                    state <= ROW2;
                end

                ROW2: begin
                    temp_c2 <= a21 * b1 + a22 * b2 + a23 * b3;
                    state <= ROW3;
                end

                ROW3: begin
                    temp_c3 <= a31 * b1 + a32 * b2 + a33 * b3;
                    state <= FINISH;
                end

                FINISH: begin
                    {c1, c2, c3} <= {temp_c1, temp_c2, temp_c3};
                    done <= 1;
                    state <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end
endmodule
