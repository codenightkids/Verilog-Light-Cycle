module lightcycle(clk, kbClk, kbData, vgar, vgag, vgab, segDispOne, segDispTwo, h_sync, v_sync);
	input clk;
	input kbClk;
	input kbData;
	
	output [3:0]vgar;
	output [3:0]vgag;
	output [3:0]vgab;
	
	wire[3:0] vgar;
   wire[3:0] vgag;
   wire[3:0] vgab;
	
	wire[3:0] redIn;
	wire[3:0] blueIn;
	wire[3:0] greenIn;
	
	output h_sync,v_sync;
   wire h_sync,v_sync;
	
	//7-seg displays for debuggin
	wire [6:0]segDispOne;
	wire [6:0]segDispTwo;
	output [6:0]segDispOne;
	output [6:0]segDispTwo;

	//the current position that the screen is drawing to
	wire [11:0]curX;
	wire [11:0]curY;
	
	//wires the keyboard
	wire [7:0]curPressed; //this holds the value of the most recently pressed key
	wire [1:0]released; //when a key is released, this switches to 0
	
	reg [11:0]stageCounter; //holds the value of which stage the program is at
	
	keyboard_driver keyboard(clk, kbClk, kbData, curPressed, released, segDispOne, segDispTwo);
	GameEngine game(clk, curX, curY, curPressed, redIn, greenIn, blueIn);
	graphic_driver graphic_driver(clk, h_sync, v_sync, redIn, greenIn, blueIn, vgar, vgag, vgab, curX, curY);
	
	always @(posedge clk)
	begin
	
	
	end
endmodule
