-- src/Features/AutoCast.lua
local env = getgenv and getgenv() or shared
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

local Nexus = env.Nexus
local isCasting = false

local function EquipeAndGetRod()
    local char = LocalPlayer.Character
    if not char then return nil end
    
    -- 1. Checa se já está na mão
    local equipped = char:FindFirstChildOfClass("Tool")
    if equipped then return equipped end
    
    -- 2. Procura na mochila e equipa
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        local tool = backpack:FindFirstChildOfClass("Tool")
        if tool then
            tool.Parent = char
            task.wait(0.6) -- Espera o boneco segurar na mão
            return tool
        end
    end
    
    return nil
end

local function PerformCast()
    if not Nexus.Config.Enabled or not Nexus.Config.AutoCast or isCasting then return end
    if LocalPlayer:GetAttribute("Fishing") == true then return end
    
    isCasting = true
    Nexus.Log("Aguardando " .. Nexus.Config.RecastDelay .. "s para lançar...")
    task.wait(Nexus.Config.RecastDelay)
    
    while Nexus.Config.Enabled and Nexus.Config.AutoCast and LocalPlayer:GetAttribute("Fishing") ~= true do
        local rod = EquipeAndGetRod()
        
        if rod then
            Nexus.Log("🎣 Vara equipada! Lançando na água...")
            
            -- Clique na zona segura (água)
            local cx, cy = Workspace.CurrentCamera.ViewportSize.X / 2, Workspace.CurrentCamera.ViewportSize.Y * 0.3
            VirtualInputManager:SendMouseMoveEvent(cx, cy, 0, game)
            task.wait(0.1)
            VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 0)
            task.wait(0.1)
            VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 0)
            
            -- Espera até 3 segundos pra ver se o jogo registrou a isca na água
            local attempts = 0
            while attempts < 30 and LocalPlayer:GetAttribute("Fishing") ~= true do
                task.wait(0.1)
                attempts = attempts + 1
            end
            
            if LocalPlayer:GetAttribute("Fishing") ~= true then
                Nexus.Log("⚠️ Lançamento falhou (UI no caminho?). Retentando...")
                task.wait(1.5)
            end
        else
            Nexus.Log("❌ Nenhuma vara de pesca encontrada no inventário!")
            task.wait(2)
        end
    end
    isCasting = false
end

local attrConn = LocalPlayer:GetAttributeChangedSignal("Fishing"):Connect(function()
    if LocalPlayer:GetAttribute("Fishing") == false then task.spawn(PerformCast) end
end)
table.insert(Nexus.Connections, attrConn)

-- Gatilho inicial
if LocalPlayer:GetAttribute("Fishing") == false then task.spawn(PerformCast) end

return true