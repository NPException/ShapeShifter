local Menu = {}
Menu.__index = Menu

local globals = GLOBALS
local config = globals.config
local lg = love.graphics

local images = require("lib.images")
local Button = require("states.gui.button")
local Fader = require("states.fader")

local function startGameCallback()
  local gameState = require("states.game").new()
  Fader.fadeTo( gameState, 0.2, 0.4, {255,255,255} )
end

function Menu.new()
  local self = setmetatable({}, Menu)
  self.buttons = {}
  self.buttons[1] = Button.new(300,700, images.button_start, images.button_start_mask, startGameCallback)
  return self
end

function Menu:draw() 
  
  lg.draw(images.background_ph,0,0,0)
  
  local title = "ShapeShifter"
  local copyright = "Copyright 2016"
  local copyright_names = " NPException\n Spriteman\n ChaosChaot"
  
  local font = lg.getFont()
  local width = font:getWidth(title)
  local height = font:getHeight()
  
  if #self.buttons>0 then
    for i=1,#self.buttons do
      self.buttons[i]:draw()
    end
  end
  
  lg.setColor(255,255,255)
  
  lg.print(title,config.width/2,100,0,5,5, width/2, height/2)
  lg.print(copyright,config.width/6,config.height-25,0,3,3, width/2, height/2)
  lg.print(copyright_names,config.width-10,config.height-125,0,3,3, width, height/2)
end

function Menu:keypressed(key, scancode, isrepeat)
  if (key == "escape") then
    love.event.quit()
  end
end

function Menu:mousereleased( x, y, button )
  if #self.buttons>0 then
    for i=1,#self.buttons do
      self.buttons[i]:mousereleased(x,y,button)
    end
  end
end

return Menu