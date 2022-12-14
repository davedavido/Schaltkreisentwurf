module fir_17(clk, 
            rst, 
            data_i, 
            valid_i, 
            data_o);

input clk;
input rst;
input valid_i;
input [7:0] data_i;
output reg [23:0] data_o;

/* FIR-Filter Taps*/

reg signed h_0  = 16'b0000000000000000;       
reg signed h_1  = 16'b1111100000000000;       
reg signed h_2  = 16'b1111001010110011;       
reg signed h_3  = 16'b1111010010100101;      
reg signed h_4  = 16'b0000000000000000;       
reg signed h_5  = 16'b0001001100011011;       
reg signed h_6  = 16'b0010100010100101;       
reg signed h_7  = 16'b0011100110010110;       
reg signed h_8  = 16'b0100000000000000;       
reg signed h_9  = 16'b0011100110010110;       
reg signed h_10 = 16'b0010100010100101;      
reg signed h_11 = 16'b0001001100011011;       
reg signed h_12 = 16'b0000000000000000;       
reg signed h_13 = 16'b1111010010100101;       
reg signed h_14 = 16'b1111001010110011;       
reg signed h_15 = 16'b1111100000000000;       
reg signed h_16 = 16'b0000000000000000;      

//Buffer 
reg signed [7:0] buff [0:16];
//Multiply Stage 16-BIt*16-Bit = 32-Bit
reg signed [23:0] acc [0:16];
reg signed [23:0] acc_r [0:16];

reg valid_i_r;

// Update Circular Buffer 
always @ (posedge clk)
    begin
        if (rst == 1'b1) begin

            valid_i_r <=1'b0;

            buff[0]<= 8'b0;
            buff[1]<= 8'b0;       
            buff[2]<= 8'b0;       
            buff[3]<= 8'b0;     
            buff[4]<= 8'b0;     
            buff[5]<= 8'b0;     
            buff[6]<= 8'b0;   
            buff[7]<= 8'b0;       
            buff[8]<= 8'b0;       
            buff[9]<= 8'b0;       
            buff[10] <= 8'b0;        
            buff[11] <= 8'b0;       
            buff[12] <= 8'b0;      
            buff[13] <= 8'b0;       
            buff[14] <= 8'b0; 
            buff[15] <= 8'b0; 
            buff[16] <= 8'b0;            
        end

        else begin

            /* Get Valid*/
            valid_i_r <= valid_i;

            /* Update Buffer */
            buff[0]  <= data_i;
            buff[1]  <= buff[0];        
            buff[2]  <= buff[1];         
            buff[3]  <= buff[2];      
            buff[4]  <= buff[3];      
            buff[5]  <= buff[4];       
            buff[6]  <= buff[5];    
            buff[7]  <= buff[6];       
            buff[8]  <= buff[7];       
            buff[9]  <= buff[8];       
            buff[10] <= buff[9];        
            buff[11] <= buff[10];       
            buff[12] <= buff[11];       
            buff[13] <= buff[12];       
            buff[14] <= buff[13];
            buff[15] <= buff[14];
            buff[16] <= buff[15]; 

           /* Register Multiplication */
            acc_r[0]    <= acc[0];
            acc_r[1]    <= acc[1];
            acc_r[2]    <= acc[2];
            acc_r[3]    <= acc[3];
            acc_r[4]    <= acc[4];
            acc_r[5]    <= acc[5];
            acc_r[6]    <= acc[6];
            acc_r[7]    <= acc[7];
            acc_r[8]    <= acc[8];
            acc_r[9]    <= acc[9];
            acc_r[10]   <= acc[10];
            acc_r[11]   <= acc[11];
            acc_r[12]   <= acc[12];
            acc_r[13]   <= acc[13];
            acc_r[14]   <= acc[14];
            acc_r[15]   <= acc[15];
            acc_r[16]   <= acc[16];
        end
    end

    
/* Kombinatorische Logik */
always @ (*)begin
        if (valid_i_r == 1'b1)
            begin
                /* Multiply Stage */
                acc[0]    = h_0 * buff[0];
                acc[1]    = h_1 * buff[1];
                acc[2]    = h_2 * buff[2];
                acc[3]    = h_3 * buff[3];
                acc[4]    = h_4 * buff[4];
                acc[5]    = h_5 * buff[5];
                acc[6]    = h_6 * buff[6];
                acc[7]    = h_7 * buff[7];
                acc[8]    = h_8 * buff[8];
                acc[9]    = h_9 * buff[9];
                acc[10]   = h_10 * buff[10];
                acc[11]   = h_11 * buff[11];
                acc[12]   = h_12 * buff[12];
                acc[13]   = h_13 * buff[13];
                acc[14]   = h_14 * buff[14];
                acc[15]   = h_15 * buff[15];
                acc[16]   = h_16 * buff[16];

                /* Accumulate stage of FIR */
                data_o = acc_r[0]  +  acc_r[1]  +  acc_r[2]  +  acc_r[3]  +  acc_r[4]  +  acc_r[5]  +  acc_r[6]  +  acc_r[7]  +  acc_r[8]  +  acc_r[9]  +  acc_r[10] +  acc_r[11] +  acc_r[12] +  acc_r[13] +  acc_r[14] +  acc_r[15] +  acc_r[16];
            end
    end   

endmodule