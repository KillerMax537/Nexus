-- Arquivo: src/Features/AutoCast.lua
local env = getgenv and getgenv() or shared
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Nexus = env.Nexus
local Input = Nexus.Input
local isCasting = false

local function PerformCast()
    if not Nexus.Config.Enabled or not Nexus.Config.AutoCast or isCasting then return end
    if LocalPlayer:GetAttribute("Fishing") == true then return end
    
    isCasting = true
    
    -- Delay rapidíssimo que você pediu (0.15s)
    task.wait(Nexus.Config.RecastDelay or 0.15)
    
    while Nexus.Config.Enabled and Nexus.Config.AutoCast and LocalPlayer:GetAttribute("Fishing") ~= true do
        
        -- Checa se a vara está na mão
        local char = LocalPlayer.Character
        local hasRod = char and char:FindFirstChildOfClass("Tool")
        
        if hasRod then
            if env.Nexus.Notify then env.Nexus.Notify("🎣 Lançando isca...", 2) end
            
            -- Clique absoluto (O mesmo que você testou e funcionou)
            Input.Click()
            
            local attempts = 0
            while attempts < 25 and LocalPlayer:GetAttribute("Fishing") ~= true do
                task.wait(0.1)
                attempts = attempts + 1
            end
        else
            if env.Nexus.Notify then env.Nexus.Notify("⚠️ Equipe a Vara na mão!", 3) end
            task.wait(2)
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