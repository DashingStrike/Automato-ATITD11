dofile("common.inc");

----------------------------------------
--          Global Variables          --
----------------------------------------
water_count = 0;
refill_jugs = 40;
total_harvests = 0;
total_waterings = 0;
click_delay = 0; -- Overide the default of 50 in common.inc libarary.

askText = singleLine([[
Pin 'Plant Wheat' window up for easy access later. Manually plant and pin up any number of wheat beds.
You must be standing with water icon present and 50 water jugs in inventory.
After you manually plant your wheat beds and pin up each window, Press Shift to continue.
]]);
----------------------------------------

function doit()
  askForWindow(askText);
  refillWater() -- Refill jugs if we can, if not don't return any errors.
  tendWheat()
end

function refillWater()
    water_count = 0;
    refill_jugs = 40;
    statusScreen("Refilling water...");
    drawWater()
end

function harvest()
    local windowcount = clickAllImages("ThisIs.png");
    if windowcount == 0 then
      error 'Did not find any pinned windows'
    end
    sleepWithStatus(300, "Searching " .. windowcount .. " windows for Harvest");

    --Search for Harvest windows. Harvest and Water will exist at same time in window,
    srReadScreen();
    local harvests = findAllImages("flax/harvest.png");
    if #harvests > 0 then
      total_harvests = total_harvests + #harvests

      --First, click harvest buttons
      for i=#harvests, 1, -1  do
        srClickMouseNoMove(harvests[i][0]+5, harvests[i][1]+3);
        lsSleep(150);
      end
      sleepWithStatus(2000, "Harvested " .. windowcount .. " windows...");
      clickAllImages("ThisIs.png");  --Refresh windows to make the harvest windows turn blank
      sleepWithStatus(1000, "Refreshing " .. windowcount .. "/Preparing to Close windows...");
      srReadScreen();
      local emptyWindow = srFindImage("WindowEmpty.png")
      if emptyWindow then
        clickAllImages("WindowEmpty.png", 50, 20);
        lsSleep(150);
      end
	  -- Keep refreshing and harvesting until there is no bed to harvest
      harvest()
    end
end

function waterWheatBeds()
	srReadScreen();
	-- Refresh windows again
	local windowcount = clickAllImages("ThisIs.png");
	sleepWithStatus(300, "Searching " .. windowcount .. " windows for Water");

	-- Search for Water windows.
	srReadScreen();
	local water = findAllImages("wheat/waterWheat.png");
	if #water > 0 then
	  for i=1, #water do
		srClickMouseNoMove(water[i][0]+5, water[i][1]+3);
		lsSleep(click_delay);
		water_count = water_count + #water;
		total_waterings = total_waterings + #water;
		refill_jugs = refill_jugs - #water;
	  end
	end

	-- When 40+ water jugs has been consumed, Refill the jugs.
	if water_count >= 40 then
	  refillWater()
	end
end

function tendWheat()
    -- It's not important to water more than every 70 seconds, but harvesting only has a 5 second window of opportunity,
	-- so check for harvests before and after any watering and sleeping
	local loopsBetweenWaterings = 3
	-- Always water at the start
    local loopsWithoutWatering = loopsBetweenWaterings
    while 1 do
	    -- Always check for harvests at start or after a sleep
        harvest()
        
        if loopsWithoutWatering >= loopsBetweenWaterings then
		    waterWheatBeds()
            loopsWithoutWatering = 0
			-- Always check for harvests after any potentially time consuming action
            harvest()
        else
            loopsWithoutWatering = loopsWithoutWatering + 1
        end
        sleepWithStatus(3000, "----------------------------------------------\nIf you want to plant more"
          .. " wheat Press Alt+Shift to Pause\n\nOR Use Win Manager button to Pause + Arrange Grids\n"
          .. "----------------------------------------------\nWaterings SINCE Jugs Refill: " .. water_count .. "\n"
          .. "Waterings UNTIL Jugs Refill: " .. refill_jugs .. "\n----------------------------------------------\n"
          .. "Total Waterings: " .. total_waterings .. "\nTotal Harvests: " .. total_harvests, nil, 0.7);
    end
end
