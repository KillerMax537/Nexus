-- Arquivo: src/Core/Input.lua
local Input = {}
local VIM = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local holding = false

-- Segurar linha
function Input.SetHold(state)
    if holding == state then return end
    holding = state
    VIM:SendMouseButtonEvent(0, 0, 0, state, game, 0)
end

-- Clique rápido para o Breakpoint
function Input.FastClick(x, y)
    VIM:SendMouseMoveEvent(x, y, 0, game)
    task.wait(0.01)
    VIM:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.01)
    VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

-- Clique na tela inteira para lançar a isca (Simula o jogador)
function Input.WorldClick()
    local cam = Workspace.CurrentCamera
    local cx, cy = cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2
    VIM:SendMouseMoveEvent(cx, cy, 0, game)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
    task.wait(0.1) -- Hold mais longo para garantir o arremesso
    VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
end

function Input.IsHolding() return holding end
return Input