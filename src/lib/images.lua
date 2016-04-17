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
  background_ph = "assets/background_placeholder.png",
  -- buttons
  button_start = "assets/buttons/btn_start.png",
  button_quit = "assets/buttons/btn_quit.png",
  button_help = "assets/buttons/btn_help.png",
  -- cars
  car1 = "assets/cars/car1",
  car2 = "assets/cars/car2",
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
