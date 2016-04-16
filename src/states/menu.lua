local Menu = {}

local globals = GLOBALS
local lg = love.graphics

local images = require("lib.images")

function Menu.new()
  return Menu
end

function Menu:draw() 
  
  lg.draw(images.backgrounds.background_ph,0,0)
    
  local width = lg.getFont():getWidth("Shift It")
  local height = lg.getFont():getHeight()
  
  
  lg.setColor(255,255,255,170)
  
  lg.print("Shift It",100,100,0,2,2, width/2, height/2)
  
end

return Menu