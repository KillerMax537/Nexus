local Library = {}
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function Library:CreateWindow(title, subtitle)
    local old = CoreGui:FindFirstChild("NexusPremiumHub")
    if old then old:Destroy() end

    local Window = { Tabs = {}, CurrentTab = nil, IsVisible = true }

    local sg = Instance.new("ScreenGui")
    sg.Name = "NexusPremiumHub"
    sg.ResetOnSpawn = false
    sg.Parent = CoreGui

    -- BOTÃO FLUTUANTE DE ABRIR/FECHAR
    local ToggleButton = Instance.new("TextButton", sg)
    ToggleButton.Size = UDim2.new(0, 45, 0, 45)
    ToggleButton.Position = UDim2.new(0.5, -22, 0, 10)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
    ToggleButton.Text = "🎣"
    ToggleButton.TextSize = 20
    Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", ToggleButton).Color = Color3.fromRGB(70, 90, 255)
    
    -- Lógica de arrastar o botão flutuante
    local tbDragging, tbStart, tbPos
    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            tbDragging = true; tbStart = input.Position; tbPos = ToggleButton.Position
        end
    end)
    ToggleButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then tbDragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and tbDragging then
            local delta = input.Position - tbStart
            ToggleButton.Position = UDim2.new(tbPos.X.Scale, tbPos.X.Offset + delta.X, tbPos.Y.Scale, tbPos.Y.Offset + delta.Y)
        end
    end)

    -- MAIN HUB FRAME
    local Main = Instance.new("Frame", sg)
    Main.Size = UDim2.new(0, 520, 0, 340)
    Main.Position = UDim2.new(0.5, -260, 0.5, -170)
    Main.BackgroundColor3 = Color3.fromRGB(12, 14, 19)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", Main).Color = Color3.fromRGB(40, 45, 60)
    
    local MainScale = Instance.new("UIScale", Main)
    MainScale.Scale = 1

    ToggleButton.MouseButton1Click:Connect(function()
        if not tbDragging then
            Window.IsVisible = not Window.IsVisible
            Main.Visible = Window.IsVisible
        end
    end)

    -- HEADER
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Color3.fromRGB(9, 11, 15)
    
    local TitleLbl = Instance.new("TextLabel", Header)
    TitleLbl.Size = UDim2.new(1, -20, 1, 0)
    TitleLbl.Position = UDim2.new(0, 18, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = string.format("<b>%s</b> <font color='#6482FF'>%s</font>", title, subtitle)
    TitleLbl.RichText = true
    TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLbl.Font = Enum.Font.Gotham
    TitleLbl.TextSize = 14
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
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- CONTAINER DE NOTIFICAÇÕES (Canto Inferior Direito)
    local NotifContainer = Instance.new("Frame", sg)
    NotifContainer.Size = UDim2.new(0, 250, 1, -50)
    NotifContainer.Position = UDim2.new(1, -270, 0, 25)
    NotifContainer.BackgroundTransparency = 1
    local NotifLayout = Instance.new("UIListLayout", NotifContainer)
    NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.Padding = UDim.new(0, 10)

    function Library:Notify(text, duration)
        local NFrame = Instance.new("Frame", NotifContainer)
        NFrame.Size = UDim2.new(1, 200, 0, 45) -- Começa fora da tela
        NFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
        Instance.new("UICorner", NFrame).CornerRadius = UDim.new(0, 6)
        Instance.new("UIStroke", NFrame).Color = Color3.fromRGB(70, 90, 255)

        local NLbl = Instance.new("TextLabel", NFrame)
        NLbl.Size = UDim2.new(1, -15, 1, 0)
        NLbl.Position = UDim2.new(0, 15, 0, 0)
        NLbl.BackgroundTransparency = 1
        NLbl.Text = text
        NLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
        NLbl.Font = Enum.Font.GothamMedium
        NLbl.TextSize = 12
        NLbl.TextWrapped = true
        NLbl.TextXAlignment = Enum.TextXAlignment.Left

        TweenService:Create(NFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Size = UDim2.new(1, 0, 0, 45)}):Play()
        
        task.delay(duration or 3, function()
            TweenService:Create(NFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 200, 0, 45), BackgroundTransparency = 1}):Play()
            task.wait(0.3)
            NFrame:Destroy()
        end)
    end

    -- SIDEBAR & PAGES
    local Body = Instance.new("Frame", Main)
    Body.Size = UDim2.new(1, 0, 1, -45)
    Body.Position = UDim2.new(0, 0, 0, 45)
    Body.BackgroundTransparency = 1

    local Sidebar = Instance.new("Frame", Body)
    Sidebar.Size = UDim2.new(0, 150, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
    
    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, 0, 1, -10)
    TabContainer.Position = UDim2.new(0, 0, 0, 10)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    local TabListLayout = Instance.new("UIListLayout", TabContainer)
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local Pages = Instance.new("Frame", Body)
    Pages.Size = UDim2.new(1, -150, 1, 0)
    Pages.Position = UDim2.new(0, 150, 0, 0)
    Pages.BackgroundTransparency = 1

    function Window:CreateTab(name)
        local Tab = {}
        
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(1, -16, 0, 34)
        TabBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(130, 130, 140)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local Page = Instance.new("ScrollingFrame", Pages)
        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.new(0, 10, 0, 10)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Color3.fromRGB(70, 90, 255)
        Page.Visible = false

        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab == Tab then return end
            if Window.CurrentTab then
                Window.CurrentTab.Btn.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
                Window.CurrentTab.Btn.TextColor3 = Color3.fromRGB(130, 130, 140)
                Window.CurrentTab.Page.Visible = false
            end
            Window.CurrentTab = Tab
            Tab.Page.Visible = true
            Tab.Btn.BackgroundColor3 = Color3.fromRGB(70, 90, 255)
            Tab.Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        Tab.Btn = TabBtn
        Tab.Page = Page
        table.insert(Window.Tabs, Tab)

        function Tab:AddToggle(text, state, callback)
            local Frame = Instance.new("Frame", Page)
            Frame.Size = UDim2.new(1, 0, 0, 42)
            Frame.BackgroundColor3 = Color3.fromRGB(20, 23, 30)
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

            local Lbl = Instance.new("TextLabel", Frame)
            Lbl.Size = UDim2.new(1, -70, 1, 0)
            Lbl.Position = UDim2.new(0, 15, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = text
            Lbl.TextColor3 = Color3.fromRGB(220, 225, 235)
            Lbl.Font = Enum.Font.GothamMedium
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left

            local Switch = Instance.new("TextButton", Frame)
            Switch.Size = UDim2.new(0, 44, 0, 22)
            Switch.Position = UDim2.new(1, -55, 0.5, -11)
            Switch.BackgroundColor3 = state and Color3.fromRGB(70, 90, 255) or Color3.fromRGB(35, 38, 48)
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
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = isEnabled and Color3.fromRGB(70, 90, 255) or Color3.fromRGB(35, 38, 48)}):Play()
                TweenService:Create(Dot, TweenInfo.new(0.2), {Position = isEnabled and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3)}):Play()
                callback(isEnabled)
            end)
        end

        function Tab:AddButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.Size = UDim2.new(1, 0, 0, 38)
            Btn.BackgroundColor3 = Color3.fromRGB(28, 32, 42)
            Btn.Text = text
            Btn.TextColor3 = Color3.fromRGB(220, 225, 235)
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 13
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
            Btn.MouseButton1Click:Connect(callback)
        end

        function Tab:AddSlider(text, min, max, default, callback)
            local Frame = Instance.new("Frame", Page)
            Frame.Size = UDim2.new(1, 0, 0, 50)
            Frame.BackgroundColor3 = Color3.fromRGB(20, 23, 30)
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

            local Lbl = Instance.new("TextLabel", Frame)
            Lbl.Size = UDim2.new(1, -20, 0, 20)
            Lbl.Position = UDim2.new(0, 10, 0, 5)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = text .. ": " .. default
            Lbl.TextColor3 = Color3.fromRGB(220, 225, 235)
            Lbl.Font = Enum.Font.GothamMedium
            Lbl.TextSize = 12
            Lbl.TextXAlignment = Enum.TextXAlignment.Left

            local SliderBg = Instance.new("TextButton", Frame)
            SliderBg.Size = UDim2.new(1, -20, 0, 6)
            SliderBg.Position = UDim2.new(0, 10, 0, 32)
            SliderBg.BackgroundColor3 = Color3.fromRGB(35, 38, 48)
            SliderBg.Text = ""
            Instance.new("UICorner", SliderBg).CornerRadius = UDim.new(1, 0)

            local Fill = Instance.new("Frame", SliderBg)
            Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(70, 90, 255)
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

            local sliding = false
            local function update(input)
                local pos = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                local val = string.format("%.1f", min + ((max - min) * pos))
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                Lbl.Text = text .. ": " .. val
                callback(tonumber(val))
            end

            SliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; update(input) end
            end)
            SliderBg.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement and sliding then update(input) end
            end)
        end

        return Tab
    end

    function Window:SetScale(scale)
        MainScale.Scale = scale
    end

    function Window:Init()
        if #Window.Tabs > 0 then
            Window.Tabs[1].Btn.BackgroundColor3 = Color3.fromRGB(70, 90, 255)
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