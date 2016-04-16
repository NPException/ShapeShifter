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
    backgrounds = {
        background_title = loadImage("assets/backgrounds/background_title.png")
      },
      cars = {
        car1 = loadImage("assets/cars/car1.png"),
        car2 = loadImage("assets/cars/car2.png")
      },
      buttons = {
        btn_start = loadImage("assets/buttons/btn_start.png"),
        btn_quit = loadImage("assets/buttons/btn_quit.png")
      }
    }

-- return
return images