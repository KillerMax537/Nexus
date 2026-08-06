-- src/Core/UILibrary.lua
local Library = {}
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function Library:CreateWindow(title, subtitle)
    local old = CoreGui:FindFirstChild("NexusEliteHub")
    if old then old:Destroy() end

    local Window = { Tabs = {}, CurrentTab = nil, IsVisible = true }

    local sg = Instance.new("ScreenGui")
    sg.Name = "NexusEliteHub"
    sg.ResetOnSpawn = false
    sg.Parent = CoreGui

    -- Esconder/Mostrar com a tecla RightControl
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.RightControl then
            Window.IsVisible = not Window.IsVisible
            sg.Enabled = Window.IsVisible
        end
    end)

    -- Janela Principal (Inicia invisível e menor para a Animação de Intro)
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 480, 0, 300)
    Main.Position = UDim2.new(0.5, -240, 0.5, -150)
    Main.BackgroundColor3 = Color3.fromRGB(12, 14, 19)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.Size = UDim2.new(0, 0, 0, 0) -- Estado inicial para a animação
    Main.Parent = sg

    local MainCorner = Instance.new("UICorner", Main)
    MainCorner.CornerRadius = UDim.new(0, 10)

    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(70, 90, 255)
    Stroke.Thickness = 1.5
    Stroke.Transparency = 0.3

    -- ANIMAÇÃO DE INTRODUÇÃO (Abertura suave estilo Hub Premium)
    task.spawn(function()
        task.wait(0.1)
        TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 500, 0, 320)
        }):Play()
    end)

    -- Header (Barra Superior para Arrastar)
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundColor3 = Color3.fromRGB(9, 11, 15)
    Header.BorderSizePixel = 0

    local TitleLbl = Instance.new("TextLabel", Header)
    TitleLbl.Size = UDim2.new(1, -20, 1, 0)
    TitleLbl.Position = UDim2.new(0, 18, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = string.format("<b>%s</b> <font color='#6482FF'>%s</font> <font color='#444'>|</font> <font color='#888'>[Right-Ctrl to Toggle]</font>", title, subtitle)
    TitleLbl.RichText = true
    TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLbl.Font = Enum.Font.Gotham
    TitleLbl.TextSize = 13
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Lógica de Arrastar Hub
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

    -- Corpo do Hub (Sidebar + Páginas)
    local Body = Instance.new("Frame", Main)
    Body.Size = UDim2.new(1, 0, 1, -45)
    Body.Position = UDim2.new(0, 0, 0, 45)
    Body.BackgroundTransparency = 1

    local Sidebar = Instance.new("Frame", Body)
    Sidebar.Size = UDim2.new(0, 145, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(10, 12, 16)
    Sidebar.BorderSizePixel = 0

    local TabContainer = Instance.new("ScrollingFrame", Sidebar)
    TabContainer.Size = UDim2.new(1, 0, 1, -10)
    TabContainer.Position = UDim2.new(0, 0, 0, 10)
    TabContainer.BackgroundTransparency = 1
    TabContainer.ScrollBarThickness = 0
    local TabListLayout = Instance.new("UIListLayout", TabContainer)
    TabListLayout.Padding = UDim.new(0, 6)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local Pages = Instance.new("Frame", Body)
    Pages.Size = UDim2.new(1, -145, 1, 0)
    Pages.Position = UDim2.new(0, 145, 0, 0)
    Pages.BackgroundTransparency = 1

    function Window:CreateTab(name)
        local Tab = {}
        
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(1, -16, 0, 36)
        TabBtn.BackgroundColor3 = Color3.fromRGB(15, 18, 24)
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(140, 145, 165)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local Page = Instance.new("ScrollingFrame", Pages)
        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.new(0, 10, 0, 10)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Color3.fromRGB(100, 120, 255)
        Page.Visible = false

        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab == Tab then return end
            if Window.CurrentTab then
                TweenService:Create(Window.CurrentTab.Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15, 18, 24), TextColor3 = Color3.fromRGB(140, 145, 165)}):Play()
                Window.CurrentTab.Page.Visible = false
            end
            Window.CurrentTab = Tab
            Tab.Page.Visible = true
            TweenService:Create(Tab.Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(70, 90, 255), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
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
            local BtnFrame = Instance.new("TextButton", Page)
            BtnFrame.Size = UDim2.new(1, 0, 0, 38)
            BtnFrame.BackgroundColor3 = Color3.fromRGB(28, 32, 42)
            BtnFrame.Text = text
            BtnFrame.TextColor3 = Color3.fromRGB(220, 225, 235)
            BtnFrame.Font = Enum.Font.GothamMedium
            BtnFrame.TextSize = 13
            Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 6)

            BtnFrame.MouseEnter:Connect(function() TweenService:Create(BtnFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(38, 42, 55)}):Play() end)
            BtnFrame.MouseLeave:Connect(function() TweenService:Create(BtnFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28, 32, 42)}):Play() end)

            BtnFrame.MouseButton1Click:Connect(function()
                local fx = TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(70, 90, 255)})
                fx:Play(); fx.Completed:Wait()
                TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 32, 42)}):Play()
                callback()
            end)
        end

        return Tab
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