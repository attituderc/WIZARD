-- helicopter Wizard pages
local THROTTLE_PAGE = 0
local AIL_PAGE = 1
local ELE_PAGE = 2
local RUD_PAGE = 3
local FLIGHT_MODE_PAGE = 4
local THROTTLE_HOLD_PAGE = 5
local CURVES_PAGE = 6
local PARAM_SET_PAGE = 7
local CONFIRMATION_PAGE = 8

-- Navigation variables
local page = THROTTLE_PAGE
local dirty = true
local edit = false
local field = 0
local fieldsMax = 0
local comboBoxMode = 0 -- Scrap variable
local switchItems = {"SA", "SB", "SC", "SD", "SE", "SG"}
local switchItems2pos = {"SF", "SH"}

-- Model settings
local thrCH1 = 0
local ailCH1 = 0
local rudCH1 = 0
local eleCH1 = 0
local fltmodSW1 = 0
local thrhldSW1 = 0
local paramsCH1 = 0
local paramsSW1 = 0
local swparamSet = 0
local swfltMode = 0
local thrhldMode = 0
local thrhldSW1 = 0
local pitchCH1 = 0



-- Common functions
local lastBlink = 0
local function blinkChanged()
  local time = getTime() % 128
  local blink = (time - time % 64) / 64
  if blink ~= lastBlink then
    lastBlink = blink
    return true
  else
    return false
  end
end

local function fieldIncDec(event, value, max, force)
  if edit or force==true then
    if event == EVT_PLUS_BREAK or event == EVT_ROT_LEFT then
      value = (value + max)
      dirty = true
    elseif event == EVT_MINUS_BREAK or event == EVT_ROT_RIGHT then
      value = (value + max + 2)
      dirty = true
    end
    value = (value % (max+1))
  end
  return value
end

local function valueIncDec(event, value, min, max)
  if edit then
    if event == EVT_PLUS_FIRST or event == EVT_PLUS_REPT or event == EVT_ROT_RIGHT then
      if value < max then
        value = (value + 1)
        dirty = true
      end
    elseif event == EVT_MINUS_FIRST or event == EVT_MINUS_REPT or event == EVT_ROT_LEFT then
      if value > min then
        value = (value - 1)
        dirty = true
      end
    end
  end
  return value
end

local function navigate(event, fieldMax, prevPage, nextPage)
  if event == EVT_ENTER_BREAK then
    edit = not edit
    dirty = true
  elseif edit then
    if event == EVT_EXIT_BREAK then
      edit = false
      dirty = true
    elseif not dirty then
      dirty = blinkChanged()
    end
  else
    if event == EVT_PAGE_BREAK then
      page = nextPage
      field = 0
      dirty = true
    elseif event == EVT_PAGE_LONG then
      page = prevPage
      field = 0
      killEvents(event);
      dirty = true
    else
      field = fieldIncDec(event, field, fieldMax, true)
    end
  end
end

local function getFieldFlags(position)
  flags = 0
  if field == position then
    flags = INVERS
    if edit then
      flags = INVERS + BLINK
    end
  end
  return flags
end

local function channelIncDec(event, value)
  if not edit and event==EVT_MENU_BREAK then
    servoPage = value
    dirty = true
  else
    value = valueIncDec(event, value, 0, 15)
  end
  return value
end

-- Init function
local function init()
  thrCH1 = defaultChannel(2)
  ailCH1 = defaultChannel(3)
  rudCH1 = defaultChannel(0)
  eleCH1 = defaultChannel(1)
  paramsetCH1 = defaultChannel(4)
  pitchCH1 = defaultChannel(5)
end

-- Throttle Menu
local function drawThrottleMenu()
  lcd.clear()
  lcd.drawText(1, 0, "Select helicopter throttle channel", 0)
  lcd.drawFilledRectangle(0, 0, LCD_W, 8, GREY_DEFAULT+FILL_WHITE)
  --lcd.drawCombobox(0, 8, LCD_W/2, {"..."}, comboBoxMode, getFieldFlags(1))
  lcd.drawLine(LCD_W/2-1, 18, LCD_W/2-1, LCD_H-1, DOTTED, 0)
  lcd.drawPixmap(120, 8, "7HV.bmp")
  lcd.drawText(20, LCD_H-16, "Assign Throttle", 0);
  lcd.drawText(20, LCD_H-8, "Channel", 0);
  lcd.drawText(LCD_W/2-19, LCD_H-8, ">>>", 0);
  lcd.drawSource(113, LCD_H-8, MIXSRC_CH1+thrCH1, getFieldFlags(0))
  fieldsMax = 0
end

local function throttleMenu(event)
  if dirty then
    dirty = false
    drawThrottleMenu()
  end
  navigate(event, fieldsMax, page, page+1)
  thrCH1 = channelIncDec(event, thrCH1)
end

-- Aileron Menu
local function drawAilMenu()
  lcd.clear()
  lcd.drawText(1, 0, "Select helicopter Aileron channel", 0)
  lcd.drawFilledRectangle(0, 0, LCD_W, 8, GREY_DEFAULT+FILL_WHITE)
  --lcd.drawCombobox(0, 8, LCD_W/2, {"..."}, comboBoxMode, getFieldFlags(1))
  lcd.drawLine(LCD_W/2-1, 18, LCD_W/2-1, LCD_H-1, DOTTED, 0)
  lcd.drawPixmap(120, 8, "7HV.bmp")
  lcd.drawText(20, LCD_H-16, "Assign Aileron", 0);
  lcd.drawText(20, LCD_H-8, "Channel", 0);
  lcd.drawText(LCD_W/2-19, LCD_H-8, ">>>", 0);
  lcd.drawSource(113, LCD_H-8, MIXSRC_CH1+ailCH1, getFieldFlags(0))
  fieldsMax = 0
end

local function ailMenu(event)
  if dirty then
    dirty = false
    drawAilMenu()
  end
  navigate(event, fieldsMax, page-1, page+1)
  ailCH1 = channelIncDec(event, ailCH1)
end

-- Elevator Menu
local function drawEleMenu()
  lcd.clear()
  lcd.drawText(1, 0, "Select helicopter Elevator channel", 0)
  lcd.drawFilledRectangle(0, 0, LCD_W, 8, GREY_DEFAULT+FILL_WHITE)
  --lcd.drawCombobox(0, 8, LCD_W/2, {"..."}, comboBoxMode, getFieldFlags(1))
  lcd.drawLine(LCD_W/2-1, 18, LCD_W/2-1, LCD_H-1, DOTTED, 0)
  lcd.drawPixmap(120, 8, "7HV.bmp")
  lcd.drawText(20, LCD_H-16, "Assign Elevator", 0);
  lcd.drawText(20, LCD_H-8, "Channel", 0);
  lcd.drawText(LCD_W/2-19, LCD_H-8, ">>>", 0);
  lcd.drawSource(113, LCD_H-8, MIXSRC_CH1+eleCH1, getFieldFlags(0))
  fieldsMax = 0
end

local function eleMenu(event)
  if dirty then
    dirty = false
    drawEleMenu()
  end
  navigate(event, fieldsMax, page-1, page+1)
  eleCH1 = channelIncDec(event, eleCH1)
end

-- Rudder Menu
local function drawRudMenu()
  lcd.clear()
  lcd.drawText(1, 0, "Select helicopter Rudder channel", 0)
  lcd.drawFilledRectangle(0, 0, LCD_W, 8, GREY_DEFAULT+FILL_WHITE)
  --lcd.drawCombobox(0, 8, LCD_W/2, {"..."}, comboBoxMode, getFieldFlags(1))
  lcd.drawLine(LCD_W/2-1, 18, LCD_W/2-1, LCD_H-1, DOTTED, 0)
  lcd.drawPixmap(120, 8, "7HV.bmp")
  lcd.drawText(20, LCD_H-16, "Assign Rudder", 0);
  lcd.drawText(20, LCD_H-8, "Channel", 0);
  lcd.drawText(LCD_W/2-19, LCD_H-8, ">>>", 0);
  lcd.drawSource(113, LCD_H-8, MIXSRC_CH1+rudCH1, getFieldFlags(0))
  fieldsMax = 0
end

local function rudMenu(event)
  if dirty then
    dirty = false
    drawRudMenu()
  end
  navigate(event, fieldsMax, page-1, page+1)
  rudCH1 = channelIncDec(event, rudCH1)
end

-- Flight Mode Menu
local function drawFltmodMenu()
  lcd.clear()
  lcd.drawText(1, 0, "Select Flight Mode Switch", 0)
  lcd.drawFilledRectangle(0, 0, LCD_W, 8, GREY_DEFAULT+FILL_WHITE)
  lcd.drawCombobox(0, 8, LCD_W/2, switchItems, swfltMode, getFieldFlags(0))
  if swfltMode == 0 then
    -- SA
    lcd.drawPixmap(112, 8, "SA.bmp")
    fieldsMax = 0
	elseif swfltMode == 1 then
	-- SB
    lcd.drawPixmap(112, 8, "SB.bmp")
    fieldsMax = 1
	elseif swfltMode == 2 then
    -- SC
    lcd.drawPixmap(112, 8, "SC.bmp")
    fieldsMax = 2
	elseif swfltMode == 3 then
    -- SD
    lcd.drawPixmap(112, 8, "SD.bmp")
    fieldsMax = 3
    elseif swfltMode == 4 then
    -- SE
    lcd.drawPixmap(112, 8, "SE.bmp")
    fieldsMax = 4
	elseif swfltMode == 5 then
    -- SG
    lcd.drawPixmap(112, 8, "SG.bmp")
    fieldsMax = 5
   end
end

local function fltmodMenu(event)
  if dirty then
    dirty = false
    drawFltmodMenu()
  end

  navigate(event, fieldsMax, page-1, page+1)

  if field==0 then
    swfltMode = fieldIncDec(event, swfltMode, 5)
  elseif field==1 then
    ailCH1 = channelIncDec(event, ailCH1)
  elseif field==2 then
    ailCH2 = channelIncDec(event, ailCH2)
  elseif field==3 then
    ailCH2 = channelIncDec(event, ailCH2)
	end
end

-- CURVES_PAGE

--[[local function setCurves()
  xpoints = {}
  xpoints[0] = 0
  xpoints[1] = 17
  xpoints[2] = 23
  xpoints[3] = 32
  xpoints[4] = 52
  xpoints[5] = 77
  xpoints[6] = 100

  ypoints = {}
  ypoints[0] = 23
  ypoints[1] = 187
  ypoints[2] = 23
  ypoints[3] = -80
  ypoints[4] = 10
  ypoints[5] = -70
  ypoints[6] = 20
  ypoints[7] = 20
  ypoints[8] = 20

  params = {}
  params["x"] = xpoints
  params["y"] = ypoints
  params["points"] = 7
  params["smooth"] = 1
  params["type"] = 1
  val =  model.setCurve(2, params)

  params["type"] = 0

  params["points"]=9
  val2 =  model.setCurve(0, params)
  lcd.clear()
  lcd.drawNumber(48, 1, val2)
  lcd.drawNumber(48, 15, val)
  -- lcd.drawNumber(48, 30, num)
end
--]]
local function drawCurvesMenu()
  lcd.clear()
  lcd.drawText(1, 0, "Confirm Curves", 0)
  lcd.drawFilledRectangle(0, 0, LCD_W, 8, GREY_DEFAULT+FILL_WHITE)
  lcd.drawLine(LCD_W/2-1, 18, LCD_W/2-1, LCD_H-1, DOTTED, 0)
  lcd.drawPixmap(120, 8, "7HV.bmp")
  --setCurves()
  
  fieldsMax = 0
end

local function curvesMenu(event)
  if dirty then
    dirty = false
    drawCurvesMenu()
  end
  navigate(event, fieldsMax, page, page+1)
  thrCH1 = channelIncDec(event, thrCH1)
end

-- Param Set Menu
local function drawParamMenu()
  lcd.clear()
  lcd.drawText(1, 0, "Select Bank Switch", 0)
  lcd.drawFilledRectangle(0, 0, LCD_W, 8, GREY_DEFAULT+FILL_WHITE)
  lcd.drawCombobox(0, 8, LCD_W/2, switchItems, paramsSW1, getFieldFlags(0))
  if paramsSW1 == 0 then
    -- SA
    lcd.drawPixmap(112, 8, "SA.bmp")
    fieldsMax = 0
	elseif paramsSW1 == 1 then
	-- SB
    lcd.drawPixmap(112, 8, "SB.bmp")
    fieldsMax = 1
	elseif paramsSW1 == 2 then
    -- SC
    lcd.drawPixmap(112, 8, "SC.bmp")
    fieldsMax = 2
	elseif paramsSW1 == 3 then
    -- SD
    lcd.drawPixmap(112, 8, "SD.bmp")
    fieldsMax = 3
    elseif paramsSW1 == 4 then
    -- SE
    lcd.drawPixmap(112, 8, "SE.bmp")
    fieldsMax = 4
	elseif paramsSW1 == 5 then
    -- SG
    lcd.drawPixmap(112, 8, "SG.bmp")
    fieldsMax = 5
	end
end


local function paramMenu(event)
  if dirty then
    dirty = false
    drawParamMenu()
  end
  navigate(event, fieldsMax, page-1, page+1)
  paramsetCH1 = channelIncDec(event, paramsetCH1)
end

-- Throttle HOLD Menu
local function drawThrhldMenu()
  lcd.clear()
  lcd.drawText(1, 0, "Select Throttle HOLD Switch", 0)
  lcd.drawFilledRectangle(0, 0, LCD_W, 8, GREY_DEFAULT+FILL_WHITE)
  lcd.drawCombobox(0, 8, LCD_W/2, switchItems2pos, thrhldMode, getFieldFlags(0))
  if thrhldMode == 0 then
    -- SF
    lcd.drawPixmap(112, 8, "SF.bmp")
    fieldsMax = 0
	elseif thrhldMode == 1 then
	-- SH
    lcd.drawPixmap(112, 8, "SF.bmp")
    fieldsMax = 1
	end
end

  local function thrhldMenu(event)
  if dirty then
    dirty = false
    drawThrhldMenu()
  end
  navigate(event, fieldsMax, page-1, page+1)
  thrhldMode = channelIncDec(event, thrhldMode)
end

-- Confirmation Menu
local function drawNextLine(x, y, label, channel)
  lcd.drawText(x, y, label, 0);
  lcd.drawSource(x+52, y, MIXSRC_CH1+channel, 0)
  y = y + 8
  if y > 50 then
    y = 12
    x = 120
  end
  return x, y
end

local function drawConfirmationMenu()
  local x = 22
  local y = 12
  lcd.clear()
  lcd.drawText(48, 1, "Ready to go?", 0);
  lcd.drawFilledRectangle(0, 0, LCD_W, 9, 0)
  x, y = drawNextLine(x, y, "Throttle:", thrCH1)
  x, y = drawNextLine(x, y, "Aileron:", ailCH1)
  x, y = drawNextLine(x, y, "Elevator:", eleCH1)
  x, y = drawNextLine(x, y, "Rudder:", rudCH1)
  lcd.drawText(48, LCD_H-8, "[Enter Long] to confirm", 0);
  lcd.drawFilledRectangle(0, LCD_H-9, LCD_W, 9, 0)
  lcd.drawPixmap(LCD_W-18, 0, "confirm-tick.bmp")
  lcd.drawPixmap(0, LCD_H-17, "confirm-plane.bmp")
  fieldsMax = 0
end

local function addMix(channel, input, name, weight, index)
  local mix = { source=input, name=name }
  if weight ~= nil then
    mix.weight = weight
  end
  if index == nil then
    index = 0
  end
  model.insertMix(channel, index, mix)
end

local function applySettings()
  model.defaultInputs()
  model.deleteMixes()
  addMix(thrCH1,   MIXSRC_FIRST_INPUT+defaultChannel(2), "Throttle")
  addMix(ailCH1,  MIXSRC_FIRST_INPUT+defaultChannel(3), "Aileron")
  addMix(rudCH1,   MIXSRC_FIRST_INPUT+defaultChannel(0), "Rudder")
  addMix(eleCH1, MIXSRC_FIRST_INPUT+defaultChannel(1), "Elevator")
end

local function confirmationMenu(event)
  if dirty then
    dirty = false
    drawConfirmationMenu()
  end

  navigate(event, fieldsMax, PARAM_SET_PAGE, page)

  if event == EVT_EXIT_BREAK then
    return 2
  elseif event == EVT_ENTER_LONG then
    killEvents(event)
    applySettings()
    return 2
  else
    return 0
  end
end

-- Main
local function run(event)
  if event == nil then
    error("Cannot be run as a model script!")
  end
  if page == THROTTLE_PAGE then
    throttleMenu(event)
  elseif page == AIL_PAGE then
    ailMenu(event)
  elseif page == RUD_PAGE then
    rudMenu(event)
  elseif page == ELE_PAGE then
    eleMenu(event)
  elseif page == FLIGHT_MODE_PAGE then
    fltmodMenu(event)
  elseif page == THROTTLE_HOLD_PAGE then
    thrhldMenu(event)
  elseif page == CURVES_PAGE then
    curvesMenu(event)
  elseif page == PARAM_SET_PAGE then
    paramMenu(event)
  elseif page == CONFIRMATION_PAGE then
    return confirmationMenu(event)
  end
  return 0
end

return { init=init, run=run }
