module fifo(
    input logic clk,
    input logic rst,

    input logic wr_en,
    input logic rd_en,
    
    input logic [7:0] din,
    output logic [7:0] dout,

    output logic full,
    output logic empty
    
);

    logic [7:0] mem [0:15];
    logic [3:0] wr_ptr;
    logic [3:0] rd_ptr;
    logic [4:0] count;
    logic write_accept;
    logic read_accept;


    assign empty = (count ==0);
    assign full = (count ==16);
    assign write_accept = wr_en && !full;
    assign read_accept = rd_en && !empty;


always_ff @( posedge clk ) begin 
    if(rst) begin
        wr_ptr <=0;
    end
    else if(write_accept) begin
        mem[wr_ptr] <=din;
        wr_ptr <= wr_ptr + 1'b1;
    end
end

always_ff @(posedge clk) begin
    if(rst) begin
        rd_ptr<=0;
        dout <=0;
    end
    else if(read_accept)begin
        dout <= mem[rd_ptr];
        rd_ptr <= rd_ptr + 1'b1;
    end
end

always_ff @(posedge clk) begin
    if(rst) begin
        count <=0;
    end
    else begin
        case({write_accept,read_accept})

        2'b00: count <= count;
        2'b01: count <= count -1'b1;
        2'b10: count <= count +1'b1;
        2'b11: count <= count;
        endcase
    end
end


endmodule
