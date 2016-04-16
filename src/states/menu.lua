local Menu = {}
Menu.__index = Menu

local globals = GLOBALS
local config = globals.config
local lg = love.graphics

local images = require("lib.images")

function Menu.new()
  return setmetatable({}, Menu)
end

function Menu:draw() 
  
  lg.draw(images.backgrounds.background_ph,0,0,0)
  
  local font = lg.getFont()
  local width = font:getWidth("ShapeShifter")
  local height = font:getHeight()
  
  
  lg.setColor(255,255,255)
  
  lg.print("ShapeShifter",config.width/2,100,0,5,5, width/2, height/2)
  
  lg.print("-> Start <-",200,500,0,4,4, width/2, height/2)
end

return Menu