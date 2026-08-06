-- Arquivo: src/Core/Input.lua
local Input = {}
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local holding = false

-- Centro exato da tela (Garante que o Roblox registre o InputBegan)
function Input.GetCenter()
    local cam = Workspace.CurrentCamera
    return cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2
end

-- Simula segurar o mouse
function Input.SetHold(state)
    if state == holding then return end
    holding = state
    local cx, cy = Input.GetCenter()
    VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, state, game, 0)
end

-- Simula um clique rápido e limpo
function Input.Click()
    local cx, cy = Input.GetCenter()
    VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
    task.wait(0.01) -- Micro-delay cruicial para o Roblox ler o clique
    VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
end

function Input.IsHolding()
    return holding
end

return Input