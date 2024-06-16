`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/05/2023 05:35:09 PM
// Design Name: 
// Module Name: top_module
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


module top_module(
    input clk,
    input rst,
    
    input BTNA,
    input BTNB,
    
    input [1:0] DIRA,
    input [1:0] DIRB,
    
    input [2:0] YA,
    input [2:0] YB,
   
    output LEDA,
    output LEDB,
    output [4:0] LEDX,
    
    output a_out,b_out,c_out,d_out,e_out,f_out,g_out,p_out,
    output [7:0]an
);
    wire clk_out;     
    wire [6:0] SSD0, SSD1,SSD2,SSD3,SSD4,SSD5,SSD6,SSD7;
    wire [3:0] state, timer;
    wire [1:0] score_A, score_B, turn;
    wire [2:0] X_COORD, Y_COORD;
    wire[2:0] dirY, dirA, dirB;
    wire db1,db2;
    
// Instantiate clock divider module
clk_divider clock (clk,rst,clk_out);

// Instantiate debouncer module for BTNA
debouncer debouncer_btna (clk_out,rst,BTNA,db1);

// Instantiate debouncer module for BTNB
debouncer debouncer_btnb (clk_out,rst,BTNB,db2);
hockey hockey_module (clk_out,rst,db1,db2,DIRA,DIRB,YA,YB,LEDA,LEDB,LEDX,SSD7,SSD6,SSD5,SSD4,SSD3,SSD2,SSD1,SSD0);

// Instantiate ssd module
ssd ssd_instance (clk,rst,SSD7,SSD6,SSD5,SSD4,SSD3,SSD2,SSD1,SSD0,a_out,b_out,c_out,d_out,e_out,f_out,g_out,p_out,an);


    
   
	
endmodule
