local HowToPlay = {}
HowToPlay.__index = HowToPlay

local lg = love.graphics

local images = require("lib.images")
local Button = require("states.gui.button")
local Fader = require("states.fader")

local function backToMenu()
  local menu = require("states.menu").new()
  Fader.fadeTo( menu, 0.2, 0.4, {255,255,255} )
end

function HowToPlay.new()
  local self = setmetatable({}, HowToPlay)
  self.buttons = {}
  local w,h = images.button_back:getDimensions()
  self.buttons[1] = Button.new(1080/2-w/2,1920-h*3, images.button_back, nil, backToMenu)
  
  return self
end

function HowToPlay:draw() 
  
  lg.draw(images.background_menu,0,0,0)
  lg.draw(images.howtoplay_title,0,0,0)
  
  local textX = 1080/2 - images.howtoplay_text:getWidth()/2
  lg.draw(images.howtoplay_text, textX, images.howtoplay_title:getHeight()+30)

  if #self.buttons>0 then
    for i=1,#self.buttons do
      self.buttons[i]:draw()
    end
  end
end

function HowToPlay:keypressed(key, scancode, isrepeat)
  if (key == "escape") then
    backToMenu()
  end
end

function HowToPlay:mousereleased( x, y, button )
  if #self.buttons>0 then
    for i=1,#self.buttons do
      self.buttons[i]:mousereleased(x,y,button)
    end
  end
end

return HowToPlay