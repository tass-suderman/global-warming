GWorld = {}
GWorld.__index = GWorld

Gravity = 7500
WindowWidth = 1020
WindowHeight = 768
GroundHeight = 50
GroundWidth = 800
JumpHeight = 200
WallHeight = 50
WallWidth = 200
SmallWallWidth = 75
CloseSideWallMargin = 100


local drawables =  {}

function GWorld:new()
    local wf = require "lib/windfield"
    local obj = setmetatable({}, self)

    obj.world = wf.newWorld(0, Gravity)

    AddCollisionClasses(obj.world)

    obj.leftBoundary                          = AddStaticObject(obj.world, 0, 0, 1, WindowHeight, false)
    obj.rightBoundary                         = AddStaticObject(obj.world, WindowWidth - 1, 0, 1, WindowHeight, false)
    obj.topBoundary                           = AddStaticObject(obj.world, 0, 0, WindowWidth, 1, false)
    obj.ground                                = AddStaticObject(obj.world, (WindowWidth - GroundWidth) / 2,
        WindowHeight - GroundHeight, GroundWidth, GroundHeight, false)
    obj.centreWall                            = AddStaticObject(obj.world, (WindowWidth - WallWidth * 1.5) / 2,
        WindowHeight - JumpHeight, WallWidth * 1.5, WallHeight, true)

    obj.leftMarginWall, obj.rightMarginWall   = AddMirroredWalls(obj.world, CloseSideWallMargin,
        WindowHeight - (JumpHeight * 1.75), WallWidth, WallHeight)
    obj.leftCornerWall, obj.rightCornerWall   = AddMirroredWalls(obj.world, 0, WindowHeight - (JumpHeight * 1.75) +
        WallHeight, WallWidth * .75, WallHeight)
    obj.leftHighWall, obj.rightHighWall       = AddMirroredWalls(obj.world, WallWidth * 1.75,
        WindowHeight - (JumpHeight * 2.5), WallWidth / 2, WallHeight * .75)
    obj.leftLookoutWall, obj.rightLookoutWall = AddMirroredWalls(obj.world, WallWidth * 1.5,
        WindowHeight - (JumpHeight * 3.25), WallWidth / 4, WallHeight * .75)

    obj.highCentreField                       = AddEnergyField(obj.world, WallWidth * 2.25,
        WindowHeight - (JumpHeight * 2.4), WindowWidth - WallWidth * 2.25, WindowHeight - (JumpHeight * 2.4))

    obj.centreField                           = AddEnergyField(obj.world, WindowWidth / 2, WindowHeight - GroundHeight,
        WindowWidth / 2, WindowHeight - JumpHeight + WallHeight)

    obj.leftEnergyField, obj.rightEnergyField = AddMirroredEnergyFields(obj.world, WallWidth * 1.75,
        WindowHeight - (JumpHeight * 2.5), WallWidth * 1.75, WindowHeight - (JumpHeight * 3.25))

    obj.floorKillField                        = AddKillField(obj.world, - 100, WindowHeight + 50, WindowWidth+ 200, 1)

    return obj
end

function AddKillField(world, x, y, width, height)
    local obj = world:newRectangleCollider(x, y, width, height)
    obj:setType("static")
    table.insert(drawables,{"kill", x,y, width, height})
    obj:setCollisionClass("KillField")

    return obj
end

function AddMirroredWalls(world, x, y, width, height)
    local leftWall = AddStaticObject(world, x, y, width, height, true)
    local rightWall = AddStaticObject(world, WindowWidth - x - width, y, width, height, true)
    return leftWall, rightWall
end

function AddStaticObject(world, x, y, width, height, oneWay)
    local obj = world:newRectangleCollider(x, y, width, height)
    table.insert(drawables,{"wall", x,y, width, height})
    obj:setCollisionClass('Terrain')
    obj:setType("static")
    if oneWay then
        obj:setPreSolve(function(collider_1, collider_2, contact)
            local _, py = collider_1:getPosition()
            local _, oy = collider_2:getPosition()
            if py < oy then
                contact:setEnabled(false)
            end
        end)
    end
    return obj
end

function AddMirroredEnergyFields(world, x1, y1, x2, y2)
    local leftField = AddEnergyField(world, x1, y1, x2, y2)
    local rightField = AddEnergyField(world, WindowWidth - x2, y1, WindowWidth - x1, y2)
    return leftField, rightField
end

function AddEnergyField(world, x1, y1, x2, y2)
    local obj = world:newLineCollider(x1, y1, x2, y2)
    table.insert(drawables,{"energy", x1,y1,x2, y2})
    obj:setType("static")
    obj:setCollisionClass('EnergyField')
    return obj
end

function GWorld:draw()
    for _, item in ipairs(drawables) do
        local type, x, y, x1, y1 = unpack(item)
        if type == "wall" then
            love.graphics.push("all")
            love.graphics.setColor(1,1,1)

            love.graphics.rectangle("line", x, y, x1,y1)
            love.graphics.pop()
        end
        if type == "energy" then
            love.graphics.setColor(.6,.2,1)
            love.graphics.line( x, y, x1,y1)
        end
    end
end

function AddCollisionClasses(world)
    world:addCollisionClass('FirePlayer')
    world:addCollisionClass('Terrain')
    world:addCollisionClass('IcePlayer', { ignores = { 'FirePlayer' } })
    world:addCollisionClass('FireBullet', { ignores = { 'FirePlayer'} })
    world:addCollisionClass('IceBullet', { ignores = { 'IcePlayer' } })
    world:addCollisionClass('EnergyField', { ignores = { 'FirePlayer', 'IcePlayer' } })
    world:addCollisionClass('KillField', { ignores = { 'FirePlayer', 'IcePlayer' } })
    world:addCollisionClass('IceCrystal', {ignores = {'FirePlayer', 'IcePlayer', 'IceBullet'}})
    world:addCollisionClass('FireCrystal', {ignores = {'FirePlayer', 'IcePlayer', 'FireBullet'}})
end
