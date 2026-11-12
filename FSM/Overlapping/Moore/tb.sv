module tb;
logic clk,rst,x,out;

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

    //Sequence
    @(negedge clk);
    x=1'b1;

    @(negedge clk);
    x=1'b0;

    @(negedge clk);
    x=1'b1;

    @(negedge clk);
    x=1'b0;

    @(negedge clk);
    x=1'b1;   

    @(posedge clk);
    #1;

    if (out !==1'b1)
        $fatal(1,"TEST FAILED: 10101 not detected");
    else
        $display("TEST PASSED:10101 detected");

    //Testing Overlapping
    @(negedge clk);
    x=1'b0;

    @(negedge clk);
    x=1'b1;

    @(posedge clk);
    #1;
    if (out !==1'b1)
        $fatal(1,"TEST FAILED: 1010101 not detected");
    else
        $display("TEST PASSED:1010101 detected");
    
    //Check return to S0
    @(negedge clk);
    x=0;
    @(posedge clk);
    #1;
    if(out !== 1'b0)
        $fatal(1,"TEST FAILED: Output did not return to 0");
    else
        $display("TEST PASSED: Output returned to 0");

    $display("Simulation Completed");
    $finish;

end
endmodule


