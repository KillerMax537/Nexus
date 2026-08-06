-- Arquivo: src/Core/Input.lua
local Input = {}
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")

local holding = false
local lastClickTime = 0

function Input.GetSafeZone()
    -- Ignora a barra superior do Roblox para o clique não pegar nela
    local inset = GuiService:GetGuiInset()
    local cam = Workspace.CurrentCamera
    return cam.ViewportSize.X / 2, (cam.ViewportSize.Y / 4) + inset.Y
end

function Input.SetHold(state)
    local x, y = Input.GetSafeZone()
    if state and not holding then
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
        holding = true
    elseif not state and holding then
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
        holding = false
    end
end

function Input.FastClick()
    -- LIMITADOR: Permite no máximo 15 cliques por segundo. Isso salva o minigame de travar!
    if tick() - lastClickTime < 0.06 then return end 
    lastClickTime = tick()

    local x, y = Input.GetSafeZone()
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
    -- Simula um micro delay humano
    task.spawn(function()
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
    end)
end

function Input.ForceRelease()
    if holding then
        local x, y = Input.GetSafeZone()
        VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
        holding = false
    end
end

return Input