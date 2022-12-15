module fir_17_tb;

parameter		NVL 	= 10000;		//	Number of Noise Samples
	

reg					clk;
reg					rst;
reg signed [7:0]	data_i;
reg 				tmp;
reg					valid_i;

integer				fd_i, fd_o;

wire signed [9:0]	data_o;
				
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
	#80
	clk				=	0;
	valid_i			=	0;
	data_i			=	0;
	tmp 			= 	0;
	rst				=	1;
	#80;
	rst				=	0;
	valid_i 		=	1;

end		

always @ (posedge clk) begin
	if(valid_i) begin
		if (!($feof(fd_i))) begin
			tmp = $fscanf(fd_i, "%d\n", data_i);
			$fwrite(fd_o, "%d\n", data_o);
		end else begin
			$fclose(fd_i);
			$fclose(fd_o);
			$finish;
		end
end
end
endmodule	
	