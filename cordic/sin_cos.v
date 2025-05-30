`timescale 1ns/10ps
`define R 155

/*
 * 1 + n  arctan(2 ^ -n) / 90 * 256
 * 1      128.0
 * 2      75.56281223702184
 * 3      39.925314753213094
 * 4      20.26671317020956
 * 5      10.172684444436909
 * 6      5.091301285677709
 * 7      2.5462718868226117
 * 8      1.2732136415589066
 */

module NOT(input wire A, output wire B);
    assign #22 B = ~A;
endmodule

module ADDER(input wire [7:0] A, input wire [7:0] B, input wire SUB, output wire [7:0] C);
    assign #16.5 C = SUB ? B - A : A + B;
endmodule

module CMP(input wire [7:0] A, input wire [7:0] B, output wire GT, output wire LT, output wire EQ);
    assign #17.5 GT = A > B;
    assign #17.5 LT = A < B;
    assign #17.5 EQ = A == B;
endmodule

module CLOCK(output wire CLK);
    reg clk;
    initial
        clk = 1;

    always
        #28.5 clk = ~clk;

    assign CLK = clk;
endmodule

module REGISTER(
    input wire [7:0] IN, input wire WRITE_EN_LOW, input wire RESET, input wire CLK,
    output wire [7:0] OUT
);
    reg [7:0] data;
    
    always @ (posedge CLK)
        if (!RESET)
            data = 0;
        else if (!WRITE_EN_LOW)
            data <= IN;

    assign #5.2 OUT = data;
endmodule

module LSHIFT(input wire [7:0] IN, output wire [7:0] OUT);
    assign OUT = IN << 1;
endmodule

module LUT(
    input wire CLK, input wire RESET,
    output wire [7:0] ANGLE, output wire HALT
);
    reg [7:0] angle_data;
    reg [2:0] pointer;
    reg halt;

    reg [7:0] angle_array [0:7];

    always @ (posedge CLK) begin
        if (RESET) begin
            if (!halt) begin
                pointer += 1;
                angle_data = angle_array[pointer];
                if (pointer == 0)
                    halt = 1;
            end
        end else begin
            pointer = 0;
            angle_data = angle_array[pointer];
            halt = 0;
        end
    end

    initial begin
        angle_array[0] = 128;
        angle_array[1] = 76;
        angle_array[2] = 40;
        angle_array[3] = 20;
        angle_array[4] = 10;
        angle_array[5] = 5;
        angle_array[6] = 3;
        angle_array[7] = 1;
    end

    assign #32 ANGLE = angle_data;
    assign #24 HALT = halt;
endmodule

module CORDIC(input wire [7:0] IN_ANGLE, input wire RESET_PULSE, output wire[7:0] THETA_ADDER_IN);
    wire CLK;
    CLOCK clock(CLK);

    wire [7:0] THETA_ADDER_OUT;
    wire TGT_LT, TGT_GT, TGT_EQ;

    wire [7:0] LUT_ANGLE;
    wire HALT;
    LUT lut(CLK, RESET_PULSE, LUT_ANGLE, HALT);
    
    REGISTER theta(THETA_ADDER_OUT, HALT, RESET_PULSE, CLK, THETA_ADDER_IN);
    CMP comparator(IN_ANGLE, THETA_ADDER_IN, TGT_GT, TGT_LT, TGT_EQ);
    ADDER theta_adder(LUT_ANGLE, THETA_ADDER_IN, TGT_LT, THETA_ADDER_OUT);
endmodule
