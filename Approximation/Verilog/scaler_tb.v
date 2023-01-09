`include "parameter.v"

module scaler_tb;

/* parameter */
parameter W = 8;//INPUT_BIT_WIDTH;


/* i/o ports*/
reg					clk;
reg					rst;
reg signed [(W-1):0] x_i;
reg 				tmp;

wire signed [(W-1):0]	x_scaled_o;
wire shift_l_o, shift_r_o, no_shift_o;

integer				fd_i, fd_o;

scaler DUT(
    .clk				(clk),
	.rst				(rst),
    .x_i				(x_i),
    .x_scaled_o         (x_scaled_o),
    .shift_l_o			(shift_l_o),
    .shift_r_o			(shift_r_o),
    .no_shift_o         (no_shift_o)
);

always
	#5 	clk=!clk;
	 
initial begin
	fd_i = $fopen("input.txt", "r");
	fd_o = $fopen("output.txt", "w");
	
	if (fd_i)     $display("File was opened successfully : %0d", fd_i);
    else      	  $display("File was NOT opened successfully : %0d", fd_i);

    if (fd_o)     $display("File was opened successfully : %0d", fd_o);
    else      	  $display("File was NOT opened successfully : %0d", fd_o);
	#80
	clk				=	0;
	rst				=	1;
    x_i             =   0;
	#80;
	rst				=	0;

end		

always @ (posedge clk) begin

	if (!($feof(fd_i))) begin
        #40
		tmp = $fscanf(fd_i, "%d\n", x_i);
        #80
		$fwrite(fd_o, "%d,%d,%d,%d\n", x_scaled_o, no_shift_o, shift_l_o, shift_r_o);
	end else begin
		$fclose(fd_i);
		$fclose(fd_o);
		$finish;
	end
end

endmodule	
	