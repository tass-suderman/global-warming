local Thermo = require("thermo")
Game = {}

State = {}
State.items = { "Menu", "Game", "GameOver" }
State.current = "Menu"

Temperature = 0

HOT_WIN = 100
COLD_WIN = -100

local gauge

function Game.load()
    gauge = Thermo.new { x = WindowWidth / 2, y = 50, height = 220, width = 24, bulbRadius = 28, min = COLD_WIN, max = HOT_WIN, value = 0 }
end

function Game.update()
end

function ChangeScore(value)
    Temperature = Temperature + value
    gauge:set(Temperature)
    if Temperature >= HOT_WIN or Temperature <= COLD_WIN then
        PlayerWin()
    end
end

function PlayerWin()
    State.current = "GameOver"
end

function KillPlayer(player)
    local playertype = player.config.name;
    local didKill = player:kill()
    if didKill then
        ChangeScore(({
            Fire = function() return -5 end,
            Ice = function() return 5 end
        })[playertype]())
    end
end

function DestroyCrystal(faction)
    ChangeScore(({
        Fire = function() return -5 end,
        Ice = function() return 5 end
    })[faction]())
end

function Game:draw()
    gauge:draw()
end
