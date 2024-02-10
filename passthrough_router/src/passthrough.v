`timescale 1ns/1ps

/*
 *  A passthrough module that just pass inputs to outputs
 */

module passthrough 
   #(
    parameter DATA_WIDTH = 64,
    parameter CTRL_WIDTH = DATA_WIDTH/8,
    parameter UDP_REG_SRC_WIDTH = 2
)
   (
    input  [DATA_WIDTH-1:0]             in_data,
    input  [CTRL_WIDTH-1:0]             in_ctrl,
    input                               in_wr,
    output                              in_rdy,

    output [DATA_WIDTH-1:0]             out_data,
    output [CTRL_WIDTH-1:0]             out_ctrl,
    output                              out_wr,
    input                               out_rdy,

    // --- Register interface
    input                               reg_req_in,
    input                               reg_ack_in,
    input                               reg_rd_wr_L_in,
    input  [`UDP_REG_ADDR_WIDTH-1:0]    reg_addr_in,
    input  [`CPCI_NF2_DATA_WIDTH-1:0]   reg_data_in,
    input  [UDP_REG_SRC_WIDTH-1:0]      reg_src_in,

    output                              reg_req_out,
    output                              reg_ack_out,
    output                              reg_rd_wr_L_out,
    output  [`UDP_REG_ADDR_WIDTH-1:0]   reg_addr_out,
    output  [`CPCI_NF2_DATA_WIDTH-1:0]  reg_data_out,
    output  [UDP_REG_SRC_WIDTH-1:0]     reg_src_out,

    // misc
    input                                reset,
    input                                clk
);


    assign out_data = in_data;
    assign out_ctrl = in_ctrl;
    assign out_wr = in_wr;
    assign in_rdy = out_rdy;

    assign reg_req_out = reg_req_in;
    assign reg_ack_out = reg_ack_in;
    assign reg_rd_wr_L_out = reg_rd_wr_L_in;
    assign reg_addr_out = reg_addr_in;
    assign reg_data_out = reg_data_in;
    assign reg_src_out = reg_src_in;

    generic_regs #(
        .UDP_REG_SRC_WIDTH  (UDP_REG_SRC_WIDTH),
    );

endmodule