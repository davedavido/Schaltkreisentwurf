`include "parameter.v"

module scaler(clk, rst, start_scaler_i, x_i, x_scaled_o, shift_l_o, shift_r_o, done_o);

/* parameters */
parameter W = 16;//INPUT_BIT_WIDTH;

/* i/o ports */
input clk, rst, start_scaler_i;
input signed [(W-1):0] x_i;
output reg signed [(W-1):0] x_scaled_o;
output reg [2:0] shift_l_o, shift_r_o;
output reg done_o;

/* Intern */
reg count_l, count_r;

always @ (posedge clk) begin
	if(rst) begin
		shift_l_o 	<= 'd0;
		shift_r_o 	<= 'd0;
		x_scaled_o 	<= 'd0;
		done_o		<= 'd0;
		count_l		<= 'd0;
		count_r		<= 'd0;
	end
	else begin
		if (count_l) begin
			shift_l_o <= shift_l_o + 'd1;
		end
		
		else if (count_r) begin
			shift_r_o <= shift_r_o + 'd1;
		end
	
	end
end


/* kombinatorischer block */
always @(*) begin

	count_l = 'd0;
	count_r = 'd0;

	if (start_scaler_i)begin
	
		if (x_i > 'd5734) begin  //Upper bound = 1.4
			x_scaled_o = x_i >>1;
			shift_l_o = 1'b0;
			done_o = 1'b0;
			count_r = 'd1;
		end
		else if(x_i < 'd2458)begin // Lower bound = 0.6
			x_scaled_o = x_i <<1;
			shift_r_o = 1'b0;
			done_o = 1'b0;
			count_l = 'd1;
		end
		else begin
			x_scaled_o = x_i;
			done_o = 1'b1;
			count_l = 'd0;
			count_r = 'd0;
		end
	end
end

endmodule