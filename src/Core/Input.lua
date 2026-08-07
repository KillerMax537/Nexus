-- Arquivo: src/Core/Input.lua
local Input = {}
local VIM = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local holding = false

function Input.SetHold(state)
    if holding == state then return end
    holding = state
    if state then
        if mouse1press then mouse1press() else VIM:SendMouseButtonEvent(0,0,0,true,game,0) end
    else
        if mouse1release then mouse1release() else VIM:SendMouseButtonEvent(0,0,0,false,game,0) end
    end
end

function Input.Click()
    -- Clique rápido no hardware (mais confiável)
    if mouse1click then
        mouse1click()
    else
        VIM:SendMouseButtonEvent(0,0,0,true,game,0)
        task.wait(0.01)
        VIM:SendMouseButtonEvent(0,0,0,false,game,0)
    end
end

function Input.WorldClick()
    -- Mira no topo (céu/água) para arremessar
    local cam = Workspace.CurrentCamera
    local cx = cam.ViewportSize.X / 2
    local cy = 50 -- Topo da tela
    
    if mouse1click then
        -- Move o mouse e clica
        mousemoveabs(cx, cy)
        task.wait(0.05)
        mouse1click()
    else
        VIM:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
        task.wait(0.05)
        VIM:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
    end
end

function Input.IsHolding() return holding end
return Input