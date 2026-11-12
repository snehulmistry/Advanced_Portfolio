module rtl(
    input logic clk,rst,x,
    output logic out
);

typedef enum logic [2:0] { 
    S0,S1,S2,S3,S4
} state_t;

state_t state,next_state;
//State Register
always_ff @( posedge clk or posedge rst) begin 
    if(rst)
        state <=S0;
    else
        state <=next_state;
end

//Next State Logic
always_comb begin 
    next_state=state;
    out =1'b0;

    case(state)
    S0:begin
        if(x)
            next_state =S1;
        else
            next_state =S0;
        
    end

    S1:begin
        if(x)
            next_state = S1;
        else
            next_state=S2;
    end

    S2:begin
        if(x)
            next_state=S3;
        else
            next_state=S0;
    end

    S3:begin
        if(x)
            next_state=S1;
        else
            next_state=S4;
    end

    S4:begin
        if(x) begin
            //Detection!
            next_state=S3;
            out =1'b1;
        end
        else begin
            next_state=S0;
        end
    end

default: begin
    next_state = S0;
    out=1'b0;
end
    endcase
end
endmodule

