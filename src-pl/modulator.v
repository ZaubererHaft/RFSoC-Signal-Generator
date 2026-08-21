`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08.07.2026 13:07:30
// Design Name: 
// Module Name: transmitter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module modulator
    #(
        parameter [31:0] ref_clk_mhz = 128,
        parameter [31:0] symbol_rate_mhz = 8
    )
    (
        input  wire nreset,
        input  wire clk,
        input  wire [15:0] data_in, 
        input  wire [3:0]  mod_type,
        output reg  [15:0] data_out_i,
        output reg  [15:0] data_out_q,
        output reg         valid,
        output reg  [31:0] accumulator,
        output reg  [7:0]  index
    );
    
    localparam [31:0] cycles_until_next = ref_clk_mhz / symbol_rate_mhz;
    
    localparam [15:0] MAX_POS = 16'd32767;
    localparam [15:0] MAX_NEG = -16'd32768;
    
    localparam [15:0] MID_POS = 16'd10922;
    localparam [15:0] MID_NEG = -16'd10922;
        
    always @(posedge clk) begin
        if(!nreset) begin 
            valid             <= 0;
            accumulator       <= 32'h1;
            data_out_i        <= 16'h0;
            data_out_q        <= 16'h0;  
            
            if (mod_type == 4'b0) begin
                index             <=  8'd14; 
            end
            else begin
                index             <=  8'd12;       
            end
        end
        else begin
            if (accumulator > 1) begin 
                accumulator <= accumulator - 1;
                valid <= 0;
            end 
            else begin      
                accumulator   <= cycles_until_next;
                valid <= 1;
                
                if (mod_type == 4'b0) begin
                    if (data_in[index +: 2] == 2'b00) begin
                        data_out_i  <= MAX_POS;      
                        data_out_q  <= MAX_POS;       
                    end
                    else if (data_in[index +: 2] == 2'b01) begin
                        data_out_i  <= MAX_NEG;      
                        data_out_q  <= MAX_POS;       
                    end
                    else if (data_in[index +: 2] == 2'b10) begin
                        data_out_i  <= MAX_POS;      
                        data_out_q  <= MAX_NEG;   
                    end           
                    else begin 
                        data_out_i  <= MAX_NEG;      
                        data_out_q  <= MAX_NEG;   
                    end
                    
                    if (index <= 8'd0) begin
                        index         <=  8'd14; 
                    end
                    else begin
                        index         <= index - 8'd2;
                    end
                end
                else begin 
                    // First Row
                    if (data_in[index +: 4] == 4'b0000) begin
                        data_out_i  <= MAX_POS;      
                        data_out_q  <= MAX_POS;       
                    end
                    if (data_in[index +: 4] == 4'b0001) begin
                        data_out_i  <= MAX_POS;      
                        data_out_q  <= MID_POS;       
                    end           
                    if (data_in[index +: 4] == 4'b0010) begin
                        data_out_i  <= MAX_POS;      
                        data_out_q  <= MAX_NEG;       
                    end
                    if (data_in[index +: 4] == 4'b0011) begin
                        data_out_i  <= MAX_POS;      
                        data_out_q  <= MID_NEG;       
                    end
                    // Second Row
                    if (data_in[index +: 4] == 4'b0100) begin
                        data_out_i  <= MID_POS;      
                        data_out_q  <= MAX_POS;       
                    end     
                    if (data_in[index +: 4] == 4'b0101) begin
                        data_out_i  <= MID_POS;      
                        data_out_q  <= MID_POS;       
                    end         
                    if (data_in[index +: 4] == 4'b0110) begin
                        data_out_i  <= MID_POS;      
                        data_out_q  <= MAX_NEG;       
                    end    
                    if (data_in[index +: 4] == 4'b0111) begin
                        data_out_i  <= MID_POS;      
                        data_out_q  <= MID_NEG;       
                    end         
                    // Third Row                
                    if (data_in[index +: 4] == 4'b1000) begin
                        data_out_i  <= MAX_NEG;      
                        data_out_q  <= MAX_POS;       
                    end   
                    if (data_in[index +: 4] == 4'b1001) begin
                        data_out_i  <= MAX_NEG;      
                        data_out_q  <= MID_POS;       
                    end   
                    if (data_in[index +: 4] == 4'b1010) begin
                        data_out_i  <= MAX_NEG;      
                        data_out_q  <= MAX_NEG;       
                    end   
                    if (data_in[index +: 4] == 4'b1011) begin
                        data_out_i  <= MAX_NEG;      
                        data_out_q  <= MID_NEG;       
                    end     
                    // Fourth Row              
                    if (data_in[index +: 4] == 4'b1100) begin
                        data_out_i  <= MID_NEG;      
                        data_out_q  <= MAX_POS;       
                    end   
                    if (data_in[index +: 4] == 4'b1101) begin
                        data_out_i  <= MID_NEG;      
                        data_out_q  <= MID_POS;       
                    end   
                    if (data_in[index +: 4] == 4'b1110) begin
                        data_out_i  <= MID_NEG;      
                        data_out_q  <= MAX_NEG;       
                    end  
                    if (data_in[index +: 4] == 4'b1111) begin
                        data_out_i  <= MID_NEG;      
                        data_out_q  <= MID_NEG;       
                    end  
                                                                                                                                           
                    if (index <= 8'd0) begin
                        index         <=  8'd12; 
                    end
                    else begin
                        index         <= index - 8'd4;
                    end
                end
            end
        end
    end
    
endmodule
