module fir_17_tb;

parameter		NVL 	= 10000;		//	Number of Noise Samples
	

reg					clk;
reg					rst;
reg signed [7:0]	data_i, data_file;
reg					valid_i;

integer			fd_i, fd_o;
integer			i, a, t;

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
	fd_i = $fopen("/Users/Davidlohner/Documents/Schaltkreisentwurf/Praktikum/FIR/Matlab/fir_o.txt", "r");
	fd_o = $fopen("/Users/Davidlohner/Documents/Schaltkreisentwurf/Praktikum/FIR/Matlab/fir_o.txt", "w");
	clk				=	0;
	rst				=	1;
	valid_i			=	0;
	data_i			=	0;
	#50;
	rst				=	0;
	valid_i			=	1;
end		

always @ (posedge clk) begin
	if(valid_i) begin
		$fscanf(fd_i, "%d\n", data_file);
		$fwrite(fd_o, "%d\n", data_o);
		if (!$feof(fd_i)) begin
			data_i <= data_file;
		end else begin
			$fclose(fd_i);
			$fclose(fd_o);
			$finish;
		end
end
end
endmodule	
	