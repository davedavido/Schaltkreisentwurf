module approx_top (
	rst,
	clk,
	x_i,
	nIt_i,
	start_i,
	
	busy_o,
	y_o,
	valid_o);

/* Ein- und Ausgänge */
input					clk, rst;
input					start_i;
input signed	  [15:0] 	x_i;
input	  [2:0]			nIt_i;

output wire [15:0] 		y_o;
output	  		busy_o, valid_o;

/* Intern */

wire			check_for_termination, start_scaler, wren_x1, wren_x1_n, wren_x1_n_mult, wren_y, wren_n, wren_sigma_n, wren_x, shift_y_left, shift_y_right;
wire			x_to_alu_a, y_to_alu_a, x1_to_alu_a, x1_n_to_alu_b, sigma_n_to_alu, n_to_alu_a, x_to_scaler;

wire		[2:0] alu_mode;

wire		done_o;


/* Verbindungen */

datapath DATAPATH (
   .clk							(clk),
   .rst							(rst),
   .start_i                     (start_i),
   .start_scaler_i				(start_scaler),
   .check_for_termination_i     (check_for_termination),
   .x_i                         (x_i),
   .numIt_i                     (nIt_i),
   .mode_i                      (alu_mode),
								
   // Write Flags              
   .wren_x1_i                   (wren_x1),
   .wren_x1_n_i                 (wren_x1_n),
   .wren_x1_n_mult_i			(wren_x1_n_mult),
   .wren_y_i                    (wren_y),
   .wren_n_i                    (wren_n),
   .wren_sigma_n_i              (wren_sigma_n),
   .wren_x_i					(wren_x),
   
   // Shift Flags //
   .shift_y_left_i				(shift_y_left),
   .shift_y_right_i				(shift_y_right),
								
   // Register Transfer        
   .x_to_alu_a_i                (x_to_alu_a),
   .y_to_alu_a_i                (y_to_alu_a),
   .x1_to_alu_a_i               (x1_to_alu_a),
   .x1_n_to_alu_b_i             (x1_n_to_alu_b),
   .sigma_n_to_alu_i            (sigma_n_to_alu),
   .n_to_alu_a_i                (n_to_alu_a),
   .x_to_scaler_i				(x_to_scaler),
								
   .valid_o                     (valid_o),
   .y_o                         (y_o),
   .done_o						(done_o)
);

controller CONTROLLER (
	.clk						(clk),
    .rst                        (rst),
    .start_i                    (start_i),
    .valid_i                    (valid_o),
	.done_i						(done_o),
							    
    .busy_o                     (busy_o),
    .mode_o                     (alu_mode),
    .check_for_termination_o    (check_for_termination),
	.start_scaler_o             (start_scaler),
    /* write enable*/           
    .wren_x1_o                  (wren_x1),
    .wren_x1_n_o                (wren_x1_n),
	.wren_x1_n_mult_o			(wren_x1_n_mult),
    .wren_y_o                   (wren_y),
    .wren_n_o                   (wren_n),
    .wren_sigma_n_o             (wren_sigma_n),
	.wren_x_o					(wren_x),
	
	// Shift Flags //
   .shift_y_left_o				(shift_y_left),
   .shift_y_right_o				(shift_y_right),
   
    /* register transfer */     
    .x_to_alu_a_o               (x_to_alu_a),
    .y_to_alu_a_o               (y_to_alu_a),
    .x1_to_alu_a_o              (x1_to_alu_a),
    .x1_n_to_alu_b_o            (x1_n_to_alu_b),
    .sigma_n_to_alu_o           (sigma_n_to_alu),
    .n_to_alu_a_o               (n_to_alu_a),
	.x_to_scaler_o				(x_to_scaler)
);
endmodule       