-- Library made in 2025
local module = {}

-- Theme table for colors and styling
local theme = {
    background_color = Color3.fromRGB(15, 25, 105),
    text_color = Color3.fromRGB(255, 255, 255),
    menuRounding = 8 -- rounding in pixels
}

-- Initialize the UI library with a main frame
module.init = function(title)
    -- Create ScreenGui
    module.sg = Instance.new("ScreenGui")
    module.sg.Name = title or "CustomUILibrary"
    module.sg.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
    module.sg.ResetOnSpawn = false

    -- Create main frame
    local frame = Instance.new("Frame")
    frame.Parent = module.sg
    frame.Position = UDim2.new(0.3, -250, 0.3, -200) -- centered-ish
    frame.Size = UDim2.new(0, 500, 0, 400)
    frame.BackgroundColor3 = theme.background_color
    frame.BorderSizePixel = 0

    -- Optional: rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, theme.menuRounding)
    corner.Parent = frame

    module.frame = frame
    return frame
end

-- Function to draw text labels
-- parent: Frame or ScreenGui
-- text: string
-- x, y: pixel position relative to parent
-- text_color: optional Color3
local function draw_text(parent, text, x, y, text_color)
    local textElement = Instance.new("TextLabel")
    textElement.Parent = parent
    textElement.Position = UDim2.new(0, x, 0, y)
    textElement.Size = UDim2.new(0, 200, 0, 30)
    textElement.Text = text
    textElement.TextColor3 = text_color or theme.text_color
    textElement.BackgroundTransparency = 1
    textElement.Font = Enum.Font.Arcade
    textElement.TextSize = 16
    textElement.TextXAlignment = Enum.TextXAlignment.Left
    return textElement
end

-- Function to draw a button
-- parent: Frame
-- text: string
-- callback: function to run on click
local function draw_button(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = parent
    btn.Size = UDim2.new(0, 200, 0, 40)
    btn.Position = UDim2.new(0, 0, 0, 0) -- adjust later or use layout
    btn.Text = text
    btn.Font = Enum.Font.Arcade
    btn.TextSize = 16
    btn.TextColor3 = theme.text_color
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.BorderSizePixel = 0

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, theme.menuRounding)
    corner.Parent = btn

    if callback then
        btn.MouseButton1Click:Connect(callback)
    end

    return btn
end

-- Optional: helper to change theme dynamically
function module.set_theme(newTheme)
    for k,v in pairs(newTheme) do
        theme[k] = v
    end
    if module.frame then
        module.frame.BackgroundColor3 = theme.background_color
    end
end

-- Expose helper functions
module.draw_text = draw_text
module.draw_button = draw_button

return module
