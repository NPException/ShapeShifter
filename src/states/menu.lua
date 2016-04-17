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

local function howToPlayCallback()
  
end

local function quitCallback()
  love.event.quit()
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

  local copyright = "Copyright 2016"
  local copyright_names = " NPException\n Spriteman\n ChaosChaot"
  
  local font = lg.getFont()
  local width = font:getWidth(copyright)
  local height = font:getHeight()
  
  if #self.buttons>0 then
    for i=1,#self.buttons do
      self.buttons[i]:draw()
    end
  end
  
  lg.setColor(255,255,255)
  
  lg.print(copyright,config.width/5,config.height-25,0,3,3, width/2, height/2)
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