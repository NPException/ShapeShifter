-- ---------------------
-- Image handler
-- ---------------------

-- shorten love function and error handling
local loadImage = function(imagePath)
  local status, msg = pcall(love.graphics.newImage, imagePath)
  if (status) then
    return msg
  else
    print("No image present at path '"..imagePath.."'. Using default image.")
    return love.graphics.newImage("assets/default.png")
  end
end

-- define image table
local images = {
  -- backgrounds
  background_game = "assets/gearshift/game_background.png",
  background_menu = "assets/menu/background_menu.png",
  
  -- title
  game_title = "assets/menu/game_title.png",
  fuzzy_dice = "assets/misc/fuzzy_dice_updated_update_very_transparent.png",
  howtoplay_title = "assets/menu/howtoplay_title.png",
  howtoplay_text = "assets/menu/howtoplay_text.png",
  credits = "assets/menu/credits.png",
  
  -- buttons
  button_start = "assets/menu/buttons/btn_startgame.png",
  button_start_mask = "assets/menu/buttons/btn_startgame_mask.png",
  button_quit = "assets/menu/buttons/btn_quit.png",
  button_quit_mask = "assets/menu/buttons/btn_quit_mask.png",
  button_help = "assets/menu/buttons/btn_howtoplay.png",
  button_help_mask = "assets/menu/buttons/btn_howtoplay_mask.png",
  button_choose_driver = "assets/menu/buttons/btn_chooseyourdriver.png",
  button_arrow_left = "assets/menu/buttons/btn_arrow_left.png",
  button_arrow_left_mask = "assets/menu/buttons/btn_arrow_left_mask.png",
  button_arrow_right = "assets/menu/buttons/btn_arrow_right.png",
  button_arrow_right_mask = "assets/menu/buttons/btn_arrow_right_mask.png",
  button_back = "assets/menu/buttons/btn_back.png",
  
  -- cars
  car1 = "assets/inscreen/car1.png",
  car2 = "assets/inscreen/car2.png",
  
  -- inscreen Objects
  road = "assets/inscreen/road.png",
  bollards_bg = "assets/inscreen/bollards_background.png",
  bollards_fg = "assets/inscreen/bollards_foreground.png",
  mountains = "assets/inscreen/mountains.png",
  
  -- shifter
  shift_knob = "assets/gearshift/shift_knob.png",
  shift_rod = "assets/gearshift/shift_rod.png",
  shift_symbol_bg = "assets/gearshift/symbols/symbol_background.png",
  shift_symbol_1 = "assets/gearshift/symbols/s_001.png",
  shift_symbol_2 = "assets/gearshift/symbols/s_002.png",
  shift_symbol_3 = "assets/gearshift/symbols/s_003.png",
  shift_symbol_4 = "assets/gearshift/symbols/s_004.png",
  shift_symbol_5 = "assets/gearshift/symbols/s_005.png",
  shift_symbol_6 = "assets/gearshift/symbols/s_006.png",
  shift_symbol_7 = "assets/gearshift/symbols/s_007.png",
  shift_symbol_8 = "assets/gearshift/symbols/s_008.png",
  shift_symbol_9 = "assets/gearshift/symbols/s_009.png",
  shift_symbol_10 = "assets/gearshift/symbols/s_010.png",
  shift_symbol_11 = "assets/gearshift/symbols/s_011.png",
  shift_symbol_12 = "assets/gearshift/symbols/s_012.png",
}

function images.__index(table, key)
  local path = images[key]
  if (not path) then
    error("Tried to access undeclared image: '"..key.."'")
  end
  print("Loading image: '"..key.."', path: '"..path.."'")
  local image = loadImage(path)
  rawset(table, key, image)
  return image
end

-- return
return setmetatable({}, images)
