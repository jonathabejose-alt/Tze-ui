
-- ============================================
-- TZEUI EXAMPLE SCRIPT
-- ============================================
local source = game:HttpGet("https://raw.githubusercontent.com/jonathabejose-alt/Tze-ui/refs/heads/main/source.lua")
local TzeUI = loadstring(source)()

local ui = TzeUI:CreateWindow({
    Title = "TzeUI Example",
    Author = "tze",
    Size = UDim2.fromOffset(700, 500),
    Watermark = { Text = "TzeUI v1 | Example" },
})

-- ============================================
-- SIDEBAR
-- ============================================
ui:SideBarLabel({ Title = "Quick Actions" })
ui:SideBarButton({ Title = "Discord", Callback = function()
    setclipboard("discord.gg/example")
    ui:Notify({ Title = "Discord", Content = "Invite copied!", Icon = "check", Duration = 3 })
end })
ui:SideBarButton({ Title = "GitHub", Callback = function()
    setclipboard("https://github.com/example")
    ui:Notify({ Title = "GitHub", Content = "Link copied!", Icon = "link", Duration = 3 })
end })
ui:SideBarDivider()
ui:SideBarLabel({ Title = "Info" })
ui:SideBarButton({ Title = "Made by tze" })

-- ============================================
-- TAGS
-- ============================================
ui:Tag({ Title = "v1.0", Color = Color3.fromRGB(99, 102, 241) })
ui:Tag({ Title = "Beta", Color = Color3.fromRGB(251, 146, 60) })

-- ============================================
-- OPEN BUTTON
-- ============================================
ui:OpenButton({
    Title = "TzeUI",
    Position = UDim2.new(0, 120, 0, 120),
    Draggable = true,
})

-- ============================================
-- BIND SHORTCUT
-- ============================================
ui:BindShortcut("RightAlt", function() ui:Toggle() end)

-- ============================================
-- TABS
-- ============================================
local homeTab = ui:Tab({ Title = "Home" })
local combatTab = ui:Tab({ Title = "Combat" })
local visualsTab = ui:Tab({ Title = "Visuals" })
local settingsTab = ui:Tab({ Title = "Settings" })

-- ============================================
-- HOME TAB
-- ============================================
homeTab:Paragraph({
    Title = "Welcome to TzeUI",
    Desc = "This is a custom UI library made from scratch.\nAll elements are built with pure Roblox Instances.",
    Buttons = {
        { Title = "Copy Discord", Callback = function()
            setclipboard("discord.gg/example")
            ui:Notify({ Title = "Done", Content = "Copied!", Icon = "check" })
        end },
        { Title = "GitHub", Callback = function()
            setclipboard("https://github.com/example")
            ui:Notify({ Title = "Done", Content = "Link copied!", Icon = "link" })
        end },
    },
})

homeTab:Divider()

homeTab:Stats({
    Title = "Session Info",
    Items = {
        { Key = "Library", Value = "TzeUI" },
        { Key = "Version", Value = "1.0" },
        { Key = "Author", Value = "tze" },
        { Key = "FPS", Value = "60" },
    },
})

homeTab:Divider()

homeTab:Code({
    Title = "Loader",
    Code = [[loadstring(game:HttpGet("https://raw.githubusercontent.com/tu-repo/TzeUI/main/source.lua"))()]],
    OnCopy = function()
        ui:Notify({ Title = "Copied", Content = "Loader ready!", Icon = "copy" })
    end,
})

-- ============================================
-- COMBAT TAB
-- ============================================
local combatSection = combatTab:Section({
    Title = "Aimbot",
    Desc = "Target selection and lock.",
    Icon = "crosshair",
    Box = true,
    BoxBorder = true,
})

local aimbotEnabled = false
combatSection:Toggle({
    Title = "Aimbot",
    Desc = "Locks onto nearest player.",
    Value = false,
    Callback = function(s)
        aimbotEnabled = s
        ui:Notify({ Title = "Aimbot", Content = s and "ON" or "OFF", Icon = s and "check" or "x" })
    end,
})

combatSection:Slider({
    Title = "FOV Radius",
    Desc = "Aimbot detection radius.",
    Value = { Min = 50, Max = 500, Default = 200 },
    Step = 10,
    Suffix = "px",
    IsTextbox = true,
    IsTooltip = true,
    Callback = function(v) print("FOV:", v) end,
})

combatSection:Dropdown({
    Title = "Target Part",
    Value = "Head",
    Values = { "Head", "Torso", "HumanoidRootPart" },
    Callback = function(v) print("Targeting:", v) end,
})

combatSection:Divider()

combatSection:Button({
    Title = "Lock Target",
    Desc = "Locks onto nearest enemy.",
    Callback = function()
        ui:Notify({ Title = "Combat", Content = "Target locked!", Icon = "crosshair" })
    end,
})

-- ============================================
-- VISUALS TAB
-- ============================================
local espSection = visualsTab:Section({
    Title = "Player ESP",
    Desc = "Highlight and name tags.",
    Icon = "eye",
    Box = true,
    BoxBorder = true,
})

espSection:Toggle({
    Title = "Player ESP",
    Desc = "Shows player names and highlights.",
    Value = false,
    Callback = function(s)
        ui:Notify({ Title = "ESP", Content = s and "ON" or "OFF", Icon = "eye" })
    end,
})

espSection:Toggle({
    Title = "Box ESP",
    Desc = "Draws 2D boxes around players.",
    Value = false,
    Callback = function(s) print("Box ESP:", s) end,
})

espSection:Divider()

local worldSection = visualsTab:Section({
    Title = "World",
    Icon = "sun",
    Box = true,
})

worldSection:Toggle({
    Title = "Full Bright",
    Value = false,
    Callback = function(s)
        game:GetService("Lighting").Brightness = s and 5 or 1
        ui:Notify({ Title = "Full Bright", Content = s and "ON" or "OFF", Icon = "sun" })
    end,
})

worldSection:Slider({
    Title = "FOV",
    Value = { Min = 30, Max = 120, Default = 70 },
    Step = 1,
    Suffix = "°",
    Callback = function(v)
        workspace.CurrentCamera.FieldOfView = v
    end,
})

-- ============================================
-- SETTINGS TAB
-- ============================================
local configSection = settingsTab:Section({
    Title = "Configuration",
    Icon = "settings",
    Box = true,
})

configSection:Input({
    Title = "Custom Text",
    Placeholder = "Type something...",
    Callback = function(v)
        ui:Notify({ Title = "Input", Content = "You typed: " .. v, Icon = "edit" })
    end,
})

configSection:Divider()

local btnGroup = configSection:Group({})
btnGroup:Button({ Title = "Save", Callback = function()
    ui:Notify({ Title = "Config", Content = "Saved!", Icon = "save" })
end })
btnGroup:Button({ Title = "Load", Callback = function()
    ui:Notify({ Title = "Config", Content = "Loaded!", Icon = "folder" })
end })
btnGroup:Button({ Title = "Reset", Callback = function()
    ui:Notify({ Title = "Config", Content = "Reset!", Icon = "refresh-cw" })
end })

-- ============================================
-- NOTIFICACIÓN DE CARGA
-- ============================================
ui:Notify({
    Title = "TzeUI",
    Content = "Example script loaded successfully!",
    Icon = "check",
    Duration = 5,
})
