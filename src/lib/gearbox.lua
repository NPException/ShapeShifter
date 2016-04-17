local gearbox = {}

--[[
  These nodes define the paths the shift stick is able to travel
  a   c   e
  |   |   |
  n1--n2--n3
  |   |   |
  b   d   f
]]--
gearbox.nodes = {
  a =  {x=340, y=1000},
  b =  {x=330, y=1550},
  c =  {x=565, y=990},
  d =  {x=555, y=1540},
  e =  {x=775, y=995},
  f =  {x=777, y=1540},
  n1 = {x=340, y=1270},
  n2 = {x=570, y=1270},
  n3 = {x=780, y=1280}
}

gearbox.neighbours = {
  a = {"n1"},
  b = {"n1"},
  c = {"n2"},
  d = {"n2"},
  e = {"n3"},
  f = {"n3"},
  n1 = {"a","b","n2"},
  n2 = {"c","d","n1","n3"},
  n3 = {"e","f","n2"}
}

local function dot( vec1, vec2 )
  return vec1.x*vec2.x + vec1.y*vec2.y
end

function gearbox.project( x, y, n1, n2 )
  local node1 = gearbox.nodes[n1]
  local node2 = gearbox.nodes[n2]
  local vecA = {x = x-node1.x, y = y-node1.y}
  local vecB = {x = node2.x-node1.x, y = node2.y-node1.y}
  local l = math.sqrt(vecB.x*vecB.x + vecB.y*vecB.y)
  local uVecB = {x = vecB.x/l, y = vecB.y/l}
  local a1 = dot( vecA, uVecB )
  local proj = {x = uVecB.x*a1, y = uVecB.y*a1}
  return node1.x+proj.x, node1.y+proj.y
end

return gearbox