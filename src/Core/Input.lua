local Input = {}
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")

local holding = false
local lastClickTime = 0

-- Clique para arremessar a isca (Mira na água - 30% do topo da tela)
function Input.WorldClick()
    local cam = Workspace.CurrentCamera
    local x, y = cam.ViewportSize.X / 2, cam.ViewportSize.Y * 0.3
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
    task.wait(0.05)
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, false, game, 0)
end

-- Simula segurar o mouse apenas para o Minigame (Sem mirar em nada específico)
function Input.MinigameHold(state)
    if state and not holding then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
        holding = true
    elseif not state and holding then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        holding = false
    end
end

-- Spam de cliques para quebrar o Breakpoint
function Input.MinigameFastClick()
    if tick() - lastClickTime < 0.03 then return end 
    lastClickTime = tick()

    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    task.spawn(function()
        task.wait(0.01)
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
    end)
end

function Input.ForceRelease()
    if holding then
        VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
        holding = false
    end
end

return Input