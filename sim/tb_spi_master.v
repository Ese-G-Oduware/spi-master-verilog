`timescale 1ns / 1ps

module tb_spi_master();

    // Testbench Signals
    reg        clk;
    reg        rst;
    reg        start;
    reg  [7:0] tx_data;
    
    wire       sclk;
    wire       mosi;
    reg        miso;
    wire       cs;
    
    wire [7:0] rx_data;
    wire       busy;
    wire       done;

    // Instantiate Device Under Test (DUT)
    spi_master dut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .tx_data(tx_data),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .cs(cs),
        .rx_data(rx_data),
        .busy(busy),
        .done(done)
    );

    // 1. Clock Generation (100 MHz -> 10ns period)
    always #5 clk = ~clk;

    // 2. Stimulus Process
    initial begin
        // Initialize signals
        clk     = 0;
        rst     = 1;
        start   = 0;
        tx_data = 8'h00;
        miso    = 0;

        // Hold reset for 20ns
        #20;
        rst = 0;
        #20;

        // TEST CASE 1: Send 0xA5
        $display("Starting SPI Transfer: TX = 0xA5");
        tx_data = 8'hA5;
        start   = 1;
        #10;
        start   = 0;

        // Wait until transaction finishes
        wait(done == 1'b1);
        #20;

        $display("Transfer Complete! Received RX = 0x%h", rx_data);
        
        #100;
        $finish;
    end

    // 3. Simple Slave Behavior
    always @(posedge sclk) begin
        if (!cs) begin
            miso <= ~miso;
        end
    end

endmodule