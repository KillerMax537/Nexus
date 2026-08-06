-- Arquivo: src/Core/Input.lua
local Input = {}
local VIM = game:GetService("VirtualInputManager")

local holding = false

function Input.SetHold(state)
    if holding == state then return end
    holding = state
    VIM:SendMouseButtonEvent(0, 0, 0, state, game, 0)
end

-- Novo: Clique preciso em coordenadas específicas
function Input.DirectClick(x, y)
    VIM:SendMouseMoveEvent(x, y, 0, game)
    task.wait(0.01)
    VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.01)
    VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

function Input.IsHolding() return holding end
return Input