module rtl(
    input logic clk,
    input logic rst,
    input logic x,
    output logic out
);

typedef enum logic[1:0] { 
    S0,S1,S2,S3
} state_t;

state_t state,next_state;

//State Register
always_ff @(posedge clk) begin
    if(rst)
        state <=S0;
    else    
        state <= next_state;
end

//Next State Logic

always_comb begin
    case (state)

        S0: begin
            if (x)
                next_state = S1;
            else
                next_state = S0;
        end

        S1: begin
            if (x)
                next_state = S1;
            else
                next_state = S2;
        end

        S2: begin
            if (x)
                next_state = S3;
            else
                next_state = S0;
        end

        S3: begin
            next_state = S0;
        end

        default: begin
            next_state = S0;
        end

    endcase
end



//Output Logic
assign out = (state ==S3);

endmodule