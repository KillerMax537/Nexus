-- Arquivo: src/Features/Fishing.lua
local env = getgenv and getgenv() or shared
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local Nexus = env.Nexus
local Input = Nexus.Input

-- A genialidade: Em vez de True/False, usamos um contador.
-- Isso previne que um áudio atropele o outro!
local activeBreakpoints = 0

task.spawn(function()
    while task.wait(1) do
        local ui = PlayerGui:FindFirstChild("FishingUI")
        if ui then
            local sounds = ui:FindFirstChild("Sounds")
            if sounds then
                local startSnd = sounds:FindFirstChild("BreakpointStart")
                local successSnd = sounds:FindFirstChild("BreakpointSuccess")
                
                if startSnd and not startSnd:GetAttribute("Hooked") then
                    startSnd.Played:Connect(function() 
                        if Nexus.Config.Enabled then 
                            activeBreakpoints = activeBreakpoints + 1 
                        end
                    end)
                    startSnd:SetAttribute("Hooked", true)
                end
                
                if successSnd and not successSnd:GetAttribute("Hooked") then
                    successSnd.Played:Connect(function() 
                        activeBreakpoints = math.max(0, activeBreakpoints - 1) 
                    end)
                    successSnd:SetAttribute("Hooked", true)
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
        if not Nexus.Config.Enabled then continue end
        
        local ui = PlayerGui:FindFirstChild("FishingUI")
        if not ui or not ui.Enabled then continue end
        
        -- Se houver QUALQUER breakpoint na fila, ele atira.
        if activeBreakpoints > 0 then
            Input.SetHold(false)
            task.wait(0.01) 
            Input.Click()
            task.wait(0.02)
        else
            Input.SetHold(true)
        end
    end
end)

return true