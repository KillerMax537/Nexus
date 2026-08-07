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
    task.wait(Nexus.Config.RecastDelay or 0.15)
    
    while Nexus.Config.Enabled and Nexus.Config.AutoCast and LocalPlayer:GetAttribute("Fishing") ~= true do
        -- Verifica apenas se você está segurando uma ferramenta
        local hasToolEquipped = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
        
        if hasToolEquipped then
            Nexus.Notify("🎣 Lançando isca...", 2)
            
            -- Clique na tela!
            Input.WorldClick()
            
            -- Aguarda até 3 segundos pra confirmar o arremesso
            local attempts = 0
            while attempts < 30 and LocalPlayer:GetAttribute("Fishing") ~= true do
                task.wait(0.1)
                attempts = attempts + 1
            end
        else
            -- Se não estiver na mão, avisa na UI até você colocar!
            Nexus.Notify("⚠️ Equipe a Vara de Pesca na mão!", 3)
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

-- Tentativa inicial
if LocalPlayer:GetAttribute("Fishing") == false then 
    task.spawn(PerformCast) 
end

return true