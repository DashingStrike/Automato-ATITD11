dofile("common.inc");
dofile("settings.inc");

askText = [[Beetlejuice Beetlejuice Beetlejuice
	
This macro helps you farm Khefre's Essence by mulching beetles on terrariums down to a specified number of male and females. The beetles mulched are chosen randomly. Do not use this on a terrarium you are breeding beetles in for the test!

Press SHIFT in the ATITD window to begin.]];

maxM = 1;
maxF = 10;

function doCull()
	local mx, my = srMousePos();

	closeAllWindows();
	
	if not openAndPin(mx, my, 1000) then
		sleepWithStatus(2000, "No window opened at the specified mouse coordinates");
		return;
	end
	
	if not findImage("mulch.png") then
		sleepWithStatus(2000, "Mulch button not found");
		closeAllWindows();
		return;
	end
	
	srReadScreen();
	ofs = makeBox(50,50,0,0);
	stashWindow(mx + 5, my + 5, TOP_LEFT, nil, ofs);
	
	lsSleep(150);
	
	while true do
		srReadScreen();
		checkBreak();

		pos = findText("View Beetle");
		if not pos then
			sleepWithStatus(2000, "View Beetle button not found");
			break;
		end

		clickText(pos);
		lsSleep(50);

		srReadScreen();
		win = findText("In Terrarium");

		if not win then
			sleepWithStatus(2000, "No beetles in terrarium found");
			break;
		end

		local status, result = pcall(function () return findAllText(searchText, nil, REGEX); end);

		if (status) then
			print('Status: '..tostring(status).. "; Results: "..#result);
			errorInfo = '';
			textlist = result or {};
		else 
			print('Status: '..tostring(status).. "; Result: "..result);
			errorInfo = result:match(": ([A-Za-z ]+)");    
			textlist = {};
		end

		started = false;
		
		malelist = {};
		femalelist = {};

		for i=1,#textlist do
			parse = textlist[i];

			if not started then
				if string.match(parse[2], "In Terrarium") then
					started = true;
				end
			else
				if string.match(parse[2], "In Inventory") then
					break;
				end
				
				if string.match(parse[2], "^.*[(]M[)]$") then
					lsPrintln("M:" .. parse[2]);
					table.insert(malelist, parse[2]);
				elseif string.match(parse[2], "^.*[(]F[)]$") then
					lsPrintln("F:" .. parse[2]);
					table.insert(femalelist, parse[2]);
				end
			end
		end

		lsPrintln(#malelist .. " males, " .. #femalelist .. " females");

		if (#malelist <= maxM) and (#femalelist <= maxF) then
			sleepWithStatus(2000, #malelist .. " males, " .. #femalelist .. " females--all done!");
			break;
		end
		
		if (#malelist > maxM) then
			i = math.random(#malelist);
			clickAllText(malelist[i]);
			lsSleep(50);
			srReadScreen();
			findImage("mulch.png")
			clickAllImages("mulch.png");
		elseif (#femalelist > maxF) then
			i = math.random(#femalelist);
			clickAllText(femalelist[i]);
			lsSleep(50);
			srReadScreen();
			clickAllImages("mulch.png");
		end

		if lsButtonText(lsScreenX - 110, lsScreenY - 30, 0, 100, 0xFFFFFFff, "End script") then
			error "Clicked End Script button";
		end

		lsDoFrame();
		lsSleep(50);
	end
	
	srKeyEvent('\27');
	lsSleep(50);
	closeAllWindows();
end

function doit()
	local x, y;

	math.randomseed(lsGetTimer());
	askForWindow(askText);
	searchText = "";

	maxM = readSetting("maxM", maxM);
	maxF = readSetting("maxF", maxF);

	while true do
		checkBreak();
		
		bCtrlPressed = lsControlHeld();
		
		if bCtrlPressed then
			while bCtrlPressed do
				checkBreak();
				bCtrlPressed = lsControlHeld();
				lsSleep(50);
			end
			
			writeSetting("maxM", maxM);
			writeSetting("maxF", maxF);
			doCull();
		end
		
		x = 10;
		y = 10;
		lsPrint(10, y, 10, 0.7, 0.7, 0xFFFFFFff, "How many beetles to keep?");
		y = y + 60;
	
		lsPrint(10, y, 10, 0.7, 0.7, 0xFFFFFFff, "Males");
		is_done, count = lsEditBox('males', 80, y, 0, 50, 0, 1.0, 1.0, 0x000000ff, maxM)
		maxM = tonumber(count);
		y = y + 30;
		
		lsPrint(10, y, 10, 0.7, 0.7, 0xFFFFFFff, "Females");
		is_done, count = lsEditBox('females', 80, y, 0, 50, 0, 1.0, 1.0, 0x000000ff, maxF)
		maxF = tonumber(count);
		y = y + 60;

		lsPrint(10, y, 10, 0.7, 0.7, 0xFFFFFFff, "Press CTRL over terrarium to cull.");
	
		if lsButtonText(lsScreenX - 110, lsScreenY - 30, 0, 100, 0xFFFFFFff, "End script") then
			error "Clicked End Script button";
		end

		lsDoFrame();
		lsSleep(50);
	end
end