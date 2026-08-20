`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/20/2026 11:24:22 AM
// Design Name: 
// Module Name: modulator
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


module modulator(
        input wire nreset,
        input wire valid,
        input wire clock,
        output reg[15:0] i,
        output reg[15:0] q
    );
    
    always @(posedge clock) begin
        if(!nreset) begin
            i <= 16'h0;
            q <= 16'h0;
        end
        else begin
            i <= 16'h1;
            q <= 16'h1;
        end
    end
endmodule
