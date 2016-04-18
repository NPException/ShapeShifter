-- global variables
require("lib.stringfunctions")
require("loop")
local Fader = require("states.fader")

GLOBALS = { debug = false }
local globals = GLOBALS
local lg

-- main variables
local fps, mspf
local canvas


-- LOAD --
function love.load( arg )
  math.randomseed(os.time())
  lg = love.graphics
  globals.config = require("conf")
  globals.time = 0
  
  globals.scaleX = function()
    return lg.getWidth()/globals.config.width
  end
  
  globals.scaleY = function()
    return lg.getHeight()/globals.config.height
  end
  
  globals.getMousePosition = function()
    local x,y = love.mouse.getPosition()
    return x/globals.scaleX(), y/globals.scaleY()
  end
  
  canvas = lg.newCanvas( globals.config.width, globals.config.height )
  
  lg.setCanvas(canvas)
  
  lg.setDefaultFilter("linear","nearest")
  
  -- load fonts
  globals.fonts = {
    highscore = lg.newFont("assets/font/Raleway-Black.ttf", 200)
  }
  
  -- load initial game state here
  globals.states = setmetatable({}, {
    __index = function(table, key)
      print("Loading state: "..key)
      local state = require("states."..key).new()
      rawset(table, key, state)
      return state
    end
  })
  Fader.fadeTo( globals.states.menu, 0, 0.5, {255,255,255})
end


-- KEYPRESSED --
function love.keypressed( key, scancode, isrepeat )
  if (key == "kp+") then
    globals.debug = not globals.debug
  elseif (key == "1") then
    debug.debug()
  end
  
  -- do game keypressed actions here
  local state = globals.state
  if (state and state.keypressed) then
    state:keypressed( key, scancode, isrepeat )
  end
end


function love.mousepressed( x, y, button )
  local state = globals.state
  if (state and state.mousepressed) then
    state:mousepressed( x/globals.scaleX(), y/globals.scaleY(), button )
  end
end


function love.mousereleased( x, y, button )
  local state = globals.state
  if (state and state.mousereleased) then
    state:mousereleased( x/globals.scaleX(), y/globals.scaleY(), button )
  end
end


function love.mousemoved( x, y, dx, dy )
  local state = globals.state
  if (state and state.mousemoved) then
    local sx, sy = globals.scaleX(), globals.scaleY()
    state:mousemoved( x/sx, y/sy, dx/sx, dy/sy )
  end
end


-- UPDATE --
function love.update( dt )
  globals.time = globals.time + dt
  
  -- do game state update here
  local state = globals.state
  if (state and state.update) then
    state:update( dt )
  end
  
  if (globals.debug) then
    fps = love.timer.getFPS()
    mspf = math.floor(100000/fps)/100
  end
end


-- DRAW --
function love.draw()
  lg.setCanvas(canvas)
  
  lg.setColor(255,255,255)
  -- do game state draw here
  local state = globals.state
  if (state and state.draw) then
    state:draw()
  end
  
  lg.setCanvas()
  lg.setColor(255,255,255)
  lg.draw(canvas, 0, 0, 0, globals.scaleX(), globals.scaleY())

  if (globals.debug) then
    love.graphics.setColor(0,0,0,128)
    love.graphics.rectangle("fill",0,0,100,40)
    love.graphics.setColor(255,255,255)
    love.graphics.print("FPS:  "..fps, 5,5)
    love.graphics.print("ms/F: "..mspf, 5,20)
  end
end
