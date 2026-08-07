-- Arquivo: src/Features/AutoCast.lua
local env = getgenv and getgenv() or shared
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Nexus = env.Nexus
local Input = Nexus.Input

task.spawn(function()
    while task.wait(1) do -- Verifica a cada segundo se precisa lançar
        if Nexus.Config.Enabled and Nexus.Config.AutoCast then
            if LocalPlayer:GetAttribute("Fishing") == false then
                local char = LocalPlayer.Character
                if char and char:FindFirstChildOfClass("Tool") then
                    -- Lança a isca ignorando se o usuário está clicando ou não
                    Input.WorldClick()
                    task.wait(2) -- Delay após tentar arremessar
                else
                    Nexus.Notify("⚠️ Equipe a Vara na mão!", 2)
                    task.wait(3)
                end
            end
        end
    end
end)

return true