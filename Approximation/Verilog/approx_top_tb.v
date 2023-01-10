module approx_top_tb;


reg				clk, rst;
reg				start_i;
reg  	[7:0] 	x_i;
reg  	[2:0]	nIt_i;


wire 	[7:0] 	y_o;
wire			busy_o, valid_o;

integer				fd_i, fd_o;

approx_top DUT(

	.rst			(rst),
	.clk            (clk),
	.x_i            (x_i),
	.nIt_i          (nIt_i),
	.start_i        (start_i),
	
	.busy_o         (busy_o),
	.y_o            (y_o),
	.valid_o        (valid_o)
);

always 
		#5  clk = !clk;
		
initial begin
	fd_i = $fopen("input.txt", "r");
	fd_o = $fopen("output.txt", "w");
	
	if (fd_i)     $display("File was opened successfully : %0d", fd_i);
    else      	  $display("File was NOT opened successfully : %0d", fd_i);

    if (fd_o)     $display("File was opened successfully : %0d", fd_o);
    else      	  $display("File was NOT opened successfully : %0d", fd_o);
	
	#20
	clk		= 0;
	rst	    = 1;
	x_i		= 0;
	nIt_i   = 0;
	start_i = 0;
	#80
	rst 		= 0;
	start_i 	= 1'd1;
	nIt_i		= 3'd5;

end

always @ (posedge clk) begin

	if (!($feof(fd_i))) begin
			x_i = 8'd19;
			#160
			$fwrite(fd_o, "%d,%d,%d\n", busy_o, valid_o, y_o);
		end 
	
	else begin
		$fclose(fd_i);
		$fclose(fd_o);
		$finish;
	end
end
endmodule