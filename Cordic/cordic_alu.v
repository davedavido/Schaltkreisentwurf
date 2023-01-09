module cordic_alu(
	clk,
	rst,
	op_a_i,
	op_b_i,
	op_c_i,
	mode_i,
	
	res_o
);

localparam SHIFT_A_WITH_B 		= 3'd0;
localparam SIGN_MULT_C_WITH_B 	= 3'd1;
localparam ADD_B_WITH_C 		= 3'd2;
localparam SIGN_MULT_A_WITH_B	= 3'd3;
localparam SUB_B_WITH_C 	 	= 3'd4;
localparam ADD_A_WITH_B 		= 3'd5;
localparam ALU_IDLE 			= 3'd7;

input clk, rst;
input signed [15:0] op_a_i, op_b_i, op_c_i;
input [2:0] mode_i;

output reg [15:0] res_o;

always @ (*) begin
	
	case(mode_i)
		SHIFT_A_WITH_B: begin
			res_o = op_a_i >>> op_b_i;
		end
		
		SIGN_MULT_C_WITH_B: begin
			res_o = (op_b_i == 1'b1) ? -op_c_i : op_c_i;
		end
		
		ADD_B_WITH_C: begin
			res_o = op_b_i + op_c_i;
		end
		
		SIGN_MULT_A_WITH_B: begin
			res_o = (op_b_i == 1'b1) ? -op_a_i : op_a_i;
		end
	
		SUB_B_WITH_C: begin
			res_o = op_b_i - op_c_i;
		end
		
		ADD_A_WITH_B: begin
			res_o = op_a_i + op_b_i;
		end
	
		default: res_o = 'd0;
	endcase

end	
	
endmodule

	