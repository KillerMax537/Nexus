-- Arquivo: src/Core/UILibrary.lua
local Library = {}
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function Library:CreateWindow(title, subtitle)
    -- Limpa a UI antiga se existir
    local old = CoreGui:FindFirstChild("NexusPremiumHub")
    if old then old:Destroy() end

    local Window = { Tabs = {}, CurrentTab = nil }

    local sg = Instance.new("ScreenGui")
    sg.Name = "NexusPremiumHub"
    sg.ResetOnSpawn = false
    sg.Parent = CoreGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 480, 0, 300)
    Main.Position = UDim2.new(0.5, -240, 0.5, -150)
    Main.BackgroundColor3 = Color3.fromRGB(15, 16, 21)
    Main.ClipsDescendants = true
    Main.Parent = sg

    Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
    
    local Stroke = Instance.new("UIStroke", Main)
    Stroke.Color = Color3.fromRGB(45, 50, 75)
    Stroke.Thickness = 1.5

    -- Lógica de arrastar a janela (Dragging)
    local dragging, dragInput, dragStart, startPos
    Main.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    Main.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Barra Lateral (Sidebar)
    local Sidebar = Instance.new("Frame", Main)
    Sidebar.Size = UDim2.new(0, 140, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(11, 12, 16)
    Sidebar.BorderSizePixel = 0

    local TitleLbl = Instance.new("TextLabel", Sidebar)
    TitleLbl.Size = UDim2.new(1, 0, 0, 60)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = string.format("%s <font color='#6478FF'>%s</font>", title, subtitle)
    TitleLbl.RichText = true
    TitleLbl.TextColor3 = Color3.fromRGB(240, 240, 240)
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 16

    local TabContainer = Instance.new("Frame", Sidebar)
    TabContainer.Size = UDim2.new(1, 0, 1, -60)
    TabContainer.Position = UDim2.new(0, 0, 0, 60)
    TabContainer.BackgroundTransparency = 1
    
    local TabListLayout = Instance.new("UIListLayout", TabContainer)
    TabListLayout.Padding = UDim.new(0, 5)
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    -- Container das Páginas
    local Pages = Instance.new("Frame", Main)
    Pages.Size = UDim2.new(1, -140, 1, 0)
    Pages.Position = UDim2.new(0, 140, 0, 0)
    Pages.BackgroundTransparency = 1

    -- Função para Criar Abas
    function Window:CreateTab(name)
        local Tab = {}
        
        -- Botão da Aba na Sidebar
        local TabBtn = Instance.new("TextButton", TabContainer)
        TabBtn.Size = UDim2.new(1, -20, 0, 32)
        TabBtn.BackgroundColor3 = Color3.fromRGB(11, 12, 16)
        TabBtn.Text = name
        TabBtn.TextColor3 = Color3.fromRGB(140, 145, 165)
        TabBtn.Font = Enum.Font.GothamMedium
        TabBtn.TextSize = 13
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        -- Página de conteúdo da Aba
        local Page = Instance.new("CanvasGroup", Pages)
        Page.Size = UDim2.new(1, -20, 1, -30)
        Page.Position = UDim2.new(0, 10, 0, 15)
        Page.BackgroundTransparency = 1
        Page.GroupTransparency = 1
        Page.Visible = false

        local PageLayout = Instance.new("UIListLayout", Page)
        PageLayout.Padding = UDim.new(0, 8)

        -- Lógica de troca de Aba
        TabBtn.MouseButton1Click:Connect(function()
            if Window.CurrentTab == Tab then return end
            
            -- Desativa o antigo
            if Window.CurrentTab then
                TweenService:Create(Window.CurrentTab.Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(11, 12, 16), TextColor3 = Color3.fromRGB(140, 145, 165)}):Play()
                TweenService:Create(Window.CurrentTab.Page, TweenInfo.new(0.2), {GroupTransparency = 1}):Play()
                task.delay(0.2, function() Window.CurrentTab.Page.Visible = false end)
            end

            -- Ativa o novo
            Window.CurrentTab = Tab
            Tab.Page.Visible = true
            TweenService:Create(Tab.Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(100, 120, 255), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
            TweenService:Create(Tab.Page, TweenInfo.new(0.3), {GroupTransparency = 0}):Play()
        end)

        Tab.Btn = TabBtn
        Tab.Page = Page
        table.insert(Window.Tabs, Tab)

        -- ==========================================
        -- COMPONENTES DA ABA (TOGGLES E BOTÕES)
        -- ==========================================

        -- Criar Toggles (Interruptores ON/OFF)
        function Tab:AddToggle(text, state, callback)
            local ToggleFrame = Instance.new("Frame", Page)
            ToggleFrame.Size = UDim2.new(1, 0, 0, 40)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)

            local Lbl = Instance.new("TextLabel", ToggleFrame)
            Lbl.Size = UDim2.new(1, -70, 1, 0)
            Lbl.Position = UDim2.new(0, 15, 0, 0)
            Lbl.BackgroundTransparency = 1
            Lbl.Text = text
            Lbl.TextColor3 = Color3.fromRGB(210, 215, 230)
            Lbl.Font = Enum.Font.GothamMedium
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left

            local Switch = Instance.new("TextButton", ToggleFrame)
            Switch.Size = UDim2.new(0, 46, 0, 24)
            Switch.Position = UDim2.new(1, -60, 0.5, -12)
            Switch.BackgroundColor3 = state and Color3.fromRGB(100, 120, 255) or Color3.fromRGB(35, 38, 48)
            Switch.Text = ""
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

            local Dot = Instance.new("Frame", Switch)
            Dot.Size = UDim2.new(0, 18, 0, 18)
            Dot.Position = state and UDim2.new(1, -21, 0, 3) or UDim2.new(0, 3, 0, 3)
            Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", Dot).CornerRadius = UDim.new(1, 0)

            local isEnabled = state
            Switch.MouseButton1Click:Connect(function()
                isEnabled = not isEnabled
                TweenService:Create(Switch, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {BackgroundColor3 = isEnabled and Color3.fromRGB(100, 120, 255) or Color3.fromRGB(35, 38, 48)}):Play()
                TweenService:Create(Dot, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = isEnabled and UDim2.new(1, -21, 0, 3) or UDim2.new(0, 3, 0, 3)}):Play()
                callback(isEnabled)
            end)
        end

        -- Criar Botões Simples (Apenas clique)
        function Tab:AddButton(text, callback)
            local BtnFrame = Instance.new("Frame", Page)
            BtnFrame.Size = UDim2.new(1, 0, 0, 40)
            BtnFrame.BackgroundColor3 = Color3.fromRGB(22, 24, 30)
            Instance.new("UICorner", BtnFrame).CornerRadius = UDim.new(0, 6)

            local ActionBtn = Instance.new("TextButton", BtnFrame)
            ActionBtn.Size = UDim2.new(1, 0, 1, 0)
            ActionBtn.BackgroundTransparency = 1
            ActionBtn.Text = text
            ActionBtn.TextColor3 = Color3.fromRGB(210, 215, 230)
            ActionBtn.Font = Enum.Font.GothamMedium
            ActionBtn.TextSize = 13

            -- Efeitos visuais Premium (Hover)
            ActionBtn.MouseEnter:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 38, 48)}):Play()
            end)
            ActionBtn.MouseLeave:Connect(function()
                TweenService:Create(BtnFrame, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 24, 30)}):Play()
            end)

            -- Clique
            ActionBtn.MouseButton1Click:Connect(function()
                local ripple = TweenService:Create(BtnFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(100, 120, 255)})
                ripple:Play()
                ripple.Completed:Wait()
                TweenService:Create(BtnFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(35, 38, 48)}):Play()
                
                callback()
            end)
        end
        
        return Tab
    end

    -- Inicializa mostrando a primeira Aba
    function Window:Init()
        if #Window.Tabs > 0 then
            local firstTab = Window.Tabs[1]
            firstTab.Btn.BackgroundColor3 = Color3.fromRGB(100, 120, 255)
            firstTab.Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            firstTab.Page.Visible = true
            firstTab.Page.GroupTransparency = 0
            Window.CurrentTab = firstTab
        end
    end

    function Window:Destroy()
        sg:Destroy()
    end

    return Window
end

return Library