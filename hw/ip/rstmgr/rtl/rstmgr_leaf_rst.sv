// Copyright lowRISC contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// This module generates the leaf resets and instantiates the associated reset
// checks.

`include "prim_assert.sv"

module rstmgr_leaf_rst
  import rstmgr_pkg::*;
  import rstmgr_reg_pkg::*;
(
  input clk_i,
  input rst_ni,
  input leaf_clk_i,
  input parent_rst_ni,
  input sw_rst_req_ni,
  input scan_rst_ni,
  input scan_sel,
  output lc_ctrl_pkg::lc_tx_t rst_en_o,
  output logic leaf_rst_o,
  output logic err_o
);

  logic leaf_rst_sync;
  prim_flop_2sync #(
    .Width(1),
    .ResetValue('0)
  ) u_rst_sync (
    .clk_i(leaf_clk_i),
    .rst_ni(parent_rst_ni),
    .d_i(sw_rst_req_ni),
    .q_o(leaf_rst_sync)
  );

  prim_clock_mux2 #(
    .NoFpgaBufG(1'b1)
  ) u_rst_mux (
    .clk0_i(leaf_rst_sync),
    .clk1_i(scan_rst_ni),
    .sel_i(scan_sel),
    .clk_o(leaf_rst_o)
  );

  rstmgr_cnsty_chk u_rst_chk (
    .clk_i,
    .rst_ni,
    .child_clk_i(leaf_clk_i),
    .child_rst_ni(leaf_rst_o),
    .parent_rst_ni,
    .sw_rst_req_i(~sw_rst_req_ni),
    .err_o
  );

  // reset asserted indication for alert handler
  prim_lc_sender #(
    .ResetValueIsOn(1)
  ) u_prim_lc_sender_rst (
    .clk_i(leaf_clk_i),
    .rst_ni(leaf_rst_o),
    .lc_en_i(lc_ctrl_pkg::Off),
    .lc_en_o(rst_en_o)
  );


endmodule // rstmgr_leaf_rst