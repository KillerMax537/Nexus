-- src/Features/MasterFishing.lua
local env = getgenv and getgenv() or shared
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local LocalPlayer = Players.LocalPlayer

local Nexus = env.Nexus
local Input = Nexus.Input

local activeBreakpoints = 0

-- Detector de breakpoints via sons
task.spawn(function()
    while task.wait(0.5) do
        local ui = PlayerGui:FindFirstChild("FishingUI")
        if ui then
            local sounds = ui:FindFirstChild("Sounds")
            if sounds then
                local startSnd = sounds:FindFirstChild("BreakpointStart")
                local successSnd = sounds:FindFirstChild("BreakpointSuccess")
                
                if startSnd and not startSnd:GetAttribute("NexusHooked") then
                    startSnd.Played:Connect(function()
                        if Nexus.Config.MasterActive and Nexus.Config.AutoFisher then
                            activeBreakpoints = activeBreakpoints + 1
                            if Nexus.Log then Nexus.Log("Breakpoint! Queue: " .. activeBreakpoints) end
                        end
                    end)
                    startSnd:SetAttribute("NexusHooked", true)
                end
                
                if successSnd and not successSnd:GetAttribute("NexusHooked") then
                    successSnd.Played:Connect(function()
                        activeBreakpoints = math.max(0, activeBreakpoints - 1)
                    end)
                    successSnd:SetAttribute("NexusHooked", true)
                end
            end
        end
    end
end)

-- Eventos de pesca para resetar estado
local FishingEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Fishing")
local evtConn = FishingEvent.OnClientEvent:Connect(function(event)
    if event == "StartMinigame" or event == "Cancel" or event == "Success" or event == "Fail" then
        activeBreakpoints = 0
        Input.SetHold(false)
    end
end)
table.insert(Nexus.Connections, evtConn)

-- Loop do mini-jogo (0.01s)
task.spawn(function()
    while task.wait(0.01) do
        if not Nexus.Config.MasterActive or not Nexus.Config.AutoFisher then
            Input.SetHold(false)
            continue
        end

        local ui = PlayerGui:FindFirstChild("FishingUI")
        if not ui or not ui.Enabled then continue end

        if activeBreakpoints > 0 then
            if Input.IsHolding() then
                Input.SetHold(false)
                task.wait(0.02)
            end
            Input.Click()
            task.wait(0.03)
        else
            if not Input.IsHolding() then
                Input.SetHold(true)
            end
        end
    end
end)

-- Loop de auto-cast (0.2s) – agora respeita AutoCast
task.spawn(function()
    while task.wait(0.2) do
        if not Nexus.Config.MasterActive or not Nexus.Config.AutoCast then
            continue
        end

        if LocalPlayer:GetAttribute("Fishing") == false then
            local char = LocalPlayer.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    task.wait(Nexus.Config.RecastDelay or 2)
                    if LocalPlayer:GetAttribute("Fishing") == false and Nexus.Config.MasterActive and Nexus.Config.AutoCast then
                        if Nexus.Notify then Nexus.Notify("🎣 Casting...", 1.5) end
                        if Nexus.Log then Nexus.Log("Auto-cast disparado.") end
                        Input.WorldClick()
                        task.wait(1.5)
                    end
                else
                    if Nexus.Notify then Nexus.Notify("⚠️ Equipe a vara de pesca!", 3) end
                    task.wait(3)
                end
            end
        end
    end
end)

return true