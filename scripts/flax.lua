dofile("common.inc")
dofile("settings.inc")

askText =
  singleLine(
  [[
  Plant flax and harvest either flax or seeds. --
  Make sure the plant flax window is pinned and on the RIGHT side of
  the screen. Your Automato window should also be on the RIGHT side
  of the screen. You may need to
  F12 at low resolutions or hide your chat window (if it starts
  planting and fails to move downward, it probably clicked on your
  chat window).
  Will plant a spiral grid heading North-East of current  location.
  'Plant all crops where you stand' must be ON.
  'Right click pins/unpins a menu' must be ON.
]]
)

----------------------------------------
--          Global Variables          --
----------------------------------------
xyCenter = {}
xyFlaxMenu = {}
window_h = 120;

is_plant = true;
readClock = false;
num_loops = 5;
grid_w = 4;
grid_h = 4;
grid_direction = 1;
grid_directions = { "Northeast", "Northwest", "Southeast", "Southwest" };
grid_deltas =
{
  { {1, 0, -1, 0}, {0, -1, 0, 1} },
  { {-1, 0, 1, 0}, {0, -1, 0, 1} },
  { {1, 0, -1, 0}, {0, 1, 0, -1} },
  { {-1, 0, 1, 0}, {0, 1, 0, -1} }
};
seeds_per_pass = 5;
harvestLeft = 0
harvestLeft = 0
finish_up = 0;
finish_up_message = "";

-- Don't touch. These are set according to Jimbly's black magic.
walk_px_x = 355;
walk_px_y = 315;

--Offset for window stashing placement. Harvest seeds (longest window)
-- is 367 x 127 (when guilded). +5 to avoid touching game borders.
local offset = {};
offset.x = 372;
offset.y = 132;
local bottomRightOffset = {};
bottomRightOffset.x = 367;
bottomRightOffset.y = 127;
----------------------------------------

----------------------------------------
--         walkTo() Parameters        --
----------------------------------------
rot_flax = false;

water_needed = false;
water_location = {}
water_location[0] = 0;
water_location[1] = 0;
----------------------------------------

-- Tweakable delay values
refresh_time = 75; -- Time to wait for windows to update

max_width_offset = 350;
numSeedsHarvested = 0;

CLICK_MIN_WEED = 15 * 1000
CLICK_MIN_SEED = 27 * 1000

-------------------------------------------------------------------------------
-- initGlobals()
--
-- Set up black magic values used for trying to walk a standard grid.
-------------------------------------------------------------------------------

function initGlobals()
  -- Macro written with 1720 pixel wide window
  srReadScreen()
  xyWindowSize = srGetWindowSize()

  local pixel_scale = xyWindowSize[0] / 1720
  lsPrintln("pixel_scale " .. pixel_scale)

  walk_px_y = math.floor(walk_px_y * pixel_scale)
  walk_px_x = math.floor(walk_px_x * pixel_scale)

  local walk_x_drift = 14
  local walk_y_drift = 18
  if (lsScreenX < 1280) then
    -- Have to click way off center in order to not move at high resolutions
    walk_x_drift = math.floor(walk_x_drift * pixel_scale)
    walk_y_drift = math.floor(walk_y_drift * pixel_scale)
  else
    -- Very little drift at these resolutions, clicking dead center barely moves
    walk_x_drift = 1
    walk_y_drift = 1
  end

  xyCenter[0] = xyWindowSize[0] / 2 - walk_x_drift
  xyCenter[1] = xyWindowSize[1] / 2 + walk_y_drift

  xyFlaxMenu[0] = xyCenter[0] - 43 * pixel_scale
  xyFlaxMenu[1] = xyCenter[1] + 0
end

-------------------------------------------------------------------------------
-- checkForEnd()
--
-- Similar to checkBreak, but also looks for a clean exit.
-------------------------------------------------------------------------------

local ending = false

function checkForEnd()
  if ((lsAltHeld() and lsControlHeld()) and not ending) then
    ending = true
    error "broke out with Alt+Ctrl"
  end
  if (lsShiftHeld() and lsControlHeld()) then
    if lsMessageBox("Break", "Are you sure you want to exit?", MB_YES + MB_NO) == MB_YES then
      error "broke out with Shift+Ctrl"
    end
  end
  if lsAltHeld() and lsShiftHeld() then
    -- Pause
    while lsAltHeld() or lsShiftHeld() do
      statusScreen("Please release Alt+Shift", 0x808080ff, false)
    end
    local done = false
    while not done do
      local unpaused = lsButtonText(lsScreenX - 110, lsScreenY - 60, nil, 100, 0xFFFFFFff, "Unpause")
      statusScreen("Hold Alt+Shift to resume", 0xFFFFFFff, false)
      done = (unpaused or (lsAltHeld() and lsShiftHeld()))
    end
    while lsAltHeld() or lsShiftHeld() do
      statusScreen("Please release Alt+Shift", 0x808080ff, false)
    end
  end
end

-------------------------------------------------------------------------------
-- checkWindowSize()
--
-- Set width and height of flax window based on whether they are guilded or Game Master is playing.
-------------------------------------------------------------------------------

window_check_done_once = false
function checkWindowSize()
  if not window_check_done_once then
    srReadScreen()
    window_check_done_once = true
    local pos = findText("Useable by")
      if pos then
        window_h = window_h + 15
      end
    pos = findText("Game Master")
      if pos then
        window_h = window_h + 30
      end
  end
end

-------------------------------------------------------------------------------
-- promptFlaxNumbers()
--
-- Gather user-settable parameters before beginning
-------------------------------------------------------------------------------

function promptFlaxNumbers()
  scale = 0.8

  local z = 0
  local is_done = nil
  -- Edit box and text display
  while not is_done do
    -- Make sure we don't lock up with no easy way to escape!
    checkBreak()
    local y = 10

    num_loops = readSetting("num_loops", num_loops)
    lsPrint(10, y, z, scale, scale, 0xFFFFFFff, "Passes:")

    is_done, num_loops = lsEditBox("num_loops", 105, y, z, 45, 0, scale, scale, 0x000000ff, num_loops)
    if not tonumber(num_loops) then
      is_done = nil
      lsPrint(10, y + 18, z + 10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER")
      num_loops = 1
    end

    num_loops = tonumber(num_loops)
    writeSetting("num_loops", num_loops)
    y = y + 26

    grid_w = readSetting("grid_w", grid_w)
    lsPrint(10, y, z, scale, scale, 0xFFFFFFff, "Grid size:")
    is_done, grid_w = lsEditBox("grid_w", 105, y, z, 45, 0, scale, scale, 0x000000ff, grid_w)
    if not tonumber(grid_w) then
      is_done = nil
      lsPrint(10, y + 18, z + 10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER")
      grid_w = 2
    end
    grid_w = tonumber(grid_w)
    if grid_w < 2 then
      is_done = nil
      lsPrint(10, y + 18, z + 10, 0.7, 0.7, 0xFF2020ff, "MUST BE > 1")
    end
    writeSetting("grid_w", grid_w)

    grid_h = readSetting("grid_h", grid_h)
    lsPrint(153, y+3, z, scale, scale, 0xFFFFFFff, "x")
    is_done, grid_h = lsEditBox("grid_h", 165, y, z, 45, 0, scale, scale, 0x000000ff, grid_h)
    if not tonumber(grid_h) then
      is_done = nil
      lsPrint(10, y + 18, z + 10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER")
      grid_h = 2
    end
    grid_h = tonumber(grid_h)
    if grid_h < 2 then
      is_done = nil
      lsPrint(10, y + 18, z + 10, 0.7, 0.7, 0xFF2020ff, "MUST BE > 1")
    end
    writeSetting("grid_h", grid_h)
    y = y + 26

    if not is_plant then
      lsPrint(10, y, z, scale, scale, 0xFFFFFFff, "Seeds per:")
      seeds_per_pass = readSetting("seeds_per_pass", seeds_per_pass)
      is_done, seeds_per_pass = lsEditBox("seedsper", 105, y, z, 45, 0, scale, scale, 0x000000ff, seeds_per_pass)
      seeds_per_pass = tonumber(seeds_per_pass)
      if not seeds_per_pass then
        is_done = nil
        lsPrint(10, y + 18, z + 10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER")
        seeds_per_pass = 4
      end
      seeds_per_pass = tonumber(seeds_per_pass)
      writeSetting("seeds_per_pass", seeds_per_pass)
      y = y + 26
    end

    if setWalkDelay then
      lsPrint(10, y, z, scale, scale, 0xFFFFFFff, "Walk delay:")
      walkSpeed = readSetting("walkSpeed", walkSpeed)
      is_done, walkSpeed = lsEditBox("walkSpeed", 105, y, z, 45, 0, scale, scale, 0x000000ff, walkSpeed)
      walkSpeed = tonumber(walkSpeed)
        if not walkSpeed then
          is_done = nil
          lsPrint(10, y + 18, z + 10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER")
        end
      walkSpeed = tonumber(walkSpeed)
      writeSetting("walkSpeed", walkSpeed)
      y = y + 26
    else
      walkSpeed = 550
    end

    lsPrint(10, y, z, scale, scale, 0xFFFFFFff, "Plant to the:");
    lsSetCamera(0,0,lsScreenX*1.4,lsScreenY*1.4);
    grid_direction = readSetting("grid_direction",grid_direction);

    if setWalkDelay and not is_plant then
      grid_direction = lsDropdown("grid_direction", 145, y+46, 0, 145, grid_direction, grid_directions);
    elseif setWalkDelay then
      grid_direction = lsDropdown("grid_direction", 145, y+36, 0, 145, grid_direction, grid_directions);
    elseif not is_plant then
      grid_direction = lsDropdown("grid_direction", 145, y+36, 0, 145, grid_direction, grid_directions);
    else
      grid_direction = lsDropdown("grid_direction", 145, y+26, 0, 145, grid_direction, grid_directions);
    end

    writeSetting("grid_direction",grid_direction);
    lsSetCamera(0,0,lsScreenX,lsScreenY);
    y = y + 26

    lsPrintWrapped(
      10,
      y,
      z + 10,
      lsScreenX - 20,
      0.7,
      0.7,
      0xffff40ff,
      "Macro Settings:\n-------------------------------------------"
    )

    is_plant = readSetting("is_plant", is_plant)
    is_plant = CheckBox(10, y + 28, z, 0xFFFFFFff, " Grow Flax", is_plant, 0.7, 0.7)
    writeSetting("is_plant", is_plant)

    readClock = readSetting("readClock", readClock)
    readClock = CheckBox(145, y + 28 , z, 0xFFFFFFff, " Read Coords", readClock, 0.7, 0.7)
    writeSetting("readClock", readClock)
    y = y + 17;

    clearUI = readSetting("clearUI",clearUI);
    clearUI = CheckBox(10, y + 28, z + 10, 0xFFFFFFff, " Pin grid below UI", clearUI, 0.7, 0.7);
    writeSetting("clearUI",clearUI);

    setWalkDelay = readSetting("setWalkDelay",setWalkDelay);
    setWalkDelay = CheckBox(145, y + 28, z + 10, 0xFFFFFFff, " Set walk delay", setWalkDelay, 0.7, 0.7);
    writeSetting("setWalkDelay",setWalkDelay);
    y = y + 17;

    lsPrintWrapped(
      10,
      y + 27,
      z + 10,
      lsScreenX - 20,
      0.7,
      0.7,
      0xffff40ff,
      "-------------------------------------------"
    )
    y = y + 40

    if readClock and is_plant then
      water_needed = readSetting("water_needed", water_needed)
      water_needed = CheckBox(10, y+5, z, 0xFFFFFFff, " Water Required", water_needed, 0.7, 0.7)
      writeSetting("water_needed", water_needed)
      y = y + 17;

      rot_flax = readSetting("rot_flax", rot_flax)
      rot_flax = CheckBox(10, y+5, z, 0xFFFFFFff, " Rot Flax", rot_flax, 0.7, 0.7)
      writeSetting("rot_flax", rot_flax)

      if rot_flax or water_needed then
        lsSetCamera(0,0,lsScreenX*1.2,lsScreenY*1.2);
        water_location[0] = readSetting("water_locationX", water_location[0])

        if setWalkDelay then
          lsPrint(170, y+27, z, scale, scale, 0xFFFFFFff, "Coords:")
          is_done, water_location[0] = lsEditBox("water_locationX", 230, y+27, z, 55, 0,
                                            scale, scale, 0x000000ff, water_location[0])
        else
          lsPrint(170, y+23, z, scale, scale, 0xFFFFFFff, "Coords:")
          is_done, water_location[0] = lsEditBox("water_locationX", 230, y+23, z, 55, 0,
                                            scale, scale, 0x000000ff, water_location[0])
        end

        water_location[0] = tonumber(water_location[0])
          if not water_location[0] then
            is_done = nil
            lsPrint(135, y + 28, z + 10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER")
            water_location[0] = 1
          end
        writeSetting("water_locationX", water_location[0])

        water_location[1] = readSetting("water_locationY", water_location[1])

        if setWalkDelay then
          lsPrint(170, y+27, z, scale, scale, 0xFFFFFFff, "Coords:")
          is_done, water_location[1] =
          lsEditBox("water_locationY", 290, y+27, z, 55, 0, scale, scale, 0x000000ff, water_location[1])
        else
          is_done, water_location[1] =
          lsEditBox("water_locationY", 290, y+23, z, 55, 0, scale, scale, 0x000000ff, water_location[1])
        end

        water_location[1] = tonumber(water_location[1])
          if not water_location[1] then
            is_done = nil
            lsPrint(135, y + 28, z + 10, 0.7, 0.7, 0xFF2020ff, "MUST BE A NUMBER")
            water_location[1] = 1
          end
        writeSetting("water_locationY", water_location[1])
        lsSetCamera(0,0,lsScreenX,lsScreenY);
      end
      lsPrintWrapped(
        10,
        y + 17,
        z + 10,
        lsScreenX - 20,
        0.7,
        0.7,
        0xffff40ff,
        "-------------------------------------------"
      )
      y = y + 40
    end

    if walkSpeed ~= nil then
      if lsButtonText(10, lsScreenY - 30, 0, 100, 0x00ff00ff, "Start !", 0.9, 0.9) then
          is_done = 1;
      end
    end

    if is_plant then
      -- Will plant and harvest flax
      window_w = 270
      space_to_leave = false

      lsPrintWrapped(10, y, z + 10, lsScreenX - 20, 0.7, 0.7, 0xffff40ff, 'Uncheck "Grow Flax" for SEEDS!')
      y = y + 24
      lsPrintWrapped(
        10,
        y,
        z + 10,
        lsScreenX - 20,
        0.7,
        0.7,
        0xD0D0D0ff,
        "This will plant and harvest a " ..
          grid_w ..
            "x" ..
              grid_h ..
                " grid of flax beds " ..
                      num_loops ..
                        " times, requiring " ..
                          math.floor(grid_w * grid_h * num_loops) ..
                            " seeds, doing " .. math.floor(grid_w * grid_h * num_loops) .. " flax harvests."
      )
    else
      lsPrintWrapped(10, y+10, z + 10, lsScreenX - 20, 0.7, 0.7, 0x00ff00ff, 'Check "Grow Flax" for FLAX!')
      y = y + 24

      -- Will make seeds

      -- Flax window will grow to 333 px before returning to 290.
      -- This window MUST be big enough otherwise rip out seeds will hang automato!
      -- As a result, we need to reduce space on the right to accomodate a 5x5 grid on widescreen monitors
      window_w = 370
      space_to_leave = 150

      lsPrintWrapped(
        10,
        y + 7,
        z + 10,
        lsScreenX - 20,
        0.7,
        0.7,
        0xD0D0D0ff,
        "This will plant a " ..
          grid_w ..
            "x" ..
              grid_h ..
                " grid of flax beds and harvest it " ..
                      seeds_per_pass ..
                        " times, requiring " ..
                          (grid_w * grid_h * num_loops) .. " seeds, and repeat this " .. num_loops .. " times, yielding " ..
                          (grid_w * grid_h * seeds_per_pass * num_loops) .. " seed harvests."
      )
    end

    if is_done and (not num_loops or not grid_w) then
      error "Canceled"
    end

    if lsButtonText(lsScreenX - 110, lsScreenY - 30, z, 100, 0xFF0000ff, "End script") then
      error "Clicked End Script button"
    end

    lsDoFrame()
    lsSleep(tick_delay)
  end
end

-------------------------------------------------------------------------------
-- getPlantWindowPos()
-------------------------------------------------------------------------------

function getPlantWindowPos()
  srReadScreen()
  local plantPos = srFindImage("plant.png",6000);
  if plantPos then
    plantPos[0] = plantPos[0] + 20
    plantPos[1] = plantPos[1] + 10
  else
    plantPos = lastPlantPos
    if plantPos then
      safeClick(plantPos[0], plantPos[1])
      lsSleep(refresh_time)
    end
  end
  if not plantPos then
    error "Could not find plant window"
  end
  lastPlantPos = plantPos
  return plantPos
end

-------------------------------------------------------------------------------
-- doit()
-------------------------------------------------------------------------------

function doit()
  promptFlaxNumbers()
  askForWindow(askText)
  initGlobals()
  local startPos

  if readClock then
    srReadScreen()
    startPos = findCoords()
    if not startPos then
      error("ATITD clock not found. Try unchecking Read Clock option if problem persists")
    end
    lsPrintln("Start pos:" .. startPos[0] .. ", " .. startPos[1])
  else
    rot_flax = false;
    water_needed = false;
  end

  setCameraView(CLOSEWHEELINTHESKYCAM)
  drawWater()
  startTime = lsGetTimer()

  for loop_count = 1, num_loops do
    checkBreak()
    quit = false
    numSeedsHarvested = 0
    clicks = {}
    plantAndPin(loop_count)
    dragWindows(loop_count)
    harvestAll(loop_count)
    if is_plant and (water_needed or rot_flax) then
      walk(water_location, false)
      if water_needed then
        drawWater()
        lsSleep(150)
        clickMax() -- Sometimes drawWater() misses the max button
      end
    end
    if rot_flax then
      rotFlax()
    end
    walkHome(startPos)
    drawWater()
    if finish_up == 1 or quit then
      break;
    end
  end
  lsPlaySound("Complete.wav")
  lsMessageBox("Elapsed Time:", getElapsedTime(startTime), 1)
end

-------------------------------------------------------------------------------
-- rotFlax()
--
-- Rots flax in water.  Requires you to be standing near water already.
-------------------------------------------------------------------------------

function rotFlax()
  srReadScreen();
  local flax = srFindImage("flax/flaxInv.png")
    if not flax then
      error("'Flax' was not visible in the inventory window");
    else
      safeClick(flax[0]+5, flax[1]);
      lsSleep(refresh_time)
      srReadScreen()
      local rot = srFindImage("flax/rotFlax.png")
        if rot then
          safeClick(rot[0], rot[1]);
          lsSleep(refresh_time)
          srReadScreen()
          clickMax()
        end
    end
end

-------------------------------------------------------------------------------
-- plantAndPin()
--
-- Walk around in a spiral, planting flax seeds and grabbing windows.
-------------------------------------------------------------------------------

function plantAndPin(loop_count)
  local icon_tray = srFindImage("icon_tray_opened.png");
  if icon_tray then
    safeClick(icon_tray[0] + 5, icon_tray[1] + 5);
  end

  local xyPlantFlax = getPlantWindowPos()

  -- for spiral
  local dxi = 1                      -- direction: 1=right, 2=down, 3=left, 4=up
  local dt_max_w = grid_w            -- total horizontal distance to be traveled on this stretch of remaining spiral
  local dt_max_h = grid_h            -- total vertical distance to be traveled on this stretch of remaiing spiral
  local dt = grid_w - 1              -- distance remaining to be traveled after first planting in current direction, we start to the right so we take grid_w as base
  local i;
  local dx = {};
  local dy = {};
    for i=1, 4 do
      dx[i] = grid_deltas[grid_direction][1][i];
      dy[i] = grid_deltas[grid_direction][2][i];
    end
  -- local num_at_this_length = 3   -- old var
  local x_pos = 0
  local y_pos = 0
  local success = true

  for y = 1, grid_h do
    for x = 1, grid_w do
      sleepWithStatus(
        refresh_time,
        "(" ..
          loop_count ..
            "/" .. num_loops .. ") Planting " .. x .. ", " .. y .. "\n\nElapsed Time: " .. getElapsedTime(startTime),
        nil,
        0.7
      )
      success = plantHere(xyPlantFlax, y)
      if not success then
        break
      end

      -- Move to next position
      if not ((x == grid_w) and (y == grid_h)) then
        lsPrintln("walking dx=" .. dx[dxi] .. " dy=" .. dy[dxi])
        lsSleep(40)
        x_pos = x_pos + dx[dxi]
        y_pos = y_pos + dy[dxi]
        safeClick(xyCenter[0] + walk_px_x * dx[dxi], xyCenter[1] + walk_px_y * dy[dxi], 0)
        spot = getWaitSpot(xyFlaxMenu[0], xyFlaxMenu[1])
        if not waitForChange(spot, 1500) then
          error_status = "Did not move on click."
          break
        end
        lsSleep(walkSpeed)
        waitForStasis(spot, 1000)
        -- dt = dt - 1
        -- if dt == 1 then
        --  dxi = dxi + 1
        --  num_at_this_length = num_at_this_length - 1
        --  if num_at_this_length == 0 then
        --     dt_max = dt_max - 1
        --     num_at_this_length = 2
        --   end
        --   if dxi == 5 then
        --     dxi = 1
        --   end
        --   dt = dt_max
        -- end

        dt = dt - 1
        if dt == 0 then               -- end of stretch?
          dxi = dxi + 1               -- change direction
          -- going down?
          if dxi == 2 then             -- down?
            dt_max_h = dt_max_h - 1
            dt = dt_max_h
          end
          -- going left?
          if dxi == 3 then             -- left?
            dt_max_w = dt_max_w - 1
            dt = dt_max_w
          end
          -- going up?
          if dxi == 4 then             -- up?
            dt_max_h = dt_max_h - 1
            dt = dt_max_h
          end
         -- going right?
          if dxi == 5 then             -- right?
            dxi = 1
            dt_max_w = dt_max_w - 1
            dt = dt_max_w
          end
        end

      else
        lsPrintln("skipping walking, on last leg")
      end
    end
    checkBreak()
    if not success then
      break
    end
  end

  icon_tray = srFindImage("icon_tray_closed.png");
  if icon_tray then
    safeClick(icon_tray[0] + 5, icon_tray[1] + 5);
  end

  local finalPos = {}
  finalPos[0] = x_pos
  finalPos[1] = y_pos
  return finalPos
end

-------------------------------------------------------------------------------
-- plantHere(xyPlantFlax)
--
-- Plant a single flax bed, get the window, pin it, then stash it.
-------------------------------------------------------------------------------

function plantHere(xyPlantFlax)
  -- Plant
  -- lsPrintln("planting " .. xyPlantFlax[0] .. "," .. xyPlantFlax[1])
  local bed = clickPlant(xyPlantFlax)
  if not bed then
    return false
  end

  -- Bring up menu
  -- lsPrintln("menu " .. bed[0] .. "," .. bed[1])
  if not openAndPin(bed[0], bed[1], 3500) then
    error_status = "No window came up after planting."
    return false
  end

  -- Check for window size
  checkWindowSize()

  -- Move window into corner
  stashWindow(bed[0] + 5, bed[1] + 3, BOTTOM_RIGHT, nil, offset)
  return true
end

function clickPlant(xyPlantFlax)
  local result = xyFlaxMenu
  local spot = getWaitSpot(xyFlaxMenu[0], xyFlaxMenu[1])
  safeClick(xyPlantFlax[0], xyPlantFlax[1], 0)

  local plantSuccess = waitForChange(spot, 1500)
  if not plantSuccess then
    error_status = "No flax bed was placed when planting."
    result = nil
  end
  return result
end

-------------------------------------------------------------------------------
-- dragWindows(loop_count)
--
-- Move flax windows into a grid on the screen.
-------------------------------------------------------------------------------

function dragWindows(loop_count)
  sleepWithStatus(
    refresh_time,
    "(" ..
      loop_count ..
        "/" .. num_loops .. ")  " .. "Dragging Windows into Grid" .. "\n\nElapsed Time: " .. getElapsedTime(startTime),
    nil,
    0.7
  )

  if clearUI then
    arrangeStashed(nil, true, window_w, window_h, space_to_leave, 35, 20, nil, bottomRightOffset);
  else
    arrangeStashed(nil, nil, window_w, window_h, space_to_leave, 35, 20, nil, bottomRightOffset);
  end

end

-------------------------------------------------------------------------------
-- harvestAll(loop_count)
--
-- Harvest all the flax or seeds and clean up the windows afterwards.
-------------------------------------------------------------------------------

function harvestAll(loop_count)
  local did_harvest = false
  local totalBeds = 0
  local isHarvestTime = false

  while not did_harvest do
    lsSleep(10);
    srReadScreen()

    -- Monitor for Weed This/etc
    local tops = findAllImages("flax/flaxBed.png")
    for i = 1, #tops do
      checkBreak()
      safeClick(tops[i][0], tops[i][1])
    end

    if is_plant then
      harvestLeft = #tops
      if totalBeds == 0 and #tops > 1 then
        totalBeds = #tops
      end
    else
      --harvestLeft = seeds_per_iter - numSeedsHarvested;
      harvestLeft = (seeds_per_pass * #tops) - numSeedsHarvested -- New method in case one or more plants failed and we have less flax beds than expected
    end

    sleepWithStatusHarvest(200, "(" .. loop_count .. "/" .. num_loops ..
         ") Harvests Left: " .. harvestLeft .. "\n\nElapsed Time: " .. getElapsedTime(startTime) ..
         finish_up_message, nil, 0.7, "Monitoring Windows");

    if is_plant then
      lsPrintln("Checking Weeds")
      lsPrintln("numTops: " .. #tops)

      local waters = findAllImages("flax/water.png")
      for i = #waters, 1, -1 do
        lastClick = lastClickTime(waters[i][0], waters[i][1])
        if lastClick == nil or lsGetTimer() - lastClick >= CLICK_MIN_WEED then
          safeClick(waters[i][0], waters[i][1]);
          trackClick(waters[i][0], waters[i][1])
        end
      end

      local weeds = findAllImages("flax/weedThis.png")
      for i = #weeds, 1, -1 do
        lastClick = lastClickTime(weeds[i][0], weeds[i][1])
        if lastClick == nil or lsGetTimer() - lastClick >= CLICK_MIN_WEED then
          safeClick(weeds[i][0], weeds[i][1]);
          trackClick(weeds[i][0], weeds[i][1])
        end
      end

      local harvests = findAllImages("flax/harvest.png")
      if isHarvestTime == false and #harvests == totalBeds then
        isHarvestTime = true
      end
      if isHarvestTime == true then
        for i = #harvests, 1, -1 do
          safeClick(harvests[i][0], harvests[i][1]);
          lsSleep(refresh_time);
          safeClick(harvests[i][0], harvests[i][1] - 15, 1);
          lsSleep(1500);
        end
      end
    else -- if not is_plant
      seedsList = findAllImages("flax/harvest.png")
        for i = #seedsList, 1, -1 do
          lastClick = lastClickTime(seedsList[i][0], seedsList[i][1])
          if lastClick == nil or lsGetTimer() - lastClick >= CLICK_MIN_SEED then
            clickText(seedsList[i])
            trackClick(seedsList[i][0], seedsList[i][1])
            numSeedsHarvested = numSeedsHarvested + 1
          end
        end
      end -- if not is_plant

    --if numSeedsHarvested >= seeds_per_iter and not is_plant  then
    if harvestLeft <= 0 and not is_plant then -- New method in case one or more plants failed and we have less flax beds than expected
      bedDisappeared = false
      did_harvest = true
      while did_harvest and not bedDisappeared do
        lsSleep(30);
        srReadScreen();
        -- Monitor for Weed This/etc
        local tops = findAllImages("ThisIs.png")
        for i = 1, #tops do
          checkBreak()
          safeClick(tops[i][0], tops[i][1])
        end

        if #tops <= 0 then
          bedDisappeared = true
          closeAllWindows(0, 0, xyWindowSize[0] - max_width_offset, xyWindowSize[1])
        else
          sleepWithStatus(
            1500,
            "(" .. loop_count .. "/" .. num_loops .. ") ... Waiting for flax beds to disappear",
            nil,
            0.7,
            "Stand by"
          )
        end
      end
    end

    if #tops <= 0 then
      lsPrintln("finished harvest")
      did_harvest = true
    end
    checkBreak()
  end

  -- Wait for last flax bed to disappear
  sleepWithStatus(
    1500,
    "(" .. loop_count .. "/" .. num_loops .. ") ... Waiting for flax beds to disappear",
    nil,
    0.7,
    "Stand by"
  )
  closeAllWindows(0, 0, xyWindowSize[0] - max_width_offset, xyWindowSize[1])
end

-------------------------------------------------------------------------------
-- walkHome(loop_count, finalPos)
--
-- Walk back to the origin (southwest corner) to start planting again.
-------------------------------------------------------------------------------

function walkHome(finalPos)
  if readClock then
    walkTo(finalPos)
  end
end

-------------------------------------------------------------------------------
-- walk(dest,abortOnError)
--
-- Walk to dest while checking for menus caused by clicking on objects.
-- Returns true if you have arrived at dest.
-- If walking around brings up a menu, the menu will be dismissed.
-- If abortOnError is true and walking around brings up a menu,
-- the function will return.  If abortOnError is false, the function will
-- attempt to move around a little randomly to get around whatever is in the
-- way.
-------------------------------------------------------------------------------

function walk(dest, abortOnError)
  centerMouse()
  srReadScreen()
  local coords = findCoords()
  local failures = 0
  while coords[0] ~= dest[0] or coords[1] ~= dest[1] do
    centerMouse()
    lsPrintln("Walking from (" .. coords[0] .. "," .. coords[1] .. ") to (" .. dest[0] .. "," .. dest[1] .. ")")
    walkTo(makePoint(dest[0], dest[1]))
    srReadScreen()
    coords = findCoords()
    checkForEnd()
    if checkForMenu() then
      if (coords[0] == dest[0] and coords[1] == dest[1]) then
        return true
      end
      if abortOnError then
        return false
      end
      failures = failures + 1
      if failures > 50 then
        return false
      end
      lsPrintln("Hit a menu, moving randomly")
      walkTo(makePoint(math.random(-1, 1), math.random(-1, 1)))
      srReadScreen()
    else
      failures = 0
    end
  end
  return true
end

function checkForMenu()
  srReadScreen()
  pos = srFindImage("unpinnedPin.png", 5000)
  if pos then
    safeClick(pos[0] - 5, pos[1])
    lsPrintln("checkForMenu(): Found a menu...returning true")
    return true
  end
  return false
end

-------------------------------------------------------------------------------
-- Click Tracking Functions
-------------------------------------------------------------------------------

clicks = {}
function trackClick(x, y)
  local curTime = lsGetTimer()
  -- lsPrintln("Tracking click " .. x .. ", " .. y .. " at time " .. curTime)
  if clicks[x] == nil then
    clicks[x] = {}
  end
  clicks[x][y] = curTime
end

function lastClickTime(x, y)
  if clicks[x] ~= nil then
    if clicks[x][y] ~= nil then
      lsPrintln("Click " .. x .. ", " .. y .. " found at time " .. clicks[x][y])
    end
    return clicks[x][y]
  end
  lsPrintln("Click " .. x .. ", " .. y .. " not found. ")
  return nil
end

local waitChars = {"-", "\\", "|", "/"};
local waitFrame = 1;

function sleepWithStatusHarvest(delay_time, message, color, scale, waitMessage, loop_count)
  if not waitMessage then
    waitMessage = "Waiting ";
  else
    waitMessage = waitMessage .. " ";
  end
  if not color then
    color = 0xffffffff;
  end
  if not delay_time then
    error("Incorrect number of arguments for sleepWithStatus()");
  end
  if not scale then
    scale = 0.8;
  end
  local start_time = lsGetTimer();
  while delay_time > (lsGetTimer() - start_time) do
    local frame = math.floor(waitFrame/5) % #waitChars + 1;
    time_left = delay_time - (lsGetTimer() - start_time);
    newWaitMessage = waitMessage;
    if delay_time >= 1000 then
      newWaitMessage = waitMessage .. time_left .. " ms ";
    end
    lsPrintWrapped(10, 50, 0, lsScreenX - 20, scale, scale, 0xd0d0d0ff,
                   newWaitMessage .. waitChars[frame]);

	if finish_up == 0 and tonumber(loop_count) ~= tonumber(num_loops) then
		if lsButtonText(lsScreenX - 110, lsScreenY - 60, z, 100, 0xFFFFFFff, "Finish up") then
      finish_up = 1;
      finish_up_message = "\n\nFinishing up ..."
		end
	else
		if lsButtonText(lsScreenX - 110, lsScreenY - 60, z, 100, 0xff6251ff, "Cancel Finish Up") then
      finish_up = 0;
      finish_up_message = ""
		end
	end

    statusScreen(message, color, nil, scale);
    lsSleep(tick_delay);
    waitFrame = waitFrame + 1;
  end
end
