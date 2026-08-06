-- Arquivo: src/Core/Input.lua
local Input = {}
local VIM = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local holding = false

-- Segura o mouse (Para puxar o peixe)
function Input.SetHold(state)
    if holding == state then return end
    holding = state
    VIM:SendMouseButtonEvent(0, 0, 0, state, game, 0)
end

-- Clique ultra-rápido para quebrar o obstáculo
function Input.Click()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.01) -- Tempo exato para o servidor registrar o clique
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Clique no centro da câmera para lançar a vara (Garante que atinge o mundo 3D)
function Input.WorldClick()
    local cam = Workspace.CurrentCamera
    local cx = cam.ViewportSize.X / 2
    local cy = cam.ViewportSize.Y / 2
    VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
end

return Input