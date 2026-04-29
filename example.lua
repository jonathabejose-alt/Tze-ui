-- ============================================
-- TZEUI EXAMPLE SCRIPT
-- ============================================
local TzeUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/jonathabejose-alt/Tze-ui/refs/heads/main/source.lua"))()

local ui = TzeUI:CreateWindow({
    Title = "TzeUI Demo",
    Author = "tze",
    Size = UDim2.fromOffset(680, 480),
    Watermark = { Enabled = true, Text = "TzeUI v1" },
})

-- Sidebar
ui:SideBarLabel({ Title = "Quick Actions" })
ui:SideBarButton({ Title = "Discord", Callback = function()
    ui:Notify({ Title = "Discord", Content = "Copied!", Icon = "check", Duration = 3 })
end })
ui:SideBarDivider()

-- Tabs
local home = ui:Tab({ Title = "Home" })
local elements = ui:Tab({ Title = "Elements" })

-- Home Tab
home:Paragraph({
    Title = "Welcome to TzeUI",
    Desc = "A modern dark UI library made from scratch.\nSupports sections, toggles, sliders, dropdowns & more.",
})

home:Stats({
    Title = "Info",
    Items = {
        { Key = "Library", Value = "TzeUI" },
        { Key = "Author", Value = "tze" },
        { Key = "Version", Value = "v1" },
    },
})

-- Elements Tab
local sec = elements:Section({ Title = "Controls", Desc = "All available elements.", Box = true })

sec:Toggle({
    Title = "Enable Feature",
    Value = false,
    Callback = function(v) print("Toggle:", v) end,
})

sec:Button({
    Title = "Click Me",
    Desc = "This is a button.",
    Callback = function()
        ui:Notify({ Title = "Clicked!", Content = "Button works!", Icon = "check" })
    end,
})

sec:Slider({
    Title = "Volume",
    Value = { Min = 0, Max = 100, Default = 50 },
    Suffix = "%",
    Callback = function(v) end,
})

sec:Dropdown({
    Title = "Mode",
    Value = "Easy",
    Values = { "Easy", "Medium", "Hard" },
    Callback = function(v) end,
})

sec:Input({
    Title = "Username",
    Placeholder = "Type here...",
    Callback = function(v) end,
})

-- Notify
ui:Notify({ Title = "TzeUI", Content = "Loaded successfully!", Icon = "check", Duration = 4 })
