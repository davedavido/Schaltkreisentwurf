module cordic_controller(
	clk,
	rst,
	start_i,
	valid_i,
	
	bussy_o,
	mode_o,
	check_for_termination_o,
	//// write Back flags
	wren_y_n_o,
	wren_x_n_o,
	wren_phi_sum_o,
	wren_sigma_n_o,
	wren_x_0_o,
	wren_y_0_o,
	
	// Register transfer
	x_0_to_alu_a_o,
	x_0_to_alu_b_o,
	n_to_alu_b_o,
	sigma_n_to_alu_b_o,
	y_0_to_alu_a_o,
	y_0_to_alu_b_o,
	edb_to_alu_a_o,
	phi_sum_to_alu_b_o,
	phi_to_alu_b_o,
	one_to_alu_a_o
);

localparam SHIFT_A_WITH_B 		= 3'd0;
localparam SIGN_MULT_C_WITH_B 	= 3'd1;
localparam ADD_B_WITH_C 		= 3'd2;
localparam SIGN_MULT_A_WITH_B	= 3'd3;
localparam SUB_B_WITH_C 	 	= 3'd4;
localparam ADD_A_WITH_B 		= 3'd5;
localparam ALU_IDLE 			= 3'd7;

localparam IDLE 				= 4'd0;	
localparam SHIFT1 				= 4'd1;
localparam SIGN1 				= 4'd2;
localparam ADD1 				= 4'd3;
localparam SHIFT2 				= 4'd4;
localparam SIGN2 				= 4'd5;
localparam SUB1 				= 4'd6;
localparam LUT 					= 4'd7;
localparam SIGN3 				= 4'd8;
localparam ADD2 				= 4'd9;
localparam SUB2 				= 4'd10;
localparam SIGN4 				= 4'd11;
localparam ADD3 				= 4'd12;
localparam ENDIT 				= 4'd13;



input 					clk, rst;
input 					start_i, valid_i;
output 	reg				bussy_o;
output 	reg		[2:0]	mode_o;

// Register Transfer zu Zurückschreiben von Ergebnissen in Register
output 	reg				wren_y_n_o, wren_x_n_o, wren_phi_sum_o, wren_sigma_n_o, wren_x_0_o, wren_y_0_o;

// Register Transfer auf die ALU Datenbusse
output 	reg				x_0_to_alu_a_o, x_0_to_alu_b_o, n_to_alu_b_o, sigma_n_to_alu_b_o, y_0_to_alu_a_o, y_0_to_alu_b_o, edb_to_alu_a_o, phi_sum_to_alu_b_o, phi_to_alu_b_o, one_to_alu_a_o;
output reg					check_for_termination_o;

// Variablenregister
reg 				start_r, valid_r;
reg [3:0] 			current_state, next_state;


always @ (posedge clk) begin
	if(rst) begin
		valid_r			<= 'd0;
		start_r			<= 'd0;
		current_state 	<= IDLE;
	end
	else begin
		valid_r			<= valid_i;
		start_r			<= start_i;
		current_state 	<= next_state;
	end
end

always @ (*) begin
	bussy_o 					= 1'b1;
	mode_o 						= ALU_IDLE;
	next_state 					= current_state;
	check_for_termination_o 	= 1'b0;
	/// Register write enable
	wren_y_n_o					= 1'b0;
	wren_x_n_o					= 1'b0;
	wren_phi_sum_o				= 1'b0;
	wren_sigma_n_o				= 1'b0;
	wren_x_0_o					= 1'b0;
	wren_y_0_o					= 1'b0;
	
	// Register transfer
	x_0_to_alu_a_o				= 1'b0;
	x_0_to_alu_b_o				= 1'b0;
	n_to_alu_b_o				= 1'b0;
	sigma_n_to_alu_b_o			= 1'b0;
	y_0_to_alu_a_o				= 1'b0;
	y_0_to_alu_b_o				= 1'b0;
	edb_to_alu_a_o				= 1'b0;
	phi_sum_to_alu_b_o			= 1'b0;
	phi_to_alu_b_o				= 1'b0;
	one_to_alu_a_o				= 1'b0;
	
	case(current_state)
		IDLE: begin
			bussy_o = 1'd0;
			if(start_r == 1'b1) begin
				next_state = SHIFT1;
			end
		end
		
		SHIFT1: begin
			x_0_to_alu_a_o		= 1'b1;
			n_to_alu_b_o 		= 1'b1;
			next_state 			= SIGN1;
			mode_o 				= SHIFT_A_WITH_B;
		end
		
		SIGN1: begin
			next_state 			= ADD1;
			sigma_n_to_alu_b_o	= 1'b1;
			mode_o 				= SIGN_MULT_C_WITH_B;
		end
		
		ADD1: begin
			next_state 			= SHIFT2;
			y_0_to_alu_b_o		= 1'b1;
			mode_o 				= ADD_B_WITH_C;
		end
		
		SHIFT2: begin
			next_state 			= SIGN2;
			y_0_to_alu_a_o 		= 1'b1;
			n_to_alu_b_o 		= 1'b1;
			mode_o 				= SHIFT_A_WITH_B;
			wren_y_n_o 			= 1'b1;
		end
		
		SIGN2: begin
			next_state 			= SUB1;
			sigma_n_to_alu_b_o 	= 1'b1;
			mode_o				= SIGN_MULT_C_WITH_B;
		end
		
		SUB1: begin
			next_state 			= LUT;
			x_0_to_alu_b_o 		= 1'b1;
			mode_o 				= SUB_B_WITH_C;
		end
		
		LUT: begin
			next_state 			= SIGN3;
			wren_x_n_o 			= 1'b1;	
		end
		
		SIGN3: begin
			next_state 			= ADD2;
			edb_to_alu_a_o 		= 1'b1;
			sigma_n_to_alu_b_o 	= 1'b1;
			mode_o 				= SIGN_MULT_A_WITH_B;
		end
		
		ADD2: begin
			next_state 			= SUB2;
			phi_sum_to_alu_b_o 	= 1'b1;
			mode_o 				= ADD_B_WITH_C;
		end
		
		SUB2: begin
			next_state 			= SIGN4;
			wren_phi_sum_o 		= 1'b1;
			phi_to_alu_b_o 		= 1'b1;
			mode_o 				= SUB_B_WITH_C;
		end
		
		SIGN4: begin
			next_state 			= ADD3;
			wren_sigma_n_o 		= 1'b1;
			wren_y_0_o 			= 1'b1;
		end
		
		ADD3: begin
			next_state 			= ENDIT;
			one_to_alu_a_o 		= 1'b1;
			n_to_alu_b_o 		= 1'b1;
			mode_o 				= ADD_A_WITH_B;
			wren_x_0_o 			= 1'b1;
		end
		
		ENDIT: begin
			next_state 				= SHIFT1;
			check_for_termination_o = 1'b1;
		end
		

		
	endcase
	
	if(valid_r == 1'b1) begin
		next_state = IDLE;
	end
	
end
	

	
endmodule