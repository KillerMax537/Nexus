-- src/Features/AutoCast.lua
local env = getgenv and getgenv() or shared
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Nexus = env.Nexus
local isCasting = false

local function EquipAndGetRod()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    -- 1. Verifica se já está na mão
    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped then return equipped end
    
    -- 2. Pega da mochila se estiver guardada
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChildOfClass("Tool")
        if tool then
            tool.Parent = char
            task.wait(0.4) -- Tempo para o braço do personagem segurar a ferramenta
            return tool
        end
    end
    
    return nil
end

local function PerformCast()
    if not Nexus.Config.Enabled or not Nexus.Config.AutoCast or isCasting then return end
    if LocalPlayer:GetAttribute("Fishing") == true then return end
    
    isCasting = true
    Nexus.Log("Aguardando " .. Nexus.Config.RecastDelay .. "s para lançar a vara...")
    task.wait(Nexus.Config.RecastDelay)
    
    while Nexus.Config.Enabled and Nexus.Config.AutoCast and LocalPlayer:GetAttribute("Fishing") ~= true do
        local rod = EquipAndGetRod()
        
        if rod then
            Nexus.Log("🎣 Vara equipada! Lançando linha...")
            
            -- Ativa a ferramenta de forma oficial do Roblox
            pcall(function()
                rod:Activate()
            end)
            
            -- Aguarda a confirmação de que a pesca iniciou (Até 3 segundos)
            local attempts = 0
            while attempts < 30 and LocalPlayer:GetAttribute("Fishing") ~= true do
                task.wait(0.1)
                attempts = attempts + 1
            end
            
            if LocalPlayer:GetAttribute("Fishing") ~= true then
                Nexus.Log("⚠️ A tentativa falhou, re-tentando...")
                task.wait(1.5)
            end
        else
            Nexus.Log("❌ Nenhuma vara encontrada na mão ou inventário!")
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