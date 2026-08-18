`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/18/2026 11:43:58 AM
// Design Name: 
// Module Name: spi_master
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

//CPOL = CPHA = 0
module spi_master(
    //System Signals
    input wire clk, //FPGA clock signal
    input wire rst, //resets stae machine to 0
    input wire start, //1 bit signal that wakes up SPI controller
    input wire [7:0] tx_data, //8 bit bus that has the byte we send out
    //SPI Hardware (Bus)
    output reg sclk, //SPI clock
    output reg mosi, //master out
    input wire miso, //master in
    output reg cs, //Chip select (active low)
    //Status
    output reg [7:0] rx_data, // 8 bit register that saves data from Slave
    output reg busy, //turns 1 while transfer is happening
    output reg done  // 1 cycle pulse than indicates 8-bit transfer is complete
    );
    //Define States (4 states)
    localparam IDLE = 2'b00,
               INIT = 2'b01, //setup time
               TRANSFER = 2'b10,
               DONE = 2'b11;
    //Registers to keep track of state and counters
    reg [1:0] state;
    reg[2:0] bit_cnt; //counts from 0 to 7
    reg [7:0] shift_reg; //Temporary storage for data being sent out or in
    
    //FSM Logic
    always @(posedge clk or posedge rst) begin
        if(rst)begin
            state <= IDLE;
            sclk <= 1'b0;
            mosi <= 1'b0;
            cs <= 1'b1; // Active low means 1 is off
            busy <= 1'b0;
            done <= 1'b0;
            rx_data <= 8'b0;
            shift_reg <= 8'b0;
            bit_cnt <= 3'b0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 1'b0;
                    cs <= 1'b1; //Inactive
                    sclk <= 1'b0;
                    if(start) begin
                        busy <= 1'b1;
                        shift_reg <= tx_data;
                        state <= INIT;
                    end else begin
                        busy <= 1'b0;
                        state <= IDLE;
                    end
                end
                INIT: begin
                    cs <= 1'b0; //Activate
                    state <= TRANSFER;
                end
                TRANSFER: begin
                    if (sclk == 1'b0) begin
                        //Put current MSB onto MOSI
                        mosi <= shift_reg[7];
                        sclk <= 1'b1;
                    end else begin
                        //Smapling: CLOCK is high, read miso from slave
                        sclk <= 1'b0;
                        
                        shift_reg <= {shift_reg[6:0], miso}; //shift left then take miso bit
                        
                        //Check if all bits have been processed
                        if(bit_cnt == 3'd7) begin
                            bit_cnt <= 3'd0;
                            rx_data <= {shift_reg[6:0], miso};
                            state <= DONE;
                        end else begin
                            bit_cnt <= bit_cnt + 1'b1;
                            state <= TRANSFER;
                        end
                    end
                end
                DONE: begin
                    cs <= 1'b1; //Deactivate
                    busy <= 1'b0;
                    done <= 1'b1;
                    state <= IDLE;
                end
                default: state <= IDLE;
            endcase
       end
  end 
     
endmodule
