-- Starry Night UI Library 2025 (Enhanced)
local module = {}

-- [[ THEME ]] -----------------------------------------------------------------
local theme = {
    background_color = Color3.fromRGB(10, 20, 60), -- Deep night blue
    accent_color = Color3.fromRGB(85, 170, 255),  -- Starry blue
    text_color = Color3.fromRGB(230, 230, 255),   -- White/Pale blue for text
    muted_text = Color3.fromRGB(150, 150, 200),
    menu_rounding = 8,
    hover_color = Color3.fromRGB(50, 80, 150),
    stroke_color = Color3.fromRGB(10, 10, 30),
    padding = 5
}

-- [[ HELPERS ]] ---------------------------------------------------------------

-- Helper to create UI instances
local function create(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props) do
        obj[k] = v
    end
    return obj
end

-- Function to apply button hover logic
local function applyHover(btn, defaultColor, hoverColor)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = hoverColor end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = defaultColor end)
end

-- [[ SECTION OBJECT ]] --------------------------------------------------------
local Section = {}
Section.__index = Section

local UserInputService = game:GetService("UserInputService")
local function updateSectionHeight(section, height)
    section.frame.Size = section.frame.Size + UDim2.new(0, 0, 0, height + theme.padding)
end

function Section:CreateButton(text, callback)
    local btn = create("TextButton", {
        Parent = self.frame,
        Size = UDim2.new(1, -theme.padding*2, 0, 30),
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = theme.text_color,
        BackgroundColor3 = theme.accent_color,
        BorderSizePixel = 0,
        AutoButtonColor = false
    })
    
    create("UICorner",{Parent=btn, CornerRadius=UDim.new(0, theme.menu_rounding)})
    create("UIStroke",{Parent=btn, Thickness=1, Color=theme.stroke_color, ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    
    applyHover(btn, theme.accent_color, theme.hover_color)
    if callback then btn.MouseButton1Click:Connect(callback) end
    
    updateSectionHeight(self, 30)
    return btn
end

function Section:CreateLabel(text)
    local lbl = create("TextLabel", {
        Parent = self.frame,
        Size = UDim2.new(1, -theme.padding*2, 0, 25),
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = theme.muted_text,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    updateSectionHeight(self, 25)
    return lbl
end

function Section:CreateToggle(text, callback)
    local state = false
    local container = create("Frame",{Parent=self.frame,Size=UDim2.new(1,-theme.padding*2,0,30),BackgroundTransparency=1})
    local btn = create("TextButton",{
        Parent=container, Size=UDim2.new(1,0,1,0), TextXAlignment = Enum.TextXAlignment.Left,
        Text = "  " .. text, Font=Enum.Font.Gotham, TextSize=14, TextColor3=theme.text_color,
        BackgroundColor3=Color3.fromRGB(50,50,100), BorderSizePixel=0, AutoButtonColor = false
    })
    
    create("UICorner",{Parent=btn,CornerRadius=UDim.new(0,theme.menu_rounding)})
    create("UIStroke",{Parent=btn, Thickness=1, Color=theme.stroke_color, ApplyStrokeMode=Enum.ApplyStrokeMode.Border})

    local indicator = create("Frame", {
        Parent = btn, Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 10, 0.5, -5),
        BackgroundColor3 = Color3.fromRGB(200, 50, 50), BorderColor3 = theme.stroke_color, BorderSizePixel = 1
    })
    create("UICorner", {Parent=indicator, CornerRadius=UDim.new(0.5, 0)})
    
    local function updateStateVisuals()
        indicator.BackgroundColor3 = state and theme.accent_color or Color3.fromRGB(200, 50, 50)
    end
    updateStateVisuals()
    
    btn.MouseButton1Click:Connect(function()
        state = not state
        updateStateVisuals()
        if callback then callback(state) end
    end)

    applyHover(btn, Color3.fromRGB(50,50,100), theme.hover_color)
    updateSectionHeight(self, 30)
    return container
end

function Section:CreateSlider(text, min, max, default, callback)
    local value = default
    local container = create("Frame",{Parent=self.frame,Size=UDim2.new(1,-theme.padding*2,0,50),BackgroundTransparency=1})
    local label = create("TextLabel",{Parent=container,Size=UDim2.new(1,0,0,20),Text=text.." : "..default,Font=Enum.Font.Gotham,TextSize=14,TextColor3=theme.text_color,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left})
    local barBg = create("Frame",{Parent=container,Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,0,25),BackgroundColor3=Color3.fromRGB(50,50,100),BorderSizePixel=0})
    create("UICorner",{Parent=barBg,CornerRadius=UDim.new(0,theme.menu_rounding)})
    local barFill = create("Frame",{Parent=barBg,Size=UDim2.new((default-min)/(max-min),0,1,0),BackgroundColor3=theme.accent_color,BorderSizePixel=0})
    create("UICorner",{Parent=barFill,CornerRadius=UDim.new(0,theme.menu_rounding)})

    local dragging=false
    local function updateValue(rel)
        barFill.Size = UDim2.new(rel,0,1,0)
        value = math.floor(min + rel*(max-min))
        label.Text = text.." : "..value
        if callback then callback(value) end
    end
    
    local function onInput(input)
        local rel = math.clamp((input.Position.X-barBg.AbsolutePosition.X)/barBg.AbsoluteSize.X,0,1)
        updateValue(rel)
    end

    barBg.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; onInput(input) end
    end)
    barBg.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
            onInput(input)
        end
    end)
    
    updateSectionHeight(self, 50)
    return container
end

function Section:CreateTextBox(placeholder,callback)
    local box = create("TextBox",{
        Parent=self.frame,
        Size=UDim2.new(1,-theme.padding*2,0,30),
        Text="", PlaceholderText=placeholder, Font=Enum.Font.Gotham, TextSize=14,
        TextColor3=theme.text_color, BackgroundColor3=Color3.fromRGB(50,50,100), BorderSizePixel=0,
        TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center, TextPadding = UDim.new(0, 10)
    })
    create("UICorner",{Parent=box,CornerRadius=UDim.new(0,theme.menu_rounding)})
    create("UIStroke",{Parent=box, Thickness=1, Color=theme.stroke_color, ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    box.FocusLost:Connect(function(enter) if enter and callback then callback(box.Text) end end)
    
    updateSectionHeight(self, 30)
    return box
end

function Section:CreateColorPicker(text, defaultColor, callback)
    local frame = create("Frame",{Parent=self.frame,Size=UDim2.new(1,-theme.padding*2,0,40),BackgroundTransparency=1})
    local label = create("TextLabel",{Parent=frame,Size=UDim2.new(1,0,0,20),Text=text,Font=Enum.Font.Gotham,TextSize=14,TextColor3=theme.text_color,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left})
    local colorBtn = create("TextButton",{Parent=frame,Size=UDim2.new(0,30,0,20),Position=UDim2.new(1,-35,0,20),BackgroundColor3=defaultColor,BorderSizePixel=0,Text="", AutoButtonColor=false})
    create("UICorner",{Parent=colorBtn,CornerRadius=UDim.new(0,theme.menu_rounding)})
    
    -- Placeholder for actual color picker logic
    colorBtn.MouseButton1Click:Connect(function()
        local ColorInput = Instance.new("Color3Value")
        ColorInput.Value = colorBtn.BackgroundColor3
        -- In a real environment, you'd open a color picker GUI here
        -- For this example, we simulate a change
        local newColor = Color3.fromRGB(math.random(0,255), math.random(0,255), math.random(0,255))
        colorBtn.BackgroundColor3 = newColor
        if callback then callback(newColor) end
    end)
    
    updateSectionHeight(self, 40)
    return frame
end

function Section:CreateKeybind(text, defaultKey, callback)
    local bind = {
        Key = defaultKey or "None",
        Mode = "Hold" -- Default mode: Hold
    }
    
    local isListening = false
    
    -- Container Frame
    local container = create("Frame",{Parent=self.frame, Size=UDim2.new(1,-theme.padding*2,0,30), BackgroundTransparency=1})
    local mainFrame = container.Parent.Parent.Parent -- Reference to the main window Frame

    -- Main Button (Displays Key and initiates binding)
    local keyBtn = create("TextButton",{
        Parent=container, Size=UDim2.new(1,0,1,0), TextXAlignment = Enum.TextXAlignment.Left,
        Text = text.." ["..bind.Key.."] ("..bind.Mode..")", Font=Enum.Font.Gotham,
        TextSize=14, TextColor3=theme.text_color, BackgroundColor3=Color3.fromRGB(50,50,100),
        BorderSizePixel=0, AutoButtonColor = false
    })
    
    create("UICorner",{Parent=keyBtn,CornerRadius=UDim.new(0,theme.menu_rounding)})
    create("UIStroke",{Parent=keyBtn, Thickness=1, Color=theme.stroke_color, ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    applyHover(keyBtn, Color3.fromRGB(50,50,100), theme.hover_color)

    local function updateText()
        keyBtn.Text = text.." ["..bind.Key.."] ("..bind.Mode..")"
    end

    -- === KEY BINDING LOGIC ===
    local function finishBinding(input)
        local keyName
        if input.UserInputType ~= Enum.UserInputType.Keyboard then
            keyName = input.UserInputType.Name -- Captures MouseButton1, MouseButton2, etc.
        else
            keyName = input.KeyCode.Name
        end

        if keyName == "Escape" or keyName == "Return" then
            bind.Key = "None"
        elseif keyName == "Unknown" then
            return 
        else
            bind.Key = keyName
        end

        keyBtn.BackgroundColor3 = Color3.fromRGB(50,50,100)
        isListening = false
        updateText()
    end
    
    keyBtn.MouseButton1Click:Connect(function()
        if not isListening then
            isListening = true
            keyBtn.Text = text.." [PRESS KEY...]"
            keyBtn.BackgroundColor3 = theme.accent_color
        end
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if isListening and not gameProcessed then
            finishBinding(input)
        end
    end)

    -- === TOGGLE/HOLD CONTEXT MENU (RIGHT CLICK) ===
    local menu = create("Frame",{
        Parent = mainFrame, -- Parent to the main window for proper positioning
        Size = UDim2.new(0,100,0,60),
        BackgroundColor3 = theme.background_color,
        Visible = false,
        ZIndex = 3
    })
    create("UICorner",{Parent=menu, CornerRadius=UDim.new(0,theme.menu_rounding)})
    create("UIStroke",{Parent=menu, Thickness=1, Color=theme.stroke_color, ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    local layout = create("UIListLayout",{Parent=menu, Padding=UDim.new(0,2), SortOrder=Enum.SortOrder.LayoutOrder, HorizontalAlignment=Enum.HorizontalAlignment.Center})
    create("UIPadding",{Parent=menu, PaddingAll=UDim.new(0,5)})
    
    local function createMenuItem(menuText, mode)
        local item = create("TextButton",{
            Parent=menu, Size=UDim2.new(1,0,0,20), Text=menuText, TextSize=12,
            TextColor3=theme.text_color, BackgroundColor3=Color3.fromRGB(30,40,80), AutoButtonColor=false
        })
        applyHover(item, Color3.fromRGB(30,40,80), theme.hover_color)
        item.MouseButton1Click:Connect(function()
            bind.Mode = mode
            updateText()
            menu.Visible = false
        end)
    end
    
    createMenuItem("Set to Toggle", "Toggle")
    createMenuItem("Set to Hold", "Hold")
    
    keyBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton2 then -- Right Click
            -- Position the menu relative to the mouse location
            local mouseLoc = UserInputService:GetMouseLocation()
            menu.Position = UDim2.new(0, mouseLoc.X, 0, mouseLoc.Y)
            menu.Visible = true
            input:Cancel() -- Consume the right-click event
        end
    end)
    
    -- Close menu when clicking away (or right-clicking again)
    UserInputService.InputBegan:Connect(function(input)
        if menu.Visible and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2) then
            -- Check if the click was outside the menu
            if not menu:IsA("GuiObject") or not menu:GetChildren()[1]:IsA("GuiObject") or not menu:GetChildren()[1]:GetAbsolutePosition().X then
                -- Fallback check for safe closing
                menu.Visible = false
                return
            end

            local mouseLoc = UserInputService:GetMouseLocation()
            local menuAbs = menu.AbsolutePosition
            local menuSize = menu.AbsoluteSize
            
            if mouseLoc.X < menuAbs.X or mouseLoc.X > menuAbs.X + menuSize.X or
               mouseLoc.Y < menuAbs.Y or mouseLoc.Y > menuAbs.Y + menuSize.Y then
                menu.Visible = false
            end
        end
    end)
    
    updateSectionHeight(self, 30)
    
    -- Return the bind state and updater for external logic
    return {
        Key = bind.Key,
        Mode = bind.Mode,
        Update = updateText
    }
end

-- [[ TAB OBJECT ]] ------------------------------------------------------------
local Tab = {}
Tab.__index = Tab

function Tab:CreateSection(name)
    local section = setmetatable({},Section)
    section.name=name
    section.frame=create("Frame",{Parent=self.frame,Size=UDim2.new(1,0,0,10),BackgroundColor3=theme.background_color,BorderSizePixel=0})
    
    create("TextLabel",{
        Parent=section.frame, Size=UDim2.new(1,0,0,20), Text=name,
        Font=Enum.Font.GothamBold, TextSize=16, TextColor3=theme.accent_color,
        BackgroundTransparency=1, TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, theme.padding, 0, 0)
    })
    
    create("UICorner",{Parent=section.frame,CornerRadius=UDim.new(0,theme.menu_rounding)})
    create("UIStroke",{Parent=section.frame, Thickness=1, Color=theme.stroke_color, ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    
    section.layout=create("UIListLayout",{
        Parent=section.frame, Padding=UDim.new(0, theme.padding), SortOrder=Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center, FillDirection = Enum.FillDirection.Vertical
    })
    
    section.padding=create("UIPadding",{
        Parent=section.frame, PaddingTop=UDim.new(0,25), PaddingLeft=UDim.new(0,theme.padding),
        PaddingRight=UDim.new(0,theme.padding), PaddingBottom=UDim.new(0,theme.padding)
    })
    
    section.frame.Size = UDim2.new(1, 0, 0, 25 + theme.padding)
    table.insert(self.sections,section)
    return section
end

-- [[ WINDOW OBJECT ]] ---------------------------------------------------------
local Window = {}
Window.__index = Window

function Window:CreateTab(name)
    local tab=setmetatable({},Tab)
    tab.name=name
    tab.sections={}
    
    tab.frame=create("Frame",{
        Parent=self.container, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Visible=false
    })
    
    create("UIListLayout", {
        Parent = tab.frame, Padding = UDim.new(0, theme.padding), SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center, FillDirection = Enum.FillDirection.Vertical
    })
    
    local tabBtn=create("TextButton",{
        Parent=self.tabBar, Size=UDim2.new(0,100,1,0), Text=name, Font=Enum.Font.GothamBold,
        TextSize=14, TextColor3=theme.text_color, BackgroundColor3=theme.accent_color,
        BorderSizePixel=0, AutoButtonColor = false
    })
    
    create("UICorner",{Parent=tabBtn,CornerRadius=UDim.new(0,theme.menu_rounding)})
    applyHover(tabBtn, theme.accent_color, theme.hover_color)

    tabBtn.MouseButton1Click:Connect(function()
        for _,t in pairs(self.tabs) do t.frame.Visible=false end
        tab.frame.Visible=true
    end)

    table.insert(self.tabs,tab)
    return tab
end

-- Top bar icon for settings menu
local function createSettingsMenu(parent)
    local settingsBtn = create("TextButton",{Parent=parent,Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,theme.padding,0,theme.padding/2),Text="⚙",Font=Enum.Font.GothamBold,TextSize=18,TextColor3=theme.text_color,BackgroundColor3=theme.accent_color,BorderSizePixel=0, AutoButtonColor=false})
    create("UICorner",{Parent=settingsBtn,CornerRadius=UDim.new(0,theme.menu_rounding)})
    applyHover(settingsBtn, theme.accent_color, theme.hover_color)
    
    local menuFrame = create("Frame",{Parent=parent,Size=UDim2.new(0,200,0,200),Position=UDim2.new(0,theme.padding,0,40),BackgroundColor3=theme.background_color,Visible=false})
    create("UICorner",{Parent=menuFrame,CornerRadius=UDim.new(0,theme.menu_rounding)})
    create("UIStroke",{Parent=menuFrame, Thickness=1, Color=theme.stroke_color, ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
    
    settingsBtn.MouseButton1Click:Connect(function() menuFrame.Visible=not menuFrame.Visible end)
    return settingsBtn, menuFrame
end

-- [[ LIBRARY INIT ]] ----------------------------------------------------------
module.init=function(title)
    local sg=create("ScreenGui",{Parent=game.Players.LocalPlayer:WaitForChild("PlayerGui"),ResetOnSpawn=false,Name=title or "StarryNightUI"})
    local frame=create("Frame",{Parent=sg,Size=UDim2.new(0,500,0,400),Position=UDim2.new(0.5,-250,0.5,-200),BackgroundColor3=theme.background_color,BorderSizePixel=0, Active=true})
    
    create("UICorner",{Parent=frame,CornerRadius=UDim.new(0,theme.menu_rounding)})
    create("UIStroke",{Parent=frame, Thickness=2, Color=theme.stroke_color, ApplyStrokeMode=Enum.ApplyStrokeMode.Border})

    -- Top bar with title + icon (Used for dragging)
    local topBar=create("Frame",{Parent=frame,Size=UDim2.new(1,0,0,40),BackgroundTransparency=1, Active=true})
    
    -- Dragging Logic
    local drag = false
    local lastInput = nil
    local dragStart = Vector2.new(0, 0)
    
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true
            lastInput = input
            dragStart = input.Position - frame.AbsolutePosition
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == lastInput and drag then
            local newPos = input.Position - dragStart
            frame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
        end
    end)
    topBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = false
            lastInput = nil
        end
    end)


    local titleLabel=create("TextLabel",{Parent=topBar,Size=UDim2.new(1,0,1,0),Text=title or "Starry Night UI",Font=Enum.Font.GothamBold,TextSize=18,TextColor3=theme.text_color,BackgroundTransparency=1})
    local settingsBtn, settingsMenu=createSettingsMenu(topBar)

    local tabBar=create("Frame",{Parent=frame,Size=UDim2.new(1,0,0,40),Position=UDim2.new(0,0,0,40),BackgroundTransparency=1})
    
    create("UIListLayout",{Parent=tabBar, Padding=UDim.new(0,theme.padding), SortOrder=Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Left, VerticalAlignment = Enum.VerticalAlignment.Center})
    create("UIPadding",{Parent=tabBar, PaddingLeft=UDim.new(0,theme.padding), PaddingRight=UDim.new(0,theme.padding)})
    
    local container=create("Frame",{Parent=frame,Size=UDim2.new(1,0,1,-80),Position=UDim2.new(0,0,0,80),BackgroundTransparency=1})
    create("UIPadding",{Parent=container, PaddingAll=UDim.new(0,theme.padding)})
    
    return setmetatable({sg=sg,frame=frame,container=container,tabBar=tabBar,tabs={},settingsBtn=settingsBtn,settingsMenu=settingsMenu},Window)
end

module.set_theme=function(newTheme)
    for k,v in pairs(newTheme) do theme[k]=v end
end

return module