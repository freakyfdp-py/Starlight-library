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

-- WINDOW OBJECT
local Window = {}
Window.__index = Window

function Window:CreateTab(name)
    local tab = {}
    setmetatable(tab, Tab)
    tab.name = name

    -- Create tab frame inside the window container
    tab.frame = create("Frame", {
        Parent = self.container,
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Visible = false
    })

    -- Layout inside tab
    tab.layout = create("UIListLayout", {Parent = tab.frame, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder})
    tab.padding = create("UIPadding", {Parent = tab.frame, PaddingTop = UDim.new(0,10), PaddingLeft = UDim.new(0,10)})

    table.insert(self.tabs, tab)
    return tab
end

-- TAB OBJECT
local Tab = {}
Tab.__index = Tab

function Tab:CreateSection(name)
    local section = {}
    setmetatable(section, Section)
    section.name = name

    -- Section frame
    section.frame = create("Frame", {
        Parent = self.frame,
        Size = UDim2.new(1,0,0,100),
        BackgroundColor3 = theme.background_color,
        BorderSizePixel = 0
    })

    create("UICorner", {Parent = section.frame, CornerRadius = UDim.new(0, theme.menuRounding)})

    -- Layout inside section
    section.layout = create("UIListLayout", {Parent = section.frame, Padding = UDim.new(0,5), SortOrder = Enum.SortOrder.LayoutOrder})
    section.padding = create("UIPadding", {Parent = section.frame, PaddingTop = UDim.new(0,5), PaddingLeft = UDim.new(0,5)})

    table.insert(self.sections or {}, section)
    return section
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

    -- Layout for tabs
    local container = create("Frame", {
        Parent = frame,
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1
    })

    local win = setmetatable({
        sg = sg,
        frame = frame,
        container = container,
        tabs = {}
    }, Window)

    return win
end

-- Expose theme
module.set_theme = function(newTheme)
    for k,v in pairs(newTheme) do
        theme[k] = v
    end
end

return module
