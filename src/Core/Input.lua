-- src/Core/Input.lua
local Input = {}
local VirtualInputManager = game:GetService("VirtualInputManager")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")

local holding = false
local lastClickTime = 0

function Input.GetSafeZone()
    local inset = GuiService:GetGuiInset()
    local cam = Workspace.CurrentCamera
    -- Mira levemente para cima (água) para evitar clicar em UIs e no próprio boneco
    return cam.ViewportSize.X / 2, (cam.ViewportSize.Y * 0.3) + inset.Y
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
    -- 30 cliques por segundo. Perfeito para destruir Breakpoints instantaneamente.
    if tick() - lastClickTime < 0.03 then return end 
    lastClickTime = tick()

    local x, y = Input.GetSafeZone()
    VirtualInputManager:SendMouseButtonEvent(x, y, 0, true, game, 0)
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