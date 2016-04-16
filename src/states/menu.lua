local Menu = {}
Menu.__index = Menu

local globals = GLOBALS
local config = globals.config
local lg = love.graphics

local images = require("lib.images")
local Button = require("states.gui.button")
local Fader = require("states.fader")

local function startGameCallback()
  local playState = Menu.new() -- TODO
  Fader.fadeTo( playState, 1, 1, {255,255,255} )
end

function Menu.new()
  local self = setmetatable({}, Menu)
  self.buttons = {}
  self.buttons[1] = Button.new(300,700, images.buttons.btn_start, startGameCallback)
  return self
end

function Menu:draw() 
  
  lg.draw(images.backgrounds.background_ph,0,0,0)
  
  local font = lg.getFont()
  local width = font:getWidth("ShapeShifter")
  local height = font:getHeight()
  
  if #self.buttons>0 then
    for i=1,#self.buttons do
      self.buttons[i]:draw()
    end
  end
  
  
  lg.setColor(255,255,255)
  
  lg.print("ShapeShifter",config.width/2,100,0,5,5, width/2, height/2)
  
  lg.print("-> Start <-",200,500,0,4,4, width/2, height/2)
end

function Menu:mousereleased( x, y, button )
  print("Menu mouse released: "..x..","..y)
  if #self.buttons>0 then
    for i=1,#self.buttons do
      self.buttons[i]:mousereleased(x,y,button)
    end
  end
end

return Menu