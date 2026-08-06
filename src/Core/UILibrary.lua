-- Arquivo: src/Core/UILibrary.lua
local Library = {}
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

function Library:CreateWindow(title, subtitle)
    local env = getgenv and getgenv() or shared
    local old = CoreGui:FindFirstChild("NexusEliteHub")
    if old then old:Destroy() end

    local Window = { Tabs = {}, CurrentTab = nil, IsVisible = true }

    local sg = Instance.new("ScreenGui")
    sg.Name = "NexusEliteHub"
    sg.ResetOnSpawn = false
    sg.Parent = CoreGui

    -- ==========================================
    -- BOTÃO FLUTUANTE DE ABRIR/FECHAR (CORRIGIDO)
    -- ==========================================
    local ToggleBtn = Instance.new("TextButton", sg)
    ToggleBtn.Size = UDim2.new(0, 45, 0, 45)
    ToggleBtn.Position = UDim2.new(0.5, -22, 0, 10)
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
    ToggleBtn.Text = "🎣"
    ToggleBtn.TextSize = 20
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", ToggleBtn).Color = Color3.fromRGB(90, 110, 255)
    
    local tbDragging, tbStartPos, tbStartInput
    ToggleBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tbDragging = true
            tbStartPos = ToggleBtn.Position
            tbStartInput = input.Position
        end
    end)
    ToggleBtn.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            tbDragging = false
            -- Diferencia um clique de um arrasto (se moveu menos de 5 pixels, é clique)
            if (input.Position - tbStartInput).Magnitude < 5 then
                Window.IsVisible = not Window.IsVisible
                Window.Main.Visible = Window.IsVisible
            end
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if tbDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - tbStartInput
            ToggleBtn.Position = UDim2.new(tbStartPos.X.Scale, tbStartPos.X.Offset + delta.X, tbStartPos.Y.Scale, tbStartPos.Y.Offset + delta.Y)
        end
    end)

    -- ==========================================
    -- MAIN WINDOW
    -- ==========================================
    local Main = Instance.new("Frame", sg)
    Main.Size = UDim2.new(0, 550, 0, 350)
    Main.Position = UDim2.new(0.5, -275, 0.5, -175)
    Main.BackgroundColor3 = Color3.fromRGB(12, 13, 18)
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Window.Main = Main

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", Main).Color = Color3.fromRGB(40, 45, 60)

    -- HEADER (Arrastar a Janela)
    local Header = Instance.new("Frame", Main)
    Header.Size = UDim2.new(1, 0, 0, 40)
    Header.BackgroundColor3 = Color3.fromRGB(9, 10, 14)
    
    local TitleLbl = Instance.new("TextLabel", Header)
    TitleLbl.Size = UDim2.new(1, -20, 1, 0)
    TitleLbl.Position = UDim2.new(0, 15, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = string.format("<b>%s</b> <font color='#5A6EFF'>%s</font>", title, subtitle)
    TitleLbl.RichText = true
    TitleLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
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
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- ==========================================
    -- SISTEMA DE REDIMENSIONAMENTO (DRAG TO RESIZE)
    -- ==========================================
    local ResizeGrip = Instance.new("TextButton", Main)
    ResizeGrip.Size = UDim2.new(0, 15, 0, 15)
    ResizeGrip.Position = UDim2.new(1, -15, 1, -15)
    ResizeGrip.BackgroundTransparency = 1
    ResizeGrip.Text = "◢"
    ResizeGrip.TextColor3 = Color3.fromRGB(90, 110, 255)
    ResizeGrip.TextSize = 14
    ResizeGrip.ZIndex = 10

    local resizing, resizeStart, startSize
    ResizeGrip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true; resizeStart = input.Position; startSize = Main.Size
        end
    end)
    ResizeGrip.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then resizing = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - resizeStart
            -- Limites: Min 450x300 | Max 800x600
            local newX = math.clamp(startSize.X.Offset + delta.X, 450, 800)
            local newY = math.clamp(startSize.Y.Offset + delta.Y, 300, 600)
            Main.Size = UDim2.new(0, newX, 0, newY)
        end
    end)

    -- ==========================================
    -- CORPO (SIDEBAR & PAGES)
    -- ==========================================
    local Body = Instance.new("Frame", Main)
    Body.Size = UDim2.new(1, 0, 1, -40)
    Body.Position = UDim2.new(0, 0, 0, 40)
    Body.BackgroundTransparency = 1

    local Sidebar = Instance.new("Frame", Body)
    Sidebar.Size = UDim2.new(0, 140, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(10, 11, 15)
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
    Pages.Size = UDim2.new(1, -140, 1, 0)
    Pages.Position = UDim2.new(0, 140, 0, 0)
    Pages.BackgroundTransparency = 1

    function Window:CreateTab(name)
        local Tab = {}
        
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(1, -16, 0, 32)
        TabBtn.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(130, 135, 150)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local Page = Instance.new("ScrollingFrame", Pages)
        Page.Size = UDim2.new(1, -20, 1, -20)
        Page.Position = UDim2.new(0, 10, 0, 10)
        Page.BackgroundTransparency = 1
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Color3.fromRGB(90, 110, 255)
        Page.Visible = false

        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 8)
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)

        TabBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab == Tab then return end
            if Window.CurrentTab then
                Window.CurrentTab.Btn.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
                Window.CurrentTab.Btn.TextColor3 = Color3.fromRGB(130, 135, 150)
                Window.CurrentTab.Page.Visible = false
            end
            Window.CurrentTab = Tab
            Tab.Page.Visible = true
            Tab.Btn.BackgroundColor3 = Color3.fromRGB(90, 110, 255)
            Tab.Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        Tab.Btn = TabBtn
        Tab.Page = Page
        table.insert(Window.Tabs, Tab)

        -- Toggles
        function Tab:AddToggle(text, state, callback)
            local Frame = Instance.new("Frame", Page)
            Frame.Size = UDim2.new(1, 0, 0, 42)
            Frame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
            Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

            local Lbl = Instance.new("TextLabel", Frame)
            Lbl.Size = UDim2.new(1, -70, 1, 0)
            Lbl.Position = UDim2.new(0, 15, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = text
            Lbl.TextColor3 = Color3.fromRGB(220, 225, 230)
            Lbl.Font = Enum.Font.GothamMedium
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left

            local Switch = Instance.new("TextButton", Frame)
            Switch.Size = UDim2.new(0, 42, 0, 22)
            Switch.Position = UDim2.new(1, -55, 0.5, -11)
            Switch.BackgroundColor3 = state and Color3.fromRGB(90, 110, 255) or Color3.fromRGB(35, 38, 48)
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
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = isEnabled and Color3.fromRGB(90, 110, 255) or Color3.fromRGB(35, 38, 48)}):Play()
                TweenService:Create(Dot, TweenInfo.new(0.2), {Position = isEnabled and UDim2.new(1, -19, 0, 3) or UDim2.new(0, 3, 0, 3)}):Play()
                callback(isEnabled)
            end)
        end

        function Tab:AddButton(text, callback)
            local Btn = Instance.new("TextButton", Page)
            Btn.Size = UDim2.new(1, 0, 0, 38)
            Btn.BackgroundColor3 = Color3.fromRGB(28, 30, 40)
            Btn.Text = text
            Btn.TextColor3 = Color3.fromRGB(220, 225, 230)
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 13
            Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

            Btn.MouseButton1Click:Connect(function()
                local fx = TweenService:Create(Btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(90, 110, 255)})
                fx:Play(); fx.Completed:Wait()
                TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(28, 30, 40)}):Play()
                callback()
            end)
        end

        return Tab
    end

    function Window:Init()
        if #Window.Tabs > 0 then
            Window.Tabs[1].Btn.BackgroundColor3 = Color3.fromRGB(90, 110, 255)
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