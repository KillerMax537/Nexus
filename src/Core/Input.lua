-- Arquivo: src/Core/Input.lua
local Input = {}
local VIM = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local holding = false

function Input.SetHold(state)
    if holding == state then return end
    holding = state
    VIM:SendMouseButtonEvent(0, 0, 0, state, game, 0)
end

function Input.Click()
    VIM:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.wait(0.01) 
    VIM:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

function Input.WorldClick()
    local cam = Workspace.CurrentCamera
    local cx = cam.ViewportSize.X / 2
    
    -- O Pulo do Gato: 50 pixels do topo da tela. 
    -- Garante que o clique vai pro céu/água e nunca clica em cima do seu próprio personagem ou em UIs centrais.
    VIM:SendMouseButtonEvent(cx, 50, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(cx, 50, 0, false, game, 0)
end

return Input