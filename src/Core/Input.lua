-- Arquivo: src/Core/Input.lua
local Input = {}
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local holding = false

function Input.GetSafeZone()
    return Workspace.CurrentCamera.ViewportSize.X / 2, 50 
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
    local x, y = Input.GetSafeZone()
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

return Input