require "bullet"
Player = {
    size = {
        x = 40,
        y = 40
    }
}
Player.__index = Player

RESPAWN_INVULNERABILITY_TIME = 1

XAcceleration = 50
XMaxSpeed = 300
LeftXDeadZone = 0.3
AimXDeadZone = 0.5
LeftYDeadZone = 0.5
AimYDeadZone = 0.6
YAcceleration = 6000
SprintFactor = 2
JumpDelay = 0.01

function Player:new(config)
    local obj = setmetatable({}, self)
    obj.onGround = false
    obj.config = config
    obj.collider = GameWorld.world:newRectangleCollider(obj.config.spawn.x, obj.config.spawn.y, obj.size.x, obj.size.y)
    obj.collider:setObject(obj)
    obj.collider:setCollisionClass(config.name .. "Player")
    obj.facing = config.start_facing
    obj.bullets = {}
    obj.invulnerableTime = 0
    obj.jumpCooldown = 0
    obj.shootCooldown = 0
    obj.sprite = love.graphics.newImage(config.sprite)

    return obj
end

function Player:update(dt)
    self.jumpCooldown = self.jumpCooldown + dt
    self.shootCooldown = self.shootCooldown + dt
    self.invulnerableTime = math.max(self.invulnerableTime - dt, 0)
    self:manageGamepadInputs()
    self:manageKeyboardInputs()
    self:updateBullets(dt)
    self:handleCollision()
end

function Player:manageGamepadInputs()
    local _, py = self.collider:getLinearVelocity()
    local joysticks = love.joystick.getJoysticks()
    if #joysticks >= self.config.gamepadIndex and joysticks[self.config.gamepadIndex]:isGamepad() then
        local joystick = joysticks[self.config.gamepadIndex]
        local axisX = joystick:getGamepadAxis(self.config.joystickLeft)
        local lookX = joystick:getGamepadAxis(self.config.joystickLeft)
        local lookY = joystick:getGamepadAxis(self.config.joystickUp)
        local axisTrigger = joystick:getGamepadAxis(self.config.shootButton)
        local jumpButtonPressed = joystick:isGamepadDown(self.config.jumpButton)

        if axisX > LeftXDeadZone then
            self:tryMoveHorizontal(axisX, joystick:isGamepadDown(self.config.sprintButton))
        end
        if axisX < -1 * LeftXDeadZone then
            self:tryMoveHorizontal(axisX, joystick:isGamepadDown(self.config.sprintButton))
        end
        if math.abs(lookX) > AimXDeadZone then
            self.facing.x = lookX
        end
        if lookY < 0 then
           self.facing.y = math.ceil(lookY - AimYDeadZone)
        end
        if lookY > 0 then
            self.facing.y = math.floor(lookY + AimYDeadZone)
        end
        if jumpButtonPressed and py == 0 then
            self:tryJump(-1)
        end

        if axisTrigger > 0.5 then
            self:tryShoot()
        end
    else
        if love.keyboard.isDown(self.config.shoot) then
            self:tryShoot()
        end
    end
end

function Player:manageKeyboardInputs()
    local px, py = self.collider:getLinearVelocity()
    if love.keyboard.isDown(self.config.left) and px > -300 then
        self.facing.x = -1
        self.collider:applyLinearImpulse(-1000, 0)
    end
    if love.keyboard.isDown(self.config.right) and px < 300 then
        self.facing.x = 1
        self.collider:applyLinearImpulse(1000, 0)
    end
    if love.keyboard.isDown(self.config.up) and py == 0 then
			self:tryJump(-1)
    end
end

function Player:updateBullets(dt)
    local removableItems = {}
    if self.bullets then
        for i, bullet in ipairs(self.bullets) do
            bullet:update(dt)

            if (bullet.collider:isDestroyed()) then
                self.config.audio.miss:clone():play()
                table.insert(removableItems, i)
            end
        end
    end
    for _, i in ipairs(removableItems) do
        table.remove(self.bullets, i)
    end
    self:handleCollision()
end

function Player:tryMoveHorizontal(movementAmount, isSprinting)
    local px, _ = self.collider:getLinearVelocity()
    local maxSpeed = isSprinting and (XMaxSpeed * SprintFactor) or XMaxSpeed
    if(math.abs(px) < maxSpeed) then
        local accel = isSprinting and (XAcceleration * SprintFactor) or XAcceleration
        self.collider:applyLinearImpulse(movementAmount * accel, 0)
    end
end

function Player:tryJump(movementAmount)
    if self.onGround then
        print "on ground"
        if self.jumpCooldown > JumpDelay then
            print "jump cooldown is good "
            self.collider:applyLinearImpulse(0, movementAmount * YAcceleration)
            print "jump cooldown reset"
            self.onGround = false
            self.jumpCooldown = 0
        end
    end
end

function Player:handleCollision()
    if self.collider:enter("KillField") then
        self.collider:setType("static")
        self:respawn()
        self.collider:setType("dynamic")
    end
    if self.collider:enter("Terrain") then
        self.onGround = true
        local joystick = love.joystick.getJoysticks()[self.config.gamepadIndex]
        if joystick ~= nil and joystick:isGamepadDown(self.config.jumpButton) then
            self:tryJump(-0.2 )
        end
    end
end

function Player:tryShoot()
    if self.shootCooldown > .25 then
        local px, py = self.collider:getPosition()

        local bullet = Bullet:new(self, px, py, round(self.facing.x), round(self.facing.y))
        table.insert(self.bullets, bullet)
        self.config.audio.shoot[math.random(#self.config.audio.shoot)]:clone():play()
        self.shootCooldown = 0
    end
end

function Player:kill()
    if not self:isInvulnerable() then
        self.config.audio.death:clone():play()
        Screen:setShake(20)
        self:respawn()
        return true
    end
    return false
end

function Player:respawn()
    self.invulnerableTime = RESPAWN_INVULNERABILITY_TIME
    self.collider:setPosition(self.config.spawn.x, self.config.spawn.y)
end

function Player:isInvulnerable()
    return self.invulnerableTime > 0
end

function Player:draw()
    love.graphics.push("all")
    love.graphics.setColor(1, 1, 1)
    local px, py = self.collider:getPosition()

    love.graphics.draw(
        self.sprite,
        px,
        py,
        self.collider:getAngle(),
        .1 * (self.facing.x * -1),
        .1,
        self.sprite:getWidth() / 2,
        self.sprite:getHeight() / 2
    )

    love.graphics.pop()

    if self:isInvulnerable() then
        love.graphics.push("all")
        love.graphics.setColor(0, 0, .8, .3)
        love.graphics.circle("fill", px-4, py, self.size.x)
        love.graphics.setColor(0, 0, .8, .8)
        love.graphics.circle("line", px-4, py, self.size.x)
        love.graphics.pop()
    end
    for _, bullet in ipairs(self.bullets) do
        bullet:draw()
    end
end

function round(num)
    local addVal = num >= 0 and 0.5 or -0.5
    return math.floor(num + addVal)
end
