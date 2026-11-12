module tb;
logic clk;
logic rst;
logic x;
logic out;

//DUT
rtl DUT(
    .clk(clk),
    .rst(rst),
    .x(x),
    .out(out)
);

//Clock Generation
initial clk=0;
always #5 clk=~clk;

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0,tb);

    //Initial Conditions
    rst=1;
    x=0;

    #12;
    rst=0;

    //Input Sequence 101
    @(negedge clk);
    x=1;

    @(negedge clk);
    x=0;

    @(negedge clk);
    x=1;

    //Wait for FSM state register to update
    @(posedge clk);
    #1;

    if(out !== 1'b1)
        $error("Test Failed:101 not detected");
    else
        $display("Test Passed:101 detected");

    //Check return to 0
    @(negedge clk);
    x=0;

    @(posedge clk);
    #1;

    if(out!== 1'b0)
        $error("Test Failed:Output did not return to 0");
    else
        $display("Test Passed: Output returned to 0");

    $display("Simulation Completed");
    $finish;
end
endmodule
