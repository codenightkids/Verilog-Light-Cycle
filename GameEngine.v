module GameEngine (clk, curX, curY, curPressed, red, green, blue);

input clk;

//----Where the screen is currently displaying (but really it's the next curX and curY)---//
input [11:0]curX;
input [11:0]curY;

//----What is currently being pressed by the players (used for vehicle movement)---//
input [7:0]curPressed;

//-----The color that's being sent to the screen---//
output [3:0]red;
output [3:0]green;
output [3:0]blue;
reg [3:0]red;
reg [3:0]green;
reg [3:0]blue;

//-----lightcycle datas---//
reg [23:0]car1Pos;//the position where car 1 is at
reg [23:0]car2Pos;//the position where car 2 is at
reg [23:0]car1DirPos;//the position where car 1 is at
reg [23:0]car2DirPos;//the position where car 2 is at

reg [11:0]car1Color;//player1 color (later will be set by the player)
reg [11:0]car2Color;//player2 color

reg [11:0]carMem1Color;//player1 color (later will be set by the player)
reg [11:0]carMem2Color;//player2 color

reg [3:0]car1Direction;
reg [3:0]car2Direction;

reg [23:0]car1Tail[75:0];
reg [23:0]car2Tail[75:0];

reg [11:0]car1Turns;
reg [11:0]car2Turns;

//----registers for use somewhere ---//
reg [0:0]onDraw;
reg [33:0]FPS;
reg [6:0]frameCounter;
reg [15:0]GridCounter;
reg [3:0]bgFade;
reg [1:0]increase;
integer i = 3;

reg car1Collided; //---if car 1 has collided with something (ie. died))
reg car2Collided; //---if car 2 has collided with something (ie. died))

reg checkCol1;
reg checkCol2;

reg resetMatch;

integer player1Win = 0;
integer player2Win = 0;

//----registers for tempX and tempY (car tails need this?)---//

reg [11:0]tempX;
reg [11:0]tempY;
reg [11:0]tempX2;
reg [11:0]tempY2;

//-----register for clock sync (drawing should be done at 25mhz, not 50) ------//

reg halfClk;

//----Intial Value Declarations
initial
begin
//player colors (place holder until menu is made)
car1Color[3:0] = 15;
car1Color[7:4] = 4;
car1Color[11:8] = 0;

car2Color[3:0] = 0;
car2Color[7:4] = 4;
car2Color[11:8] = 15;

carMem1Color[3:0] = 15;
carMem1Color[7:4] = 4;
carMem1Color[11:8] = 0;

carMem2Color[3:0] = 0;
carMem2Color[7:4] = 4;
carMem2Color[11:8] = 15;


//initial color setting
	red[3:0] = 0;
	green[3:0] = 15;
	blue[3:0] = 0;

//set the initial position of the cars
	//x for car 1
	car1Pos[23:12] = 20;
	//y for car 1
	car1Pos[11:0] = 20;
	//direction for car1
	car1Direction[3:0] = 0;
	//car1's tail initial pos to remove glitch
	car1Tail[1][23:12] = 20;
	car1Tail[1][11:0] = 20;
	car1Collided = 0;
	
	//x for car 2
	car2Pos[23:12] = 615;
	//y for car 2
	car2Pos[11:0] = 460;
	//direction for car2
	car2Direction[3:0] = 0;
	//car 2 tail intial poop
	car2Tail[1][23:12] = 615;
	car2Tail[1][11:0] = 460;
	car2Collided = 0;
	
//intial logic variables
	onDraw = 0;
	bgFade = 0;
	GridCounter = 0;
	
	car1Turns = 0;
	car2Turns = 0;

	checkCol1 = 0;
	checkCol2 = 0;
	
	resetMatch = 0;
	
end


//============================End of Declarations=============================================//

task automatic show_line;
	input[23:0] tailSeg1;
	input[23:0] tailSeg2;
	input[0:0] car; 
	
	//Check two see if car1 is colliding with this "line"
	if((curX >= car1DirPos[23:12] - 1 & curX <= car1DirPos[23:12] + 1) & (curY >= car1DirPos[11:0] - 1 & curY <= car1DirPos[11:0] + 1))
	begin
		checkCol1 = 1;
	end
	
	//Check two see if car2 is colliding with this "line"
	if((curX >= car2DirPos[23:12] - 1 & curX <= car2DirPos[23:12] + 1) & (curY >= car2DirPos[11:0] - 1 & curY <= car2DirPos[11:0] + 1))
	begin
		checkCol2 = 1;
	end
	

	if((((curX >= tailSeg1[23:12]) & (curX <= tailSeg2[23:12])) & ((curY >= tailSeg1[11:0]) & (curY <= tailSeg2[11:0]))) & tailSeg2 !=0)
	begin
		
		//player1 drawn 
		if(car)
		begin
			red = car1Color[3:0];
			green = car1Color[7:4] - bgFade;
			blue = car1Color[11:8];
		end
		//player2 drawn
		else
		begin
			red = car2Color[3:0];
			green = car2Color[7:4] - bgFade;
			blue = car2Color[11:8];
		end
		
		if(checkCol1 & resetMatch != 1)
		begin
			car1Collided = 1;
		end
		
		if(checkCol2 & resetMatch != 1)
		begin
			car2Collided = 1;
		end
		
	end
	else
	if(((curX >= tailSeg2[23:12]) & (curX <= tailSeg1[23:12])) & ((curY >= tailSeg1[11:0]) & (curY <= tailSeg2[11:0])) & tailSeg2 !=0)
	begin
		//player1 drawn 
		if(car)
		begin
			red = car1Color[3:0];
			green = car1Color[7:4] - bgFade;
			blue = car1Color[11:8];
		end
		//player2 drawn
		else
		begin
			red = car2Color[3:0];
			green = car2Color[7:4] - bgFade;
			blue = car2Color[11:8];
		end
		
		if(checkCol1 & resetMatch != 1)
		begin
			car1Collided = 1;
		end
		
		if(checkCol2 & resetMatch != 1)
		begin
			car2Collided = 1;
		end
		
	end
	else
	if(((curX >= tailSeg1[23:12]) & (curX <= tailSeg2[23:12])) & ((curY >= tailSeg2[11:0]) & (curY <= tailSeg1[11:0])) & tailSeg2 !=0)
	begin
		//player1 drawn 
		if(car)
		begin
			red = car1Color[3:0];
			green = car1Color[7:4] - bgFade;
			blue = car1Color[11:8];
		end
		//player2 drawn
		else
		begin
			red = car2Color[3:0];
			green = car2Color[7:4] - bgFade;
			blue = car2Color[11:8];
		end
		
		if(checkCol1 & resetMatch != 1)
		begin
			car1Collided = 1;
		end
		
		if(checkCol2 & resetMatch != 1)
		begin
			car2Collided = 1;
		end
	end
	else
	if(((curX >= tailSeg2[23:12]) & (curX <= tailSeg1[23:12])) & ((curY >= tailSeg2[11:0]) & (curY <= tailSeg1[11:0])) & tailSeg2 !=0)
	begin
	
		//player1 drawn 
		if(car)
		begin
			red = car1Color[3:0];
			green = car1Color[7:4] - bgFade;
			blue = car1Color[11:8];
		end
		//player2 drawn
		else
		begin
			red = car2Color[3:0];
			green = car2Color[7:4] - bgFade;
			blue = car2Color[11:8];
		end
		
		if(checkCol1 & resetMatch != 1)
		begin
			car1Collided = 1;
		end
		
		if(checkCol2 & resetMatch != 1)
		begin
			car2Collided = 1;
		end
		
	end
	else
	begin
		checkCol1 = 0;
		checkCol2 = 0;
	end
	
	if(resetMatch)
	begin
		checkCol1 = 0;
		checkCol2 = 0;
		car1Collided = 0;
		car2Collided = 0;
	end
	
endtask

//COUNTER CONTROL
always@ (negedge clk)
begin
	if(FPS>=433333)
	begin
		onDraw = 1;
		FPS = 0;
	end else
	begin
		onDraw = 0;
		FPS = FPS + 1;
	end
end


always@ (posedge clk)
begin
	halfClk = ~halfClk;
end

//---The Drawing of the cars and walls here --//
always@(negedge halfClk)
begin

	//first assume the background is black
	red=0;
	green=0;
	blue=0;
	
	//then draw the grid if it wants to
	if((curX%15==0) | (curY%9 == 0))
	begin
		red = 0;
		green = bgFade/2;
		blue = bgFade;
	end
	
//drawing walls
	//left wall
	if((curX >= 0) & (curX <= 5))
	begin
		red=0;
		green=3;
		blue=8;
	end

	//right wall
	if((curX >= 635) & (curX <= 640))
	begin
		red=0;
		green=3;
		blue=8;
	end

	//top wall
	if((curY >= 0) & (curY <= 5))
	begin
		red=0;
		green=3;
		blue=8;
	end

	//bot wall
	if((curY >= 475) & (curY <= 480))
	begin
		red=0;
		green=3;
		blue=8;
	end

	//Drawing cars

	if((curX >= car1Pos[23:12]) & (curX <= (car1Pos[23:12]+9)) & (curY >= car1Pos[11:0]) & (curY <= car1Pos[11:0]+9))
	begin
		red = car1Color[3:0];
		green = car1Color[7:4];
		blue = car1Color[11:8];
	end 
	
	if((curX >= car2Pos[23:12]) & (curX <= (car2Pos[23:12]+9)) & (curY >= car2Pos[11:0]) & (curY <= car2Pos[11:0]+9))
	begin
		red = car2Color[3:0];
		green = car2Color[7:4];
		blue = car2Color[11:8];
	end

	//Drawing Tails for car1
	for(i = 1; i<74; i=i+1)
	begin
		show_line(car1Tail[i-1], car1Tail[i], 1);
	end
	
	//Drawing Tails for car2
	for(i = 1; i<74; i=i+1)
	begin
		show_line(car2Tail[i-1], car2Tail[i], 0);
	end
	
	//doing some wall collision in here cause we didnt think this out enough
	if(resetMatch != 1)
	begin
		if(car1Pos[23:12]+10 >= 635)
		begin
			car1Collided = 1;
		end

		if(car1Pos[23:12] <= 5)
		begin
			car1Collided = 1;
		end

		if(car1Pos[11:0] <= 5)
		begin
			car1Collided = 1;;
		end

		if(car1Pos[11:0] >= 470)
		begin
			car1Collided = 1;
		end

		if(car2Pos[23:12]+9 >= 635)
		begin
			car2Collided = 1;
		end

		if(car2Pos[23:12] <= 5)
		begin
			car2Collided = 1;
		end

		if(car2Pos[11:0] <= 5)
		begin
			car2Collided = 1;
		end

		if(car2Pos[11:0] >= 470)
		begin
			car2Collided = 1;
		end		
	end
	
	
end

//grid color alternator
always@ (posedge onDraw)
begin

	if((GridCounter%20 == 0) & GridCounter < 320)
	begin
		if(bgFade < 7)
		begin
			bgFade = bgFade + 1;
		end
	end
	
	if((GridCounter%20 == 0) & GridCounter == 320)
	begin
			bgFade = 7;
	end
	
	if((GridCounter%20 == 0) & GridCounter > 320)
	begin
			if(bgFade > 0)
			begin
				bgFade = bgFade - 1;
			end
	end
	
end



//----Game Logic Here
always@ (posedge onDraw)
begin

	if(resetMatch)
	begin
	//car1 reset stuff
		if(curPressed == 8'h2d)
		begin
			car1Pos[23:12] = 20;
			car1Pos[11:0] = 20;

			car1Color = carMem1Color;
			
			car1Turns = 0;
			
			car1Direction = 0;	
				
			for(i=0;i<74;i=i+1) car1Tail[i] = 0;
			car1Tail[1][23:12] = 25;
			car1Tail[1][11:0] = 25;
			
		//car2 reset stuff
			car2Pos[23:12] = 615;
			car2Pos[11:0] = 460;
			
			car2Color = carMem2Color;
			
			car2Turns = 0;
			
			car2Direction = 0;	

			for(i=0;i<74;i=i+1) car2Tail[i] = 0;
			car2Tail[1][23:12] = 620;
			car2Tail[1][11:0] = 465;
			
		//Reset the match variable to 0 if the other "philosophers" have eaten.	
			if(car1Collided == 0 & car2Collided == 0)
			begin
				resetMatch = 0;
			end	
		end
	end//end of resetMatch
	
	car1Tail[0][23:12] = 25;
	car1Tail[0][11:0] = 25;
			
	car1Tail[car1Turns][23:12] = car1Pos[23:12] + 5; //x shift of tail
	car1Tail[car1Turns][11:0] = car1Pos[11:0] + 5; //y shift of tail

	car2Tail[0][23:12] = 620;
	car2Tail[0][11:0] = 465;
			
	car2Tail[car2Turns][23:12] = car2Pos[23:12] + 5; //x shift of tail
	car2Tail[car2Turns][11:0] = car2Pos[11:0] + 5; //y shift of tail
	
	//--Stuff for graphic animations
	if(GridCounter == 640)
	begin
		GridCounter = 0;
	end
	GridCounter = GridCounter+1;
	frameCounter = (frameCounter + 1)%60;


	//--player 1 current direction detection
	if(curPressed[7:0] == 8'h1D & car1Direction != 3)//up
	begin
		if(car1Direction[3:0] != 1)
		begin
			car1Turns = car1Turns + 1;
			
		end
		car1Direction[3:0] = 1;
	end 

	if(curPressed[7:0] == 8'h23 & car1Direction != 4)//right
	begin
		if(car1Direction[3:0] != 2)
		begin
			car1Turns = car1Turns + 1;
		end
		car1Direction[3:0] = 2;
		
	end 

	if(curPressed[7:0] == 8'h1B & car1Direction != 1)//down
	begin
		if(car1Direction[3:0] != 3)
		begin
			car1Turns = car1Turns + 1;
		end
		car1Direction[3:0] = 3;
	end

	if(curPressed[7:0] == 8'h1C & car1Direction != 2)//left
	begin
		if(car1Direction[3:0] != 4)
		begin
			car1Turns = car1Turns + 1;
		end
		car1Direction[3:0] = 4;
	end

	//player 2 current direction detection
	if(curPressed[7:0] == 8'h43 & car2Direction != 3)//up
	begin
		if(car2Direction[3:0] != 1)
		begin
			car2Turns = car2Turns + 1;
		end
		car2Direction[3:0] = 1;
	end 

	if(curPressed[7:0] == 8'h4b & car2Direction != 4)//right
	begin
		if(car2Direction[3:0] != 2)
		begin
			car2Turns = car2Turns + 1;
		end
		car2Direction[3:0] = 2;
	end 

	if(curPressed[7:0] == 8'h42 & car2Direction != 1)//down
	begin
		if(car2Direction[3:0] != 3)
		begin
			car2Turns = car2Turns + 1;
		end
		car2Direction[3:0] = 3;
	end 

	if(curPressed[7:0] == 8'h3b & car2Direction != 2)//left
	begin
		if(car2Direction[3:0] != 4)
		begin
			car2Turns = car2Turns + 1;
		end
		car2Direction[3:0] = 4;
	end 

		//player 1 movement (dependent upon direction)
	if(car1Collided != 1 )
	begin
		if(resetMatch != 1)
		begin
			if(car1Direction[3:0] == 1)
			begin	
				car1Pos[11:0] = car1Pos[11:0] - 1;
				
				car1DirPos[23:12] = car1Pos[23:12] + 5;//move the directional pos to the right 5
				car1DirPos[11:0] = car1Pos[11:0] + 2;
			end
			else
			if(car1Direction[3:0] == 2)
			begin
				car1Pos[23:12] = car1Pos[23:12] + 1;
				
				car1DirPos[23:12] = car1Pos[23:12] + 6;//move the directional pos to the right 9
				car1DirPos[11:0] = car1Pos[11:0] + 5;//move the directional pos down 5
			end
			else
			if(car1Direction[3:0] == 3)
			begin
				car1Pos[11:0] = car1Pos[11:0] + 1;
				
				car1DirPos[23:12] = car1Pos[23:12] + 5;//move the directional pos to the right 5
				car1DirPos[11:0] = car1Pos[11:0] + 6;//move the directional pos down 9
			end
			else
			if(car1Direction[3:0] == 4)
			begin	
				car1Pos[23:12] = car1Pos[23:12] - 1;
				
				car1DirPos[23:12] = car1Pos[23:12] + 2;
				car1DirPos[11:0] = car1Pos[11:0] + 5;//move the directional pos down 5
				
			end
			else
			begin
				car1Pos = car1Pos;
				car1DirPos = car1DirPos;
			end
		end
	end
	else
	begin
		car1Color[3:0] = 15;
		car1Color[7:4] = 15;
		car1Color[11:8] = 15;
		player2Win = player2Win + 1;
		resetMatch = 1;
	end

		//player 2 movement
	if(car2Collided != 1 )
	begin
		if(resetMatch != 1)
		begin
			if(car2Direction[3:0] == 1)
			begin
				car2Pos[11:0] = car2Pos[11:0] - 1;
				
				
				car2DirPos[23:12] = car2Pos[23:12] + 5;//move the directional pos to the right 5
				car2DirPos[11:0] = car2Pos[11:0] + 2;
			end
			else
			if(car2Direction[3:0] == 2)
			begin
				car2Pos[23:12] = car2Pos[23:12] + 1;
				
				car2DirPos[23:12] = car2Pos[23:12] + 6;//move the directional pos to the right 9
				car2DirPos[11:0] = car2Pos[11:0] + 5;//move the directional pos down 5			
			end
			else
			if(car2Direction[3:0] == 3)
			begin
				car2Pos[11:0] = car2Pos[11:0] + 1;
				
				car2DirPos[23:12] = car2Pos[23:12] + 5;//move the directional pos to the right 5
				car2DirPos[11:0] = car2Pos[11:0] + 6;//move the directional pos down 9
			end
			else
			if(car2Direction[3:0] == 4)
			begin
				car2Pos[23:12] = car2Pos[23:12] - 1;
				
				car2DirPos[23:12] = car2Pos[23:12] + 2;
				car2DirPos[11:0] = car2Pos[11:0] + 5;//move the directional pos down 5
			end
			else
			begin
				car2Pos = car2Pos;
			end
		end
	end
	else
	begin
		car2Color[3:0] = 15;
		car2Color[7:4] = 15;
		car2Color[11:8] = 15;
		player1Win = player1Win + 1;
		resetMatch = 1;
	end
	
end

endmodule



