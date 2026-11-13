
`timescale 1ns/1ps

module tb;

    logic clk;
    logic rst;
    logic wr_en;
    logic rd_en;
    logic [7:0] din;
    logic [7:0] dout;
    logic full;
    logic empty;

    integer i;

    // DUT
    fifo dut (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .din(din),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Waveform dumping
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    end

    // Write task
    task write_data(input logic [7:0] data);
        begin
            @(negedge clk);
            wr_en = 1;
            din = data;

            @(negedge clk);
            wr_en = 0;
        end
    endtask

    // Read task
    task read_data(input logic [7:0] expected);
        begin
            @(negedge clk);
            rd_en = 1;

            @(posedge clk);
            #1;

            if (dout !== expected)
                $fatal(1, "READ FAILED: Expected %h, Got %h",
                       expected, dout);
            else
                $display("READ PASS: Data = %h", dout);

            @(negedge clk);
            rd_en = 0;
        end
    endtask

    // Main test sequence
    initial begin

        rst = 1;
        wr_en = 0;
        rd_en = 0;
        din = 0;

        // TEST 1: Reset
        $display("\nTEST 1: RESET");

        repeat(2) @(negedge clk);
        rst = 0;

        if (!empty)
            $fatal(1, "FAIL: FIFO should be empty");

        $display("RESET PASS");

        // TEST 2: Fill FIFO
        $display("\nTEST 2: FILL FIFO");

        for (i = 0; i < 16; i = i + 1)
            write_data(i);

        if (!full)
            $fatal(1, "FAIL: FIFO should be full");

        $display("FULL FLAG PASS");

        // TEST 3: Overflow protection
        $display("\nTEST 3: OVERFLOW PROTECTION");

        write_data(8'hFF);

        if (!full)
            $fatal(1, "FAIL: Overflow protection");

        $display("OVERFLOW PROTECTION PASS");

        // TEST 4: FIFO ordering
        $display("\nTEST 4: FIFO ORDERING");

        for (i = 0; i < 16; i = i + 1)
            read_data(i);

        if (!empty)
            $fatal(1, "FAIL: FIFO should be empty");

        $display("FIFO ORDERING PASS");
        $display("EMPTY FLAG PASS");

        // TEST 5: Underflow protection
        $display("\nTEST 5: UNDERFLOW PROTECTION");

        @(negedge clk);
        rd_en = 1;

        @(posedge clk);
        #1;

        if (!empty)
            $fatal(1, "FAIL: FIFO underflow");

        @(negedge clk);
        rd_en = 0;

        $display("UNDERFLOW PROTECTION PASS");

        // TEST 6: Simultaneous read/write
        $display("\nTEST 6: SIMULTANEOUS READ/WRITE");

        write_data(8'hA1);
        write_data(8'hB2);

        @(negedge clk);
        rd_en = 1;
        wr_en = 1;
        din = 8'hC3;

        @(posedge clk);
        #1;

        if (dout !== 8'hA1)
            $fatal(1, "FAIL: Simultaneous read");

        $display("SIMULTANEOUS READ PASS");

        @(negedge clk);
        rd_en = 0;
        wr_en = 0;

        read_data(8'hB2);
        read_data(8'hC3);

        if (!empty)
            $fatal(1, "FAIL: FIFO should be empty");

        // TEST 7: Reset during operation
        $display("\nTEST 7: RESET DURING OPERATION");

        write_data(8'h11);
        write_data(8'h22);
        write_data(8'h33);

        @(negedge clk);
        rst = 1;

        @(posedge clk);
        #1;

        if (!empty || dout !== 8'h00)
            $fatal(1, "FAIL: Reset did not clear FIFO state");

        @(negedge clk);
        rst = 0;

        $display("MID-OPERATION RESET PASS");

        // TEST 8: Pointer wraparound
        $display("\nTEST 8: POINTER WRAPAROUND");

        for (i = 0; i < 20; i = i + 1) begin
            write_data(8'h40 + i);
            read_data(8'h40 + i);
        end

        $display("POINTER WRAPAROUND PASS");

        // TEST 9: Simultaneous read/write at FULL
        $display("\nTEST 9: SIMULTANEOUS OPERATION AT FULL");

        for (i = 0; i < 16; i = i + 1)
            write_data(8'h20 + i);

        if (!full)
            $fatal(1, "FAIL: FIFO should be full");

        @(negedge clk);
        wr_en = 1;
        rd_en = 1;
        din = 8'hEE;

        @(posedge clk);
        #1;

        if (dout !== 8'h20)
            $fatal(1, "FAIL: Incorrect read during FULL");

        if (full || dut.count !== 5'd15)
            $fatal(1, "FAIL: Incorrect occupancy after simultaneous operation");

        @(negedge clk);
        wr_en = 0;
        rd_en = 0;

        for (i = 1; i < 16; i = i + 1)
            read_data(8'h20 + i);

        if (!empty)
            $fatal(1, "FAIL: FIFO should be empty");

        $display("FULL SIMULTANEOUS OPERATION PASS");

        // FINAL RESULT
        $display("\n================================");
        $display(" ALL 9 TESTS COMPLETED SUCCESSFULLY");
        $display(" SYNCHRONOUS FIFO VERIFICATION PASS");
        $display("================================");

        $finish;

    end

endmodule
