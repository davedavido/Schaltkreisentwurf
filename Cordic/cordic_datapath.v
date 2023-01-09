module cordic_datapath(
	clk,
	rst,
	start_i,
	check_for_termination_i,
	x_i,
	y_i,
	phi_i,
	numIt_i,
	edb_i,
	mode_i,
	
	//// write Back flags
	wren_y_n_i,
	wren_x_n_i,
	wren_phi_sum_i,
	wren_sigma_n_i,
	wren_x_0_i,
	wren_y_0_i,
	
	// Register transfer
	x_0_to_alu_a_i,
	x_0_to_alu_b_i,
	n_to_alu_b_i,
	sigma_n_to_alu_b_i,
	y_0_to_alu_a_i,
	y_0_to_alu_b_i,
	edb_to_alu_a_i,
	phi_sum_to_alu_b_i,
	phi_to_alu_b_i,
	one_to_alu_a_i,
	
	eab_o,
	valid_o,
	x_o,
	y_o,
	deg_o
);


input 					clk, rst;
input  			[15:0] 	edb_i;
input 	signed 	[7:0] 	phi_i;
input 			[2:0]	numIt_i;
input	signed 	[15:0]	x_i, y_i;
input 			[2:0]	mode_i;
input 					wren_y_n_i, wren_x_n_i, wren_phi_sum_i, wren_sigma_n_i, wren_x_0_i, wren_y_0_i;
input 					x_0_to_alu_a_i, x_0_to_alu_b_i, n_to_alu_b_i, sigma_n_to_alu_b_i, y_0_to_alu_a_i, y_0_to_alu_b_i, edb_to_alu_a_i, phi_sum_to_alu_b_i, phi_to_alu_b_i, one_to_alu_a_i;
input 					start_i,check_for_termination_i;

output 	wire	[2:0] 	eab_o;
output wire 	[15:0]	 x_o, y_o;
output wire 			valid_o;
output wire 	[15:0] deg_o;
	

// Variablenregister
reg 		[2:0] 	numIterations_r, numIterations_temp;
reg 		[2:0] 	n_r, n_temp, numIt_r;
reg signed 	[7:0] 	phi_r;
reg signed 	[15:0] 	phi_save_r, phi_save_temp;
reg signed 	[15:0] 	phi_sum_r, phi_sum_temp;
reg	signed 	[15:0] 	x_r, y_r;
reg	signed 	[15:0] 	x_0_r, y_0_r, x_0_temp, y_0_temp;
reg	signed 	[15:0] 	x_n_r, y_n_r, x_n_temp, y_n_temp;
reg 			  	sigma_n_r, sigma_n_temp;
reg 				start_r;

/// interne Busse
reg signed [15:0] 	alu_a_temp, alu_b_temp;
wire signed [15:0]  wbb;

// ALU Ausgangsregister alu_c_r
reg 	signed [15:0] alu_c_r;
wire 	signed [15:0] alu_c;

/// ALU Instanziierung
cordic_alu ALU(
	.clk		(clk),
	.rst 		(rst),
	.op_a_i		(alu_a_temp),
	.op_b_i 	(alu_b_temp),
	.op_c_i		(alu_c_r),
	.mode_i		(mode_i),
	
	.res_o	 	(alu_c)
);



always @ (posedge clk) begin
	if(rst) begin
		numIterations_r <= 'd0;
		n_r 			<= 'd0;
		phi_r 			<= 'd0;
		phi_save_r 		<= 'd0;
		phi_sum_r 		<= 'd0;
		x_r 			<= 'd0;
		y_r 			<= 'd0;
		x_0_r 			<= 'd0;
		y_0_r			<= 'd0;
		x_n_r 			<= 'd0;
		y_n_r			<= 'd0;
		sigma_n_r 		<= 'd0;
		start_r			<= 'd0;
		alu_c_r 		<= 'd0;
		numIt_r 		<= 'd0;
	end
	else begin
		numIterations_r <= numIterations_temp;
		n_r 			<= n_temp;
		phi_r 			<= phi_i;
		phi_save_r 		<= phi_save_temp;
		phi_sum_r 		<= phi_sum_temp;
		x_r 			<= x_i;
		y_r 			<= y_i;
		x_0_r 			<= x_0_temp;
		y_0_r			<= y_0_temp;
		x_n_r 			<= x_n_temp;
		y_n_r			<= y_n_temp;
		sigma_n_r 		<= sigma_n_temp;
		start_r			<= start_i;
		alu_c_r 		<= alu_c;
		numIt_r 		<= numIt_i;
	end
end

always @ (*) begin
	alu_a_temp 			= 'd0;
	alu_b_temp 			= 'd0;
	numIterations_temp 	= numIterations_r;
	n_temp 				= n_r;
	phi_save_temp 		= phi_save_r;
	phi_sum_temp 		= phi_sum_r;
	x_0_temp			= x_0_r;
	y_0_temp			= y_0_r;
	x_n_temp			= x_n_r;
	y_n_temp			= y_n_r;
	sigma_n_temp		= sigma_n_r;
	
	/// Initialize Registers upon start_i
	if(start_r) begin
		numIterations_temp  = numIt_r;
		n_temp 				= 'd0; 
		phi_save_temp 		= {phi_r,8'd0};
		phi_sum_temp 		= 'd0;
		x_0_temp 			= x_r;
		y_0_temp 			= y_r;
		sigma_n_temp 		= phi_r[7];
	end
	
	/// Write Back Logic ///////////////////
	if(wren_y_n_i) begin
		y_n_temp = wbb;
	end
	
	if(wren_x_n_i) begin
		x_n_temp = wbb;
	end
	
	if(wren_phi_sum_i) begin
		phi_sum_temp = wbb;
	end
	
	if(wren_sigma_n_i) begin
		sigma_n_temp = wbb[15];
	end
	
	if(wren_x_0_i) begin
		x_0_temp = x_n_r;
	end
	
	if(wren_y_0_i) begin
		y_0_temp = y_n_r;
	end
	
	if(check_for_termination_i) begin
		n_temp = wbb[2:0];
	end
	
	// Register Transfer logic

	if(x_0_to_alu_a_i) begin
		alu_a_temp = x_0_r;
	end
	else if(y_0_to_alu_a_i) begin
		alu_a_temp = y_0_r;
	end
	else if(edb_to_alu_a_i) begin
		alu_a_temp = edb_i;
	end
	else if(one_to_alu_a_i) begin
		alu_a_temp = 16'd1;
	end
	
	if(x_0_to_alu_b_i) begin
		alu_b_temp = x_0_r;
	end
	else if(y_0_to_alu_b_i) begin
		alu_b_temp = y_0_r;
	end
	else if(n_to_alu_b_i) begin
		alu_b_temp = n_r;
	end
	else if(sigma_n_to_alu_b_i) begin
		alu_b_temp[0] = sigma_n_r;
	end
	else if(phi_sum_to_alu_b_i) begin
		alu_b_temp = phi_sum_r;
	end
	else if(phi_to_alu_b_i) begin
		alu_b_temp = phi_save_r;
	end
end
	
assign valid_o	= check_for_termination_i & (wbb == numIterations_r);
assign eab_o 	= n_r;
assign wbb 		= alu_c_r;
assign x_o		= x_0_r;
assign y_o 		= y_0_r; //y_temp_r
assign deg_o 	= phi_sum_r;
	
endmodule