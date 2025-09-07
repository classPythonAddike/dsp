`timescale 1ns/10ps

module MAC (
    input wire RESET,
    input wire CLK,
    input wire[7:0] DATA_IN_1,
    input wire[7:0] DATA_IN_2,
    output wire[7:0] DATA_OUT
);
    reg[7:0] accum;

    always @ (posedge CLK) begin
        if (!RESET)
            accum <= 8'b0;
        else
            accum <= accum + DATA_IN_1 * DATA_IN_2;
    end
    
    assign DATA_OUT = accum;
endmodule

module VEC_DELAY_BLOCK #(parameter N = 1) (
    input wire RESET,
    input wire CLK,
    input wire[7:0] DATA_IN,
    output wire[7:0] DATA_OUT
);
    reg[7:0] shift_reg [0:N-1];
    integer i;
    
    always @ (posedge CLK) begin
        if (!RESET)
            for (i = 0; i < N; i = i + 1)
                shift_reg[i] <= 0;
        else begin
            shift_reg[0] = DATA_IN;
            for (i = 1; i < N; i = i + 1)
                shift_reg[i] <= shift_reg[i - 1];
        end
    end
    
    assign DATA_OUT = shift_reg[N - 1];
endmodule

module ROW_DELAY_BLOCK #(parameter M = 4) (
    input wire RESET,
    input wire CLK,
    input wire [DATA_WIDTH-1:0] DATA_IN[N-1:0],
    output wire [DATA_WIDTH-1:0] DATA_OUT[N-1:0]
);
    genvar i;

    generate
        for (i = 0; i < N; i = i + 1)
            VEC_DELAY_BLOCK #(i) delay_data (RESET, CLK, DATA_IN[i], DATA_OUT[i]);
    endgenerate
endmodule


module tb_ROW_DELAY_BLOCK;

    parameter N = 2;
    parameter DATA_WIDTH = 8;

    reg CLK;
    reg RESET;
    reg [DATA_WIDTH-1:0] DATA_IN[N-1:0];
    wire [DATA_WIDTH-1:0] DATA_OUT[N-1:0];

    initial CLK = 0;
    always #5 CLK = ~CLK;

    ROW_DELAY_BLOCK #(N, DATA_WIDTH) dut (
        RESET, CLK,
        DATA_IN, DATA_OUT
    );

    integer i;

    initial begin
        RESET = 0;
        for (i = 0; i < N; i = i + 1)
            DATA_IN[i] = 0;

        #12 RESET = 1;

        #10 DATA_IN[0] = 8'd10; DATA_IN[1] = 8'd20;
        #10 DATA_IN[0] = 8'd11; DATA_IN[1] = 8'd21;
        #10 DATA_IN[0] = 8'd12; DATA_IN[1] = 8'd22;
        #10 DATA_IN[0] = 8'd13; DATA_IN[1] = 8'd23;
        #10 DATA_IN[0] = 8'd14; DATA_IN[1] = 8'd24;
        #10 DATA_IN[0] = 0;     DATA_IN[1] = 0;

        #50 $finish;
    end

    initial begin
        $display("Time\tCLK\tRESET\tIN[0]\tIN[1]\tOUT[0]\tOUT[1]");
        $monitor("%0t\t%b\t%b\t%d\t%d\t%d\t%d",
            $time, CLK, RESET,
            DATA_IN[0], DATA_IN[1],
            DATA_OUT[0], DATA_OUT[1]
        );
    end
endmodule
