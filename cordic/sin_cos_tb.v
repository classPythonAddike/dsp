`timescale 1ns/10ps

module CORDIC_TB();
    reg [7:0] INPUT_ANGLE;
    wire [7:0] LUT_ANGLE;
    reg RESET_PULSE;
    wire CLK;

    CORDIC cordic_test(INPUT_ANGLE, RESET_PULSE);

    initial begin
        RESET_PULSE = 0;
        INPUT_ANGLE = 210; // 73.8 deg
        // 128 + 76 + 40 - 20 - 10 - 5 + 3 - 1
        // 204, 244, 224, 214, 209, 212, 211
        
        $dumpfile("cordic_vars.vcd");
        $dumpvars(0, CORDIC_TB);
        // $monitor("time=%0t Angle=%d LUT Angle=%d, clk=%d", $time, OUTPUT_ANGLE, LUT_ANGLE, CLK);

        #150 RESET_PULSE = 1;
        #550 RESET_PULSE = 0;
        #50 INPUT_ANGLE = 94;
        #100 RESET_PULSE = 1;
        #550 $finish;
    end
endmodule
