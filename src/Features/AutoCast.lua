-- Arquivo: src/Features/AutoCast.lua
local env = getgenv and getgenv() or shared
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Nexus = env.Nexus
local Input = Nexus.Input
local isCasting = false

local function EquipRod()
    local char = LocalPlayer.Character
    if not char then return false end
    if char:FindFirstChildOfClass("Tool") then return true end
    
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChildOfClass("Tool")
        if tool then
            tool.Parent = char
            task.wait(0.2) -- Equipamento mais rápido
            return true
        end
    end
    return false
end

local function PerformCast()
    if not Nexus.Config.Enabled or not Nexus.Config.AutoCast or isCasting then return end
    if LocalPlayer:GetAttribute("Fishing") == true then return end
    
    isCasting = true
    -- Delay hiper-rápido conforme você solicitou (0.15s)
    task.wait(0.15)
    
    while Nexus.Config.Enabled and Nexus.Config.AutoCast and LocalPlayer:GetAttribute("Fishing") ~= true do
        if EquipRod() then
            Nexus.Log("🎣 Lançando isca...")
            
            -- Clique no topo da tela!
            Input.WorldClick()
            
            local attempts = 0
            while attempts < 15 and LocalPlayer:GetAttribute("Fishing") ~= true do
                task.wait(0.1)
                attempts = attempts + 1
            end
            
            if LocalPlayer:GetAttribute("Fishing") ~= true then
                Nexus.Log("⚠️ Tentando lançar novamente...")
            end
        else
            Nexus.Log("❌ Pegue sua vara de pesca!")
            task.wait(1)
        end
    end
    isCasting = false
end

local attrConn = LocalPlayer:GetAttributeChangedSignal("Fishing"):Connect(function()
    if LocalPlayer:GetAttribute("Fishing") == false then 
        task.spawn(PerformCast) 
    end
end)
table.insert(Nexus.Connections, attrConn)

if LocalPlayer:GetAttribute("Fishing") == false then 
    task.spawn(PerformCast) 
end

return true