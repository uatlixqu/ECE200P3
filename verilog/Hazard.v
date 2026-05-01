module Hazard(

	//MODULE INPUTS
	
		//CONTROL SIGNALS
		input	CLOCK,
		input 	RESET,	

	//MODULE OUTPUTS

		output 	STALL_IFID,
		output 	FLUSH_IFID,
	
		output 	STALL_IDEXE,
		output 	FLUSH_IDEXE,
	
		output 	STALL_EXEMEM,
		output 	FLUSH_EXEMEM,
	
		output 	STALL_MEMWB,
		output 	FLUSH_MEMWB

);

// The original design used this ring to force multicycle behavior:
// only one instruction was allowed to enter the pipeline every five cycles.
// Project 3 requires that behavior during the boot/initialization region only,
// because the boot code has dependencies and the project does not require
// implementing forwarding/hazard detection for Task 1.  After 250 processor
// cycles, the pipeline registers are allowed to advance every cycle.
reg [4:0]  MultiCycleRing;
reg [31:0] CycleCount;

wire BootMode;
assign BootMode = (CycleCount < 32'd250);

// No explicit flushing/stalling after boot mode.  The test program has no data
// dependences, so normal five-stage pipelined execution is sufficient.
assign FLUSH_MEMWB  = 1'b0;
assign STALL_MEMWB  = 1'b0;

assign FLUSH_EXEMEM = 1'b0;
assign STALL_EXEMEM = 1'b0;

assign FLUSH_IDEXE  = 1'b0;
assign STALL_IDEXE  = 1'b0;

// During the first 250 cycles, preserve the provided multicycle protocol by
// letting IF/ID update only when MultiCycleRing[0] is high.  This also stalls
// the IF stage because MIPS.v connects STALL_IFID to IF.STALL.
assign FLUSH_IFID   = BootMode ? !(MultiCycleRing[0]) : 1'b0;
assign STALL_IFID   = BootMode ? !(MultiCycleRing[0]) : 1'b0;

always @(posedge CLOCK or negedge RESET) begin

	if(!RESET) begin

		MultiCycleRing <= 5'b00001;
		CycleCount     <= 32'd0;

	end else if(CLOCK) begin

		$display("");
		$display("----- HAZARD UNIT -----");
		$display("CycleCount: %d", CycleCount);
		$display("BootMode: %b", BootMode);
		$display("Multicycle Ring: %b", MultiCycleRing);

		CycleCount     <= CycleCount + 32'd1;
		MultiCycleRing <= {MultiCycleRing[3:0], MultiCycleRing[4]};

	end

end

endmodule
