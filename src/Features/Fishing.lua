-- src/Features/Fishing.lua
local env = getgenv and getgenv() or shared
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local Nexus = env.Nexus
local Input = Nexus.Input

local isBreaking = false

local function CheckBreakpointsFolder(fishingUI)
    local bpFolder = fishingUI:FindFirstChild("FishingFrame") 
        and fishingUI.FishingFrame:FindFirstChild("FishingRodMain") 
        and fishingUI.FishingFrame.FishingRodMain:FindFirstChild("Breakpoints")
    
    if bpFolder then
        local anyVisible = false
        for _, bp in ipairs(bpFolder:GetChildren()) do
            if bp:IsA("Frame") and bp.Visible then
                anyVisible = true
                break
            end
        end
        return anyVisible
    end
    return false
end

-- Monitora os áudios do minigame com segurança
local function MonitorAudioCues()
    local fishingUI = PlayerGui:FindFirstChild("FishingUI")
    if fishingUI then
        local sounds = fishingUI:FindFirstChild("Sounds")
        if sounds then
            local startSnd = sounds:FindFirstChild("BreakpointStart")
            local successSnd = sounds:FindFirstChild("BreakpointSuccess")
            
            if startSnd and not startSnd:GetAttribute("NexusHooked") then
                startSnd.Played:Connect(function() isBreaking = true end)
                startSnd:SetAttribute("NexusHooked", true)
            end
            if successSnd and not successSnd:GetAttribute("NexusHooked") then
                successSnd.Played:Connect(function() isBreaking = false end)
                successSnd:SetAttribute("NexusHooked", true)
            end
        end
    end
end

local FishingEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Fishing")
local evtConn = FishingEvent.OnClientEvent:Connect(function(event)
    if event == "StartMinigame" then
        isBreaking = false
        MonitorAudioCues()
    elseif event == "Cancel" or event == "Success" or event == "Fail" then
        isBreaking = false
        Input.ForceRelease()
    end
end)
table.insert(Nexus.Connections, evtConn)

-- Loop Frame-Perfect Inteligente
local loopConn = RunService.Heartbeat:Connect(function()
    if not Nexus.Config.Enabled then 
        Input.ForceRelease()
        return 
    end

    local fishingUI = PlayerGui:FindFirstChild("FishingUI")
    if not fishingUI or not fishingUI.Enabled then
        Input.ForceRelease()
        isBreaking = false
        return
    end

    MonitorAudioCues()

    -- Verifica visualmente se ainda há breakpoints na tela. Se sumiram, força isBreaking = false!
    local visualHasBP = CheckBreakpointsFolder(fishingUI)
    if not visualHasBP then
        isBreaking = false
    end

    -- Execução da Física
    if isBreaking or visualHasBP then
        Input.SetHold(false)
        Input.FastClick()
    else
        Input.SetHold(true)
    end
end)
table.insert(Nexus.Connections, loopConn)

return true