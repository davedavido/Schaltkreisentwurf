module cordic_rom(
	eab_i,
	clk,
	edb_o
);

input 		[2:0] 	eab_i;
input 				clk;
output reg [15:0] 	edb_o;


reg [15:0] mem [0:7];
integer i;

initial begin
	$readmemb("cordic_rom_init.txt", mem);
end

always @ (posedge clk) begin
	edb_o <= mem[eab_i];
end
	
	
endmodule