local CarSelect = {}
CarSelect.__index = CarSelect

local lg = love.graphics

local images = require("lib.images")
local Button = require("states.gui.button")
local Fader = require("states.fader")

local characters = {}
CarSelect.characters = characters
for i=1,#GLOBALS.config.carsAndCharacters do
  characters[#characters+1] = {
    smallCar = images["car_small_"..i],
    largeCar = images["car_large_"..i],
    char = images["character_"..i],
    charX = GLOBALS.config.carsAndCharacters[i].charX,
    carX = GLOBALS.config.carsAndCharacters[i].carX
  }
end

local function backToMenu()
  Fader.fadeTo( GLOBALS.states.menu, 0.2, 0.4, {255,255,255} )
end

function CarSelect.new()
  local self = setmetatable({}, CarSelect)
  local this = self
  
  local callbackStart = function() this:startGame() end
  local callbackLeft = function() this:changeSelection(false) end
  local callbackRight = function() this:changeSelection(true) end
  
  self.currentSelection = 1
  self.selections = {}
  for i=1,#characters do
    local character = characters[i]
    local carX = character.carX
    local carY = 1540 - character.largeCar:getHeight()
    local charX = character.charX
    local charY = 1750 - character.char:getHeight()
    
    local carButton = Button.new(carX,carY, character.largeCar, nil, callbackStart)
    carButton:setColor({255,255,255})
    local charButton = Button.new(charX,charY, character.char, nil, callbackStart)
    charButton:setColor({255,255,255})
      
    if i~=self.currentSelection then
      carButton.x = -1500
      charButton.x = 1500
    end
    
    self.selections[i] = {carButton=carButton, charButton=charButton}
  end
  
  local by = 1800
  local chooseButtonX, chooseButtonY = images.button_choose_driver:getDimensions()
  chooseButtonX = 1080/2 - chooseButtonX/2
  chooseButtonY = by - chooseButtonY/2
  
  local leftX, leftY = images.button_arrow_left:getDimensions()
  leftX = 50
  leftY = by - leftY/2
  local rightX, rightY = images.button_arrow_right:getDimensions()
  rightX = 1080-50 - rightX
  rightY = by - rightY/2
  
  self.buttons = {
    Button.new(chooseButtonX, chooseButtonY, images.button_choose_driver, nil, callbackStart),
    Button.new(leftX, leftY, images.button_arrow_left, images.button_arrow_left_mask, callbackLeft),
    Button.new(rightX, rightY, images.button_arrow_right, images.button_arrow_right_mask, callbackRight)
  }
  
  return self
end


function CarSelect:changeSelection( goRight )
  local f = (goRight and 1 or -1)
  local nextSelection = self.currentSelection + f
  if nextSelection < 1 then
    nextSelection = #self.selections
  elseif nextSelection > #self.selections then
    nextSelection = 1
  end
  
  local time, easing = 0.7, "inOutBack"
  
  local old = self.selections[self.currentSelection]
  old.carButton:tween(time, {x=1500*f}, easing)
  old.charButton:tween(time, {x=-1500*f}, easing)
  
  local new = self.selections[nextSelection]
  new.carButton.x=-1500*f
  new.carButton:tween(time, {x=new.carButton.orgX}, easing)
  new.charButton.x=1500*f
  new.charButton:tween(time, {x=new.charButton.orgX}, easing)  
  
  self.currentSelection = nextSelection
end


function CarSelect:startGame()
  local selection = self.currentSelection
  local initGameState = function() return require("states.game").new(selection) end
  Fader.fadeTo( initGameState, 0.1, 0.5, {255,255,255} )
end


function CarSelect:update( dt )
  for i=1,#self.selections do
    local selection = self.selections[i]
    if selection.carButton:update(dt) and i~=self.currentSelection then
      selection.carButton.x = -1500
    end
    if selection.charButton:update(dt) and i~=self.currentSelection then
      selection.charButton.x = 1500
    end
  end
end


function CarSelect:draw() 
  
  lg.draw(images.background_menu,0,0,0)
  lg.draw(images.game_title,0,0,0)
  
  for i=1,#self.selections do
    local selection = self.selections[i]
    selection.carButton:draw()
    selection.charButton:draw()
  end

  if #self.buttons>0 then
    for i=1,#self.buttons do
      self.buttons[i]:draw()
    end
  end
end

function CarSelect:keypressed(key, scancode, isrepeat)
  if (key == "escape") then
    backToMenu()
  elseif (key == "right") then
    self:changeSelection(true)
  elseif (key == "left") then
    self:changeSelection(false)
  elseif (key == "return" or key == "kpenter") then
    self:startGame()
  end
end

function CarSelect:mousereleased( x, y, button )
  for i=1,#self.buttons do
    if self.buttons[i]:mousereleased(x,y,button) then
      return
    end
  end
  for i=1,#self.selections do
    local selection = self.selections[i]
    if selection.carButton:mousereleased(x,y,button)
        or selection.charButton:mousereleased(x,y,button) then
      return
    end
  end
end

return CarSelect