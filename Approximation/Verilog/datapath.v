module datapath(
    clk,
    rst, 
    start_i,
    check_for_termination_i,
    x_i,
    numIt_i,
    mode_i,

    // Write Flags
    wren_x1_i,
    wren_x1_n_i, 
    wren_y_i, 
    wren_n_i, 
    wren_sigma_n_i,

    // Register Transfer
    x_to_alu_a_i, 
    y_to_alu_a_i,
    x1_to_alu_a_i, 
    x1_n_to_alu_b_i, 
    sigma_n_to_alu_i,
    n_to_alu_a_i,  

    valid_o,
    y_o

);

/* Ein- und Ausgänge */
input           clk, rst;
input           start_i, check_for_termination_i;
input [7:0]     x_i;
input [2:0]     numIt_i;
input [2:0]     mode_i;
input           wren_x1_i,wren_x1_n_i, wren_y_i, wren_n_i, wren_sigma_n_i;
input           x_to_alu_a_i, y_to_alu_a_i, x1_to_alu_a_i, x1_n_to_alu_b_i, sigma_n_to_alu_i, n_to_alu_a_i;  

output wire       valid_o;
output wire [7:0] y_o;

/* Intern */
reg             start_r;
reg [2:0]       numIterations_r, numIterations_temp;
reg [2:0]       n_r, n_temp, numIt_r;
reg [7:0]       x_r, x_temp, x_temp_r; // Eingang
reg [7:0]       y_r, y_temp, y_temp_r; // Ausgang
reg             sigma_n_r, sigma_n_temp;
reg [7:0]       x1_r, x1_temp ; // (x-1) 
reg [7:0]       x1_n_r, x1_n_temp; //(x-1)^2

/* Busse */
reg [7:0] alu_a_temp, alu_b_temp, alu_sigma_temp;
wire[7:0] wbb;

/* ALU Ausgang */
reg [7:0] alu_out_r;
wire [7:0] alu_out;

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
    end

end

always @ (*) begin
    alu_a_temp          ='d0;
    alu_b_temp          ='d0;
    numIterations_temp  = numIterations_r;
    n_temp              = n_r;
    sigma_n_temp        = sigma_n_r;
    x1_n_temp           = x1_n_r;
    x1_temp             = x1_r;
    y_temp              = y_temp_r;
    x_temp              = x_temp_r;

    /* Startwerte Register */
    if (start_r) begin
        numIterations_r     = numIt_r;
        n_temp              = 'd1; //Startvorzeichen = - (LSB = 1)
        sigma_n_temp        = n_r[0];  // Vorzeichen = LSB von n
        y_temp              = 'd1; //Startwert y=1
        x1_temp             = 'd0;
        x1_n_temp           = 'd0;
        x_temp              = x_r;
    end

    /* Schreibelogik*/
    
    if(wren_y_i) begin
        y_temp  = wbb;
    end
    if(wren_x1_i) begin
        x1_temp = wbb;
    end
    if(wren_x1_n_i)begin
        x1_n_temp = wbb;
    end
    if(wren_n_i)begin
        n_temp  = wbb;
    end
    if(wren_sigma_n_i)begin
        sigma_n_i = wbb[0]; //LSB aus Addition 1 + n
    end

    /* Register Transferlogik */

    /* ALU Eingang a */
    if(x_to_alu_a_i,)begin
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
        alu_sigma_temp = sigma_n_r
    end

    assign valid_o  = check_for_termination_i & (wbb == numIterations_r);
    assign wbb      = alu_out_r;
    assign y_o      = y_temp_r;
end
endmodule