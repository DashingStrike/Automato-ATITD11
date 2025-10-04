dofile("common.inc");
dofile("settings.inc");

askText = "Fisherman\nPin your lure menu like in fishing.lua. Also like fishing.lua, if you have whole fish in inventory and pin your fillet menu (so that Fillet all fish is visible) and if auto-fillet is enabled, will automatically fillet fish as it goes.\n\nThis macro is still a bit experimental.\n\nFly rod selection on menu screen is for logging purposes only. Fishing will use your default fly rod."

rods = { "Simple Fly Rod", "Whisperer's Fly Rod", "Beachcomber's Fly Rod", "Spiderfang Fly Rod", "Whiptail Fly Rod", "Openheart Fly Rod", "Snakespine Fly Rod"};
commonfish = {"Abdju", "Carp", "Catfish", "Chromis", "Oxyrynchus", "Perch", "Phagrus", "Tilapia"};

flyrod = 1;
autofillet = false;
logfish = true;
loglure = false;
logfillet = false;
maxcasts = 0;
castsmade = 0;
isfishing = false;

currentlure = nil;
lures = {};
caughtFish = {};

CAUGHTFISH = 1;
FISHMENU = 2;
CASTFAIL = 4;

validlines = {"Caught ", "You didn't catch anything", "line got wrapped around", "almost caught", "found part", "you did catch"};

local waitChars = {"-", "\\", "|", "/"};
local waitFrame = 1;

OR, XOR, AND = 1, 3, 4

function trim(s)
	return string.match( s, "^()%s*$" ) and "" or string.match( s, "^%s*(.*%S)" )
end

function checkIfMain(chatText)
--	lsPrintln("function checkIfMain");
  for j = 1, #chatText do
    if string.find(chatText[j][2], "^%*%*", 0) then
      return true;
    end
  end
  return false;
end

function getChatLine(validtext)
--	lsPrintln("function getChatLine");
	local chatText = getChatText();
	while not (checkIfMain(chatText)) do
		sleepWithStatus(1000, "Please selec the main chat tab so we can determine last chat line.");
		srReadScreen();
		chatText = getChatText();
	end
	local s = chatText[#chatText][2];
	return s:match("%]%s*([%w%s%p]+)");
end

function findLures()
	srReadScreen();
	refreshAllWindows();
	lsSleep(click_delay);
	srReadScreen();
	local l = findText("Fishing Lure");
	if not l then
		errmsg = "Out of lures";
		return false;
	end
	lures = {};
	local w = getWindowBorders(l[0], l[1]);
	local p = findAllText(nil, w);
	local i = 0;
	for i = 2, #p do
		lures[#lures+1] = p[i][2];
	end
	errmsg = nil;
	return true;
end

function chooseLure()
	findLures();
	castsmade = 0;
	local l = lures[1];
	srReadScreen();
	refreshAllWindows();
	lsSleep(click_delay);
	srReadScreen();
	local p = findText(l);
	if not p then
		errmsg = "Find Lure Fail;";
		return false;
	end
	currentlure = l:match("([A-Za-z%s]+)%s*%(");
	if currentlure then
		currentlure = trim(currentlure);
	end
	clickText(p);
	p = waitForText("Select as preferred", 1000);
	if not p then
		srReadScreen();
		local p2 = findText("Deselect");
		if p2 then
			local win = getWindowBorders(p2[0], p2[1]);
			unpinWindow(win);
			lsSleep(click_delay);
			unpinWindow(win);
			return true;
		end
		errmsg = "Select Lure Fail";
		return false;
	end
	clickText(p);
	waitForNoText("Select as preferred");
	srReadScreen();
	errmsg = nil;
	return true;
end

function logLure()
	if loglure then
		local t = getTime(1);
		local r = getRegion();
		if not t then
			t = "----";
		end
		local f = io.open("fisherman_lures.txt","a");
		f:write(t .. "\t" .. r .. "\t" .. currentlure .. "\n");
		f:close();
	end
end

function logFish(db, fish)
	if logfish then
		local t = getTime(1);
		local r = getRegion();
		local loc = findCoords();
		local f = io.open("fisherman.txt","a");
		f:write(t .. "\t" .. r .. "\t" .. loc[0] .. "\t" .. loc[1] .. "\t" .. rods[flyrod] .. "\t" .. currentlure .. "\t" .. fish .. "\t" .. db .. "\n");
		f:close();
	end
end

function logFillet(meat, roe, oil, rmeat)
	if logfillet then
		if lastFish then
			local t = getTime("date");
			local d = t:match("([%a%s]+)-[%d]");
			local f = io.open("fisherman_fillet.txt","a");
			f:write(d .. "\t" .. lastFish .. "\t" .. meat .. "\t" .. roe .. "\t" .. oil .. "\t" .. rmeat .. "\n");
			f:close();
		end
	end
end

function doTimestamp()
--	lsPrintln("function doTimestamp");
	srReadScreen();
	local chatmin = srFindImage("chat/chat_min.png");
	if chatmin then
		srCharEvent("\n");
		srReadScreen();
		waitForNoImage("chat/chat_min.png");
	end
	srCharEvent("/time\n");
	lsSleep(click_delay);
	srReadScreen();
	if chatmin then
		srCharEvent("\n");
		srReadScreen();
		waitForImage("chat/chat_min.png");
	end
end

function filletFish(dofillet)
--	lsPrintln("function filletFish");
--	lsPrintln(dofillet);
	if not autofillet then
		doTimestamp();
		return;
	end
	
--	lsPrintln("bitoper: filletFish");
	if dofillet and dofillet > 0 then
--		lsPrintln("doing fillet");
		local p = nil;
		local s = nil;
		
		while not p do
			checkBreak();
			srReadScreen();
			clickAllImages("WindowEmpty.png", 5, 5, nil, nil);
			lsSleep(click_delay);
			srReadScreen();
--			refreshAllWindows();
			p = findText("Fillet all fish");
			if not p then
				p = findText("All Fish");
			end
		end
--		lsPrintln("fillet all fish found");
		clickText(p);
		
		while p do
			checkBreak();
			local win = getWindowBorders(p[0], p[1]);
			srClickMouseNoMove(win.x + 5, win.y+5);
			lsSleep(click_delay);
			srReadScreen();
--			refreshAllWindows();
			p = findText("Fillet all fish");
			if not p then
				p = findText("All Fish");
			end
		end
		
		local filletText = nil;
		while not filletText do
			checkBreak();
			lsSleep(click_delay);
			srReadScreen();
			s = getChatLine();
			if s:find("You produced") then
				filletText = s;
			end
		end
		
		local m, r, o, rm = filletText:match("(%d+) Meat, (%d+) Roe, (%d+) Fish Oil and (%d+) Rotten Meat");
		logFillet(m, r, o, rm);
	else
		doTimestamp();
	end
end

function checkCommonFish(fishtext)
--	lsPrintln("function checkCommonFish");
	local i;
	for i = 1, #commonfish do
		if fishtext:find(commonfish[i]) then
			lastFish = nil;
--			isfishing = false;
			return 1;
		end
	end
	return 0;
end

function checkCaughtFish(fishtext)
--	lsPrintln("function checkCaughtFish");
	local db, f
	
	if not fishtext:find("Caught a") and not fishtext:find("did catch a") then 
		return 0
	end
	db, f = fishtext:match("a (%d+) deben ([%a%s]+).");
	lastFish = f;
	local	newCaught = {};
	newCaught[1] = db .. "db " .. f .. " [" .. currentlure .. "]" ;
	
	if #caughtFish > 0 then
		local m = math.min(9, #caughtFish);
		local i;
		for i = 1, m do
			newCaught[i + 1] = caughtFish[i];
		end
	end
	caughtFish = newCaught;
	
	logFish(db, f);
--	isfishing = false;
	return 1;
end

function checkLostLure(fishtext)
--	lsPrintln("function checkLostLure");
--	if fishtext:find("The Fishing Lure") then
--		if fishtext:find("falls apart, it is unable to do any more work") then
--			return true
--		end
--	end
	if fishtext:find("lost your lure") then
		return true;
	end
	return false;
end

function getFishingResult()
--	lsPrintln("function getFishingResult");
	local result = 0;
	srReadScreen();
	local chatText = getChatText();
	while not (checkIfMain(chatText)) do
		checkBreak();
		sleepWithStatus(1000, "Please selec the main chat tab so we can determine last chat line.");
		srReadScreen();
		chatText = getChatText();
	end
	
	local i, j;
	for i = #chatText, 1, -1 do
		local s = chatText[i][2];
		local s2 = s:match("%]%s*([%w%s%p]+)");
--		lsPrintln(s2);
		if s2:find("You produced") or s2:find("Year") then
			return nil;
		end
		
		for j = 1, #validlines do
			if s2:find(validlines[j]) then
				return s2;
			end
		end
		
		return nil;
	end
	
	return nil;
end

function fishingTick()
--	lsPrintln("fishingTick");
	local dofillet = 0;
	
	if not isfishing then
		if currentlure then
			if maxcasts > 0 then
				if castsmade >= maxcasts then
					isfishing = false
					return;
				end
			end
			srReadScreen();
			local fishIcon = findImage("fishing/fishicon.png");
			while not fishIcon do
				sleepWithStatus(2000, "You are not in range of water...");
				srReadScreen();
				fishIcon = findImage("fishing/fishicon.png");
			end
			logLure();
			srClickMouseNoMove(fishIcon[0], fishIcon[1]);
			castsmade = castsmade + 1;
			isfishing = true
			return;
		end
	else
		local fishingResult = getFishingResult();
		if not fishingResult then
			return
		end

	--	lsPrintln(fishingResult);
		
		dofillet = dofillet + checkCommonFish(fishingResult);
		dofillet = dofillet + checkCaughtFish(fishingResult);
		if checkLostLure(fishingResult) then
			chooseLure();
		end
		
		filletFish(dofillet);
		
		isfishing = false;
	end
end

function fishingLoop()
	isfishing = false;
	errmsg = nil;
	
--	lsPrintln("function doFishing");
	if not findLures() then
		return;
	end

	chooseLure();
	
	local scale = 1.4;
  local z = 0;
	local domenu = false;
	
	while (1) do	
		checkBreak();

		local luremsg;
		if maxcasts > 0 then
			luremsg = "Current lure: " .. currentlure .. " [" .. castsmade .. "/" .. maxcasts .. " casts]";	
		else
			luremsg = "Current lure: " .. currentlure .. " [" .. castsmade .. " casts]";
		end
		
    local frame = math.floor(waitFrame/5) % #waitChars + 1;
		local waitmsg = "Waiting for fishing result  " .. waitChars[frame];
		local y = 20
		lsSetCamera(0,0,lsScreenX*scale,lsScreenY*scale);
		lsPrint(10, y, z, 1, 1, 0xffffffff, luremsg);		
		y = y + 30;
		lsPrint(10, y, z, 1, 1, 0xffffffff, waitmsg);		
		y = y + 60;
		lsPrint(10, y, z, 0.8, 0.8, 0xffffffff, "Last 10 fish caught:");		
		y = y + 20;
		local i;
		for i = 1, #caughtFish do
			lsPrint(10, y, z, 0.8, 0.81, 0xffffffff, caughtFish[i]);		
			y = y + 20;
		end
		
		if not domenu then
			if lsButtonText(10 * scale, (lsScreenY - 30) * scale, z, 100, 0xFFFFFFff, "Menu") then
		    domenu = true;
		  end
		end

    if lsButtonText((lsScreenX - 100) * scale, (lsScreenY - 30) * scale, z, 100, 0xFFFFFFff,
      "End script") then
      error "Clicked End Script button";
    end
		
		if not isfishing and (errmsg or domenu or (maxcasts > 0 and castsmade >= maxcasts)) then
			return;
		end
		
    lsDoFrame();
    lsSleep(100);
    waitFrame = waitFrame + 1;
    fishingTick();
	end
end

function doit()
	askForWindow(askText)
	srReadScreen();
	
	doTimestamp();
	
	local scale = 1.4;
  local z = 0;
  local is_done = false;
	local r = flyrod;
	local f = autofillet;
	local lf = logfish;
	local ll = loglure;
	local lfi = logfillet;
	local mc = maxcasts;
	local allowstart = true;
	
  while not is_done do
		checkBreak();

		local y = 30
		lsSetCamera(0,0,lsScreenX*scale,lsScreenY*scale);
		
		lsPrint(10, y, z, 1, 1, 0xffffffff, "Fisherman");		
		y = y + 30;
		if errmsg then
			lsPrint(10, y, z, 1, 1, 0xffa500ff, errmsg);		
		end
		y = y + 30;
		
		lsPrint(10, y, z, 1, 1, 0xffffffff, "Fly Rod: ");
    r = readSetting("flyrod",r);
    r = lsDropdown("FlyRod", 90, y, 0, 280, r, rods);
    if r ~= flyrod then
    	flyrod = r;
			writeSetting("flyrod",flyrod);
		end
		y = y + 40;

		lsPrint(10, y, z, 1, 1, 0xffffffff, "Max Casts per lure: ");
		lsPrint(270, y, z, 1, 1, 0xffffffff, "0 = no limit");
    mc = readSetting("maxcasts",mc);
    allowstart, mc = lsEditBox("MaxCasts", 190, y, z, 50, 30, scale, scale, countColor or 0x000000ff, mc);
    mc = tonumber(mc);
    if not mc then
    	countColor = 0xFF2020ff;
    	allowstart = false; 
    	lsPrint(250, y-3, z+10, 1.3, 1.3, countColor, "!");
    	lsPrint(190, y+30, z+10, 0.65, 0.65, countColor, "MUST BE A NUMBER");
    	mc = 0;
    else
    	countColor = 0x000000ff;
    	allowstart = true; 
    end
    if mc ~= maxcasts then
    	maxcasts = mc;
			writeSetting("maxcasts",maxcasts);
		end
		y = y + 60;

    f = readSetting("autofillet", f)
    f = lsCheckBox(10, y, z, 0xFFFFFFff, "Automatically Fillet Fish", f);
    if f ~= autofillet then
    	autofillet = f;
    	writeSetting("autofillet", f)
		end
		y = y + 30;
		
		lf = readSetting("logfish", lf)
    lf = lsCheckBox(10, y, z, 0xFFFFFFff, "Log Fish Caught", lf);
    if lf ~= logfish then
    	logfish = lf;
    	writeSetting("logfish", lf)
		end
		y = y + 30;

		ll = readSetting("loglure", ll)
    ll = lsCheckBox(10, y, z, 0xFFFFFFff, "Log Used Lures", ll);
    if ll ~= loglure then
    	loglure = ll;
    	writeSetting("loglure", loglure);
    end
		y = y + 30;

		lfi = readSetting("logfillet", lfi)
    lfi = lsCheckBox(10, y, z, 0xFFFFFFff, "Log Fillets", lfi);
    if lfi ~= logfillet then
    	logfillet = lfi;
    	writeSetting("logfillet", logfillet);
    end
		y = y + 30;

		if allowstart then
			if lsButtonText(100 * scale, (lsScreenY - 30) * scale, z, 100, 0xFFFFFFff,
	      "Start") then
	      errmsg = nil;
	      currentlure = nil;
	      fishingLoop();
	    end
		end
		
    if lsButtonText((lsScreenX - 100) * scale, (lsScreenY - 30) * scale, z, 100, 0xFFFFFFff,
      "End script") then
      error "Clicked End Script button";
    end

    lsDoFrame();
    lsSleep(100);
	end
end
