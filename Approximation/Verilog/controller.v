module controller (
    clk,
    rst,
    start_i,
    valid_i,
	done_i,

    busy_o,
    mode_o,
    check_for_termination_o,
	start_scaler_o,
    /* write enable*/
    wren_x1_o,
    wren_x1_n_o, 
	wren_x1_n_mult_o,
    wren_y_o, 
    wren_n_o, 
    wren_sigma_n_o,
	wren_x_o, 
	
	/*shift enable */
	shift_y_left_o,
	shift_y_right_o,
	
    /* register transfer */
    x_to_alu_a_o, 
    y_to_alu_a_o,
    x1_to_alu_a_o, 
    x1_n_to_alu_b_o, 
    sigma_n_to_alu_o,
    n_to_alu_a_o,
	x_to_scaler_o
);

/* ALU Anweisungen */

localparam ADD_ONE      = 3'd0;  // A + 1
localparam SUB_ONE      = 3'd1;  // A - 1
localparam ADD_SUB      = 3'd2;  // Y +/- (x-1)
localparam MULTIPLY     = 3'd3;
localparam ALU_IDLE     = 3'd4;

/* Zustände */
localparam IDLE         =4'd0;
localparam SUB1         =4'd1;
localparam WB           =4'd2;
localparam ADDSUB       =4'd3;
localparam ADD          =4'd4;
localparam MULT         =4'd5;
localparam WB2          =4'd6;
localparam ENDIT        =4'd7;
localparam SCALEX		=4'd8;
localparam CHECKX		=4'd9;
localparam CHECKXWAIT	=4'd10;
localparam SCALEYLEFT	=4'd11;
localparam SCALEYRIGHT	=4'd12;


/* Ein- und Ausgänge */
input clk, rst;
input start_i, valid_i, done_i;
output reg busy_o;
output reg [2:0] mode_o;
output reg check_for_termination_o, start_scaler_o;

/* Register Transfer zu Zurückschreiben von Ergebnissen in Register*/
output reg wren_x1_o, wren_x1_n_o, wren_x1_n_mult_o, wren_y_o, wren_n_o, wren_sigma_n_o, wren_x_o ;

/* Scaling */
output reg shift_y_left_o, shift_y_right_o;

/* Register Transfer auf die ALU Datenbusse */
output reg x_to_alu_a_o, y_to_alu_a_o,x1_to_alu_a_o, x1_n_to_alu_b_o, sigma_n_to_alu_o, n_to_alu_a_o, x_to_scaler_o;

/* Interne Variablen */
reg         start_r, valid_r;
reg [3:0]   current_state, next_state;

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
	busy_o 					    = 1'b1;
	mode_o 						= ALU_IDLE;
	next_state 					= current_state;
	check_for_termination_o 	= 1'b0;
	start_scaler_o				= 1'b0;

    /* register write enable */
    wren_x1_o                   = 1'b0;
    wren_x1_n_o                 = 1'd0;
	wren_x1_n_mult_o			= 1'd0;
    wren_y_o                    = 1'd0;
    wren_n_o                    = 1'd0;
    wren_sigma_n_o              = 1'd0;
	wren_x_o					= 1'd0;
	
	/* Scale enable */
	
	shift_y_left_o				= 'd0;
	shift_y_right_o				= 'd0;

    /* register transfer */
    x_to_alu_a_o                = 1'd0;
    y_to_alu_a_o                = 1'd0;
    x1_to_alu_a_o               = 1'd0;
    x1_n_to_alu_b_o             = 1'd0;
    sigma_n_to_alu_o            = 1'd0;
    n_to_alu_a_o                = 1'd0;



case(current_state)
    IDLE: begin
        busy_o = 1'd0;
        if(start_r == 1'b1)begin
        next_state = SCALEX;
        end
    end
	
	SCALEX: begin
		x_to_scaler_o	= 1'b1;
		wren_x_o 		= 1'b1;
		start_scaler_o	= 1'b1;
		next_state = CHECKXWAIT;
	end
	
	CHECKXWAIT: begin
		next_state = CHECKX;
	
	end
	
	CHECKX: begin
		start_scaler_o	= 1'd0;
		if (done_i) begin
			next_state = SUB1;
		end
		else begin
			next_state = SCALEX;
		end
	end

    SUB1: begin
        x_to_alu_a_o = 1'b1; 
        mode_o = SUB_ONE;
        next_state = WB;
    end

    WB: begin
        wren_x1_o = 1'b1;
        wren_x1_n_o = 1'b1;
        next_state = ADDSUB;
    end

    ADDSUB: begin
        y_to_alu_a_o    = 1'd1;
        x1_n_to_alu_b_o = 1'd1;
        sigma_n_to_alu_o  = 1'd1;
        mode_o = ADD_SUB;
        next_state = ADD;
    end

    ADD: begin
        n_to_alu_a_o = 1'd1;
        wren_y_o     = 1'd1;
        mode_o = ADD_ONE;
        next_state = MULT;
    end

    MULT: begin
        wren_n_o        = 1'd1;
        wren_sigma_n_o  = 1'd1;
        x1_to_alu_a_o   = 1'd1;
        x1_n_to_alu_b_o = 1'd1;
        mode_o = MULTIPLY;
        next_state = WB2;
    end

    WB2: begin
        wren_x1_n_mult_o = 1'd1;
        next_state = ENDIT;
    end

    ENDIT: begin
        check_for_termination_o = 1'd1;
        next_state = ADDSUB;
    end
	
	SCALEYLEFT: begin
		shift_y_left_o = 1'd1;
		next_state = SCALEYRIGHT;
	end
	SCALEYRIGHT: begin
		shift_y_right_o	= 1'd1;
		next_state = IDLE;
	end
    
endcase

if(valid_r == 1'b1) begin
		next_state = SCALEYLEFT;
	end

end

endmodule