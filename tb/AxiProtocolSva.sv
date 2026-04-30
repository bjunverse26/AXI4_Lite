//==============================================================================
// File Name   : AxiProtocolSva.sv
// Project     : AXI4_Lite
// Author      : Beomjun Kim
// Description : AXI4-Lite protocol assertion and coverage monitor.
// Notes       : The directed testbench creates traffic while this module checks
//               VALID/READY stability, payload hold, and bounded responses.
//==============================================================================

`timescale 1ns / 1ps

module AxiProtocolSva (
    input logic        i_aclk,
    input logic        i_aresetn,

    input logic [31:0] i_awaddr,
    input logic        i_awvalid,
    input logic        i_awready,

    input logic [31:0] i_wdata,
    input logic [3:0]  i_wstrb,
    input logic        i_wvalid,
    input logic        i_wready,

    input logic [1:0]  i_bresp,
    input logic        i_bvalid,
    input logic        i_bready,

    input logic [31:0] i_araddr,
    input logic        i_arvalid,
    input logic        i_arready,

    input logic [31:0] i_rdata,
    input logic [1:0]  i_rresp,
    input logic        i_rvalid,
    input logic        i_rready
);

    //==============================================================================
    // Protocol Constants
    //==============================================================================

    localparam logic [1:0] RESP_OKAY   = 2'b00;
    localparam logic [1:0] RESP_SLVERR = 2'b10;
    localparam logic [1:0] RESP_DECERR = 2'b11;

    integer r_sva_error_count = 0;

    //==============================================================================
    // Handshake Sequences
    //==============================================================================

    sequence aw_hs;
        i_awvalid && i_awready;
    endsequence

    sequence w_hs;
        i_wvalid && i_wready;
    endsequence

    sequence ar_hs;
        i_arvalid && i_arready;
    endsequence

    //==============================================================================
    // Protocol Properties
    //==============================================================================

    property aw_valid_stable;
        @(posedge i_aclk) disable iff (!i_aresetn)
        i_awvalid && !i_awready |=> i_awvalid;
    endproperty

    property w_valid_stable;
        @(posedge i_aclk) disable iff (!i_aresetn)
        i_wvalid && !i_wready |=> i_wvalid;
    endproperty

    property b_valid_stable;
        @(posedge i_aclk) disable iff (!i_aresetn)
        i_bvalid && !i_bready |=> i_bvalid;
    endproperty

    property ar_valid_stable;
        @(posedge i_aclk) disable iff (!i_aresetn)
        i_arvalid && !i_arready |=> i_arvalid;
    endproperty

    property r_valid_stable;
        @(posedge i_aclk) disable iff (!i_aresetn)
        i_rvalid && !i_rready |=> i_rvalid;
    endproperty

    property aw_addr_stable;
        @(posedge i_aclk) disable iff (!i_aresetn)
        i_awvalid && !i_awready |=> $stable(i_awaddr);
    endproperty

    property w_data_stable;
        @(posedge i_aclk) disable iff (!i_aresetn)
        i_wvalid && !i_wready |=> ($stable(i_wdata) && $stable(i_wstrb));
    endproperty

    property ar_addr_stable;
        @(posedge i_aclk) disable iff (!i_aresetn)
        i_arvalid && !i_arready |=> $stable(i_araddr);
    endproperty

    property b_resp_stable;
        @(posedge i_aclk) disable iff (!i_aresetn)
        i_bvalid && !i_bready |=> $stable(i_bresp);
    endproperty

    property r_data_stable;
        @(posedge i_aclk) disable iff (!i_aresetn)
        i_rvalid && !i_rready |=> ($stable(i_rdata) && $stable(i_rresp));
    endproperty

    property reset_clears_response_valid;
        @(posedge i_aclk)
        !i_aresetn |-> (!i_bvalid && !i_rvalid);
    endproperty

    property write_eventually_gets_b;
        @(posedge i_aclk) disable iff (!i_aresetn)
        ((aw_hs ##[0:16] w_hs) or (w_hs ##[0:16] aw_hs))
        |-> ##[0:16] i_bvalid;
    endproperty

    property read_eventually_gets_r;
        @(posedge i_aclk) disable iff (!i_aresetn)
        ar_hs |-> ##[0:16] i_rvalid;
    endproperty

    property valid_bresp_values;
        @(posedge i_aclk) disable iff (!i_aresetn)
        i_bvalid |-> (i_bresp inside {RESP_OKAY, RESP_SLVERR, RESP_DECERR});
    endproperty

    property valid_rresp_values;
        @(posedge i_aclk) disable iff (!i_aresetn)
        i_rvalid |-> (i_rresp inside {RESP_OKAY, RESP_SLVERR, RESP_DECERR});
    endproperty

    //==============================================================================
    // Assertions
    //==============================================================================

    assert_aw_valid_stable: assert property (aw_valid_stable)
        else begin r_sva_error_count++; $error("[SVA FAIL] AWVALID dropped before AWREADY"); end

    assert_w_valid_stable: assert property (w_valid_stable)
        else begin r_sva_error_count++; $error("[SVA FAIL] WVALID dropped before WREADY"); end

    assert_b_valid_stable: assert property (b_valid_stable)
        else begin r_sva_error_count++; $error("[SVA FAIL] BVALID dropped before BREADY"); end

    assert_ar_valid_stable: assert property (ar_valid_stable)
        else begin r_sva_error_count++; $error("[SVA FAIL] ARVALID dropped before ARREADY"); end

    assert_r_valid_stable: assert property (r_valid_stable)
        else begin r_sva_error_count++; $error("[SVA FAIL] RVALID dropped before RREADY"); end

    assert_aw_addr_stable: assert property (aw_addr_stable)
        else begin r_sva_error_count++; $error("[SVA FAIL] AWADDR changed while waiting"); end

    assert_w_data_stable: assert property (w_data_stable)
        else begin r_sva_error_count++; $error("[SVA FAIL] WDATA/WSTRB changed while waiting"); end

    assert_ar_addr_stable: assert property (ar_addr_stable)
        else begin r_sva_error_count++; $error("[SVA FAIL] ARADDR changed while waiting"); end

    assert_b_resp_stable: assert property (b_resp_stable)
        else begin r_sva_error_count++; $error("[SVA FAIL] BRESP changed while waiting"); end

    assert_r_data_stable: assert property (r_data_stable)
        else begin r_sva_error_count++; $error("[SVA FAIL] RDATA/RRESP changed while waiting"); end

    assert_reset_valid: assert property (reset_clears_response_valid)
        else begin r_sva_error_count++; $error("[SVA FAIL] BVALID/RVALID active during reset"); end

    assert_write_eventually_gets_b: assert property (write_eventually_gets_b)
        else begin r_sva_error_count++; $error("[SVA FAIL] Write did not produce BVALID in time"); end

    assert_read_eventually_gets_r: assert property (read_eventually_gets_r)
        else begin r_sva_error_count++; $error("[SVA FAIL] Read did not produce RVALID in time"); end

    assert_valid_bresp_values: assert property (valid_bresp_values)
        else begin r_sva_error_count++; $error("[SVA FAIL] Invalid BRESP value"); end

    assert_valid_rresp_values: assert property (valid_rresp_values)
        else begin r_sva_error_count++; $error("[SVA FAIL] Invalid RRESP value"); end

    //==============================================================================
    // Coverage
    //==============================================================================

    cover_aw_handshake: cover property (@(posedge i_aclk) i_awvalid && i_awready);
    cover_w_handshake : cover property (@(posedge i_aclk) i_wvalid  && i_wready);
    cover_b_handshake : cover property (@(posedge i_aclk) i_bvalid  && i_bready);
    cover_ar_handshake: cover property (@(posedge i_aclk) i_arvalid && i_arready);
    cover_r_handshake : cover property (@(posedge i_aclk) i_rvalid  && i_rready);

    cover_aw_then_w: cover property (@(posedge i_aclk) aw_hs ##[0:16] w_hs);
    cover_w_then_aw: cover property (@(posedge i_aclk) w_hs ##[0:16] aw_hs);
    cover_aw_w_same_cycle: cover property (
        @(posedge i_aclk) i_awvalid && i_awready && i_wvalid && i_wready
    );
    cover_read_to_r: cover property (@(posedge i_aclk) ar_hs ##[0:16] (i_rvalid && i_rready));

    //==============================================================================
    // Final Summary
    //==============================================================================

    final begin
        if (r_sva_error_count == 0) begin
            $display("[SVA PASS] All required AXI-Lite assertions passed.");
        end else begin
            $display("[SVA SUMMARY] Total assertion failures: %0d", r_sva_error_count);
        end
    end

endmodule
