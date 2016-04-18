local Menu = {}
Menu.__index = Menu

local globals = GLOBALS
local config = globals.config
local lg = love.graphics

local images = require("lib.images")
local Button = require("states.gui.button")
local Fader = require("states.fader")

local function startGameCallback()
  local carselect = function() return require("states.carselect").new() end
  Fader.fadeTo( carselect, 0.2, 0.2, {255,255,255} )
end

local function howToPlayCallback()
  local htp = require("states.howtoplay").new()
  Fader.fadeTo( htp, 0.2, 0.2, {255,255,255} )
end

local function quitCallback()
  globals.state = Fader.create( globals.state, false, 0.3, love.event.quit )
end

function Menu.new()
  local self = setmetatable({}, Menu)
  self.buttons = {}
  self.buttons[1] = Button.new(85,860, images.button_start, images.button_start_mask, startGameCallback)
  self.buttons[2] = Button.new(85,1180, images.button_help, images.button_help_mask, howToPlayCallback)
  self.buttons[3] = Button.new(435,1530, images.button_quit, images.button_quit_mask, quitCallback)
  return self
end

function Menu:draw() 
  
  lg.draw(images.background_menu,0,0,0)
  lg.draw(images.game_title,0,0,0)
  lg.draw(images.fuzzy_dice,100,-80,0)
  
  if #self.buttons>0 then
    for i=1,#self.buttons do
      self.buttons[i]:draw()
    end
  end
  
  lg.setColor(255,255,255)
  
  local w,h = images.credits:getDimensions()
  lg.draw(images.credits, 1080/2-w/2, 1920-h*2)
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