-- ---------------------
-- Image handler
-- ---------------------

-- shorten love function and error handling
local loadImage = function(imagePath)
  local status, msg = pcall(love.graphics.newImage, imagePath)
  if (status) then
    return msg
  else
    return love.graphics.newImage("assets/default.png")
  end
end

-- define image table
local images = {
  -- backgrounds
  background_game = "assets/gearshift/game_background.png",
  background_title = "assets/backgrounds/background_title.png",
  background_ph = "assets/background_placeholder.png",
  -- cars
  car1 = "assets/cars/car1.png",
  car2 = "assets/cars/car2.png",
  -- buttons
  btn_start = "assets/buttons/btn_start.png",
  btn_quit = "assets/buttons/btn_quit.png",
}

function images.__index(table, key)
  local path = images[key]
  print("Loading image: '"..key.."', path: '"..tostring(path).."'")
  local image = loadImage(path)
  rawset(table, key, image)
  return image
end

-- return
return setmetatable({}, images)
