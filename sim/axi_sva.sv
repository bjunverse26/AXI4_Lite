// AXI4-Lite SVA

module axi_protocol_sva (
    // Clock / reset
    input wire aclk,
    input wire aresetn,

    // AW
    input wire [31:0] awaddr,
    input wire awvalid,
    input wire awready,

    // W
    input wire [31:0] wdata,
    input wire [3:0] wstrb,
    input wire wvalid,
    input wire wready,

    // B
    input wire [1:0] bresp,
    input wire bvalid,
    input wire bready,

    // AR
    input wire [31:0] araddr,
    input wire arvalid,
    input wire arready,

    // R
    input wire [31:0] rdata,
    input wire [1:0] rresp,
    input wire rvalid,
    input wire rready
);

    integer sva_error_count = 0;

    // VALID hold
    property aw_valid_stable;
        @(posedge aclk) disable iff (!aresetn)
        awvalid && !awready |=> awvalid;
    endproperty

    assert_aw_valid_stable: assert property(aw_valid_stable)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] AW: valid dropped before ready");
        end

    property w_valid_stable;
        @(posedge aclk) disable iff (!aresetn)
        wvalid && !wready |=> wvalid;
    endproperty

    assert_w_valid_stable: assert property(w_valid_stable)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] W: valid dropped before ready");
        end

    property b_valid_stable;
        @(posedge aclk) disable iff (!aresetn)
        bvalid && !bready |=> bvalid;
    endproperty

    assert_b_valid_stable: assert property(b_valid_stable)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] B: valid dropped before ready");
        end

    property ar_valid_stable;
        @(posedge aclk) disable iff (!aresetn)
        arvalid && !arready |=> arvalid;
    endproperty

    assert_ar_valid_stable: assert property(ar_valid_stable)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] AR: valid dropped before ready");
        end

    property r_valid_stable;
        @(posedge aclk) disable iff (!aresetn)
        rvalid && !rready |=> rvalid;
    endproperty

    assert_r_valid_stable: assert property(r_valid_stable)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] R: valid dropped before ready");
        end

    // Payload hold
    property aw_addr_stable;
        @(posedge aclk) disable iff (!aresetn)
        awvalid && !awready |=> $stable(awaddr);
    endproperty

    assert_aw_addr_stable: assert property(aw_addr_stable)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] AW: addr changed during handshake");
        end

    property w_data_stable;
        @(posedge aclk) disable iff (!aresetn)
        wvalid && !wready |=> ($stable(wdata) && $stable(wstrb));
    endproperty

    assert_w_data_stable: assert property(w_data_stable)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] W: data changed during handshake");
        end

    property ar_addr_stable;
        @(posedge aclk) disable iff (!aresetn)
        arvalid && !arready |=> $stable(araddr);
    endproperty

    assert_ar_addr_stable: assert property(ar_addr_stable)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] AR: addr changed during handshake");
        end

    property r_data_stable;
        @(posedge aclk) disable iff (!aresetn)
        rvalid && !rready |=> ($stable(rdata) && $stable(rresp));
    endproperty

    assert_r_data_stable: assert property(r_data_stable)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] R: data changed during handshake");
        end

    // Reset check
    property reset_clears_valid;
        @(posedge aclk)
        !aresetn |-> (!awvalid && !wvalid && !bvalid && !arvalid && !rvalid);
    endproperty

    assert_reset_valid: assert property(reset_clears_valid)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] Valid signals not cleared during reset");
        end

    // AW -> W order
    property aw_then_w;
        @(posedge aclk) disable iff (!aresetn)
        (awvalid && awready) |-> ##[0:10] (wvalid && wready);
    endproperty

    assert_aw_then_w: assert property(aw_then_w)
        else begin
            sva_error_count = sva_error_count + 1;
            $error("[SVA FAIL] Write data not received after address");
        end

    // Coverage
    cover_aw_handshake: cover property(@(posedge aclk) awvalid && awready);
    cover_w_handshake: cover property(@(posedge aclk) wvalid && wready);
    cover_b_handshake: cover property(@(posedge aclk) bvalid && bready);
    cover_ar_handshake: cover property(@(posedge aclk) arvalid && arready);
    cover_r_handshake: cover property(@(posedge aclk) rvalid && rready);

    cover_back_to_back_write: cover property(
        @(posedge aclk) (awvalid && awready) ##1 (awvalid && awready)
    );

    final begin
        if (sva_error_count == 0) begin
            $display("[SVA PASS] All AXI protocol assertions passed.");
        end else begin
            $display("[SVA SUMMARY] Total assertion failures: %0d", sva_error_count);
        end
    end

endmodule
