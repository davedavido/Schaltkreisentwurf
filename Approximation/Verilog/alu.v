module alu(
	clk,
	rst,
	op_a_i,
	op_b_i,
	sigma_n_i,
	mode_i,
	
	res_o
);

/* Parameter */
localparam ADD_ONE      = 3'd0;  // A + 1
localparam SUB_ONE      = 3'd1;  // A - 1
localparam ADD_SUB      = 3'd2;  // Y +/- (x-1)
localparam MULTIPLY     = 3'd3;
localparam ALU_IDLE     = 3'd4; 

/* Ein- Ausgänge */
input clk, rst;
input [7:0] op_a_i, op_b_i;
input sigma_n_i;
input mode_i;

output reg [7:0]res_o;

/* Intern */

reg [15:0] res_temp_r;

always @ (*) begin
	
	case(mode_i)
        ADD_ONE: begin
            res_o = op_a_i + 8'd1;
        end

        SUB_ONE: begin
            res_o = op_a_i - 8'd1;
        end

        ADD_SUB: begin
            res_o = (sigma_n_i == 1'b1) ? (op_a_i - op_b_i) : (op_a_i + op_b_i);
        end

        MULTIPLY: begin
                res_temp_r = op_a_i * op_b_i;
                res_o = res_temp_r >> 4; //Wieder auf 8- bit kürzen
        end

		default: res_o = 8'd0;
	endcase

end	


endmodule