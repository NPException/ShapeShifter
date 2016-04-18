local Menu = {}
Menu.__index = Menu

local globals = GLOBALS
local config = globals.config
local lg = love.graphics

local images = require("lib.images")
local Button = require("states.gui.button")
local Fader = require("states.fader")
local tween = require("lib.tween")

local function startGameCallback()
  local carselect = function() return globals.states.carselect end
  Fader.fadeTo( carselect, 0.2, 0.2, {255,255,255} )
end

local function howToPlayCallback()
  local howtoplay = function() return globals.states.howtoplay end
  Fader.fadeTo( howtoplay, 0.2, 0.2, {255,255,255} )
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
  
  self.dice = {
    image=images.fuzzy_dice,
    width = images.fuzzy_dice:getWidth(),
    height = images.fuzzy_dice:getHeight(),
    x=300,
    sx=300,
    y=-50,
    sy=-50,
    r=0.2,
    sr=0.2,
    offX = images.fuzzy_dice:getWidth()/2,
    offY = 0,
    swingTime = 3
    }
  
  self.diceTween = tween.new(self.dice.swingTime,self.dice,{x=self.dice.sx+20,r=-self.dice.sr},"inOutCubic")
  self.diceTween_back = tween.new(self.dice.swingTime,self.dice,{x=self.dice.sx,r=self.dice.sr},"inOutCubic")
 
  self.rdy = true
  return self
end

function Menu:draw() 
  
  lg.draw(images.background_menu,0,0,0)
  lg.draw(images.game_title,0,0,0)
  lg.draw(self.dice.image,self.dice.x,self.dice.y,self.dice.r,1,1,self.dice.offX,self.dice.offY)
  
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

function Menu:update(dt)
  
  if self.rdy then
    if self.diceTween:update(dt) then
      self.diceTween_back = tween.new(self.dice.swingTime,self.dice,{x=self.dice.sx,r=self.dice.sr},"inOutCubic")
      self.rdy = false
    end
  end
  
  if self.rdy == false then
      if self.diceTween_back:update(dt) then
         self.diceTween = tween.new(self.dice.swingTime,self.dice,{x=self.dice.sx+20,r=-self.dice.sr},"inOutCubic")
         self.rdy = true
     end
  end
  
end

return Menu