-- src/Features/Fishing.lua
local env = getgenv and getgenv() or shared
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local Nexus = env.Nexus
local Input = Nexus.Input

local loopConn = RunService.Heartbeat:Connect(function()
    if not Nexus.Config.Enabled then 
        Input.ForceRelease()
        return 
    end

    local fishingUI = PlayerGui:FindFirstChild("FishingUI")
    if not fishingUI or not fishingUI.Enabled then
        Input.ForceRelease()
        return
    end

    -- Varre a pasta de breakpoints em tempo real (Frame-Perfect)
    local bpFolder = fishingUI:FindFirstChild("FishingFrame") 
        and fishingUI.FishingFrame:FindFirstChild("FishingRodMain") 
        and fishingUI.FishingFrame.FishingRodMain:FindFirstChild("Breakpoints")

    local hasActiveBreakpoint = false

    if bpFolder then
        for _, bp in ipairs(bpFolder:GetChildren()) do
            -- Se houver um breakpoint visível e ativo na tela
            if bp:IsA("Frame") and bp.Visible then
                hasActiveBreakpoint = true
                break
            end
        end
    end

    -- Se tem obstáculo: solta o hold e clica instantaneamente para destruí-lo
    -- Se NÃO tem obstáculo: imediatamente volta a segurar para a barra crescer!
    if hasActiveBreakpoint then
        Input.SetHold(false)
        Input.FastClick()
    else
        Input.SetHold(true)
    end
end)

table.insert(Nexus.Connections, loopConn)
return true