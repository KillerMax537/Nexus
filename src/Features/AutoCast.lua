-- Arquivo: src/Features/AutoCast.lua
local env = getgenv and getgenv() or shared
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Nexus = env.Nexus

local function GetAndEquipRod()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    -- Se já estiver na mão, perfeito
    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped then return equipped end
    
    -- Se não, puxa da mochila
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChildOfClass("Tool")
        if tool then
            tool.Parent = char
            task.wait(0.5)
            return tool
        end
    end
    return nil
end

local function PerformCast()
    if not Nexus.Config.Enabled or not Nexus.Config.AutoCast then return end
    if LocalPlayer:GetAttribute("Fishing") == true then return end
    
    task.wait(Nexus.Config.RecastDelay)
    
    local rod = GetAndEquipRod()
    if rod then
        Nexus.UI:Notify("Lançando vara...", 1)
        -- O método mais robusto: Activate() força a ferramenta a lançar
        pcall(function() rod:Activate() end)
    else
        Nexus.UI:Notify("Vara não encontrada!", 2)
    end
end

LocalPlayer:GetAttributeChangedSignal("Fishing"):Connect(function()
    if LocalPlayer:GetAttribute("Fishing") == false then 
        task.spawn(PerformCast) 
    end
end)

if LocalPlayer:GetAttribute("Fishing") == false then 
    task.spawn(PerformCast) 
end

return true