local env = getgenv and getgenv() or shared
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local LocalPlayer = Players.LocalPlayer

local Nexus = env.Nexus
local Input = Nexus.Input

local activeBreakpoints = 0

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
                        if Nexus.Config.MasterActive then 
                            activeBreakpoints = activeBreakpoints + 1 
                            if Nexus.Log then Nexus.Log("Breakpoint detected! Queue: " .. activeBreakpoints) end
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

local FishingEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Fishing")
local evtConn = FishingEvent.OnClientEvent:Connect(function(event)
    if event == "StartMinigame" or event == "Cancel" or event == "Success" or event == "Fail" then
        activeBreakpoints = 0
        Input.SetHold(false)
    end
end)
table.insert(Nexus.Connections, evtConn)

task.spawn(function()
    while task.wait(0.01) do
        if not Nexus.Config.MasterActive then continue end
        
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

task.spawn(function()
    while task.wait(0.2) do
        if Nexus.Config.MasterActive then
            if LocalPlayer:GetAttribute("Fishing") == false then
                local char = LocalPlayer.Character
                local hasTool = char and char:FindFirstChildOfClass("Tool")
                
                if hasTool then
                    task.wait(Nexus.Config.RecastDelay or 0.15)
                    if LocalPlayer:GetAttribute("Fishing") == false and Nexus.Config.MasterActive then
                        if Nexus.Notify then Nexus.Notify("🎣 Casting bait...", 1.5) end
                        if Nexus.Log then Nexus.Log("Auto-Cast triggered.") end
                        Input.WorldClick()
                        task.wait(1.5)
                    end
                else
                    if Nexus.Notify then Nexus.Notify("⚠️ Equip the Fishing Rod!", 3) end
                    task.wait(3)
                end
            end
        end
    end
end)

return true