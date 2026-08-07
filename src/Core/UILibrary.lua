-- Arquivo: src/Core/UILibrary.lua
local Library = {}
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function Library:CreateWindow(title)
    local env = getgenv and getgenv() or shared
    local old = CoreGui:FindFirstChild("NexusABDHub")
    if old then old:Destroy() end

    local Window = { Tabs = {}, CurrentTab = nil, IsVisible = true }

    local sg = Instance.new("ScreenGui")
    sg.Name = "NexusABDHub"
    sg.ResetOnSpawn = false
    sg.Parent = CoreGui

    -- Botão Flutuante (Toggle)
    local ToggleBtn = Instance.new("TextButton", sg)
    ToggleBtn.Size = UDim2.new(0, 40, 0, 40)
    ToggleBtn.Position = UDim2.new(0.5, -20, 0, 15)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
    ToggleBtn.Text = "N"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 18
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", ToggleBtn).Color = Color3.fromRGB(110, 80, 255)
    
    local tbDragging, tbStartPos, tbStartInput
    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            tbDragging = true; tbStartPos = ToggleBtn.Position; tbStartInput = input.Position
        end
    end)
    ToggleBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            tbDragging = false
            if (input.Position - tbStartInput).Magnitude < 5 then
                Window.IsVisible = not Window.IsVisible
                Window.Main.Visible = Window.IsVisible
            end
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if tbDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - tbStartInput
            ToggleBtn.Position = UDim2.new(tbStartPos.X.Scale, tbStartPos.X.Offset + delta.X, tbStartPos.Y.Scale, tbStartPos.Y.Offset + delta.Y)
        end
    end)

    -- Janela Principal
    local Main = Instance.new("Frame", sg)
    Main.Size = UDim2.new(0, 600, 0, 380)
    Main.Position = UDim2.new(0.5, -300, 0.5, -190)
    Main.BackgroundColor3 = Color3.fromRGB(12, 12, 17)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Window.Main = Main

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", Main).Color = Color3.fromRGB(40, 40, 55)

    -- Header
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Color3.fromRGB(8, 8, 12)
    
    local TitleLbl = Instance.new("TextLabel", Header)
    TitleLbl.Size = UDim2.new(1, -20, 1, 0)
    TitleLbl.Position = UDim2.new(0, 20, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = string.format("<b>%s</b> <font color='#6e50ff'>ABD</font>", title)
    TitleLbl.RichText = true
    TitleLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
    TitleLbl.Font = Enum.Font.Gotham
    TitleLbl.TextSize = 16
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    local dragging, dragStart, startPos
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    Header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Sistema de Notificação (Toast)
    local NotifContainer = Instance.new("Frame", sg)
    NotifContainer.Size = UDim2.new(0, 250, 1, -50)
    NotifContainer.Position = UDim2.new(1, -270, 0, 25)
    NotifContainer.BackgroundTransparency = 1
    local NotifLayout = Instance.new("UIListLayout", NotifContainer)
    NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.Padding = UDim.new(0, 10)

    function Window:Notify(text, duration)
        local NFrame = Instance.new("Frame", NotifContainer)
        NFrame.Size = UDim2.new(1, 150, 0, 45)
        NFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
        Instance.new("UICorner", NFrame).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", NFrame).Color = Color3.fromRGB(110, 80, 255)

        local NLbl = Instance.new("TextLabel", NFrame)
        NLbl.Size = UDim2.new(1, -20, 1, 0)
        NLbl.Position = UDim2.new(0, 10, 0, 0)
        NLbl.BackgroundTransparency = 1
        NLbl.Text = text
        NLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
        NLbl.Font = Enum.Font.GothamMedium
        NLbl.TextSize = 12
        NLbl.TextWrapped = true
        NLbl.TextXAlignment = Enum.TextXAlignment.Left

        TweenService:Create(NFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(1, 0, 0, 45)}):Play()
        task.delay(duration or 3, function()
            TweenService:Create(NFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1, Size = UDim2.new(1, 150, 0, 45)}):Play()
            task.wait(0.3)
            NFrame:Destroy()
        end)
    end

    env.Nexus.Notify = function(t, d) Window:Notify(t, d) end

    -- Corpo (Sidebar & Páginas)
    local Body = Instance.new("Frame", Main)
    Body.Size = UDim2.new(1, 0, 1, -45)
    Body.Position = UDim2.new(0, 0, 0, 45)
    Body.BackgroundTransparency = 1

    local Sidebar = Instance.new("Frame", Body)
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(9, 9, 13)
    Sidebar.BorderSizePixel = 0
    
    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, 0, 1, -10)
    TabContainer.Position = UDim2.new(0, 0, 0, 10)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    local TabListLayout = Instance.new("UIListLayout", TabContainer)
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local Pages = Instance.new("Frame", Body)
    Pages.Size = UDim2.new(1, -160, 1, 0)
    Pages.Position = UDim2.new(0, 160, 0, 0)
    Pages.BackgroundTransparency = 1

    function Window:CreateTab(name, icon)
        local Tab = {}
        
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(1, -20, 0, 36)
        TabBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 17)
        TabBtn.Text = (icon and icon .. "  " or "") .. name
        TabBtn.TextColor3 = Color3.fromRGB(120, 120, 130)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
        
        local Padding = Instance.new("UIPadding", TabBtn)
        Padding.PaddingLeft = UDim.new(0, 12)

        local Page = Instance.new("ScrollingFrame", Pages)
        Page.Size = UDim2.new(1, -30, 1, -30)
        Page.Position = UDim2.new(0, 15, 0, 15)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Color3.fromRGB(110, 80, 255)
        Page.Visible = false

        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 10)
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab == Tab then return end
            if Window.CurrentTab then
                Window.CurrentTab.Btn.BackgroundColor3 = Color3.fromRGB(12, 12, 17)
                Window.CurrentTab.Btn.TextColor3 = Color3.fromRGB(120, 120, 130)
                Window.CurrentTab.Page.Visible = false
            end
            Window.CurrentTab = Tab
            Tab.Page.Visible = true
            Tab.Btn.BackgroundColor3 = Color3.fromRGB(110, 80, 255)
            Tab.Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        Tab.Btn = TabBtn
        Tab.Page = Page
        table.insert(Window.Tabs, Tab)

        -- [ MÉTODO 1: ADICIONAR TOGGLES ]
        function Tab:AddToggle(text, state, callback)
            local Frame = Instance.new("Frame", Page)
            Frame.Size = UDim2.new(1, 0, 0, 45)
            Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

            local Lbl = Instance.new("TextLabel", Frame)
            Lbl.Size = UDim2.new(1, -70, 1, 0)
            Lbl.Position = UDim2.new(0, 15, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = text
            Lbl.TextColor3 = Color3.fromRGB(220, 220, 220)
            Lbl.Font = Enum.Font.GothamMedium
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left

            local Switch = Instance.new("TextButton", Frame)
            Switch.Size = UDim2.new(0, 44, 0, 22)
            Switch.Position = UDim2.new(1, -55, 0.5, -11)
            Switch.BackgroundColor3 = state and Color3.fromRGB(110, 80, 255) or Color3.fromRGB(35, 35, 45)
            Switch.Text = ""
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

            local Dot = Instance.new("Frame", Switch)
            Dot.Size = UDim2.new(0, 16, 0, 16)
            Dot.Position = state and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3)
            Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

            local isEnabled = state
            Switch.MouseButton1Click:Connect(function()
                isEnabled = not isEnabled
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = isEnabled and Color3.fromRGB(110, 80, 255) or Color3.fromRGB(35, 35, 45)}):Play()
                TweenService:Create(Dot, TweenInfo.new(0.2), {Position = isEnabled and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3)}):Play()
                callback(isEnabled)
            end)
        end

        -- [ MÉTODO 2: ADICIONAR BOTÕES (CORRIGIDO) ]
        function Tab:AddButton(text, callback)
            local Frame = Instance.new("Frame", Page)
            Frame.Size = UDim2.new(1, 0, 0, 40)
            Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

            local Btn = Instance.new("TextButton", Frame)
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.BackgroundTransparency = 1
            Btn.Text = text
            Btn.TextColor3 = Color3.fromRGB(220, 220, 220)
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 13

            -- Efeitos Hover & Click
            Btn.MouseEnter:Connect(function()
                TweenService:Create(Frame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 35)}):Play()
            end)
            Btn.MouseLeave:Connect(function()
                TweenService:Create(Frame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(18, 18, 24)}):Play()
            end)
            
            Btn.MouseButton1Click:Connect(function()
                local fx = TweenService:Create(Frame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(110, 80, 255)})
                fx:Play()
                fx.Completed:Wait()
                TweenService:Create(Frame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(18, 18, 24)}):Play()
                callback()
            end)
        end

        return Tab
    end

    function Window:Init()
        if #Window.Tabs > 0 then
            Window.Tabs[1].Btn.BackgroundColor3 = Color3.fromRGB(110, 80, 255)
            Window.Tabs[1].Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Window.Tabs[1].Page.Visible = true
            Window.CurrentTab = Window.Tabs[1]
        end
    end

    function Window:Destroy()
        sg:Destroy()
    end

    return Window
end

return Library