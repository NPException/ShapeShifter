local RaceLost = {}
RaceLost.__index = RaceLost

local lg = love.graphics
local fonts = GLOBALS.fonts

local images = require("lib.images")
local Button = require("states.gui.button")
local Fader = require("states.fader")

local function backToMenu()
  Fader.fadeTo( GLOBALS.states.menu, 0.2, 0.4, {255,255,255} )
end

function RaceLost.new(reasonImage, roundsWon)
  local self = setmetatable({}, RaceLost)
  
  self.score = lg.newText(GLOBALS.fonts.highscore, tostring(roundsWon))
  self.reasonImage = reasonImage
  self.buttons = {}
  local w,h = images.button_back:getDimensions()
  self.buttons[1] = Button.new(1080/2-w/2,1920-h*3, images.button_back, nil, backToMenu)
  
  return self
end

function RaceLost:draw()
  lg.setColor(255,255,255)
  lg.draw(images.background_menu,0,0,0)
  
  lg.draw(images.race_lost, 1080/2-images.race_lost:getWidth()/2, 200)
  lg.draw(self.reasonImage, 1080/2-self.reasonImage:getWidth()/2, 900)
  
  lg.setColor(97,86,82)
  lg.draw(self.score, 1080/2-self.score:getWidth()/2, 1170)
  

  if #self.buttons>0 then
    for i=1,#self.buttons do
      self.buttons[i]:draw()
    end
  end
end

function RaceLost:keypressed(key, scancode, isrepeat)
  if (key == "escape") then
    backToMenu()
  end
end

function RaceLost:mousereleased( x, y, button )
  if #self.buttons>0 then
    for i=1,#self.buttons do
      self.buttons[i]:mousereleased(x,y,button)
    end
  end
end

return RaceLost