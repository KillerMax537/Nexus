-- Arquivo: src/Features/Fishing.lua
local env = getgenv and getgenv() or shared
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local Nexus = env.Nexus
local Input = Nexus.Input

local function HasBreakpoints()
    local ui = PlayerGui:FindFirstChild("FishingUI")
    if not ui or not ui.Enabled then return false end
    
    local bpFolder = ui:FindFirstChild("FishingFrame") 
        and ui.FishingFrame:FindFirstChild("FishingRodMain") 
        and ui.FishingFrame.FishingRodMain:FindFirstChild("Breakpoints")

    if bpFolder then
        for _, bp in ipairs(bpFolder:GetChildren()) do
            if bp:IsA("Frame") and bp.Visible then
                return true
            end
        end
    end
    return false
end

-- THREAD DEDICADA: A Abordagem Nova que não engasga a CPU e respeita os ticks do Roblox.
task.spawn(function()
    while task.wait(0.01) do
        if not Nexus.Config.Enabled then
            if Input.IsHolding() then Input.SetHold(false) end
            continue
        end

        local ui = PlayerGui:FindFirstChild("FishingUI")
        if not ui or not ui.Enabled then
            if Input.IsHolding() then Input.SetHold(false) end
            continue
        end

        if HasBreakpoints() then
            -- 1. Se estiver segurando, solta.
            if Input.IsHolding() then
                Input.SetHold(false)
                task.wait(0.02) -- PAUSA CRUCIAL: Deixa o servidor entender que você soltou a linha!
            end
            
            -- 2. Atira um clique limpo no obstáculo
            Input.Click()
            task.wait(0.02) -- Pausa para não atropelar cliques
        else
            -- Sem obstáculos? Volta a segurar IMEDIATAMENTE.
            if not Input.IsHolding() then
                Input.SetHold(true)
            end
        end
    end
end)

return true