CrystalManager = {}
CrystalManager.__index = CrystalManager

Interval = 5

CrystalLocations = {
   Fire = {
        {
            x= ((WindowWidth-GroundWidth)/4) + (CrystalSides/2),
            y = WindowHeight - (GroundHeight/1.5) - 50
        },
        {
            x = (CloseSideWallMargin/2) - (CrystalSides/2),
            y = WindowHeight - (JumpHeight*1.75) + WallHeight * .5 - (CrystalSides/2)
        },
        {
            x = WallWidth * 2 - (CrystalSides/2),
            y = WindowHeight - (JumpHeight * 2.6) - (CrystalSides/2)
        }
    },
    Ice = {
        {
            x = (WindowWidth - ((WindowWidth-GroundWidth)/3)) - (CrystalSides/2),
            y =WindowHeight - (GroundHeight/1.5) - 50
        },
        {
            x = WindowWidth - (CloseSideWallMargin/2) - (CrystalSides/2),
            y = WindowHeight - (JumpHeight*1.75) + WallHeight * .5 - (CrystalSides/2)
        },
        {
            x = WindowWidth - (WallWidth * 2) - (CrystalSides/2),
            y = WindowHeight - (JumpHeight * 2.6) - (CrystalSides/2)
        }
    }
}
function CrystalManager:new(config)
    local obj = setmetatable({}, self)
    obj.config = config
    obj.timer = 0
    obj.crystals = {}
    obj.sprite = love.graphics.newImage(config.sprite)
    return obj
end

function CrystalManager:update(dt)
    self.timer = self.timer + dt
    if self.timer >= Interval then
        self:spawnCrystal()
        self.timer = 0
    end

    for i, crystal in ipairs(self.crystals) do
        crystal:update(dt)
        if(crystal.collider:isDestroyed()) then
            DestroyCrystal(crystal.config.faction)
            table.remove(self.crystals, i)
        end
    end
end

function CrystalManager:spawnCrystal()
    local availableLocations = {}
    for _, location in ipairs(self.config.spawnLocations) do
        if next(GameWorld.world:queryRectangleArea(location.x, location.y, CrystalSides, CrystalSides, {"IceCrystal", "FireCrystal"})) == nil then
            table.insert(availableLocations, location)
        end
    end
    if #availableLocations == 0 then
        return
    end
    local location = availableLocations[math.random(#availableLocations)]
    local crystal = Crystal:new(location.x, location.y, self.sprite, self.config)
    table.insert(self.crystals, crystal)
end

function CrystalManager:draw()
    for _, crystal in ipairs(self.crystals) do
        crystal:draw()
    end
end
