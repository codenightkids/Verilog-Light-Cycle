module graphic_driver(clk, h_sync, v_sync,redIn, greenIn, blueIn, red, green, blue, curX, curY);
//Input values
	input clk;
	input [3:0]redIn;
	input [3:0]greenIn;
	input [3:0]blueIn;
	
//Outputs
	output h_sync,v_sync;
	
	output [3:0]red;
	output [3:0]green;
	output [3:0]blue;
	output [11:0]curX;
	output [11:0]curY;
	
//registers
   reg h_sync,v_sync;
	
   reg[3:0] red;
   reg[3:0] green;
   reg[3:0] blue;

   reg[9:0] h_conter;
   reg[9:0] v_conter;
	
	reg[11:0] curX;
	reg[11:0] curY;

// relative screen x, y coordinates.
	reg[9:0] yCord;
	reg[9:0] xCord;
//"half clock" for monitor/ref sync
	reg halfClk;

   wire h_max=(h_conter==799);
   wire v_max=(v_conter==525);

	
//Clock divison(50mhz to 25mhz)
	always@(posedge clk)
		halfClk = ~halfClk;

//H and V counter increase
   always@(posedge halfClk)
   if(h_max)
      h_conter<=0;
   else
      h_conter<=h_conter+1;
		
// v_counter action
   always@(posedge halfClk)
   if(v_max)
      v_conter<=0;
   else if(h_max)
      v_conter<=v_conter+1;

//This puts the first part of the hsync at the end of the horizontal draw cycle (the "a (pixels)" part)
//Same goes for the vsync (the "a (lines)" part is now at the end of the vertical draw cycle).
//It seems more intuitive this, and it's how the example code did it :P
//----- h_sync action and v_sync action -----
   always@(posedge halfClk)
   begin
        h_sync<= ( h_conter<=703);
        v_sync<= ( v_conter<=523);
   end
	
always@(posedge halfClk)
//painting---------------------------------------------------------------------
   if( (h_conter<=48)|(h_conter>=688)|(v_conter<=33)|(v_conter>=513) )
   begin
		red[3:0]<=0;
		green[3:0]<=0;
		blue[3:0]<=0;
   end else
   begin		
//setting relative x and y coordinates
		xCord = h_conter - 48;
		yCord = v_conter - 33;
//ACTUAL DRAWING STARTS HERE!----------------------------------------------------------	
	red[3:0] <= redIn;
	blue[3:0] <= blueIn;
	green[3:0] <= greenIn;
	curX = xCord;
	curY = yCord;


//DRAWING STOPS HERE!------------------------------------------------------------------
	end
endmodule
