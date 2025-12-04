-- Starry Night UI Library 2025
local module = {}

local theme = {
    background_color = Color3.fromRGB(10, 20, 60), -- deep night blue
    accent_color = Color3.fromRGB(85, 170, 255),
    text_color = Color3.fromRGB(230, 230, 255),
    muted_text = Color3.fromRGB(150,150,200),
    menuRounding = 10,
    hover_color = Color3.fromRGB(50, 80, 150)
}

-- Helper to create UI instances
local function create(class, props)
    local obj = Instance.new(class)
    for k,v in pairs(props) do
        obj[k] = v
    end
    return obj
end

-- SECTION OBJECT
local Section = {}
Section.__index = Section

function Section:CreateButton(text, callback)
    local btn = create("TextButton", {
        Parent = self.frame,
        Size = UDim2.new(1,-10,0,30),
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = theme.text_color,
        BackgroundColor3 = theme.accent_color,
        BorderSizePixel = 0
    })
    create("UICorner",{Parent=btn, CornerRadius=UDim.new(0,theme.menuRounding)})
    btn.MouseEnter:Connect(function() btn.BackgroundColor3 = theme.hover_color end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3 = theme.accent_color end)
    if callback then btn.MouseButton1Click:Connect(callback) end
    return btn
end

function Section:CreateLabel(text)
    local lbl = create("TextLabel", {
        Parent = self.frame,
        Size = UDim2.new(1,-10,0,25),
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = theme.text_color,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    return lbl
end

function Section:CreateToggle(text, callback)
    local state=false
    local frame = create("Frame",{Parent=self.frame,Size=UDim2.new(1,-10,0,30),BackgroundTransparency=1})
    local btn = create("TextButton",{Parent=frame,Size=UDim2.new(1,0,1,0),Text=text.." : OFF",Font=Enum.Font.Gotham,TextSize=14,TextColor3=theme.text_color,BackgroundColor3=theme.accent_color,BorderSizePixel=0})
    create("UICorner",{Parent=btn,CornerRadius=UDim.new(0,theme.menuRounding)})
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = text.." : "..(state and "ON" or "OFF")
        if callback then callback(state) end
    end)
    btn.MouseEnter:Connect(function() btn.BackgroundColor3=theme.hover_color end)
    btn.MouseLeave:Connect(function() btn.BackgroundColor3=theme.accent_color end)
    return frame
end

function Section:CreateSlider(text,min,max,default,callback)
    local container = create("Frame",{Parent=self.frame,Size=UDim2.new(1,-10,0,50),BackgroundTransparency=1})
    local label = create("TextLabel",{Parent=container,Size=UDim2.new(1,0,0,20),Text=text.." : "..default,Font=Enum.Font.Gotham,TextSize=14,TextColor3=theme.text_color,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left})
    local barBg = create("Frame",{Parent=container,Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,0,25),BackgroundColor3=Color3.fromRGB(50,50,100),BorderSizePixel=0})
    create("UICorner",{Parent=barBg,CornerRadius=UDim.new(0,theme.menuRounding)})
    local barFill = create("Frame",{Parent=barBg,Size=UDim2.new((default-min)/(max-min),0,1,0),BackgroundColor3=theme.accent_color,BorderSizePixel=0})
    create("UICorner",{Parent=barFill,CornerRadius=UDim.new(0,theme.menuRounding)})

    local dragging=false
    barBg.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true end
    end)
    barBg.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end
    end)
    barBg.InputChanged:Connect(function(input)
        if dragging and input.UserInputType==Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X-barBg.AbsolutePosition.X)/barBg.AbsoluteSize.X,0,1)
            barFill.Size = UDim2.new(rel,0,1,0)
            local value = math.floor(min + rel*(max-min))
            label.Text = text.." : "..value
            if callback then callback(value) end
        end
    end)
    return container
end

function Section:CreateTextBox(placeholder,callback)
    local box = create("TextBox",{Parent=self.frame,Size=UDim2.new(1,-10,0,30),Text="",PlaceholderText=placeholder,Font=Enum.Font.Gotham,TextSize=14,TextColor3=theme.text_color,BackgroundColor3=Color3.fromRGB(50,50,100),BorderSizePixel=0})
    create("UICorner",{Parent=box,CornerRadius=UDim.new(0,theme.menuRounding)})
    box.FocusLost:Connect(function(enter) if enter and callback then callback(box.Text) end end)
    return box
end

-- Color Picker
function Section:CreateColorPicker(text, defaultColor, callback)
    local frame = create("Frame",{Parent=self.frame,Size=UDim2.new(1,-10,0,40),BackgroundTransparency=1})
    local label = create("TextLabel",{Parent=frame,Size=UDim2.new(1,0,0,20),Text=text,Font=Enum.Font.Gotham,TextSize=14,TextColor3=theme.text_color,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left})
    local colorBtn = create("TextButton",{Parent=frame,Size=UDim2.new(0,30,0,20),Position=UDim2.new(1,-35,0,20),BackgroundColor3=defaultColor,BorderSizePixel=0,Text=""})
    create("UICorner",{Parent=colorBtn,CornerRadius=UDim.new(0,theme.menuRounding)})

    colorBtn.MouseButton1Click:Connect(function()
        local ColorInput = Instance.new("Color3Value")
        ColorInput.Value = defaultColor
        -- Simple input: open ColorPicker GUI (placeholder)
        -- For real implementation, integrate a full color picker
        if callback then callback(ColorInput.Value) end
    end)
    return frame
end

-- TAB OBJECT
local Tab = {}
Tab.__index = Tab

function Tab:CreateSection(name)
    local section = setmetatable({},Section)
    section.name=name
    section.frame=create("Frame",{Parent=self.frame,Size=UDim2.new(1,0,0,100),BackgroundColor3=theme.background_color,BorderSizePixel=0})
    create("UICorner",{Parent=section.frame,CornerRadius=UDim.new(0,theme.menuRounding)})
    section.layout=create("UIListLayout",{Parent=section.frame,Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder})
    section.padding=create("UIPadding",{Parent=section.frame,PaddingTop=UDim.new(0,5),PaddingLeft=UDim.new(0,5)})
    table.insert(self.sections,section)
    return section
end

-- WINDOW OBJECT
local Window = {}
Window.__index = Window

function Window:CreateTab(name)
    local tab=setmetatable({},Tab)
    tab.name=name
    tab.sections={}
    tab.frame=create("Frame",{Parent=self.container,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Visible=false})

    local tabBtn=create("TextButton",{Parent=self.tabBar,Size=UDim2.new(0,100,1,0),Text=name,Font=Enum.Font.GothamBold,TextSize=14,TextColor3=theme.text_color,BackgroundColor3=theme.accent_color,BorderSizePixel=0})
    create("UICorner",{Parent=tabBtn,CornerRadius=UDim.new(0,theme.menuRounding)})
    tabBtn.MouseEnter:Connect(function() tabBtn.BackgroundColor3=theme.hover_color end)
    tabBtn.MouseLeave:Connect(function() tabBtn.BackgroundColor3=theme.accent_color end)

    tabBtn.MouseButton1Click:Connect(function()
        for _,t in pairs(self.tabs) do t.frame.Visible=false end
        tab.frame.Visible=true
    end)

    table.insert(self.tabs,tab)
    return tab
end

-- Top bar icon for settings menu
local function createSettingsMenu(parent)
    local settingsBtn = create("TextButton",{Parent=parent,Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,5,0,5),Text="⚙",Font=Enum.Font.GothamBold,TextSize=18,TextColor3=theme.text_color,BackgroundColor3=theme.accent_color,BorderSizePixel=0})
    create("UICorner",{Parent=settingsBtn,CornerRadius=UDim.new(0,theme.menuRounding)})
    local menuFrame = create("Frame",{Parent=parent,Size=UDim2.new(0,200,0,200),Position=UDim2.new(0,5,0,40),BackgroundColor3=theme.background_color,Visible=false})
    create("UICorner",{Parent=menuFrame,CornerRadius=UDim.new(0,theme.menuRounding)})
    settingsBtn.MouseButton1Click:Connect(function() menuFrame.Visible=not menuFrame.Visible end)
    return settingsBtn, menuFrame
end

-- LIBRARY INIT
module.init=function(title)
    local sg=create("ScreenGui",{Parent=game.Players.LocalPlayer:WaitForChild("PlayerGui"),ResetOnSpawn=false,Name=title or "StarryNightUI"})
    local frame=create("Frame",{Parent=sg,Size=UDim2.new(0,500,0,400),Position=UDim2.new(0.3,-250,0.3,-200),BackgroundColor3=theme.background_color,BorderSizePixel=0})
    create("UICorner",{Parent=frame,CornerRadius=UDim.new(0,theme.menuRounding)})

    -- Top bar with title + icon
    local topBar=create("Frame",{Parent=frame,Size=UDim2.new(1,0,0,40),BackgroundTransparency=1})
    local titleLabel=create("TextLabel",{Parent=topBar,Size=UDim2.new(1,0,1,0),Text=title or "Starry Night UI",Font=Enum.Font.GothamBold,TextSize=18,TextColor3=theme.text_color,BackgroundTransparency=1})
    local settingsBtn, settingsMenu=createSettingsMenu(topBar)

    local tabBar=create("Frame",{Parent=frame,Size=UDim2.new(1,0,0,40),Position=UDim2.new(0,0,0,40),BackgroundTransparency=1})
    local container=create("Frame",{Parent=frame,Size=UDim2.new(1,0,1,-80),Position=UDim2.new(0,0,0,80),BackgroundTransparency=1})

    return setmetatable({sg=sg,frame=frame,container=container,tabBar=tabBar,tabs={},settingsBtn=settingsBtn,settingsMenu=settingsMenu},Window)
end

module.set_theme=function(newTheme)
    for k,v in pairs(newTheme) do theme[k]=v end
end

return module
