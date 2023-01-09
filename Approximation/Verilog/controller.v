module controller (
    clk,
    rst,
    start_i,
    valid_i,

    busy_o,
    mode_o,
    check_for_termination_o,
    /* write enable*/
    wren_x1_o,
    wren_x1_n_o, 
    wren_y_o, 
    wren_n_o, 
    wren_sigma_n_o
    /* register transfer */
    x_to_alu_a_o, 
    y_to_alu_a_o,
    x1_to_alu_a_o, 
    x1_n_to_alu_b_o, 
    sigma_n_to_alu_o,
    n_to_alu_a_o    
);

/* ALU Anweisungen */

localparam ADD_ONE      = 3'd0;  // A + 1
localparam SUB_ONE      = 3'd1;  // A - 1
localparam ADD_SUB      = 3'd2;  // Y +/- (x-1)
localparam MULTIPLY     = 3'd3;
localparam ALU_IDLE     = 3'd4;

/* Zustände */
localparam IDLE         =3'd0;
localparam SUB1         =3'd1;
localparam WB           =3'd2;
localparam ADDSUB       =3'd3;
localparam ADD          =3'd4;
localparam MULT         =3'd5;
localparam WB2          =3'd6;
localparam ENDIT        =3'd7;

/* Ein- und Ausgänge */
input clk, rst;
input start_i, valid_i;
output reg busy_o;
output reg [2:0] mode_o;
output reg check_for_termination_o;

/* Register Transfer zu Zurückschreiben von Ergebnissen in Register*/
output reg wren_x1_o, wren_x1_n_o, wren_y_o, wren_n_o, wren_sigma_n_o;

/* Register Transfer auf die ALU Datenbusse */
output reg x_to_alu_a_o, y_to_alu_a_o,x1_to_alu_a_o, x1_n_to_alu_b_o, sigma_n_to_alu_o, n_to_alu_a_o;

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

    /* register write enable */
    wren_x1_o                   = 1'b0;
    wren_x1_n_o                 = 1'd0;
    wren_y_o                    = 1'd0;
    wren_n_o                    = 1'd0;
    wren_sigma_n_o              = 1'd0;

    /* register transfer */
    x_to_alu_a_o                = 1'd0;
    y_to_alu_a_o                = 1'd0;
    x1_to_alu_a_o               = 1'd0;
    x1_n_to_alu_b_o             = 1'd0;
    sigma_n_to_alu_o            = 1'd0;
    n_to_alu_a_o                = 1'd0;



case(current_state)
    IDLE: begin
        bussy_o = 1'd0;
        if(start_r == 1'b1)begin
        next_state = SUB1;
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
        mode_o = ADD_SUB
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
        wren_x1_n_o     = 1'd1;
        next_state = ENDIT;
    end

    ENDIT: begin
        check_for_termination_o = 1'd1;
        next_state = ADDSUB;
    end
    
endcase

if(valid_r == 1'b1) begin
		next_state = IDLE;
	end

end

endmodule