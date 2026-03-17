dofile("common.inc");
dofile("settings.inc");

local gatherCounter = 0
local errorDuringCycle=false;

local fuelList = {"Coal", "Charcoal", "Petroleum"};
local metalList = {"Silver", "Aluminum"};
local stashList = {
  insect   = {"Insect.", "All Insect"},
  wood     = {"Limestone ("},
  medium   = {"Soda ("},
  cuttable = {"Dirt ("},
};

local items = {
  --strength
    ["Coconuts"] = {
      ["stat"] = "STR",
      ["workFn"] = function() clickText(findText("Harvest the Coconut Meat")) end
    },
    ["Wet Paper"] = {
      ["stat"] = "STR",
      ["workFn"] = function () wetPaper() end
    },

  --endurance
    ["Barrel Grinder"] = {
      ["stat"] = "END",
      ["workFn"] = function () grindMetal() end
    },
    ["Churn Butter"] = {
      ["stat"] = "END",
      ["workFn"] = function () churnButter() end
    },
    ["Dig Hole"] = {
      ["stat"] = "END",
      ["delay"] = 3000,
      ["workFn"] = function () digHole() end
    },
    ["Dirt"] = {
      ["stat"] = "END",
      ["workFn"] = function () gather("Dirt") end
    },
    ["Excavate Blocks"] = {
      ["stat"] = "END",
      ["workFn"] = function () excavateBlocks() end
    },
    ["Flax Comb"] = {
      ["stat"] = "END",
      ["workFn"] = function () combFlax() end
    },
    ["Hackling Rake"] = {
      ["stat"] = "END",
      ["workFn"] = function () hacklingRake() end
    },
    ["Limestone"] = {
      ["stat"] = "END",
      ["workFn"] = function () gather("Limestone") end
    },
    ["Oil (Flax Seed)"] = {
      ["stat"] = "END",
      ["workFn"] = function () flaxOil() end
    },
    ["Pump Aqueduct"] = {
      ["stat"] = "END",
      ["workFn"] = function() clickText(findText("Pump the Aqueduct")) end
    },
    ["Push Pyramid"] = {
      ["stat"] = "END",
      ["workFn"] = function () pyramidPush() end,
      ["x"] = nil,
      ["y"] = nil
    },
    ["Recycle Tattered Sail"] = {
      ["stat"] = "END",
      ["workFn"] = function () weave("TatteredSail") end
    },
    ["Stir Cement"] = {
      ["stat"] = "END",
      ["workFn"] = function () stirCement() end
    },
    ["Weave Canvas"] = {
      ["stat"] = "END",
      ["workFn"] = function () weave("Canvas") end
    },
    ["Weave Linen"] = {
      ["stat"] = "END",
      ["workFn"] = function () weave("Linen") end
    },
    ["Weave Papy Basket"] = {
      ["stat"] = "END",
      ["workFn"] = function () weave("Basket") end
    },
    ["Weave Silk"] = {
      ["stat"] = "END",
      ["workFn"] = function () weave("Silk") end
    },
    ["Weave Wool Cloth"] = {
      ["stat"] = "END",
      ["workFn"] = function () weave("Wool") end
    },

  --constitution
    ["Gun Powder"] = {
      ["stat"] = "CON",
      ["workFn"] = function() clickText(findText("Gunpowder")) end
    },
    ["Ink"] = {
      ["stat"] = "CON",
      ["workFn"] = function() clickText(findText("Ink")) end
    },

  --focus
    ["Barrel Tap"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Barrel Tap") end
    },
    ["Bottle Stopper"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Bottle Stopper") end
    },
    ["Clay Lamp"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Clay Lamp") end
    },
    ["Crudely Carved Handle"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Crudely Carved Handle") end
    },
    ["Flint Hatchet"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Flint Hatchet") end
    },
    ["Flint Hammer"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Flint Hammer") end
    },
    ["Flint Chisel"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Flint Chisel") end
    },
    ["Heavy Mallet"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Heavy Mallet") end
    },
    ["Large Crude Handle"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Large Crude Handle") end
    },
    ["Long Sharp Stick"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Long Sharp Stick") end
    },
    ["Personal Chit"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Personal Chit") end
    },
    ["Rawhide Strips"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Rawhide Strips") end
    },
    ["Search Rotten Wood"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Search for Bugs") end
    },
    ["Sharpened Stick"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Sharpened Stick") end
    },
    ["Slate Shovel"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Slate Shovel") end
    },
    ["Spore Paper"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () sporePaper() end
    },
    ["Tackle Block"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Tackle Block") end
    },
    ["Tap Rods"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () tapRods() end
    },
    ["Tinder"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Tinder") end
    },
    ["Wooden Cog"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Wooden Cog") end
    },
    ["Wooden Dowsing Rod"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Wooden Dowsing Rod") end
    },
    ["Wooden Peg"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Wooden Peg") end
    },
    ["Wooden Pestle"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Wooden Pestle") end
    },
	["Low Relief Carving"] = {
      ["stat"] = "FOC",
      ["workFn"] = function () findAndClickText("Low Relief Carving") end
    },
};
local selectedTasks = {};


-- This is built in to the items as a delay key
--local lagBound = {};
--lagBound["Dig Hole"] = true;
--lagBound["Survey (Uncover)"] = true;

-- Due to a window refresh bug (T9) rods can be lost when auto retrieve is enabled
-- disabling it and manually refreshing the rod window bypasses this bug.
local retrieveRods = true;
local dropdown_item_values = { -- This is filled with filterTasksForDropdowns()
  --strength
  ["strength"] = {""},
  --end
  ["endurance"] = {""},
  --con
  ["constitution"] = {""},
  --foc
  ["focus"] = {""},
};
local statNames = {"strength", "endurance", "constitution", "focus"};
local statTimer = {};
local askText = singleLine([[
   Repeatedly performs stat-dependent tasks. Can perform several tasks at once as long as they use different attributes.
   Will also eat food from a kitchen grilled veggies once food is up if a kitchen is pinned.
   Ensure that windows of tasks you are performing are pinned and press shift.
]]
);

function doit()
  filterTasksForDropdowns();
  getClickActions();
  local mousePos = askForWindow(askText);
  windowSize = srGetWindowSize();
  done = false;
    while done == false do
      doTasks();
      checkBreak();
      lsSleep(80);
    end
end

function filterTasksForDropdowns()
  local strArr = dropdown_item_values.strength;
  local endArr = dropdown_item_values.endurance;
  local conArr = dropdown_item_values.constitution;
  local focArr = dropdown_item_values.focus;
  for key, value in pairs(items) do
    items[key].id = key;
    if (value.stat == 'STR') then
      strArr[#strArr+1] = key;
    elseif (value.stat == 'END') then
      endArr[#endArr+1] = key;
    elseif (value.stat == 'CON') then
      conArr[#conArr+1] = key;
    elseif (value.stat == 'FOC') then
      focArr[#focArr+1] = key;
    end
  end
  table.sort(strArr);
  table.sort(endArr);
  table.sort(conArr);
  table.sort(focArr);
end

function doTasks()
  didTask = false;
  for i = 1, 4 do
    task_key = selectedTasks[i]
    if task_key ~= "" then
      curTask = items[task_key];
      --print(dump(curTask));
      srReadScreen();
      statImg = srFindImage("stats/" .. statNames[i] .. ".png");
      if statTimer[i] ~= nil then
          timeDiff = lsGetTimer() - statTimer[i];
      else
          timeDiff = 999999999;
      end
      local delay = curTask.delay or 1400;

      if not statImg and timeDiff > delay then
        --check for special cases, like flax.
        lsPrint(10, 10, 0, 0.7, 0.7, 0xB0B0B0ff, "Working on " .. curTask.id);

        if lsButtonText(lsScreenX - 110, lsScreenY - 30, z, 100, 0xFFFFFFff, "End script") then
          error "Clicked End Script button";
        end
        lsDoFrame();

        if autoOnion then
          eatVegetable("Onion");
        elseif autoGarlic then
          eatVegetable("Garlic");
        end

        curTask.workFn();
        statTimer[i] = lsGetTimer();
        didTask = true;
      end
    end
  end

  if didTask == false then
    lsPrint(10, 10, 0, 0.7, 0.7, 0xB0B0B0ff, "Waiting for task to be ready.");
    if autoOnion and not buffed then
      if alertNoOnions then
        lsPlaySound("siren.wav");
      end
      lsPrint(10, 30, 0, 0.7, 0.7, 0xB0B0B0ff, "Auto eat: No pinned Onions found!");
      lsSetCamera(0, 0, lsScreenX * 1.4, lsScreenY * 1.4);
      alertNoOnions = lsCheckBox(15, 60, z, 0xFFFFFFff, " Keep playing no Onion alert!!", alertNoOnions);
      lsSetCamera(0, 0, lsScreenX, lsScreenY);
    end

    if lsButtonText(lsScreenX - 110, lsScreenY - 30, z, 100, 0xFFFFFFff,
        "End script") then
        error "Clicked End Script button";
    end

      lsDoFrame();
  else
      srReadScreen();
      --closeEmptyAndErrorWindows();
      closePopUp();
      lsSleep(per_tick);
  end
end

function getClickActions()
  local scale = 1.4;
  local z = 0;
  local done = false;
  -- initializeTaskList
  tasks = {};
  for i = 1, 4 do
    tasks[i] = 1;
  end

  while not done do
    checkBreak();
    y = 10;
    lsSetCamera(0, 0, lsScreenX * 1.5, lsScreenY * 1.5);
    lsPrint(5, y, z, 1.2, 1.2, 0xFFFFFFff, "Ensure that all menus are pinned!");
    y = y + 50;
    for i = 1, #statNames do
      lsPrint(5, y, z, 1, 1, 0xFFFFFFff, statNames[i]:gsub("^%l", string.upper) .. ":");
      y = y + 24;
      tasks[i] = lsDropdown(statNames[i], 5, y, 0, 200, tasks[i], dropdown_item_values[statNames[i]]);
      y = y + 32;

      selectedTasks[i] = dropdown_item_values[statNames[i]][tasks[i]];
      if (selectedTasks[i] == "") then
        goto continue;
      end

      if statNames[i] == "endurance" then
        y = y + 15;
        autoOnion = readSetting("autoOnion",autoOnion);
        autoOnion = lsCheckBox(5, y-10, z, 0xFFFFFFff, " Automatically Eat Onions", autoOnion);
        writeSetting("autoOnion",autoOnion);
        if autoOnion then
          y = y + 20
          alertNoOnions = readSetting("alertNoOnions",alertNoOnions);
          alertNoOnions = lsCheckBox(15, y, z, 0xFFFFFFff, " Play sound if no Onions left!", alertNoOnions);
          writeSetting("alertNoOnions",alertNoOnions);

          y = y + 25;
          lsPrintWrapped(15, y, 0, lsScreenX - 20, 1.0, 1.0, 0xFFFF80ff, "Pin the 'Grilled Onion' window.");
        end
        lsPrint(5, y+15, 10, scale, scale, 0xffff40ff,
        " - - - - - - - - - - - - - - - - - - - - - - - - - - -")
        y = y + 40;
      elseif statNames[i] == "focus" then
        y = y + 15;
        autoGarlic = readSetting("autoGarlic",autoGarlic);
        autoGarlic = lsCheckBox(5, y-10, z, 0xFFFFFFff, " Automatically Eat Garlic", autoGarlic);
        writeSetting("autoGarlic",autoGarlic);
        if autoGarlic then
          y = y + 20
          alertNoGarlic = readSetting("alertNoGarlic",alertNoGarlic);
          alertNoGarlic = lsCheckBox(15, y, z, 0xFFFFFFff, " Play sound if no Garlic left!", alertNoGarlic);
          writeSetting("alertNoGarlic",alertNoGarlic);

          y = y + 25;
          lsPrintWrapped(15, y, 0, lsScreenX - 20, 1.0, 1.0, 0xFFFF80ff, "Pin the 'Grilled Garlic' window.");
        end
        lsPrint(5, y+15, 10, scale, scale, 0xffff40ff,
        " - - - - - - - - - - - - - - - - - - - - - - - - - - -")
        y = y + 40;
      end

      local task = items[selectedTasks[i]];
      if task.id == "Stir Cement" then
        y = y + 35;
        stirMaster = readSetting("stirMaster",stirMaster);
        stirMaster = lsCheckBox(5, y-30, z, 0xFFFFFFff, " Automatically fill the Clinker Vat", stirMaster);
        writeSetting("stirMaster",stirMaster);
          if stirMaster == true then
            stirFuel = readSetting("stirFuel",stirFuel);
            lsPrint(5, y, 0, 1, 1, 0xffffffff, "Fuel Type:");
            stirFuel = lsDropdown("stirFuel", 105, y, 0, 150, stirFuel, fuelList);
            writeSetting("stirFuel",stirFuel);
            y = y + 35;
          end
      end

      if task.id:match("Weave %w+") then
        y = y + 35;
        reloadLoom = readSetting("reloadLoom",reloadLoom);
        reloadLoom = lsCheckBox(5, y-30, z, 0xFFFFFFff, " Automatically reload Loom", reloadLoom);
        writeSetting("reloadLoom",reloadLoom);
	
	if reloadLoom then
		y = y + 35;
		reloadOnlyOnEmptyError = readSetting("reloadOnlyOnEmptyError",reloadOnlyOnEmptyError);
		reloadOnlyOnEmptyError = lsCheckBox(5, y-30, z, 0xFFFFFFff, " Load Loom only on empty error", reloadOnlyOnEmptyError);
		writeSetting("reloadOnlyOnEmptyError",reloadOnlyOnEmptyError);	
		if reloadOnlyOnEmptyError then
			y = y + 35;
			reloadMax = readSetting("reloadMax",reloadMax);
			reloadMax = lsCheckBox(5, y-30, z, 0xFFFFFFff, " Reload Max", reloadMax);
			writeSetting("reloadMax",reloadMax);	
		end
	end
      end

      if task.id == "Push Pyramid" then
        lsPrint(5, y+4, 0, 1, 1, 0xffffffff, "Pyramid Coords");
        lsPrint(155, y+4, 0, 1, 1, 0x00ff00ff, " X:");
        task.x = readSetting("pyramidXCoord",task.x);
        _, task.x = lsEditBox("pyramidXCoord", 185, y, z, 85, 0, scale, scale, 0x000000ff, task.x)
        task.x = tonumber(task.x)
        writeSetting("pyramidXCoord",task.x);

        lsPrint(280, y+4, 0, 1, 1, 0x00ff00ff, "Y:");
        task.y = readSetting("pyramidYCoord",task.y);
        _, task.y = lsEditBox("pyramidYCoord", 300, y, z, 85, 0, scale, scale, 0x000000ff, task.y)
        task.y = tonumber(task.y)
        writeSetting("pyramidYCoord",task.y);
        y = y + 35;
      end

      if task.id == "Tap Rods" then
        y = y + 35;
        retrieveRods = readSetting("retrieveRods",retrieveRods);
        retrieveRods = lsCheckBox(5, y-30, z, 0xFFFFFFff, " Automatically retrieve rods", retrieveRods);
        writeSetting("retrieveRods",retrieveRods);
      end

      if task.id == "Limestone" or task.id == "Dirt" then
        y = y + 35;
        stashRawMaterials = readSetting("stashRawMaterials",stashRawMaterials);
        stashRawMaterials = lsCheckBox(5, y-30, z, 0xFFFFFFff, " Automatically stash while digging (Pin WH)", stashRawMaterials);
        writeSetting("stashRawMaterials",stashRawMaterials);
      end

      if task.id == "Barrel Grinder" then
        y = y + 35;
        refilGrinder = readSetting("refilGrinder",refilGrinder);
        refilGrinder = lsCheckBox(5, y-30, z, 0xFFFFFFff, " Automatically fill the Barrel Grinder", refilGrinder);
        writeSetting("refilGrinder",refilGrinder);
        if refilGrinder == true then
          metalGrind = readSetting("metalGrind",metalGrind);
          lsPrint(5, y, 0, 1, 1, 0xffffffff, "Metal Type:");
          metalGrind = lsDropdown("metalGrind", 115, y, 0, 150, metalGrind, metalList);
          lsPrint(5, y+32, 0, 1, 1, 0xffff40ff, "Pin the 'Take... > Metal... > All Metal' window");
          writeSetting("metalGrind",metalGrind);
          y = y + 65;
        end
      end

      ::continue::
    end

    lsDoFrame();
    lsSleep(tick_delay);
    if lsButtonText(150, 55, z, 100, 0x00ff00ff, "OK") then
      done = true;
    end
  end
end

function weave(clothType)
    if clothType == "Canvas" then
        srcType = "Twine";
        srcQty = "60";
    elseif clothType == "Linen" then
        srcType = "Thread";
        srcQty = "400";  -- This can be 300 with talents
    elseif clothType == "Basket" then
        srcType = "Papyrus";
        srcQty = "200";
    elseif clothType == "Wool" then
        srcType = "Yarn";
        srcQty = "60";
    elseif clothType == "Silk" then
        srcType = "Silk";
        srcQty = "50";
    end

    -- Restring student looms
    srReadScreen();
    if studloom then
        srReadScreen();
        t = srFindImage("statclicks/restring.png");
        if t ~= nil then
            safeClick(t[0],t[1]);
            lsSleep(75);
            srReadScreen();
            closePopUp();
            lsSleep(75);
        end
    end

    -- reload the loom
    if reloadLoom and (not reloadOnlyOnEmptyError or errorDuringCycle) then
	errorDuringCycle = false;
	if not recycleSail then
		loadImage = srFindImage("statclicks/with_" .. srcType .. ".png");
		if loadImage ~= nil then
			safeClick(loadImage[0],loadImage[1]);
			local t = waitForImage("statclicks/how_much.png", 2000);
			if t ~= nil then
				if reloadMax then
					clickMax();
				else
					srCharEvent(srcQty .. "\n");
				end
			end
			closePopUp();
			lsSleep(100); -- allow loom to not be busy
		end
	end
    end

    srReadScreen();
    if clothType == "Basket" then
      weaveImage = srFindImage("statclicks/weave_papyrus.png");
    elseif clothType == "TatteredSail" then
      srReadScreen();
      recycleSail = findText("Recycle");
    else
      weaveImage = srFindImage("statclicks/weave_" .. srcType .. ".png");
    end
    if weaveImage or recycleSail ~= nil then
      if recycleSail ~= nil then
        safeClick(recycleSail[0],recycleSail[1]);
      else
        safeClick(weaveImage[0],weaveImage[1]);
      end
        lsSleep(100);
        --Close the error window if a student's loom
        srReadScreen();
        studloom = srFindImage("statclicks/student_loom.png")
          if studloom then
            lsSleep(500);
            srReadScreen();
            closePopUp();
          end

    end
end

function findAndClickText(item)
  srReadScreen();
  itemAnchor = findText(item);
  if  itemAnchor ~= nil then
    safeClick(itemAnchor[0]+5,itemAnchor[1]+3);
    lsSleep(per_tick);
    srReadScreen();
    closePopUp();
    lsSleep(per_tick);
  end
end

function digHole()
  srReadScreen();
  local digdeeper = srFindImage("statclicks/dig_deeper.png");
  if digdeeper ~= nil then
    safeClick(digdeeper[0], digdeeper[1])
    lsSleep(per_tick);
  end
end

function gather(resource)
  if resource == "Limestone" then
    srcImg = "limestone.png"
    xOffset = 0
    yOffset = 0
  elseif resource == "Dirt" then
    srcImg = "dirt.png"
    xOffset = 0
    yOffset = 10
  end

  srReadScreen();
  local material = srFindImage(srcImg);
    if material ~= nil then
      safeClick(material[0]+xOffset, material[1]+yOffset);
      lsSleep(100);
      gatherCounter = gatherCounter + 1
      if stashRawMaterials then
        sleepWithStatus(1000,"Stashing at 50 clicks.\n\nClick Count: " .. gatherCounter)
        if gatherCounter >= 50 then
          stashAll();
          gatherCounter = 0
        end
      end
    end
end

function clickMenus(menus)
  for _, menu in pairs(menus) do
    checkBreak();
    srReadScreen();
    local found = findText(menu);
    if found then
      clickText(found);
      lsSleep(200);
    else
      return false;
    end
  end
  return true;
end

function stashAll()
  local escape = "\27"
  clickMenus({"Stash."});
  for name, menus in pairs(stashList) do
    checkBreak();
    if clickMenus(menus) then
      if name ~= 'insect' then
        clickMax();
        clickMenus({"Stash."});
      end
    end
  end
  lsSleep(250);
  srKeyEvent(escape); -- Closing the stash window
end


function grindMetal()
  if metalGrind == 1 then
    metalType = "Silver"
  elseif metalGrind == 2 then
    metalType = "Aluminum"
  end

  local startGrinder = findText("Start");
  local repairGrinder = findText("Repair")

  clickText(findText("This is [a-z]+ Barrel Grinder", nil, REGEX));

  if startGrinder and repairGrinder then
    clickText(repairGrinder);
    lsSleep(per_tick);
  elseif startGrinder and not repairGrinder then
    clickText(startGrinder);
    lsSleep(per_tick);
  else
    srReadScreen();
    local wind = findText("Wind");
    if wind ~= nil then
      if refilGrinder then
        srReadScreen();
        local loadGrinder = findText("Grinder with " .. metalType);
        if loadGrinder then
          local metalWindow = findText("All Metal", nil, REGION);
            if metalType == "Silver" then
              local grindingMetal = findText("Silver", metalWindow);
              safeClick(grindingMetal[0]+150,grindingMetal[1]+5);
              metalVolume = tonumber(string.match(grindingMetal[2], "([-0-9]+)"));
            elseif metalType == "Aluminum" then
              local grindingMetal = findText("Aluminum", metalWindow);
              safeClick(grindingMetal[0]+150,grindingMetal[1]+5);
              metalVolume = tonumber(string.match(grindingMetal[2], "([-0-9]+)"));
            end
            if metalVolume < 50 then
              clickText(loadGrinder);
              waitForImage("max.png");
              srReadScreen();
              local maxButton = srFindImage("max.png");
                if(maxButton) then
                  srClickMouseNoMove(maxButton[0]+5,maxButton[1]);
                else
                  fatalError("Unable to find the Max button");
                end
                waitForNoImage("max.png");
            end
        end
      end
      clickText(wind);
      lsSleep(per_tick);
      srReadScreen();
      closePopUp();
      lsSleep(per_tick);
      srReadScreen();
    end
  end
end

function flaxOil()
  srReadScreen();
  local seperateoil = srFindImage("statclicks/seperate_oil.png");
  if seperateoil ~= nil then
    safeClick(seperateoil[0], seperateoil[1])
    lsSleep(per_tick);
    closePopUp();
  end
end

function combFlax()
    local comb = srFindImage("statclicks/comb.png", 6000);
      if comb == nil then
        return;
      end
    safeClick(comb[0], comb[1]);
    lsSleep(per_tick);
    srReadScreen();
    local fix = srFindImage("repair.png", 6000);
      if (fix) then
        repairRake("comb");
        lsSleep(75);
        srReadScreen();
        safeClick(comb[0],comb[1]);
        lsSleep(75);
      end
    srReadScreen();

    local s1 = srFindImage("rake/separate.png", 6000);
    local s23 = srFindImage("rake/process.png", 6000);
    local clean = srFindImage("rake/clean.png", 6000);
      if s1 then
        safeClick(s1[0], s1[1]);
      elseif s23 then
        safeClick(s23[0], s23[1]);
      elseif clean then
        safeClick(clean[0], clean[1]);
      else
        lsPrint(5, 0, 10, 1, 1, 0xFFFFFFFF, "Found Stats");
        lsDoFrame();
        lsSleep(2000);
      end
end

function eatVegetable(vegetable)
  srReadScreen();

  local statImg;
  if vegetable == "Onion" then
    statImg = "stats/enduranceBuff.png";
    buffed = srFindImage(statImg);
    stat = "Endurance"
  elseif vegetable == "Garlic" then
    statImg = "stats/focusBuff.png";
    buffed = srFindImage(statImg);
    stat = "Focus"
  end

    if not buffed then
      srReadScreen();
      local consume = srFindImage("consume.png")
        if consume ~= nil then
          safeClick(consume[0],consume[1]);
          waitForImage(statImg, 5000, "Waiting for " .. stat .. " Buff icon")
          -- Click the window again, to refresh, so we now see accurate count of food remaining, on pinned food menu.
          safeClick(consume[0]-5,consume[1]-10);
          lsSleep(click_delay);
        end
    end
end

function hacklingRake()
  expressionToFind = "This is [a-z]+[ Improved]* Hackling Rake";
  flaxReg = findText(expressionToFind, nil, REGION + REGEX);
  if flaxReg == nil then
      return;
  end
  flaxText = findText(expressionToFind, flaxReg, REGEX);
  clickText(flaxText);
  lsSleep(100);
  srReadScreen();
  local fix = findText("Repair");
  if (fix) then
    repairRake("hackling");
    lsSleep(75);
    srReadScreen();
    clickText(flaxText, flaxReg);
    lsSleep(75);
  end
  srReadScreen();

  s1 = findText("Separate Rotten", flaxReg);
  s23 = findText("Continue processing", flaxReg);
  clean = findText("Clean the", flaxReg);
  if s1 then
    clickText(s1);
  elseif s23 then
    clickText(s23);
  elseif clean then
    clickText(clean);
  else
    lsPrint(5, 0, 10, 1, 1, 0xFFFFFF, "Found Stats");
    lsDoFrame();
    lsSleep(2000);
  end
end

function stirCement()
  if stirFuel == 1 then
    fuelType = "Coal"
  elseif stirFuel == 2 then
    fuelType = "Charcoal"
  elseif stirFuel == 3 then
    fuelType = "Petroleum"
  end

  t = waitForText("Stir the cement", 2000);
  if t then
    safeClick(t[0]+20,t[1]);
  else
    clickText(findText("This is [a-z]+ Clinker Vat", nil, REGEX));
    lsSleep(500);
    if stirMaster then
        take = findText("Take...")
          if take then
            clickText(waitForText("Take..."));
            clickText(waitForText("Everything"));
          end
        sleepWithStatus(1750, "Adding Bauxite to the Clinker Vat")
        clickText(waitForText("Load the vat with Bauxite"));
        waitForImage("max.png", 3000);
        srCharEvent("10\n");
        waitForNoImage("max.png");
        sleepWithStatus(1750, "Adding Gypsum to the Clinker Vat")
        clickText(waitForText("Load the vat with Gypsum"));
        waitForImage("max.png", 3000);
        srCharEvent("10\n");
        waitForNoImage("max.png");
        sleepWithStatus(1750, "Adding Clinker to the Clinker Vat")
        clickText(waitForText("Load the vat with Clinker"));
        waitForImage("max.png", 3000);
        srCharEvent("800\n");
        waitForNoImage("max.png");

        lsSleep(250);
        clickText(findText("This is [a-z]+ Clinker Vat", nil, REGEX));
        fuel = findText("Fuel level")
        if not fuel then
          sleepWithStatus(1750, "Adding " .. fuelType .. " to the Clinker Vat")
          clickText(waitForText("Load the vat with " .. fuelType));
          waitForImage("max.png", 3000);
            if fuelType == "Coal" or fuelType == "Charcoal" then
              srCharEvent("800\n");
            elseif fuelType == "Petroleum" then
              srCharEvent("150\n");
            end
          waitForNoImage("max.png");
        end
        sleepWithStatus(1750, "Mixing a batch of Cement")
        clickText(waitForText("Make a batch of Cement"));
    end
  end
end

function pyramidPush()
  task = items["Push Pyramid"];

  local curCoords = findCoords();
  local t, u;
  if curCoords[0] > task.x + 2 then
    t = findText("Push this block West");
    if t ~= nil then u = t end;
  elseif curCoords[0] < task.x - 2 then
    t = findText("Push this block East");
    if t ~= nil then u = t end;
  else
    t = findText("Turn this block to face North-South");
    if t ~= nil then u = t end;
  end
  if curCoords[1] > task.y + 2 then
    t = findText("Push this block South");
    if t ~= nil then u = t end;
  elseif curCoords[1] < task.y - 2 then
    t = findText("Push this block North");
    if t ~= nil then u = t end;
  else
    t = findText("Turn this block to face East-West");
    if t ~= nil then u = t end;
  end
  if u ~= nil then
    clickText(u);
  end
end

function tapRods()
  local window = findText("This is [a-z]+ Bore Hole", nil, REGION + REGEX);
  if window == nil then
    return;
  end
  local t = findText("Tap the Bore Rod", window);
  local foundOne = false;
  if t then
    clickText(t);
    foundOne = true;
  end
  t = waitForText("Crack an outline", 300);
  if t then
    clickText(t);
    foundOne = true;
  end
  if foundOne == false and retrieveRods == true then
    t = findText("Retrieve the bore", window);
    if t then
      clickText(t);
    end
  end
end

function excavateBlocks()
  local window = findAllText("Pyramid Block");
  if window then
    for i = 1, #window do
      srClickMouseNoMove(window[i][0],window[i][1],1)
    end
    srReadScreen();
  end
  local t = findText("Dig around");
  if t then
    clickText(t);
  end
  t = waitForText("Slide a rolling rack", 300);
  if t then
    clickText(t);
    t = waitForText("Pyramid Block", 300);
    if t then
      srClickMouseNoMove(t[0],t[1],1)
    end
  end
  return;
end

function churnButter()
  local churn = findText("^Churn", nil, REGEX); -- ^ at the start of a pattern anchors it to the start of the string. This forces Churn to be the first word found on the line.
  if (churn) then    
    srClickMouseNoMove(churn[0]+10, churn[1]+2);
    lsSleep(click_delay);
  end
  srReadScreen();
  local take = findText("Take...")
  if take then
    clickText(waitForText("Take..."));
    clickText(waitForText("Everything"));
    lsSleep(75);
    srReadScreen();
  end
  local drain = findText("Drain")
  if drain then
    srClickMouseNoMove(drain[0]+10, drain[1]+2);
  end
end

function wetPaper()
  drawWater();
  srReadScreen();
  local take = findText("Take...")
  if take then
    clickText(take);
    clickText(waitForText("Everything"));
  end

  srReadScreen();
  clickText(findText("This is [a-z]+ Certificate Press", nil, REGEX));
  lsSleep(500);

  sleepWithStatus(1750, "Adding Pulp to the Certificate Press.")
  clickText(waitForText("Put Paper Pulp"));
  closePopUp();

  sleepWithStatus(1750, "Filling the Deckle with Water.")
  clickText(waitForText("Fill the Deckle"));
  closePopUp();

  sleepWithStatus(1750, "Pressing Wet Paper.")
  clickText(waitForText("Press the Plate"));
  closePopUp();
end

function sporePaper()
  srReadScreen();
  local mushroom = findText("Mushrooms")
  if mushroom then
    clickText(mushroom);
    clickText(waitForText("Inspect"));
  end

  local rw = waitForImage("spores/which.png");
	rw.x = rw[0]-155;
	rw.y = rw[1]+5;
	rw.width = 204;
	rw.height = 240;
	local parse = findAllText(nil, rw);
  local foundPaper = false
  for i = 1, #parse do
    parse[i][2] = stripCharacters(parse[i][2]);
    if foundPaper == false then
      if string.find(parse[i][2], "SporePaper") then
        foundPaper = true;
        clickText(parse[i]);
      else
        srReadScreen();
        local cancel = srFindImage("cancel.png")
          if cancel then
            safeClick(cancel[0],cancel[1])
          end
      end
    end
  end
end

function closePopUp()
  while 1 do -- Perform a loop in case there are multiple pop-ups behind each other; this will close them all before continuing.
      checkBreak();
      lsSleep(250);
      srReadScreen();
      ok = srFindImage("OK.png");
      if ok then
        srClickMouseNoMove(ok[0],ok[1]);
	errorDuringCycle=true;
      else
          break;
      end
  end
end

function repairRake(type)
  step = 1;
  lsPlaySound("error.wav");
  --Commented repair attempt is a vestige from hackling rake script. Left in if wanted in the future.
  --repairAttempt = repairAttempt + 1;
  sleepWithStatus(1000, "Attempting to Repair Rake !")
  local repair = srFindImage("repair.png")
  local material;
  local plusButtons;
  local maxButton;

  if repair then
    clickText(repair);
		lsSleep(500);

		srReadScreen();
		local loadMaterials = srFindImage("loadMaterials.png")
    clickText(loadMaterials);

    lsSleep(500);
    srReadScreen();
    plusButtons = findAllImages("plus.png");

	for i=1,#plusButtons do
		local x = plusButtons[i][0];
		local y = plusButtons[i][1];
             srClickMouseNoMove(x, y);

		if i == 1 then
		  material = "Boards";
		elseif i == 2 then
		  material = "Bricks";
		elseif i == 3 and type == "comb" then
		  material = "Thorns";
    elseif i == 3 and type == "hackling" then
		  material = "Nails";
		else
		  material = "What the heck?";
		end

    sleepWithStatus(1000,"Loading " .. material, nil, 0.7);

		srReadScreen();
		OK = srFindImage("ok.png")

		if OK then
		  sleepWithStatus(5000, "You don\'t have any \'" .. material .. "\', Aborting !\n\nClosing Build Menu and Popups ...", nil, 0.7)
		  srClickMouseNoMove(OK[0], OK[1]);
		  srReadScreen();
		  blackX = srFindImage("blackX.png");
		  srClickMouseNoMove(blackX[0], blackX[1]);
		  num_loops = nil;
		  break;

		else -- No OK button, Load Material

		  srReadScreen();
		  maxButton = srFindImage("max.png");
		  if maxButton then
		    srClickMouseNoMove(maxButton[0], maxButton[1]);
		  end

		  sleepWithStatus(1000,"Loaded " .. material, nil, 0.7);
		end -- if OK
	end -- for loop
  end -- if repair
end

function stripCharacters(s)
	local badChars = "%:%(%)%-%,%'%d%s";
	s = string.gsub(s, "[" .. badChars .. "]", "");
	return s;
end

function dump(o)
  if type(o) == 'table' then
     local s = '{ '
     for k,v in pairs(o) do
        if type(k) ~= 'number' then k = '"'..k..'"' end
        s = s .. '['..k..'] = ' .. dump(v) .. ','
     end
     return s .. '} '
  else
     return tostring(o)
  end
end
