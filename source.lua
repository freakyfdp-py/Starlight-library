-- Library made in 2025
local module = {}

local theme = {
    background_color = Color3.fromRGB(15, 25, 105),
    accent_color = Color3.fromRGB(0, 170, 255),
    text_color = Color3.fromRGB(255, 255, 255),
    menuRounding = 8
}

-- Base helper to create UI elements
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
        Size = UDim2.new(1, -10, 0, 30),
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = theme.text_color,
        BackgroundColor3 = theme.accent_color,
        BorderSizePixel = 0
    })
    create("UICorner", {Parent = btn, CornerRadius = UDim.new(0, theme.menuRounding)})

    if callback then
        btn.MouseButton1Click:Connect(callback)
    end
    return btn
end

function Section:CreateLabel(text)
    local lbl = create("TextLabel", {
        Parent = self.frame,
        Size = UDim2.new(1, -10, 0, 25),
        Text = text,
        Font = Enum.Font.Gotham,
        TextSize = 14,
        TextColor3 = theme.text_color,
        BackgroundTransparency = 1,
        TextXAlignment = Enum.TextXAlignment.Left
    })
    return lbl
end

-- TAB OBJECT
local Tab = {}
Tab.__index = Tab

function Tab:CreateSection(name)
    local section = setmetatable({}, Section)
    section.name = name

    section.frame = create("Frame", {
        Parent = self.frame,
        Size = UDim2.new(1,0,0,100),
        BackgroundColor3 = theme.background_color,
        BorderSizePixel = 0
    })
    create("UICorner", {Parent = section.frame, CornerRadius = UDim.new(0, theme.menuRounding)})

    section.layout = create("UIListLayout", {Parent = section.frame, Padding = UDim.new(0,5), SortOrder = Enum.SortOrder.LayoutOrder})
    section.padding = create("UIPadding", {Parent = section.frame, PaddingTop = UDim.new(0,5), PaddingLeft = UDim.new(0,5)})

    table.insert(self.sections, section)
    return section
end

-- WINDOW OBJECT
local Window = {}
Window.__index = Window

function Window:CreateTab(name)
    local tab = setmetatable({}, Tab)
    tab.name = name
    tab.sections = {}

    -- Create tab frame
    tab.frame = create("Frame", {
        Parent = self.container,
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Visible = false
    })

    -- Create tab button
    local tabBtn = create("TextButton", {
        Parent = self.tabBar,
        Size = UDim2.new(0, 100, 1, 0),
        Text = name,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = theme.text_color,
        BackgroundColor3 = theme.accent_color,
        BorderSizePixel = 0
    })
    create("UICorner", {Parent = tabBtn, CornerRadius = UDim.new(0, theme.menuRounding)})

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(self.tabs) do
            t.frame.Visible = false
        end
        tab.frame.Visible = true
    end)

    table.insert(self.tabs, tab)
    return tab
end

-- LIBRARY INIT
module.init = function(title)
    local sg = create("ScreenGui", {Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui"), ResetOnSpawn = false, Name = title or "CustomUILibrary"})

    -- Main window frame
    local frame = create("Frame", {
        Parent = sg,
        Size = UDim2.new(0, 500, 0, 400),
        Position = UDim2.new(0.3, -250, 0.3, -200),
        BackgroundColor3 = theme.background_color,
        BorderSizePixel = 0
    })
    create("UICorner", {Parent = frame, CornerRadius = UDim.new(0, theme.menuRounding)})

    -- Tab bar at the top
    local tabBar = create("Frame", {
        Parent = frame,
        Size = UDim2.new(1,0,0,40),
        Position = UDim2.new(0,0,0,0),
        BackgroundTransparency = 1
    })

    local windowContainer = create("Frame", {
        Parent = frame,
        Size = UDim2.new(1,0,1,-40),
        Position = UDim2.new(0,0,0,40),
        BackgroundTransparency = 1
    })

    local win = setmetatable({
        sg = sg,
        frame = frame,
        container = windowContainer,
        tabBar = tabBar,
        tabs = {}
    }, Window)

    return win
end

-- Theme setter
module.set_theme = function(newTheme)
    for k,v in pairs(newTheme) do
        theme[k] = v
    end
end

return module
