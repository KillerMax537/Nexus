-- Arquivo: src/Tabs/Logs.lua
local Nexus = getgenv().Nexus
local Window = Nexus.Window

local Tab = Window:CreateTab("Console Logs")

local Scroll = Instance.new("ScrollingFrame", Tab.Page)
Scroll.Size = UDim2.new(1, 0, 1, 0)
Scroll.BackgroundTransparency = 1
Scroll.ScrollBarThickness = 3
Scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 120, 255)

local Layout = Instance.new("UIListLayout", Scroll)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Scroll.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y)
end)

-- Sistema de notificação global anexado ao Nexus
Nexus.Log = function(msg)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.format("[%s] %s", os.date("%H:%M:%S"), msg)
    lbl.TextColor3 = Color3.fromRGB(160, 170, 200)
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = Scroll
    
    task.delay(0.05, function() Scroll.CanvasPosition = Vector2.new(0, 99999) end)
end

return true