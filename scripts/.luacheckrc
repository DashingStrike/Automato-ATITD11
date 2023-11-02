max_line_length = 120
max_code_line_length = 120
max_string_line_length = 120
max_comment_line_length = 120
ignore = { "131/doit" }
std = "lua53c+automato+common"
allow_defined = true

files["*.inc"] = { ignore = {"131"}}

stds.common = {
  read_globals = {
    "allow_pause",
    "arrangeInGrid",
    "arrangeStashed",
    "askForFocus",
    "askForWindow",
    "askForWindow",
    "boundsToBox",
    "boxToRegion",
    "BLACK_BOLD_SET",
    "BLUE_BOLD_SET",
    "BLACK_SMALL_SET",
    "BLUE_SMALL_SET",
    "BOTTOM_RIGHT",
    "BOTTOM_LEFT",
    "breakupRegion",
    "BUILDERCAM",
    "ButtonText",
    "calculatePixelDiffs",
    "centerMouse",
    "chat_minimized",
    "CheckBox",
    "checkBreak",
    "checkBreak",
    "checkBreak",
    "checkStoragePixel",
    "clickAllImages",
    "clickAllPoints",
    "clickAllText",
    "click_delay",
    "clickMax",
    "clickPoint",
    "clickText",
    "clickXY",
    "closeAllWindows",
    "closeEmptyAndErrorWindows",
    "closeEmptyRegions",
    "CLOSEWHEELINTHESKYCAM",
    "compareColor",
    "compareColorEx",
    "coord2region",
    "csplit",
    "deserialize",
    "drag",
    "drawWater",
    "drawWrappedText",
    "DUELINGCAM",
    "EXACT",
    "explode",
    "EXPLORERCAM",
    "fastFindCoords",
    "fatalError",
    "ffc_compareDigits",
    "ffc_parseDigits",
    "ffc_parseOneCoord",
    "ffc_readDigits",
    "findAllImages",
    "findAllImages",
    "findAllImagesInRange",
    "findAllText",
    "findAllTextRegions",
    "findAllWindows",
    "findAndPinContainer",
    "findChatRegion",
    "findChatRegionReplacement",
    "findChatRegionSub",
    "findClockRegion",
    "findCoords",
    "findDigit",
    "findFirstTextRegion",
    "findImage",
    "findImageInWindow",
    "findInventoryRegion",
    "findNextTextRegion",
    "findOneImage",
    "findRegionWithText",
    "findText",
    "FREECAMERA",
    "GENERALCAM",
    "getAllText",
    "getCharacterSet",
    "getChatText",
    "getElapsedTime",
    "getInventoryText",
    "getMousePos",
    "getRegion",
    "getTime",
    "getWaitSpot",
    "getWindowBorders",
    "initialize",
    "initStep",
    "isHomogenous",
    "iterateImage",
    "iterateText",
    "loadNotes",
    "lookupData",
    "makeBox",
    "makePoint",
    "maxThickWindowBorderColorRange",
    "maxThinWindowBorderColorRange",
    "MB_YES",
    "MB_NO",
    "minSetWindowInvertColorRange",
    "maxSetWindowInvertColorRange",
    "minWindowBackgroundColorRange",
    "maxWindowBackgroundColorRange",
    "minThickWindowBorderColorRange",
    "minThinWindowBorderColorRange",
    "minChatWindowBackgroundColorRange",
    "maxChatWindowBackgroundColorRange",
    "minChatWindowInvertColorRange",
    "maxChatWindowInvertColorRange",
    "ocrNumber",
    "openAndPin",
    "parseColor",
    "parseRegion",
    "parseText",
    "parseWindow",
    "pinStorageMenu",
    "pixelBlockCheck",
    "pixelDiffs",
    "pixelMatch",
    "pixelMatchList",
    "pixelRGB",
    "promptNumber",
    "promptNumber",
    "promptOkay",
    "promptOkay",
    "quit_message",
    "readSetting",
    "REGEX",
    "regionToBox",
    "REGION",
    "safeBegin",
    "safeClick",
    "safeDrag",
    "serialize",
    "serializeExample",
    "serializeInternal",
    "setCameraView",
    "setCleanupCallback",
    "singleLine",
    "sleepWithBreak",
    "sleepWithStatus",
    "sleepWithStatus",
    "sleepWithStatusPause",
    "stash",
    "stashAllWindows",
    "stashWindow",
    "statusScreen",
    "statusScreen",
    "statusScreenPause",
    "stepTo",
    "stripRegion",
    "tick_delay",
    "unpinManager",
    "unpinOnExit",
    "unpinRegion",
    "unpinStorageMenu",
    "unpinWindow",
    "waitForChange",
    "waitForFunction",
    "waitForImage",
    "waitForImageInRange",
    "waitForImageInWindow",
    "waitForImageWhileUpdating",
    "waitForKeypress",
    "waitForKeyrelease",
    "waitForNoImage",
    "waitForNoText",
    "waitForPixel",
    "waitForPixelList",
    "waitForStasis",
    "waitForText",
    "waitForTextInRegion",
    "walkTo",
    "wasStashed",
    "WHEELINTHESKYCAM",
    "windowManager",
    "writeSetting",
    "WriteFishLog",
    "WriteFishStats",
  }
}
stds.automato = {
  read_globals = {
    "lsAltHeld",
    "lsAnalyzeCustom",
    "lsAnalyzePapyrus",
    "lsAnalyzeSilt",
    "lsButtonImg",
    "lsButtonText",
    "lsCheckBox",
    "lsClipboardGet",
    "lsClipboardSet",
    "lsColorComponent",
    "lsControlHeld",
    "lsDisplaySystemSprite",
    "lsDoFrame",
    "lsDropdown",
    "lsDrawCircle",
    "lsDrawLine",
    "lsDrawRect",
    "lsEditBox",
    "lsFontShadow",
    "lsGetTimer",
    "lsGetWindowSize",
    "lsHSVtoRGBA",
    "lsKeyHeld",
    "lsMessageBox",
    "lsMouseClick",
    "lsMouseIsDown",
    "lsMouseOver",
    "lsPlaySound",
    "lsPrint",
    "lsPrintln",
    "lsPrintWrapped",
    "lsPrompOkay",
    "lsRequireVersion",
    "lsRGBAtoHSV",
    "lsScreenX",
    "lsScreenY",
    "lsScriptName",
    "lsScrollAreaBegin",
    "lsScrollAreaEnd",
    "lsServerGetNextEvent",
    "lsServerListen",
    "lsServerSend",
    "lsSetCamera",
    "lsSetCaptureWindow",
    "lsShiftHeld",
    "lsShowScreengrab",
    "lsSleep",
    "lsTopmost",
    "srClickMouse",
    "srClickMouseNoMove",
    "srDownArrow",
    "srDownArrow2",
    "srDrag",
    "srFindChatRegion",
    "srFindFirstTextRegion",
    "srFindImage",
    "srFindImageInRange",
    "srFindInvRegion",
    "srFindNearestPixel",
    "srFindNextTextRegion",
    "srGetWindowBorders",
    "srGetWindowSize",
    "srImageSize",
    "srKeyDown",
    "srKeyDown2",
    "srKeyEvent",
    "srKeyEvent2",
    "srKeyUp",
    "srKeyUp2",
    "srLeftArrow",
    "srLeftArrow2",
    "srMakeImage",
    "srMouseDown",
    "srMousePos",
    "srMouseUp",
    "srParseTextRegion",
    "srReadPixel",
    "srReadPixelFromBuffer",
    "srReadScreen",
    "srRightArrow",
    "srRightArrow2",
    "srSaveImageDebug",
    "srSaveLastReadScreen",
    "srSetMousePos",
    "srSetWindowBackgroundColorRange",
    "srSetWindowBorderColorRange",
    "srSetWindowInvertColorRange",
    "srShowImageDebug",
    "srStripRegion",
    "srStripScreen",
    "srTrainTextReader",
    "srUpArrow",
    "srUpArrow2",
    "srCharEvent",
  }
}
