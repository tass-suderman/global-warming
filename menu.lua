Menu = {}
Menu.items = {
    {
        text = "start",
        func = function()
            State.current = "Game"
        end,
    },
    {
        text = "quit",
        func = function()
            love.event.quit(0)
        end
    }
}
Menu.selected = 1
Menu.cooldown = 0
DesiredCooldown = 0.2


function Menu:keypressed(key)
    if key == MenuConfig.upKey then
        Menu.selected = (Menu.selected - 2) % #Menu.items + 1
    elseif key == MenuConfig.downKey then
        Menu.selected = Menu.selected % #Menu.items + 1
    end
    if key == MenuConfig.selectKey then
        local item = Menu.items[Menu.selected]
        item.func()
    end
end

function Menu:draw()
    for i, item in ipairs(Menu.items) do
        love.graphics.setFont(love.graphics.newFont(24))
        if i == Menu.selected then
            love.graphics.setColor(1, 0, 0)
        else
            love.graphics.setColor(0, 1, 1)
        end
        love.graphics.print(item.text, 100, 100 + i * 30)
    end
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(48))
    love.graphics.print("Global Warming", 50, 50)
    love.graphics.setColor(0, 0, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("Ice Cube is doing everything in his power to freeze the planet, while Fire Square works to melt it.", 60, 270)
    love.graphics.print("See how the climate reacts to these two forces of nature!", 60, 300)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(12))
    love.graphics.print("Use the joystick or arrow keys to navigate, and space or A to select", 50, WindowHeight - 400)
    love.graphics.print("Controls:", 50, WindowHeight - 180)
    love.graphics.print("Use Left Stick to move, A to jump, Right Trigger to shoot, Right Bumper to sprint", 50, WindowHeight - 160)
    love.graphics.print("Fire Square (Red): W/A/S/D to move, Space to shoot", 50, WindowHeight - 140)
    love.graphics.print("Ice Cube (Blue): Arrow Keys to move, Enter to shoot", 50, WindowHeight - 120)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(24))

end

function Menu:update(dt)
    if love.joystick then
        local joysticks = love.joystick.getJoysticks()
        for _, joystick in ipairs(joysticks) do
            local aButton = joystick:isGamepadDown(MenuConfig.selectButton)
            local upButton = joystick:isGamepadDown(MenuConfig.upButton)
            local downButton = joystick:isGamepadDown(MenuConfig.downButton)
            local yAxis = joystick:getGamepadAxis(MenuConfig.yAxis)
            if aButton then
                local item = Menu.items[Menu.selected]
                item.func()
            end
            if (yAxis < -0.5 or upButton) and Menu.cooldown <= 0 then
                Menu.cooldown = Menu.cooldown + dt
                Menu.selected = (Menu.selected - 2) % #Menu.items + 1

            end
            if (yAxis > 0.5 or downButton) and Menu.cooldown <= 0 then
                Menu.selected = Menu.selected % #Menu.items + 1
                Menu.cooldown = Menu.cooldown + dt
            end
        end
        Menu.cooldown = Menu.cooldown + dt
        if Menu.cooldown >= DesiredCooldown then
            Menu.cooldown = 0
        end
    end
end
