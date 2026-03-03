require "player"
require "game"
require "gameover"
require "gworld"
require "menu"
require "crystal"
require "crystalManager"
Screen = require "lib.shack.shack"
Bg, _ = require "effects.background"

Joystick = love.joystick.getJoysticks()[1]

IceConfig = {
    left = "left",
    up = "up",
    down = "down",
    right = "right",
    start_facing = { x = -1, y = 0 },
    name = "Ice",
    shoot = "return",
    spawn = {
        x = WindowWidth - 100 - 40,
        y = 300,
    },
    colour = { 0, 0, 1 },
    joystickUp = "lefty",
    joystickLeft = "leftx",
    shootButton = "triggerright",
    jumpButton = "a",
    sprintButton = "rightshoulder",
    gamepadIndex = 1,
    audio = {
        shoot = {
            love.audio.newSource("assets/audio/ice-shoot-1.mp3", "static"),
            love.audio.newSource("assets/audio/ice-shoot-2.mp3", "static")
        },
        jump = love.audio.newSource("assets/audio/jump.mp3", "static"),
        land = love.audio.newSource("assets/audio/land.mp3", "static"),
        death = love.audio.newSource("assets/audio/ice-death.mp3", "static"),
        miss = love.audio.newSource("assets/audio/ice-miss.mp3", "static"),
    },
    sprite = "assets/ice_cube.png"
}

FireConfig = {
    up = "w",
    left = "a",
    down = "s",
    right = "d",
    start_facing = { x = 1, y = 0 },
    name = "Fire",
    shoot = "space",
    colour = { 1, 0, 0 },
    spawn = {
        x = 100,
        y = 300,
    },
    joystickUp = "lefty",
    joystickLeft = "leftx",
    shootButton = "triggerright",
    jumpButton = "a",
    sprintButton = "rightshoulder",
    gamepadIndex = 2,
    audio = {
        shoot = {
            love.audio.newSource("assets/audio/fire-shoot-1.mp3", "static"),
            love.audio.newSource("assets/audio/fire-shoot-2.mp3", "static")
        },
        jump = love.audio.newSource("assets/audio/jump.mp3", "static"),
        land = love.audio.newSource("assets/audio/land.mp3", "static"),
        death = love.audio.newSource("assets/audio/fire-death.mp3", "static"),
        miss = love.audio.newSource("assets/audio/fire-miss.mp3", "static"),
    },
    sprite = "assets/magma_cube.png"
}

MenuConfig = {
    upKey = "up",
    downKey = "down",
    selectKey = "space",
    upButton = "dpup",
    downButton = "dpdown",
    yAxis = "lefty",
    selectButton = "a",
}

IceCrystalConfig = {
    audio = {
        kill = love.audio.newSource("assets/audio/water-barrel.mp3", "static"),
    },
    faction = "Fire",
    sprite = "assets/ice_crystal.png",
    color = { 1, 0, 0 },
    spawnLocations = {
        {
            x = ((WindowWidth - GroundWidth) / 4) + (CrystalSides / 2),
            y = WindowHeight - (GroundHeight / 1.5) - 50
        },
        {
            x = (CloseSideWallMargin / 2) - (CrystalSides / 2),
            y = WindowHeight - (JumpHeight * 1.75) + WallHeight * .5 - (CrystalSides / 2)
        },
        {
            x = WallWidth * 2 - (CrystalSides / 2),
            y = WindowHeight - (JumpHeight * 2.6) - (CrystalSides / 2)
        }
    }
}

FireBarrelConfig = {
    audio = {
        kill = love.audio.newSource("assets/audio/fire-barrel.mp3", "static"),
    },
    sprite = "assets/explosive_barrel.png",
    faction = "Ice",
    color = { 0, 0, 1 },
    spawnLocations = {
        {
            x = (WindowWidth - ((WindowWidth - GroundWidth) / 3)) - (CrystalSides / 2),
            y = WindowHeight - (GroundHeight / 1.5) - 50
        },
        {
            x = WindowWidth - (CloseSideWallMargin / 2) - (CrystalSides / 2),
            y = WindowHeight - (JumpHeight * 1.75) + WallHeight * .5 - (CrystalSides / 2)
        },
        {
            x = WindowWidth - (WallWidth * 2) - (CrystalSides / 2),
            y = WindowHeight - (JumpHeight * 2.6) - (CrystalSides / 2)
        }
    }
}

IcePlayer = {}
FirePlayer = {}
GameWorld = {}
Entities = {}
Explosion = require("effects.explosion")

Explosions = {}
Background = {}




function love.load()
    Screen:setShake(20)

    GameWorld = GWorld:new()
    IcePlayer = Player:new(IceConfig)
    FirePlayer = Player:new(FireConfig)
    IceCrystalManager = CrystalManager:new(IceCrystalConfig)
    FireCrystalManager = CrystalManager:new(FireBarrelConfig)
    BackgroundMusic = love.audio.newSource("assets/audio/bgm.mp3", "stream")
    Game:load()

    Explosion.load()
    Background = Bg:new()
end

function love.update(dt)
    if State.current == "Menu" then
        Menu:update(dt)
    end
    if State.current == "GameOver" then
        GameOver:update(dt)
    end
    if State.current == "Game" then
        Screen:update(dt)
        IcePlayer:update(dt)
        FirePlayer:update(dt)
        GameWorld.world:update(dt)
        IceCrystalManager:update(dt)
        FireCrystalManager:update(dt)
        for i = #Explosions, 1, -1 do
            local e = Explosions[i]
            e:update(dt)
            if e:isDead() then table.remove(Explosions, i) end
        end
        Background:update(Temperature)
    end
    if not BackgroundMusic:isPlaying() then
        BackgroundMusic:setVolume(0.8)
        BackgroundMusic:play()
    end
end

function love.draw()
    if State.current == "Game" then
        Background:draw()
        GameWorld:draw()
        IcePlayer:draw()
        FirePlayer:draw()
        IceCrystalManager:draw()
        FireCrystalManager:draw()
        Screen:apply()
        for _, e in ipairs(Explosions) do e:draw() end
        Game:draw()
    elseif State.current == "Menu" then
        Menu:draw()
    elseif State.current == "GameOver" then
        GameOver:draw()
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit(0)
    end
    if State.current == "Menu" then
        Menu:keypressed(key)
    elseif State.current == "GameOver" then
        GameOver:keypressed(key)

    end
end
