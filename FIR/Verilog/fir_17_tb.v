module fir_17_tb;

parameter		NVL 	= 10000;		//	Number of Noise Samples
	

reg					clk;
reg					rst;
reg signed [7:0]	data_i, data_from_file;
reg 				tmp;
reg					valid_i;

integer				fd_i, fd_o;

wire signed [23:0]	data_o;
				
fir_17 DUT(
    .clk				(clk),
	.rst				(rst),
    .data_i				(data_i),
    .valid_i			(valid_i),
    .data_o				(data_o)
);

always
	#5 	clk=!clk;
	 
initial begin
	fd_i = $fopen("noisesignal.txt", "r");
	fd_o = $fopen("fir_o.txt", "w");
	
	if (fd_i)     $display("File was opened successfully : %0d", fd_i);
    else      	  $display("File was NOT opened successfully : %0d", fd_i);

    if (fd_o)     $display("File was opened successfully : %0d", fd_o);
    else      	  $display("File was NOT opened successfully : %0d", fd_o);

	clk				=	0;
	rst				=	1;
	valid_i			=	0;
	data_i			=	0;
	data_from_file 	= 	0;
	tmp 			= 	0;
	#40;
	rst				=	0;
	valid_i			=	1;

end		

always @ (posedge clk) begin
	if(valid_i) begin
		tmp = $fscanf(fd_i, "%d\n", data_from_file);
		$fwrite(fd_o, "%d\n", data_o);
		if (!($feof(fd_i))) begin
			data_i <= data_from_file;
		end else begin
			$fclose(fd_i);
			$fclose(fd_o);
			$finish;
		end
end
end
endmodule	
	