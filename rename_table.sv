module rename_record_table #(
    parameter DATA_WIDTH = 8,  // Width of each data element
    parameter TABLE_DEPTH = 16  // Number of elements in the table
)(
    input clk,
    input reset,
    input write_enable,        // Enable signal for writing data
    input read_enable,         // Enable signal for reading data
    input [DATA_WIDTH-1:0] data_in,  // Input data bus
    output reg [DATA_WIDTH-1:0] data_out, // Output data bus
    output table_full,
    output table_empty
);

// Internal variables
reg [DATA_WIDTH-1:0] table_memory[TABLE_DEPTH-1:0];
reg [$clog2(TABLE_DEPTH)-1:0] write_pointer = 0, read_pointer = 0;
reg [$clog2(TABLE_DEPTH+1)-1:0] element_count = 0;

// Write logic
always @(posedge clk) begin
    if (reset) begin
        write_pointer <= 0;
        element_count <= 0;
    end else if (write_enable && !table_full) begin
        table_memory[write_pointer] <= data_in;
        write_pointer <= write_pointer + 1;
        element_count <= element_count + 1;
    end
end

// Read logic
always @(posedge clk) begin
    if (reset) begin
        read_pointer <= 0;
        element_count <= 0;
    end else if (read_enable && !table_empty) begin
        data_out <= table_memory[read_pointer];
        read_pointer <= read_pointer + 1;
        element_count <= element_count - 1;
    end
end

// Status flags
assign table_full = (element_count == TABLE_DEPTH);
assign table_empty = (element_count == 0);

endmodule

