-- Arquivo: src/Features/AutoCast.lua
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local Nexus = getgenv().Nexus
local isCasting = false

local function attemptCast()
    if not Nexus.Config.Enabled or not Nexus.Config.AutoCast or isCasting then return end
    if LocalPlayer:GetAttribute("Fishing") == true then return end
    
    isCasting = true
    Nexus.Log("Delay humanizado: " .. Nexus.Config.RecastDelay .. "s")
    task.wait(Nexus.Config.RecastDelay)
    
    while Nexus.Config.Enabled and Nexus.Config.AutoCast and LocalPlayer:GetAttribute("Fishing") ~= true do
        local char = LocalPlayer.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            if tool then
                tool.Parent = char
                task.wait(0.6)
                
                Nexus.Log("🎣 Lançando...")
                local cam = Workspace.CurrentCamera
                local cx, cy = cam.ViewportSize.X / 2, cam.ViewportSize.Y * 0.4
                VirtualInputManager:SendMouseMoveEvent(cx, cy, 0, game)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
                task.wait(0.05)
                VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
                
                local attempts = 0
                while attempts < 30 and LocalPlayer:GetAttribute("Fishing") ~= true do
                    task.wait(0.1)
                    attempts = attempts + 1
                end
                
                if LocalPlayer:GetAttribute("Fishing") ~= true then
                    Nexus.Log("⚠️ Erro de Física do Jogo. Retentando...")
                    task.wait(1.5)
                end
            end
        end
        task.wait(0.5)
    end
    isCasting = false
end

LocalPlayer:GetAttributeChangedSignal("Fishing"):Connect(function()
    if LocalPlayer:GetAttribute("Fishing") == false then attemptCast() end
end)

if LocalPlayer:GetAttribute("Fishing") == false then task.spawn(attemptCast) end

return true