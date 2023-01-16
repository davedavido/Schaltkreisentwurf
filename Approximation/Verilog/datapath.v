module datapath(
    clk,
    rst, 
    start_i,
	start_scaler_i,
    check_for_termination_i,
    x_i,
    numIt_i,
    mode_i,

    // Write Flags
    wren_x1_i,
    wren_x1_n_i, 
	wren_x1_n_mult_i,
    wren_y_i, 
    wren_n_i, 
    wren_sigma_n_i,
	wren_x_i,
	
	// Scaler //
	shift_y_left_i,
	shift_y_right_i,
	

    // Register Transfer
    x_to_alu_a_i, 
    y_to_alu_a_i,
    x1_to_alu_a_i, 
    x1_n_to_alu_b_i, 
    sigma_n_to_alu_i,
    n_to_alu_a_i,
	x_to_scaler_i,	

    valid_o,
    y_o,
	done_o

);

/* Ein- und Ausgänge */
input           clk, rst;
input           start_i, check_for_termination_i, start_scaler_i;
input signed [15:0] 	x_i;
input [2:0]     numIt_i;
input [2:0]     mode_i;
input           wren_x1_i,wren_x1_n_i, wren_x1_n_mult_i, wren_y_i, wren_n_i, wren_sigma_n_i, wren_x_i;
input 			shift_y_left_i, shift_y_right_i;
input           x_to_alu_a_i, y_to_alu_a_i, x1_to_alu_a_i, x1_n_to_alu_b_i, sigma_n_to_alu_i, n_to_alu_a_i, x_to_scaler_i;  

output wire       valid_o, done_o;
output wire [15:0] y_o;

/* Intern */
reg             	start_r;
reg [2:0]       	numIterations_r, numIterations_temp;
reg [2:0]       	n_r, n_temp, numIt_r;
reg signed [15:0]    x_r, x_temp, x_temp_r; // Eingang Q4.12
reg [15:0]	y_r, y_temp, y_temp_r; 			// Ausgang Q5.12
reg             	sigma_n_r, sigma_n_temp;
reg signed [15:0]   x1_r, x1_temp ; // (x-1) 
reg signed [15:0]   x1_n_r, x1_n_temp; //(x-1)^2

/* Busse */
reg signed [15:0]	alu_a_temp, alu_b_temp; 
reg					alu_sigma_temp;
wire signed [31:0]	wbb;

/* ALU Ausgang */
reg signed[31:0] alu_out_r;
wire signed [31:0] alu_out;

/* SCALER Ausgang */
reg signed [15:0] scaler_out_r;
wire signed [15:0] scaler_out;

reg signed	[15:0]  scaler_in_temp;
wire [2:0]	shift_l_temp, shift_r_temp;
reg  [2:0]	shift_l_r, shift_r_r;

wire 				done_o_temp;
reg					done_o_r;


/* ALU Instanzierung */

alu ALU(
    .clk        (clk),
    .rst        (rst),
    .op_a_i     (alu_a_temp),
    .op_b_i     (alu_b_temp),
    .sigma_n_i  (alu_sigma_temp),
    .mode_i     (mode_i),

    .res_o      (alu_out)
);

scaler SCALER(
	.clk		(clk),
	.rst		(rst),
	.start_scaler_i    (start_scaler_i),
	.x_i		(scaler_in_temp),
	.x_scaled_o	(scaler_out),
	.shift_l_o	(shift_l_temp),
	.shift_r_o	(shift_r_temp),
	.done_o		(done_o_temp)


);

always @ (posedge clk) begin

    if (rst) begin
        numIterations_r <= 'd0;
        n_r             <= 'd0;
        numIt_r         <= 'd0;
        x_r             <= 'd0;
        y_r             <= 'd0;
        x_temp_r        <= 'd0;
        y_temp_r        <= 'd0;
        sigma_n_r       <= 'd0;
        x1_r            <= 'd0;
        x1_n_r          <= 'd0;
        start_r         <= 'd0;
        alu_out_r       <= 'd0;
		shift_l_r		<= 'd0;
		shift_r_r		<= 'd0;
		scaler_out_r	<= 'd0;
    end

    else begin
        numIterations_r <= numIterations_temp;
        numIt_r         <= numIt_i;
        n_r             <= n_temp;
        x_r             <= x_i;
        x_temp_r        <= x_temp;
        y_temp_r        <= y_temp;
        x1_n_r          <= x1_n_temp;
        x1_r            <= x1_temp;
        sigma_n_r       <= sigma_n_temp;
        start_r         <= start_i;
        alu_out_r       <= alu_out;
		scaler_out_r    <= scaler_out;
		shift_l_r		<= shift_l_temp;
		shift_r_r		<= shift_r_temp;
		done_o_r		<= done_o_temp;
    end

end

always @ (*) begin
    alu_a_temp          ='d0;
    alu_b_temp          ='d0;
	alu_sigma_temp 		='b0;
	scaler_in_temp		='b0;
    numIterations_temp  = numIterations_r;
    n_temp              = n_r;
    sigma_n_temp        = sigma_n_r;
    x1_n_temp           = x1_n_r;
    x1_temp             = x1_r;
    y_temp              = y_temp_r;
    x_temp              = x_temp_r;

    /* Startwerte Register */
    if (start_r) begin
        numIterations_temp     = numIt_r;
        n_temp              = 'd1; //Startvorzeichen = - (LSB = 1)
        sigma_n_temp        = 1'd1;  // Vorzeichen = LSB von n
        y_temp              = 16'd4096; //Startwert y=1
        x1_temp             = 'd0;
        x1_n_temp           = 'd0;
        x_temp              = x_r;

		
    end

    /* Schreibelogik*/
    
    if(wren_y_i) begin
        y_temp  = wbb[15:0];
    end
    if(wren_x1_i) begin
        x1_temp = wbb[15:0];    	// (x-1)
    end
    if(wren_x1_n_mult_i)begin
        x1_n_temp = wbb>>12;	// (x-1)^n 
    end
	if(wren_x1_n_i)begin
        x1_n_temp = wbb[15:0];	// (x-1)^n  
    end
    if(wren_n_i)begin
        n_temp  = wbb[15:0];
    end
    if(wren_sigma_n_i)begin
        sigma_n_temp = wbb[0]; //LSB aus Addition 1 + n
    end
	if(wren_x_i) begin
		x_temp = scaler_out;
	end
	
	/* Shiftlogik */
	
	if (shift_y_left_i)begin
		y_temp = y_temp_r << shift_l_r; 
	end
	
	if (shift_y_right_i) begin
		y_temp = y_temp_r >> shift_r_r;
	end
	
    /* Register Transferlogik */

    /* ALU Eingang a */
    if(x_to_alu_a_i)begin
        alu_a_temp = x_temp_r;
    end
    else if(y_to_alu_a_i) begin
        alu_a_temp = y_temp_r;
    end
    else if(x1_to_alu_a_i) begin
        alu_a_temp = x1_r;
    end
    else if(n_to_alu_a_i) begin
        alu_a_temp = n_r;
    end

    /* ALU Eingang b */
    if(x1_n_to_alu_b_i) begin
        alu_b_temp = x1_n_r;
    end

    /* ALU Sigma in */
    if(sigma_n_to_alu_i) begin
        alu_sigma_temp = sigma_n_r;
    end
	
	/* SCALER */
	if(x_to_scaler_i) begin
		scaler_in_temp = x_temp_r;
		
	end
end
    assign valid_o  = check_for_termination_i & (n_r == numIterations_r);
    assign wbb      = alu_out_r;
    assign y_o      = y_temp_r ;
	assign done_o   = done_o_r;
endmodule