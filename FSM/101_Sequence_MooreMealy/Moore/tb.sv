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
initial clk =0;
always #5 clk=~clk;

//Test
initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0,tb);

    //Initial Conditions
    rst=1;
    x=0;
    #12;
    rst =0;

    //Input Sequence:101
    @(negedge clk);
    x=1;

    @(negedge clk);
    x=0;

    @(negedge clk);
    x=1;

    //Wait for FSM to settle
    @(posedge clk);
    #1;

    if(out !== 1'b1)
        $error("TEST FAILED:101 not detected");
    else 
        $display("TEST PASSED: 101 detected");

    //Check return to S0
    @(negedge clk);
    x=0;
    @(posedge clk);
    #1;
    if(out !== 1'b0)
        $error("TEST FAILED: Output did not return to 0");
    else
        $display("TEST PASSED: Output returned to 0");

    $display("Simulation Completed");
    $finish;

end
endmodule