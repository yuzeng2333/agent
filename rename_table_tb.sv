`timescale 1ns / 1ps

module tb_rename_record_table;

    // Parameters
    parameter DATA_WIDTH = 8;
    parameter TABLE_DEPTH = 4;  // Reduced for easier testing

    // I/O Declarations
    reg clk;
    reg reset;
    reg write_enable;
    reg read_enable;
    reg [DATA_WIDTH-1:0] data_in;
    wire [DATA_WIDTH-1:0] data_out;
    wire table_full;
    wire table_empty;

    // Instantiate the Rename Record Table
    rename_record_table #(
        .DATA_WIDTH(DATA_WIDTH),
        .TABLE_DEPTH(TABLE_DEPTH)
    ) uut (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .data_in(data_in),
        .data_out(data_out),
        .table_full(table_full),
        .table_empty(table_empty)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100 MHz clock
    end

    // Test sequence
    initial begin
        // Initialize inputs
        reset = 1;
        write_enable = 0;
        read_enable = 0;
        data_in = 0;

        // Reset the system
        #10 reset = 0;
        #10 reset = 1;
        #10 reset = 0;

        // Fill the table
        repeat (TABLE_DEPTH) begin
            #10;
            data_in = $random;
            write_enable = 1;
        end

        // Attempt to write when full
        #10;
        write_enable = 1;
        data_in = $random;  // This write should trigger the assertion

        // End test after a short delay
        #20;
        write_enable = 0;
        $finish;
    end

    // Generate VCD file
    initial begin
        $dumpfile("rename_record_table.vcd");
        $dumpvars(0, tb_rename_record_table);
    end

endmodule
