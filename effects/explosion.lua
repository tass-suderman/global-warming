-- explosion.lua
local Explosion = {}
Explosion.__index = Explosion

local circle

local function makeCircle(r)
  local c = love.graphics.newCanvas(r * 2, r * 2)
  love.graphics.push("all")
  love.graphics.setCanvas(c)
  love.graphics.clear(0, 0, 0, 0)
  love.graphics.setBlendMode("alpha", "premultiplied")
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.circle("fill", r, r, r)
  love.graphics.setCanvas()
  love.graphics.pop()
  return c
end

function Explosion.load()
  local canvas = makeCircle(4)
  circle = love.graphics.newImage(canvas:newImageData())
end

function Explosion.new(x, y, opts)
  opts = opts or {}
  local ps = love.graphics.newParticleSystem(circle, opts.max or 200)
  ps:setParticleLifetime(0.3, 0.8)
  ps:setEmissionRate(0)
  ps:setEmitterLifetime(0.05)
  ps:setSpread(math.rad(360))
  ps:setSpeed(140, 420)
  ps:setLinearDamping(2, 5)
  ps:setSizes(1.0, 0.4, 0.1)
  ps:setSizeVariation(1)
  ps:setRotation(0, math.pi * 2)
  ps:setSpin(0, 10)
  ps:setSpinVariation(1)
  ps:setRadialAcceleration(-200, -50)
  ps:setTangentialAcceleration(-60, 60)
  ps:setPosition(x, y)

  local r, g, b = opts.r or 1, opts.g or 0.6, opts.b or 0.1
  ps:setColors(
    {r, g, b,},
    {r*.8, g*.8, b*.8,},
    {r*.4, g*.4, b*.4}
  )

  ps:emit(opts.count or 120)

  local e = setmetatable({ ps = ps }, Explosion)
  return e
end

function Explosion:update(dt)
  self.ps:update(dt)
end

function Explosion:draw()

  love.graphics.push("all")
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(self.ps)
  love.graphics.pop()
end

function Explosion:isDead()
  return self.ps:isStopped() and self.ps:getCount() == 0
end

return Explosion
