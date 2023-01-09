module cordic_top(
	rst,
	clk,
	x_i,
	y_i,
	nIt_i,
	phi_deg_i,
	start_i,
	
	bussy_o,
	x_o,
	y_o,
	deg_o,
	valid_o,
);

input 					clk, rst;
input 					start_i;
input 			[15:0] 	x_i, y_i;
input 			[7:0] 	phi_deg_i;
input 			[2:0]	nIt_i;

output wire 	[15:0]	x_o, y_o;
output wire 			valid_o, bussy_o;
output wire 	[15:0] 	deg_o;

// internal wires;

wire 			check_for_termination, wren_y_n, wren_x_n, wren_phi_sum, wren_sigma_n, wren_x_0, wren_y_0;
wire 			x_0_to_alu_a, x_0_to_alu_b, n_to_alu_b, sigma_n_to_alu_b, y_0_to_alu_a, y_0_to_alu_b, edb_to_alu_a, phi_sum_to_alu_b, phi_to_alu_b, one_to_alu_a;
wire 	[15:0] 	edb;
wire 	[2:0] 	eab;
wire 	[2:0] 	alu_mode;

cordic_datapath DATAPATH(
	.clk						(clk),
	.rst						(rst),
	.start_i					(start_i),
	.check_for_termination_i	(check_for_termination),
	.x_i						(x_i),
	.y_i						(y_i),
	.phi_i						(phi_deg_i),
	.numIt_i					(nIt_i),
	.edb_i						(edb),
	.mode_i						(alu_mode),
	
	//// write Back flags
	.wren_y_n_i					(wren_y_n),
	.wren_x_n_i					(wren_x_n),
	.wren_phi_sum_i				(wren_phi_sum),
	.wren_sigma_n_i				(wren_sigma_n),
	.wren_x_0_i					(wren_x_0),
	.wren_y_0_i					(wren_y_0),
	
	// Register transfer
	.x_0_to_alu_a_i 			(x_0_to_alu_a),
	.x_0_to_alu_b_i				(x_0_to_alu_b),
	.n_to_alu_b_i				(n_to_alu_b),
	.sigma_n_to_alu_b_i			(sigma_n_to_alu_b),
	.y_0_to_alu_a_i				(y_0_to_alu_a),
	.y_0_to_alu_b_i				(y_0_to_alu_b),
	.edb_to_alu_a_i				(edb_to_alu_a),
	.phi_sum_to_alu_b_i			(phi_sum_to_alu_b),
	.phi_to_alu_b_i 			(phi_to_alu_b),
	.one_to_alu_a_i				(one_to_alu_a),
	
	.eab_o						(eab),
	.valid_o					(valid_o),
	.x_o						(x_o),
	.y_o						(y_o),
	.deg_o						(deg_o)
);

cordic_controller CNTR(
	.clk						(clk),
	.rst						(rst),
	.start_i					(start_i),
	.valid_i					(valid_o),
	
	.bussy_o					(bussy_o),
	.mode_o						(alu_mode),
	.check_for_termination_o	(check_for_termination),
	//// write Back flags
	.wren_y_n_o					(wren_y_n),
	.wren_x_n_o 				(wren_x_n),
	.wren_phi_sum_o				(wren_phi_sum),
	.wren_sigma_n_o				(wren_sigma_n),
	.wren_x_0_o					(wren_x_0),
	.wren_y_0_o					(wren_y_0),
	
	// Register transfer
	.x_0_to_alu_a_o				(x_0_to_alu_a),
	.x_0_to_alu_b_o				(x_0_to_alu_b),
	.n_to_alu_b_o				(n_to_alu_b),
	.sigma_n_to_alu_b_o			(sigma_n_to_alu_b),
	.y_0_to_alu_a_o				(y_0_to_alu_a),
	.y_0_to_alu_b_o				(y_0_to_alu_b),
	.edb_to_alu_a_o				(edb_to_alu_a),
	.phi_sum_to_alu_b_o			(phi_sum_to_alu_b),
	.phi_to_alu_b_o				(phi_to_alu_b),
	.one_to_alu_a_o				(one_to_alu_a)
);

cordic_rom LUT_ROM(
	.eab_i		(eab),
	.clk		(clk),
	.edb_o		(edb)
);

endmodule
