-- ═══════════════════════════════════════════════════════════
-- TZEUI PRO - EXAMPLE SCRIPT
-- ═══════════════════════════════════════════════════════════
local TzeUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/jonathabejose-alt/Tze-ui/refs/heads/main/source.lua"))()

local ui = TzeUI:CreateWindow({
    Title = "TzeUI Pro Demo",
    Author = "tze",
    Size = UDim2.fromOffset(640, 460),
})

-- Tabs
local home = ui:Tab({ Title = "Home" })
local elements = ui:Tab({ Title = "Elements" })

-- Home
home:Paragraph({
    Title = "Welcome to TzeUI Pro",
    Desc = "Glassmorphism UI Library\nMade by tze",
})
home:Divider()
home:Button({
    Title = "Click Me",
    Desc = "This is a button with description",
    Callback = function()
        ui:Notify("Button clicked!")
    end,
})

-- Elements
local sec = elements:Section({ Title = "Controls", Desc = "All elements", Box = true })

sec:Toggle({
    Title = "Enable Feature",
    Value = false,
    Callback = function(v)
        ui:Notify(v and "ON" or "OFF")
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
    Values = { "Easy", "Normal", "Hard" },
    Value = "Normal",
    Callback = function(v) end,
})

sec:Input({
    Title = "Username",
    Placeholder = "Type here...",
    Callback = function(v) end,
})

sec:Divider()

sec:Button({
    Title = "Save Settings",
    Callback = function()
        ui:Notify("Saved!")
    end,
})

-- Notify
ui:Notify("TzeUI Pro ready!")
