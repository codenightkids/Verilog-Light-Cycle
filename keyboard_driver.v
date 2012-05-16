module keyboard_driver (clk, bkbClk, kbData, curPresKeyCode, released, segDispOne, segDispTwo);
input clk;
input bkbClk;
input kbData;

output [6:0]segDispOne;
output [6:0]segDispTwo;
output [7:0]curPresKeyCode;
output [1:0]released;

reg [6:0] segDispOne; //7 segment display
reg [6:0] segDispTwo; //7 segment display
reg [10:0] tDelay; //a delay counter for cpu sampling
reg [4:0] sampleCnt;  //the keyboard CPU sampling. 
reg [7:0] rawCode; //the keycode as it's read in (raw)
reg [7:0] keyCode; //the keycode as is
reg [7:0] curPresKeyCode; //the Currently pressed keyCode
reg [7:0] releasedKeyCode; //the most recently released key Code
reg done; //let's other parts of the module know when its down with the current input value
reg relNext;
reg [3:0] dataCnt; //counts to see how many bits has been sent 
reg [1:0] released; //is set to '1' when a key is released

reg gkbClk; //The debounced line.

//------------------------
// KeyBoard Clk debouncer
// --Turn the "bouncing" kbClk into a "clean" signal (gkbClk)
// --My reasoning treats the sampleing as a "charge". The more the 
// --clk is on, the more "charged" it gets. The more it's off, the lesser the "charge" becomes.
//------------------------
initial
begin
	tDelay = 0;
	gkbClk = 0;
	sampleCnt = 0;
end


always@ (negedge clk)
begin
	
	//This will sample and filter the keyboards clock (the clk will be filtered to the reg gkbClk
		//every 1000 cycles...
		if(tDelay>=50)
		begin
			tDelay = 0; //reset the timer delay
			if(bkbClk == 1)//"if posedge"
			begin
				if(sampleCnt < 6)
				begin
					//If the bad kb clk is live, the sampleCnt goes up 1.
					sampleCnt = sampleCnt + 1;
				end
			end else//"if negedge"
			begin
				if(sampleCnt > 0)
				begin
					//if the bad kb clk is dead, then the sampeCnt goes down by 1
					sampleCnt = sampleCnt - 1;
				end
			end	
		end

		if(sampleCnt >= 6)
		begin
			//If the signal has been found to be on 3 times, the signal is on.
			 gkbClk = 1;
		end
		
		if(sampleCnt <=0)
		begin
			//If the signal is dead, turn off the clock.
			gkbClk = 0;
		end
		
		tDelay = tDelay + 1;
	//end of the filtering (now gkbClk has the "good" clock)
end//always

//-------------------------
// Keyboard Data to Display
// --grab keyboard data and assign the 7 Segment Display (segDisp) to that value.
//	--Turn the kbData line into data, using the refrence gkbClk,
// --Good for debuggin things
//-------------------------
always@ (negedge gkbClk)
begin
	//get the data comming in
	if(dataCnt >= 1 && dataCnt < 9)
	begin
		done = 0;
		if(kbData == 1)//if the kbdata 
		begin
			rawCode[dataCnt-1] = 1'b1;
		end else
		begin
			rawCode[dataCnt-1] = 1'b0;
		end
	end
	//Check the data after it's full up
	if(dataCnt > 9)
	begin
			done = 1;
			keyCode = rawCode; //filling up the keyCode
	end
	if(dataCnt == 11)
	begin
			dataCnt = 0; //reset the data counter
	end
	dataCnt = dataCnt + 1;
end

//gives us the currentPresseKey
always@ (posedge clk)
begin
	if(relNext == 0 )
	begin
		if(keyCode != 8'hf0)
		begin
			curPresKeyCode = keyCode;
		end
	end 
end


always@ (posedge clk)
begin


//give us the released key
	//set the 7seg displays to the raw data
	case(curPresKeyCode[3:0])//first 7seg display
		4'h1: segDispOne = 7'b1111001;
		4'h2: segDispOne = 7'b0100100;
		4'h3: segDispOne = 7'b0110000;
		4'h4: segDispOne = 7'b0011001;
		4'h5: segDispOne = 7'b0010010;
		4'h6: segDispOne = 7'b0000010;
		4'h7: segDispOne = 7'b1111000;
		4'h8: segDispOne = 7'b0000000;
		4'h9: segDispOne = 7'b0011000;	
		4'ha: segDispOne = 7'b0001000;
		4'hb: segDispOne = 7'b0000011;
		4'hc: segDispOne = 7'b1000110;
		4'hd: segDispOne = 7'b0100001;
		4'he: segDispOne = 7'b0000110;
		4'hf: segDispOne = 7'b0001110;
		4'h0: segDispOne = 7'b1000000;
	endcase
	
	case(curPresKeyCode[7:4])//second 7seg display
		4'h1: segDispTwo = 7'b1111001;
		4'h2: segDispTwo = 7'b0100100;
		4'h3: segDispTwo = 7'b0110000;
		4'h4: segDispTwo = 7'b0011001;
		4'h5: segDispTwo = 7'b0010010;
		4'h6: segDispTwo = 7'b0000010;
		4'h7: segDispTwo = 7'b1111000;
		4'h8: segDispTwo = 7'b0000000;
		4'h9: segDispTwo = 7'b0011000;	
		4'ha: segDispTwo = 7'b0001000;
		4'hb: segDispTwo = 7'b0000011;
		4'hc: segDispTwo = 7'b1000110;
		4'hd: segDispTwo = 7'b0100001;
		4'he: segDispTwo = 7'b0000110;
		4'hf: segDispTwo = 7'b0001110;
		4'h0: segDispTwo = 7'b1000000;
	endcase
end

always@(posedge clk)
begin
	if(relNext == 1 & keyCode != 8'hf0)
	begin
		releasedKeyCode = rawCode;
		relNext = 0;
	end else
	if(keyCode == 8'hf0)
	begin
		relNext = 1;
	end
end


endmodule
