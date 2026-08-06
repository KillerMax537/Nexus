local env = getgenv and getgenv() or shared
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Nexus = env.Nexus
local Input = Nexus.Input
local isCasting = false

local function EquipAndGetRod()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped then return equipped end
    
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
    if not Nexus.Config.Enabled or not Nexus.Config.AutoCast or isCasting then return end
    if LocalPlayer:GetAttribute("Fishing") == true then return end
    
    isCasting = true
    task.wait(Nexus.Config.RecastDelay)
    
    while Nexus.Config.Enabled and Nexus.Config.AutoCast and LocalPlayer:GetAttribute("Fishing") ~= true do
        local rod = EquipAndGetRod()
        
        if rod then
            Nexus.UI:Notify("Lançando isca...", 2)
            
            -- Usa o clique real na água (O tool:Activate foi descartado)
            Input.WorldClick()
            
            local attempts = 0
            while attempts < 30 and LocalPlayer:GetAttribute("Fishing") ~= true do
                task.wait(0.1)
                attempts = attempts + 1
            end
            
            if LocalPlayer:GetAttribute("Fishing") ~= true then
                task.wait(1.5)
            end
        else
            -- Notifica o jogador na tela para pegar a vara
            Nexus.UI:Notify("⚠️ Pegue a vara de pesca na mão!", 3)
            task.wait(3)
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

if LocalPlayer:GetAttribute("Fishing") == false then task.spawn(PerformCast) end

return true