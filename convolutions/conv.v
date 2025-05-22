`timescale 1ns/10ps
`define N_BITS 4
`define X_LEN 5


module CONV_BLOCK #(parameter W=0) (
    input wire [`N_BITS-1:0] Y_IN,
    input wire [`N_BITS-1:0] X,
    input wire CLK,
    output wire [`N_BITS-1:0] Y_OUT
);
    
    reg [`N_BITS-1:0] y_out_int;

    initial
        y_out_int = 0;

    always @ (posedge CLK) begin
        y_out_int <= #1 Y_IN + W * X;
    end

    assign Y_OUT = y_out_int;
endmodule

module ARRAY_BLOCK #(parameter LEN=0) (input wire CLK, output wire [`N_BITS-1:0] OUT);
    reg [`N_BITS-1:0] array [0:LEN-1];
    reg [4:0] counter;
    reg [`N_BITS-1:0] internal_storage;

    integer file, r;

    initial begin
        file = $fopen("x.txt", "r");

        for (integer i = 0; i < LEN; i += 1) begin
            r = $fscanf(file, "%d", array[i]);
        end
        
        internal_storage = 0;
        counter = 0;
    end

    always @ (posedge CLK) begin
        internal_storage = #1 counter < LEN ? array[counter] : 0;
        counter += 1;
    end

    assign OUT = internal_storage;
endmodule

module testbench();
    reg [`N_BITS-1:0] y_in;
    wire [`N_BITS-1:0] x;
    reg clk;
    wire [`N_BITS-1:0] y_out_1;
    wire [`N_BITS-1:0] y_out_2;
    
    //   w   *   x
    // [1 2] * [1 2 2 1 1] = [1 4 6 5 3 2]
    ARRAY_BLOCK #(`X_LEN) arr1 (clk, x);
    CONV_BLOCK #(4'b0010) cb1 (y_in, x, clk, y_out_1);
    CONV_BLOCK #(4'b0001) cb2 (y_out_1, x, clk, y_out_2);

    initial begin
        y_in = 0;
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        $dumpfile("conv.vcd");
        $dumpvars(1, testbench);

        #150 $finish;
    end
endmodule
