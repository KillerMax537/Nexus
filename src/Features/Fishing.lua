-- Arquivo: src/Features/Fishing.lua
local env = getgenv and getgenv() or shared
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local Nexus = env.Nexus
local Input = Nexus.Input

local function GetActiveBreakpoint(bpFolder)
    -- Encontra o primeiro Breakpoint visível para focar nele
    for _, bp in ipairs(bpFolder:GetChildren()) do
        if bp:IsA("Frame") and bp.Visible then
            return bp
        end
    end
    return nil
end

RunService.Heartbeat:Connect(function()
    if not Nexus.Config.Enabled then 
        Input.SetHold(false) 
        return 
    end

    local ui = PlayerGui:FindFirstChild("FishingUI")
    if not ui or not ui.Enabled then
        Input.SetHold(false)
        return
    end

    local bpFolder = ui:FindFirstChild("FishingFrame") 
        and ui.FishingFrame:FindFirstChild("FishingRodMain") 
        and ui.FishingFrame.FishingRodMain:FindFirstChild("Breakpoints")

    if bpFolder then
        local targetBP = GetActiveBreakpoint(bpFolder)

        if targetBP then
            -- Há um Breakpoint! Solta a linha e metralha cliques até ele sumir
            Input.SetHold(false)
            local pos = targetBP.AbsolutePosition + (targetBP.AbsoluteSize / 2)
            
            -- Limita a velocidade dos cliques pra não crashar o VIM
            if not targetBP:GetAttribute("LastClick") or tick() - targetBP:GetAttribute("LastClick") > 0.05 then
                targetBP:SetAttribute("LastClick", tick())
                Input.FastClick(pos.X, pos.Y)
            end
        else
            -- Limpo! Segura a vara
            Input.SetHold(true)
        end
    end
end)

return true