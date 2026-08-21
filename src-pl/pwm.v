`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.03.2026 10:31:42
// Design Name: 
// Module Name: pwm
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


module pwm(
        input wire clk,
        input wire[15:0] prescaler,
        input wire[15:0] period,
        input wire[15:0] duty_cycle,
        output reg out_pwm
    );
    
    reg[15:0] cnt = 0;
    reg[15:0] psc = 0;
    
    always @(posedge clk) begin
        if (psc >= prescaler) begin
            psc <= 0;
            
            if (period == cnt) begin 
                cnt <= 0;
            end
            else begin 
                cnt <= cnt + 1;
            end
        end
        else begin
            psc <= psc + 1;
        end
        
        if (duty_cycle == 0) begin
            out_pwm <= 0;
        end
        else begin
            out_pwm <= (cnt <= duty_cycle);
        end
    end
  
endmodule
