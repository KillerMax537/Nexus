-- src/Features/AutoCast.lua
local env = getgenv and getgenv() or shared
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Nexus = env.Nexus
local isCasting = false

local function GetAndEquipRod()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    -- Verifica se já está com a vara equipada na mão
    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped then return equipped end
    
    -- Procura na mochila (Backpack) e puxa para o personagem
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChildOfClass("Tool")
        if tool then
            tool.Parent = char
            task.wait(0.5) -- Tempo da animação de equipar
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
        local rod = GetAndEquipRod()
        
        if rod then
            Nexus.Log("🎣 Vara encontrada! Ativando lançamento...")
            
            -- O método mais seguro e nativo para ferramentas no Roblox
            pcall(function()
                rod:Activate()
            end)
            
            -- Aguarda até 3 segundos para ver se o jogo registrou que a isca caiu na água
            local attempts = 0
            while attempts < 30 and LocalPlayer:GetAttribute("Fishing") ~= true do
                task.wait(0.1)
                attempts = attempts + 1
            end
            
            if LocalPlayer:GetAttribute("Fishing") ~= true then
                Nexus.Log("⚠️ O lançamento falhou, tentando de novo...")
                task.wait(1.5)
            end
        else
            Nexus.Log("❌ Nenhuma vara de pesca na mão ou na mochila!")
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

-- Executa uma vez se já estiver desocupado ao injetar
if LocalPlayer:GetAttribute("Fishing") == false then 
    task.spawn(PerformCast) 
end

return true