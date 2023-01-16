module approx_top_tb;


reg				clk, rst;
reg				start_i;
reg  [15:0] 	x_i;
reg  	[2:0]	nIt_i;
reg tmp;


wire 	[15:0] 	y_o;
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
	x_i		= 16'd0;
	nIt_i   = 0;
	start_i = 0;
	#80
	rst 		= 0;
	nIt_i		= 3'd7;  //Entspricht 5 Iterationen da n bei 1 startet
	start_i 	= 1'd1;
	#10
	start_i = 1'd0;


end

always @ (posedge clk) begin

	if (!($feof(fd_i))) begin
			#40
			tmp = $fscanf(fd_i, "%d\n", x_i);
			rst = 1'd0;
			start_i 	= 1'd1;
			#10
			start_i = 1'd0;
			//x_i = 'd57344;//'d3277;//'d6554;    //Q4.12 = 0.4
			#600
			$fwrite(fd_o, "%d\n", y_o);
			rst = 1'd1;
		end 
	
	else begin
		$fclose(fd_i);
		$fclose(fd_o);
		$finish;
	end
end
endmodule