--[[
    KetamineUI Library
    A custom UI library with the Ketamine theme.
    
    Usage:
        local Library = loadstring(game:HttpGet("YOUR_RAW_LINK"))()
        
        local Window = Library:CreateWindow({
            Name = "My Script",
            Subtitle = "v1.0",
            Size = UDim2.new(0, 380, 0, 500), -- optional
            ToggleKey = Enum.KeyCode.RightControl -- optional
        })
        
        local Tab = Window:CreateTab("Main")
        
        Tab:CreateSection("Combat")
        
        Tab:CreateToggle({
            Name = "Aimbot",
            Default = false,
            Callback = function(value) end
        })
        
        Tab:CreateSlider({
            Name = "FOV Radius",
            Min = 50,
            Max = 800,
            Default = 200,
            Callback = function(value) end
        })
        
        Tab:CreateButton({
            Name = "Reset Character",
            Callback = function() end
        })
        
        Tab:CreateDropdown({
            Name = "Target Part",
            Options = {"Head", "HumanoidRootPart", "UpperTorso"},
            Default = "Head",
            Callback = function(value) end
        })
        
        Tab:CreateTextbox({
            Name = "Player Name",
            Default = "",
            Placeholder = "Enter name...",
            Callback = function(value) end
        })
        
        Tab:CreateLabel("Status: Active")
        
        -- Update elements:
        toggle:Set(true)
        slider:Set(150)
        dropdown:Set("Head")
        label:Set("Status: Inactive")
        
        -- Notifications:
        Library:Notify({
            Title = "Success",
            Text = "Feature enabled!",
            Duration = 3
        })
        
        -- Destroy:
        Library:Destroy()
]]

local Library = {}
Library.__index = Library

----------------------------------------------------------------------
-- Services
----------------------------------------------------------------------
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local LocalPlayer      = Players.LocalPlayer

----------------------------------------------------------------------
-- Theme
----------------------------------------------------------------------
Library.Theme = {
    Accent    = Color3.fromRGB(155, 89, 255),
    AccentDim = Color3.fromRGB(100, 55, 190),
    BG        = Color3.fromRGB(14, 10, 22),
    BG2       = Color3.fromRGB(22, 16, 35),
    BG3       = Color3.fromRGB(32, 24, 52),
    Text      = Color3.fromRGB(230, 220, 250),
    TextDim   = Color3.fromRGB(120, 100, 160),
    On        = Color3.fromRGB(140, 100, 255),
    Off       = Color3.fromRGB(60, 45, 85),
    Error     = Color3.fromRGB(180, 60, 120),
    Success   = Color3.fromRGB(100, 220, 140),
    Warning   = Color3.fromRGB(255, 180, 80),
}

----------------------------------------------------------------------
-- Utility
----------------------------------------------------------------------
local function tween(obj, props, dur)
    local t = TweenService:Create(obj, TweenInfo.new(dur or 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
    t:Play()
    return t
end

local function create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            obj[k] = v
        end
    end
    if props.Parent then
        obj.Parent = props.Parent
    end
    return obj
end

local function addCorner(parent, radius)
    return create("UICorner", {CornerRadius = UDim.new(0, radius or 8), Parent = parent})
end

local function addStroke(parent, color, thickness, transparency)
    return create("UIStroke", {
        Color = color or Library.Theme.Accent,
        Thickness = thickness or 1.5,
        Transparency = transparency or 0.3,
        Parent = parent
    })
end

local function addPadding(parent, l, r, t, b)
    return create("UIPadding", {
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        Parent = parent
    })
end

----------------------------------------------------------------------
-- Library:CreateWindow
----------------------------------------------------------------------
function Library:CreateWindow(config)
    config = config or {}
    local T = self.Theme
    local windowName = config.Name or "Ketamine UI"
    local subtitle = config.Subtitle or ""
    local windowSize = config.Size or UDim2.new(0, 380, 0, 500)
    local toggleKey = config.ToggleKey or Enum.KeyCode.RightControl

    local Window = {}
    Window.Tabs = {}
    Window.ActiveTab = nil

    -- ScreenGui
    local ScreenGui = create("ScreenGui", {
        Name = "KetamineUI_" .. windowName,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })
    pcall(function() ScreenGui.Parent = game:GetService("CoreGui") end)
    if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    Window.ScreenGui = ScreenGui

    -- Main Frame
    local MainFrame = create("Frame", {
        Name = "Main",
        Size = windowSize,
        Position = UDim2.new(0.5, -windowSize.X.Offset/2, 0.5, -windowSize.Y.Offset/2),
        BackgroundColor3 = T.BG,
        BorderSizePixel = 0,
        Active = true,
        Draggable = true,
        Parent = ScreenGui
    })
    addCorner(MainFrame, 14)
    addStroke(MainFrame, T.Accent, 1.5, 0.3)
    Window.MainFrame = MainFrame

    -- Title Bar
    local TitleBar = create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = T.BG2,
        BorderSizePixel = 0,
        Parent = MainFrame
    })
    addCorner(TitleBar, 14)
    -- Bottom clip to remove bottom rounding
    create("Frame", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 1, -14),
        BackgroundColor3 = T.BG2,
        BorderSizePixel = 0,
        Parent = TitleBar
    })

    -- Title text
    create("TextLabel", {
        Size = UDim2.new(1, -100, 0, 22),
        Position = UDim2.new(0, 16, 0, subtitle ~= "" and 6 or 13),
        BackgroundTransparency = 1,
        Text = windowName,
        TextColor3 = T.Accent,
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = TitleBar
    })

    -- Subtitle
    if subtitle ~= "" then
        create("TextLabel", {
            Size = UDim2.new(1, -100, 0, 14),
            Position = UDim2.new(0, 16, 0, 28),
            BackgroundTransparency = 1,
            Text = subtitle,
            TextColor3 = T.TextDim,
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = TitleBar
        })
    end

    -- Close button
    local CloseBtn = create("TextButton", {
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(1, -30, 0, 5),
        BackgroundColor3 = T.Error,
        Text = "X",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
        Parent = TitleBar
    })
    addCorner(CloseBtn, 6)
    CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, {BackgroundColor3 = Color3.fromRGB(220, 80, 140)}, 0.15) end)
    CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, {BackgroundColor3 = T.Error}, 0.15) end)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    -- Minimize button
    local MinBtn = create("TextButton", {
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(1, -56, 0, 5),
        BackgroundColor3 = T.BG3,
        Text = "-",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        AutoButtonColor = false,
        Parent = TitleBar
    })
    addCorner(MinBtn, 6)
    MinBtn.MouseEnter:Connect(function() tween(MinBtn, {BackgroundColor3 = T.AccentDim}, 0.15) end)
    MinBtn.MouseLeave:Connect(function() tween(MinBtn, {BackgroundColor3 = T.BG3}, 0.15) end)

    -- Content area (below title bar)
    local ContentArea = create("Frame", {
        Size = UDim2.new(1, 0, 1, -48),
        Position = UDim2.new(0, 0, 0, 48),
        BackgroundTransparency = 1,
        Parent = MainFrame
    })
    Window.ContentArea = ContentArea

    -- Tab bar
    local TabBar = create("Frame", {
        Size = UDim2.new(1, -16, 0, 30),
        Position = UDim2.new(0, 8, 0, 6),
        BackgroundTransparency = 1,
        Parent = ContentArea
    })
    local TabLayout = create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = TabBar
    })
    Window.TabBar = TabBar

    -- Tab content container
    local TabContainer = create("Frame", {
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = ContentArea
    })
    Window.TabContainer = TabContainer

    -- Minimize logic
    local minimized = false
    MinBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        ContentArea.Visible = not minimized
        tween(MainFrame, {Size = minimized and UDim2.new(0, windowSize.X.Offset, 0, 48) or windowSize}, 0.3)
    end)

    -- Toggle visibility
    local guiVisible = true
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if input.KeyCode == toggleKey then
            guiVisible = not guiVisible
            MainFrame.Visible = guiVisible
        end
    end)

    -- Switch tab function
    function Window:SwitchTab(tabName)
        for name, tab in pairs(self.Tabs) do
            tab.Page.Visible = (name == tabName)
            if tab.Button then
                local active = (name == tabName)
                tween(tab.Button, {
                    BackgroundColor3 = active and T.Accent or T.BG3,
                    TextColor3 = active and Color3.new(1,1,1) or T.TextDim
                }, 0.2)
            end
        end
        self.ActiveTab = tabName
    end

    -- CreateTab
    function Window:CreateTab(name)
        local Tab = {}
        Tab.Name = name
        Tab.Order = 0

        -- Tab button
        local tabBtn = create("TextButton", {
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = T.BG3,
            Text = "  " .. name .. "  ",
            TextColor3 = T.TextDim,
            Font = Enum.Font.GothamBold,
            TextSize = 12,
            AutoButtonColor = false,
            Parent = TabBar
        })
        addCorner(tabBtn, 6)
        addPadding(tabBtn, 8, 8, 0, 0)
        Tab.Button = tabBtn

        -- Tab page (scrolling frame)
        local page = create("ScrollingFrame", {
            Size = UDim2.new(1, -8, 1, -4),
            Position = UDim2.new(0, 4, 0, 2),
            BackgroundTransparency = 1,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = T.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = TabContainer
        })
        create("UIListLayout", {
            Padding = UDim.new(0, 5),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = page
        })
        addPadding(page, 4, 4, 4, 4)
        Tab.Page = page

        self.Tabs[name] = Tab

        tabBtn.MouseEnter:Connect(function()
            if self.ActiveTab ~= name then
                tween(tabBtn, {BackgroundColor3 = T.AccentDim}, 0.15)
            end
        end)
        tabBtn.MouseLeave:Connect(function()
            if self.ActiveTab ~= name then
                tween(tabBtn, {BackgroundColor3 = T.BG3}, 0.15)
            end
        end)
        tabBtn.MouseButton1Click:Connect(function()
            self:SwitchTab(name)
        end)

        -- Auto-select first tab
        if not self.ActiveTab then
            self:SwitchTab(name)
        end

        -- CreateSection
        function Tab:CreateSection(sectionName)
            Tab.Order = Tab.Order + 1
            create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 24),
                BackgroundTransparency = 1,
                Text = "  " .. sectionName:upper(),
                TextColor3 = T.Accent,
                Font = Enum.Font.GothamBold,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = Tab.Order,
                Parent = page
            })
        end

        -- CreateToggle
        function Tab:CreateToggle(opts)
            opts = opts or {}
            Tab.Order = Tab.Order + 1
            local value = opts.Default or false
            local callback = opts.Callback or function() end

            local card = create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = T.BG2,
                BorderSizePixel = 0,
                LayoutOrder = Tab.Order,
                Parent = page
            })
            addCorner(card, 8)

            create("TextLabel", {
                Size = UDim2.new(1, -60, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = opts.Name or "Toggle",
                TextColor3 = T.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = card
            })

            local togBG = create("Frame", {
                Size = UDim2.new(0, 40, 0, 20),
                Position = UDim2.new(1, -50, 0.5, -10),
                BackgroundColor3 = value and T.On or T.Off,
                Parent = card
            })
            addCorner(togBG, 10)

            local knob = create("Frame", {
                Size = UDim2.new(0, 16, 0, 16),
                Position = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8),
                BackgroundColor3 = Color3.new(1, 1, 1),
                Parent = togBG
            })
            addCorner(knob, 8)

            local btn = create("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                Parent = card
            })

            btn.MouseEnter:Connect(function() tween(card, {BackgroundColor3 = T.BG3}, 0.15) end)
            btn.MouseLeave:Connect(function() tween(card, {BackgroundColor3 = T.BG2}, 0.15) end)

            btn.MouseButton1Click:Connect(function()
                value = not value
                tween(togBG, {BackgroundColor3 = value and T.On or T.Off}, 0.2)
                tween(knob, {Position = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
                callback(value)
            end)

            local toggleObj = {}
            function toggleObj:Set(v)
                value = v
                tween(togBG, {BackgroundColor3 = value and T.On or T.Off}, 0.2)
                tween(knob, {Position = value and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)}, 0.2)
                callback(value)
            end
            function toggleObj:Get() return value end
            return toggleObj
        end

        -- CreateSlider
        function Tab:CreateSlider(opts)
            opts = opts or {}
            Tab.Order = Tab.Order + 1
            local min = opts.Min or 0
            local max = opts.Max or 100
            local value = opts.Default or min
            local callback = opts.Callback or function() end

            local card = create("Frame", {
                Size = UDim2.new(1, 0, 0, 50),
                BackgroundColor3 = T.BG2,
                BorderSizePixel = 0,
                LayoutOrder = Tab.Order,
                Parent = page
            })
            addCorner(card, 8)

            create("TextLabel", {
                Size = UDim2.new(1, -50, 0, 18),
                Position = UDim2.new(0, 12, 0, 6),
                BackgroundTransparency = 1,
                Text = opts.Name or "Slider",
                TextColor3 = T.Text,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = card
            })

            local valLbl = create("TextLabel", {
                Size = UDim2.new(0, 40, 0, 18),
                Position = UDim2.new(1, -50, 0, 6),
                BackgroundTransparency = 1,
                Text = tostring(value),
                TextColor3 = T.Accent,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                Parent = card
            })

            local track = create("Frame", {
                Size = UDim2.new(1, -24, 0, 6),
                Position = UDim2.new(0, 12, 0, 32),
                BackgroundColor3 = T.BG3,
                Parent = card
            })
            addCorner(track, 3)

            local pct = (value - min) / (max - min)
            local fill = create("Frame", {
                Size = UDim2.new(pct, 0, 1, 0),
                BackgroundColor3 = T.Accent,
                Parent = track
            })
            addCorner(fill, 3)

            local hitbox = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 24),
                Position = UDim2.new(0, 0, 0, 22),
                BackgroundTransparency = 1,
                Text = "",
                Parent = card
            })

            local dragging = false
            hitbox.MouseButton1Down:Connect(function() dragging = true end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            RunService.RenderStepped:Connect(function()
                if dragging then
                    local mx = UserInputService:GetMouseLocation().X
                    local ax = track.AbsolutePosition.X
                    local aw = track.AbsoluteSize.X
                    local p = math.clamp((mx - ax) / aw, 0, 1)
                    local val = math.floor(min + p * (max - min))
                    if val ~= value then
                        value = val
                        fill.Size = UDim2.new(p, 0, 1, 0)
                        valLbl.Text = tostring(val)
                        callback(val)
                    end
                end
            end)

            local sliderObj = {}
            function sliderObj:Set(v)
                value = math.clamp(v, min, max)
                local p = (value - min) / (max - min)
                fill.Size = UDim2.new(p, 0, 1, 0)
                valLbl.Text = tostring(value)
                callback(value)
            end
            function sliderObj:Get() return value end
            return sliderObj
        end

        -- CreateButton
        function Tab:CreateButton(opts)
            opts = opts or {}
            Tab.Order = Tab.Order + 1
            local callback = opts.Callback or function() end

            local btn = create("TextButton", {
                Size = UDim2.new(1, 0, 0, 34),
                BackgroundColor3 = T.BG3,
                Text = opts.Name or "Button",
                TextColor3 = T.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                AutoButtonColor = false,
                LayoutOrder = Tab.Order,
                Parent = page
            })
            addCorner(btn, 8)

            btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = T.AccentDim}, 0.15) end)
            btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = T.BG3}, 0.15) end)
            btn.MouseButton1Click:Connect(function()
                tween(btn, {BackgroundColor3 = T.Accent}, 0.1)
                task.delay(0.15, function() tween(btn, {BackgroundColor3 = T.BG3}, 0.2) end)
                callback()
            end)

            return btn
        end

        -- CreateDropdown
        function Tab:CreateDropdown(opts)
            opts = opts or {}
            Tab.Order = Tab.Order + 1
            local options = opts.Options or {}
            local value = opts.Default or (options[1] or "")
            local callback = opts.Callback or function() end
            local open = false

            local card = create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = T.BG2,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                LayoutOrder = Tab.Order,
                Parent = page
            })
            addCorner(card, 8)

            create("TextLabel", {
                Size = UDim2.new(0.5, -10, 0, 36),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = opts.Name or "Dropdown",
                TextColor3 = T.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = card
            })

            local selected = create("TextButton", {
                Size = UDim2.new(0.45, 0, 0, 26),
                Position = UDim2.new(0.52, 0, 0, 5),
                BackgroundColor3 = T.BG3,
                Text = value,
                TextColor3 = T.Accent,
                Font = Enum.Font.GothamBold,
                TextSize = 12,
                AutoButtonColor = false,
                Parent = card
            })
            addCorner(selected, 6)

            local optContainer = create("Frame", {
                Size = UDim2.new(0.45, 0, 0, 0),
                Position = UDim2.new(0.52, 0, 0, 34),
                BackgroundColor3 = T.BG3,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Parent = card
            })
            addCorner(optContainer, 6)
            local optLayout = create("UIListLayout", {
                Padding = UDim.new(0, 1),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = optContainer
            })

            local optButtons = {}
            for i, opt in ipairs(options) do
                local ob = create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundColor3 = T.BG2,
                    Text = opt,
                    TextColor3 = T.Text,
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    AutoButtonColor = false,
                    LayoutOrder = i,
                    Parent = optContainer
                })
                ob.MouseEnter:Connect(function() tween(ob, {BackgroundColor3 = T.AccentDim}, 0.1) end)
                ob.MouseLeave:Connect(function() tween(ob, {BackgroundColor3 = T.BG2}, 0.1) end)
                ob.MouseButton1Click:Connect(function()
                    value = opt
                    selected.Text = opt
                    open = false
                    local closedH = 36
                    tween(card, {Size = UDim2.new(1, 0, 0, closedH)}, 0.2)
                    tween(optContainer, {Size = UDim2.new(0.45, 0, 0, 0)}, 0.2)
                    callback(value)
                end)
                table.insert(optButtons, ob)
            end

            selected.MouseButton1Click:Connect(function()
                open = not open
                local optH = #options * 25
                local cardH = open and (36 + optH + 4) or 36
                tween(card, {Size = UDim2.new(1, 0, 0, cardH)}, 0.25)
                tween(optContainer, {Size = UDim2.new(0.45, 0, 0, open and optH or 0)}, 0.25)
            end)

            local dropObj = {}
            function dropObj:Set(v)
                value = v
                selected.Text = v
                callback(v)
            end
            function dropObj:Get() return value end
            function dropObj:Refresh(newOptions)
                for _, ob in ipairs(optButtons) do ob:Destroy() end
                optButtons = {}
                options = newOptions
                for i, opt in ipairs(options) do
                    local ob = create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 24),
                        BackgroundColor3 = T.BG2,
                        Text = opt,
                        TextColor3 = T.Text,
                        Font = Enum.Font.Gotham,
                        TextSize = 11,
                        AutoButtonColor = false,
                        LayoutOrder = i,
                        Parent = optContainer
                    })
                    ob.MouseEnter:Connect(function() tween(ob, {BackgroundColor3 = T.AccentDim}, 0.1) end)
                    ob.MouseLeave:Connect(function() tween(ob, {BackgroundColor3 = T.BG2}, 0.1) end)
                    ob.MouseButton1Click:Connect(function()
                        value = opt
                        selected.Text = opt
                        open = false
                        tween(card, {Size = UDim2.new(1, 0, 0, 36)}, 0.2)
                        tween(optContainer, {Size = UDim2.new(0.45, 0, 0, 0)}, 0.2)
                        callback(value)
                    end)
                    table.insert(optButtons, ob)
                end
            end
            return dropObj
        end

        -- CreateTextbox
        function Tab:CreateTextbox(opts)
            opts = opts or {}
            Tab.Order = Tab.Order + 1
            local value = opts.Default or ""
            local callback = opts.Callback or function() end

            local card = create("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundColor3 = T.BG2,
                BorderSizePixel = 0,
                LayoutOrder = Tab.Order,
                Parent = page
            })
            addCorner(card, 8)

            create("TextLabel", {
                Size = UDim2.new(0.4, 0, 1, 0),
                Position = UDim2.new(0, 12, 0, 0),
                BackgroundTransparency = 1,
                Text = opts.Name or "Input",
                TextColor3 = T.Text,
                Font = Enum.Font.Gotham,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = card
            })

            local box = create("TextBox", {
                Size = UDim2.new(0.5, -10, 0, 26),
                Position = UDim2.new(0.48, 0, 0.5, -13),
                BackgroundColor3 = T.BG3,
                Text = value,
                PlaceholderText = opts.Placeholder or "...",
                PlaceholderColor3 = T.TextDim,
                TextColor3 = T.Text,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                ClearTextOnFocus = false,
                Parent = card
            })
            addCorner(box, 6)
            addPadding(box, 8, 8, 0, 0)

            box.FocusLost:Connect(function(enter)
                if enter then
                    value = box.Text
                    callback(value)
                end
            end)

            local tbObj = {}
            function tbObj:Set(v)
                value = v
                box.Text = v
                callback(v)
            end
            function tbObj:Get() return value end
            return tbObj
        end

        -- CreateLabel
        function Tab:CreateLabel(text)
            Tab.Order = Tab.Order + 1
            local lbl = create("TextLabel", {
                Size = UDim2.new(1, 0, 0, 28),
                BackgroundColor3 = T.BG2,
                BorderSizePixel = 0,
                Text = "  " .. (text or ""),
                TextColor3 = T.TextDim,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = Tab.Order,
                Parent = page
            })
            addCorner(lbl, 8)

            local labelObj = {}
            function labelObj:Set(newText)
                lbl.Text = "  " .. newText
            end
            return labelObj
        end

        return Tab
    end

    -- Notify
    function Window:Notify(opts)
        Library:Notify(opts)
    end

    -- Destroy
    function Window:Destroy()
        ScreenGui:Destroy()
    end

    return Window
end

----------------------------------------------------------------------
-- Library:Notify
----------------------------------------------------------------------
function Library:Notify(opts)
    opts = opts or {}
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = opts.Title or "KetamineUI",
            Text = opts.Text or "",
            Duration = opts.Duration or 3
        })
    end)
end

----------------------------------------------------------------------
-- Library:Destroy
----------------------------------------------------------------------
function Library:Destroy()
    for _, gui in ipairs(game:GetService("CoreGui"):GetChildren()) do
        if gui.Name:find("KetamineUI_") then
            gui:Destroy()
        end
    end
end

return Library
