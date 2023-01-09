`include "parameter.v"

module scaler(clk, rst, x_i, x_scaled_o, shift_l_o, shift_r_o, no_shift_o);

/* parameters */
parameter W = 8;//INPUT_BIT_WIDTH;

/* i/o ports */
input clk, rst;
input [(W-1):0] x_i;
output reg signed [(W-1):0] x_scaled_o;
output reg shift_l_o, shift_r_o, no_shift_o;

/* interne variablen */
reg [(W-1):0] x_i_r;

/* sequentieller block */
always @ (posedge clk) begin

    if (rst)begin
        x_i_r       <= 8'b0;
        x_scaled_o  <= 8'b0;
        shift_l_o   <= 8'b0;
        shift_r_o   <= 8'b0;
        no_shift_o  <= 8'b0;

    end 
    else begin
        x_i_r       <= x_i;
    end
end

/* kombinatorischer block */
always @(*) begin

    if (x_i_r > 8'b00010100) begin
        x_scaled_o = x_i_r >>1;
        shift_r_o = 1'b1;
        shift_l_o = 1'b0;
        no_shift_o = 1'b0;
    end
    else if(x_i_r < 8'b00001100)begin
        x_scaled_o = x_i_r <<1;
        shift_r_o = 1'b0;
        shift_l_o = 1'b1;
        no_shift_o = 1'b0;
    end
    else begin
        x_scaled_o = x_i_r;
        shift_r_o = 1'b0;
        shift_l_o = 1'b0;
        no_shift_o = 1'b1;
    end
end

endmodule