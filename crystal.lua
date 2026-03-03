Crystal = {}
Crystal.__index = Crystal
CrystalSides = 15
CrystalCornerRadius = 3

function Crystal:new(x, y, sprite, config)
    local obj = setmetatable({}, self)
    obj.collider = GameWorld.world:newBSGRectangleCollider(x, y, CrystalSides, CrystalSides, CrystalCornerRadius)
    obj.collider:setType("static")
    obj.collider:setCollisionClass(config.faction.."Crystal")
    obj.config = config
    obj.sprite = sprite
    return obj
end

function Crystal:update()
    if((self.config.faction == "Ice" and self.collider:enter("FireBullet")) or
         (self.config.faction == "Fire" and self.collider:enter("IceBullet"))) then
          self.config.audio.kill:clone():play()
          self.collider:destroy()
    end
end

function Crystal:draw()
    local px, py = self.collider:getPosition()
    local x = px
    local y = py
    love.graphics.push("all")
    love.graphics.setColor(1,1,1)

    love.graphics.draw(self.sprite, x, y, 0, .1, .1, self.sprite:getWidth() / 2, self.sprite:getHeight() / 2)
    love.graphics.pop()
end
