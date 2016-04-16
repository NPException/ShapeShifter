-- ---------------------
-- Image handler
-- ---------------------

-- shorten love function
loadImage = love.graphics.newImage

-- define image table
images = {
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