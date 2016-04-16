local Menu = {}
Menu.__index = Menu

local globals = GLOBALS
local lg = love.graphics

local images = require("lib.images")

local sx, sy = globals.scaleX, globals.scaleY

function Menu.new()
  return setmetatable({}, Menu)
end

function Menu:draw() 
  
  lg.draw(images.backgrounds.background_ph,0,0,0, sx(), sy())
  
  local font = lg.getFont()
  local width = font:getWidth("ShapeShifter")
  local height = font:getHeight()
  
  
  lg.setColor(255,255,255)
  
  lg.print("ShapeShifter",150,100,0,2,2, width/2, height/2)
  
  lg.print("-> Start <-",150,500,0,2,2, width/2, height/2)
end

return Menu