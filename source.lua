--[[
    ╔═══════════════════════════════════════════════════════╗
    ║              ZETH UI LIBRARY  v1.0                    ║
    ║         Glassmorphism Dark — Production Grade         ║
    ╚═══════════════════════════════════════════════════════╝

    USAGE EXAMPLE:
    ──────────────
    local ZethUI = loadstring(game:HttpGet("..."))()

    local win = ZethUI:CreateWindow({
        Title = "My Hub",
        Subtitle = "v1.0",
        Key = "my_key_here",
        Discord = "https://discord.gg/...",
    })

    win:Watermark("My Hub  ·  v1.0  ·  FPS: {fps}")

    local tab = win:Tab("Main")
    local section = tab:Section("Combat")

    section:Toggle("Aimlock", false, function(val) end)
    section:Button("Teleport", function() end)
    section:Slider("Speed", 16, 0, 100, function(val) end)
    section:Divider()

    tab:Toggle("Global Toggle", false, function(val) end)
    tab:Button("Button", function() end)
    tab:Slider("Value", 50, 0, 100, function(val) end)
    tab:Dropdown("Mode", {"Off","On","Auto"}, function(val) end)
    tab:Input("Name", "placeholder...", function(val) end)
    tab:Paragraph("Title", "Body text here...")
    tab:Stats({FPS = 60, Ping = 30})
    tab:Code("print('hello')")
    tab:Divider()

    local group = tab:Group("My Group")
    group:Toggle("Option", false, function(val) end)
    group:Button("Do Thing", function() end)
]]

local ZethUI = {}
ZethUI.__index = ZethUI

--------------------------------------------------------------
-- SERVICES
--------------------------------------------------------------
local Players       = game:GetService("Players")
local RS            = game:GetService("RunService")
local UIS           = game:GetService("UserInputService")
local TS            = game:GetService("TweenService")
local SG            = game:GetService("StarterGui")
local CG            = game:GetService("CoreGui")
local LP            = Players.LocalPlayer

--------------------------------------------------------------
-- PALETTE
--------------------------------------------------------------
local C = {
    bg       = Color3.fromRGB(8,  8,  14),
    bg2      = Color3.fromRGB(14, 14, 22),
    bg3      = Color3.fromRGB(20, 20, 30),
    bg4      = Color3.fromRGB(28, 28, 42),
    bg5      = Color3.fromRGB(35, 35, 50),
    stroke   = Color3.fromRGB(40, 40, 60),
    stroke2  = Color3.fromRGB(55, 55, 78),
    dim      = Color3.fromRGB(60, 60, 82),
    dim2     = Color3.fromRGB(45, 45, 62),
    sub      = Color3.fromRGB(120,120,150),
    text     = Color3.fromRGB(228,228,248),
    white    = Color3.fromRGB(255,255,255),
    blue     = Color3.fromRGB(70, 135,255),
    blue2    = Color3.fromRGB(105,170,255),
    blueD    = Color3.fromRGB(40, 90, 200),
    blueGlow = Color3.fromRGB(30, 70, 180),
    purple   = Color3.fromRGB(135, 65,255),
    purple2  = Color3.fromRGB(170,100,255),
    gold     = Color3.fromRGB(255,185, 40),
    gold2    = Color3.fromRGB(255,218, 85),
    goldD    = Color3.fromRGB(190,135, 15),
    green    = Color3.fromRGB(45, 215, 90),
    green2   = Color3.fromRGB(80, 240,120),
    red      = Color3.fromRGB(255, 50, 50),
    red2     = Color3.fromRGB(255, 90, 90),
    orange   = Color3.fromRGB(255,145, 25),
    cyan     = Color3.fromRGB(50, 205,230),
    disc     = Color3.fromRGB(88, 101,242),
    glass    = Color3.fromRGB(15, 15, 25),
}

--------------------------------------------------------------
-- BUILD HELPERS
--------------------------------------------------------------
local function new(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then pcall(function() obj[k] = v end) end
    end
    if props.Parent then obj.Parent = props.Parent end
    return obj
end

local function tween(obj, props, dur, style, dir)
    if not obj or not obj.Parent then return end
    local t = TS:Create(obj,
        TweenInfo.new(dur or 0.3, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props)
    t:Play()
    return t
end

local function tweenBack(obj, props, dur)
    return tween(obj, props, dur or 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function corner(parent, r)
    return new("UICorner", {CornerRadius = UDim.new(0, r or 8), Parent = parent})
end

local function padding(parent, t, b, l, r)
    return new("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or 0),
        Parent = parent,
    })
end

local function stroke(parent, color, thick, transp)
    return new("UIStroke", {
        Color = color or C.stroke,
        Thickness = thick or 1,
        Transparency = transp or 0.5,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function gradient(parent, c1, c2, rot)
    return new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, c1),
            ColorSequenceKeypoint.new(1, c2),
        }),
        Rotation = rot or 0,
        Parent = parent,
    })
end

local function shadow(parent, size, transp)
    return new("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, size or 30, 1, size or 30),
        Position = UDim2.new(0.5, 0, 0.5, 4),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = transp or 0.5,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        ZIndex = -1,
        Parent = parent,
    })
end

local function listLayout(parent, dir, padding_, sort)
    return new("UIListLayout", {
        FillDirection       = dir or Enum.FillDirection.Vertical,
        SortOrder           = sort or Enum.SortOrder.LayoutOrder,
        Padding             = UDim.new(0, padding_ or 6),
        Parent              = parent,
    })
end

--------------------------------------------------------------
-- TOAST SYSTEM (shared singleton)
--------------------------------------------------------------
local _toastContainer = nil

local function ensureToastContainer(screenGui)
    if _toastContainer and _toastContainer.Parent then return end
    _toastContainer = new("Frame", {
        Name = "ZethToasts",
        Size = UDim2.new(0, 280, 1, 0),
        Position = UDim2.new(1, -16, 0, 16),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Parent = screenGui,
    })
    listLayout(_toastContainer, Enum.FillDirection.Vertical, 8)
end

local function toast(text, color, duration)
    if not _toastContainer then return end
    local accent = color or C.blue

    local pill = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = C.bg2,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = _toastContainer,
    })
    corner(pill, 10)
    stroke(pill, accent, 1, 0.3)

    local bar = new("Frame", {
        Size = UDim2.new(0, 3, 0.6, 0),
        Position = UDim2.new(0, 8, 0.2, 0),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Parent = pill,
    })
    corner(bar, 2)

    local lbl = new("TextLabel", {
        Size = UDim2.new(1, -28, 1, 0),
        Position = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = C.text,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        TextTransparency = 1,
        Parent = pill,
    })

    tweenBack(pill, {Size = UDim2.new(1, 0, 0, 36)}, 0.35)
    task.delay(0.1, function() tween(lbl, {TextTransparency = 0}, 0.25) end)
    task.delay(duration or 3, function()
        tween(lbl, {TextTransparency = 1}, 0.2)
        tween(pill, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        task.delay(0.35, function() pcall(function() pill:Destroy() end) end)
    end)
end

--------------------------------------------------------------
-- NOTIFY (Roblox CoreGui)
--------------------------------------------------------------
local function notify(title, text, dur)
    pcall(function()
        SG:SetCore("SendNotification", {
            Title = title or "ZethUI",
            Text = text or "",
            Duration = dur or 3,
        })
    end)
end

--------------------------------------------------------------
-- ELEMENT FACTORY (shared by Tab, Section, Group)
--------------------------------------------------------------
local ElementFactory = {}
ElementFactory.__index = ElementFactory

-- Helper: auto-resize scrolling frame
local function autoResize(scrollFrame)
    local layout = scrollFrame:FindFirstChildOfClass("UIListLayout")
    if not layout then return end
    local function update()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    update()
end

-- ─── Row container ───────────────────────────────────────
local function makeRow(parent, height)
    local row = new("Frame", {
        Size = UDim2.new(1, 0, 0, height or 34),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent,
    })
    return row
end

-- ─── Toggle ──────────────────────────────────────────────
function ElementFactory:Toggle(label, default, callback)
    local state = default or false
    local row = makeRow(self._container, 34)

    local lbl = new("TextLabel", {
        Size = UDim2.new(1, -56, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = C.text,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local trackBg = new("Frame", {
        Size = UDim2.new(0, 38, 0, 20),
        Position = UDim2.new(1, -48, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = C.bg4,
        BorderSizePixel = 0,
        Parent = row,
    })
    corner(trackBg, 10)
    stroke(trackBg, C.stroke2, 1, 0.3)

    local knob = new("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = C.sub,
        BorderSizePixel = 0,
        Parent = trackBg,
    })
    corner(knob, 7)

    local function refresh(val, animate)
        if val then
            if animate then
                tween(trackBg, {BackgroundColor3 = C.blueD}, 0.2)
                tween(knob, {Position = UDim2.new(0, 21, 0.5, 0), BackgroundColor3 = C.white}, 0.25, Enum.EasingStyle.Back)
            else
                trackBg.BackgroundColor3 = C.blueD
                knob.Position = UDim2.new(0, 21, 0.5, 0)
                knob.BackgroundColor3 = C.white
            end
        else
            if animate then
                tween(trackBg, {BackgroundColor3 = C.bg4}, 0.2)
                tween(knob, {Position = UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = C.sub}, 0.25, Enum.EasingStyle.Back)
            else
                trackBg.BackgroundColor3 = C.bg4
                knob.Position = UDim2.new(0, 3, 0.5, 0)
                knob.BackgroundColor3 = C.sub
            end
        end
    end

    refresh(state, false)

    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        Parent = row,
    })
    btn.MouseButton1Click:Connect(function()
        state = not state
        refresh(state, true)
        pcall(callback, state)
    end)
    btn.MouseEnter:Connect(function()
        tween(row, {BackgroundColor3 = C.bg3}, 0.15)
        row.BackgroundTransparency = 0.5
    end)
    btn.MouseLeave:Connect(function()
        tween(row, {BackgroundTransparency = 1}, 0.15)
    end)

    return {
        Set = function(_, val)
            state = val
            refresh(state, true)
            pcall(callback, state)
        end,
        Get = function() return state end,
    }
end

-- ─── Button ──────────────────────────────────────────────
function ElementFactory:Button(label, callback)
    local row = makeRow(self._container, 34)

    local btn = new("TextButton", {
        Size = UDim2.new(1, -16, 0, 28),
        Position = UDim2.new(0, 8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = C.bg4,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = row,
    })
    corner(btn, 8)
    stroke(btn, C.stroke2, 1, 0.4)

    local lbl = new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = C.text,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        Parent = btn,
    })

    local norm = UDim2.new(1, -16, 0, 28)
    local hov  = UDim2.new(1, -12, 0, 30)

    btn.MouseEnter:Connect(function()
        tweenBack(btn, {Size = hov, BackgroundColor3 = C.bg5}, 0.18)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {Size = norm, BackgroundColor3 = C.bg4}, 0.15)
    end)
    btn.MouseButton1Down:Connect(function()
        tween(btn, {Size = UDim2.new(1, -20, 0, 26)}, 0.07)
    end)
    btn.MouseButton1Up:Connect(function()
        tweenBack(btn, {Size = norm}, 0.2)
        pcall(callback)
    end)
end

-- ─── Slider ──────────────────────────────────────────────
function ElementFactory:Slider(label, default, min, max, callback)
    local value = math.clamp(default or min, min, max)
    local row = makeRow(self._container, 52)

    local topRow = new("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Parent = row,
    })

    local lbl = new("TextLabel", {
        Size = UDim2.new(0.7, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = C.text,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topRow,
    })

    local valLbl = new("TextLabel", {
        Size = UDim2.new(0.3, -10, 1, 0),
        Position = UDim2.new(0.7, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = tostring(value),
        TextColor3 = C.blue2,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = topRow,
    })

    local track = new("Frame", {
        Size = UDim2.new(1, -20, 0, 5),
        Position = UDim2.new(0, 10, 0, 30),
        BackgroundColor3 = C.bg4,
        BorderSizePixel = 0,
        Parent = row,
    })
    corner(track, 3)

    local fill = new("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = C.blue,
        BorderSizePixel = 0,
        Parent = track,
    })
    corner(fill, 3)
    gradient(fill, C.blue, C.purple, 0)

    local knob = new("Frame", {
        Size = UDim2.new(0, 13, 0, 13),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = C.white,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = track,
    })
    corner(knob, 7)

    local function setVal(v)
        value = math.clamp(math.round(v), min, max)
        local ratio = (value - min) / (max - min)
        tween(fill, {Size = UDim2.new(ratio, 0, 1, 0)}, 0.1)
        tween(knob, {Position = UDim2.new(ratio, 0, 0.5, 0)}, 0.1)
        valLbl.Text = tostring(value)
        pcall(callback, value)
    end

    setVal(value)

    local dragging = false
    local hitbox = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundTransparency = 1,
        Text = "",
        Parent = row,
    })
    hitbox.MouseButton1Down:Connect(function()
        dragging = true
        tween(knob, {Size = UDim2.new(0, 16, 0, 16)}, 0.1)
    end)
    UIS.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            tween(knob, {Size = UDim2.new(0, 13, 0, 13)}, 0.1)
        end
    end)
    UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local abs = track.AbsolutePosition
            local sz  = track.AbsoluteSize
            local rx = math.clamp((inp.Position.X - abs.X) / sz.X, 0, 1)
            setVal(min + rx * (max - min))
        end
    end)

    return {
        Set = function(_, v) setVal(v) end,
        Get = function() return value end,
    }
end

-- ─── Dropdown ────────────────────────────────────────────
function ElementFactory:Dropdown(label, options, callback)
    local selected = options[1] or ""
    local open = false
    local row = makeRow(self._container, 34)
    row.ClipsDescendants = false
    row.ZIndex = 10

    local lbl = new("TextLabel", {
        Size = UDim2.new(0.45, 0, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = C.text,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10,
        Parent = row,
    })

    local trigger = new("TextButton", {
        Size = UDim2.new(0.52, 0, 0, 26),
        Position = UDim2.new(0.47, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = C.bg4,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ClipsDescendants = false,
        ZIndex = 10,
        Parent = row,
    })
    corner(trigger, 8)
    stroke(trigger, C.stroke2, 1, 0.4)

    local selLbl = new("TextLabel", {
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = selected,
        TextColor3 = C.blue2,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11,
        Parent = trigger,
    })

    local arrow = new("TextLabel", {
        Size = UDim2.new(0, 16, 1, 0),
        Position = UDim2.new(1, -18, 0, 0),
        BackgroundTransparency = 1,
        Text = "▾",
        TextColor3 = C.sub,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        ZIndex = 11,
        Parent = trigger,
    })

    -- dropdown list
    local dropFrame = new("Frame", {
        Size = UDim2.new(0.52, 0, 0, 0),
        Position = UDim2.new(0.47, 0, 0, 34),
        BackgroundColor3 = C.bg2,
        BackgroundTransparency = 0.04,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 20,
        Visible = false,
        Parent = row,
    })
    corner(dropFrame, 8)
    stroke(dropFrame, C.stroke2, 1, 0.2)
    shadow(dropFrame, 14, 0.7)

    local dropList = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 20,
        Parent = dropFrame,
    })
    padding(dropList, 4, 4, 0, 0)
    listLayout(dropList, Enum.FillDirection.Vertical, 2)

    local itemHeight = 26
    for _, opt in ipairs(options) do
        local optBtn = new("TextButton", {
            Size = UDim2.new(1, -8, 0, itemHeight),
            BackgroundColor3 = C.bg3,
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Text = opt,
            TextColor3 = C.text,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            AutoButtonColor = false,
            ZIndex = 21,
            Parent = dropList,
        })
        corner(optBtn, 6)
        padding(optBtn, 0, 0, 8, 0)
        optBtn.TextXAlignment = Enum.TextXAlignment.Left

        optBtn.MouseEnter:Connect(function()
            tween(optBtn, {BackgroundTransparency = 0, BackgroundColor3 = C.bg4}, 0.12)
        end)
        optBtn.MouseLeave:Connect(function()
            tween(optBtn, {BackgroundTransparency = 0.5, BackgroundColor3 = C.bg3}, 0.12)
        end)
        optBtn.MouseButton1Click:Connect(function()
            selected = opt
            selLbl.Text = opt
            open = false
            tween(dropFrame, {Size = UDim2.new(0.52, 0, 0, 0)}, 0.2)
            tween(arrow, {Rotation = 0}, 0.2)
            task.delay(0.2, function() dropFrame.Visible = false end)
            pcall(callback, opt)
        end)
    end

    local totalH = #options * (itemHeight + 2) + 8
    trigger.MouseButton1Click:Connect(function()
        open = not open
        if open then
            dropFrame.Visible = true
            dropFrame.Size = UDim2.new(0.52, 0, 0, 0)
            tweenBack(dropFrame, {Size = UDim2.new(0.52, 0, 0, totalH)}, 0.3)
            tween(arrow, {Rotation = 180}, 0.2)
        else
            tween(dropFrame, {Size = UDim2.new(0.52, 0, 0, 0)}, 0.2)
            tween(arrow, {Rotation = 0}, 0.2)
            task.delay(0.2, function() dropFrame.Visible = false end)
        end
    end)

    return {
        Set = function(_, v)
            selected = v
            selLbl.Text = v
        end,
        Get = function() return selected end,
    }
end

-- ─── Input ───────────────────────────────────────────────
function ElementFactory:Input(label, placeholder, callback)
    local row = makeRow(self._container, 54)

    new("TextLabel", {
        Size = UDim2.new(1, -16, 0, 14),
        Position = UDim2.new(0, 10, 0, 2),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = C.sub,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local box = new("Frame", {
        Size = UDim2.new(1, -16, 0, 30),
        Position = UDim2.new(0, 8, 0, 18),
        BackgroundColor3 = C.bg3,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = row,
    })
    corner(box, 8)
    local boxStroke = stroke(box, C.stroke, 1, 0.35)

    local input = new("TextBox", {
        Size = UDim2.new(1, -18, 1, 0),
        Position = UDim2.new(0, 9, 0, 0),
        BackgroundTransparency = 1,
        PlaceholderText = placeholder or "",
        PlaceholderColor3 = C.dim2,
        Text = "",
        TextColor3 = C.text,
        TextSize = 12,
        Font = Enum.Font.GothamMedium,
        ClearTextOnFocus = false,
        Parent = box,
    })

    input.Focused:Connect(function()
        tween(boxStroke, {Color = C.blue, Transparency = 0}, 0.2)
        tween(box, {BackgroundColor3 = C.bg4}, 0.2)
    end)
    input.FocusLost:Connect(function()
        tween(boxStroke, {Color = C.stroke, Transparency = 0.35}, 0.25)
        tween(box, {BackgroundColor3 = C.bg3}, 0.25)
        pcall(callback, input.Text)
    end)

    return {
        Set = function(_, v) input.Text = v end,
        Get = function() return input.Text end,
    }
end

-- ─── Paragraph ───────────────────────────────────────────
function ElementFactory:Paragraph(title, body)
    local row = makeRow(self._container, 10)

    local inner = new("Frame", {
        Size = UDim2.new(1, -16, 0, 10),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundColor3 = C.bg3,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Parent = row,
    })
    corner(inner, 8)
    stroke(inner, C.stroke, 1, 0.5)
    padding(inner, 8, 8, 10, 10)

    local layout = listLayout(inner, Enum.FillDirection.Vertical, 4)

    local titleLbl = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = C.blue2,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = inner,
    })

    local bodyLbl = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        BackgroundTransparency = 1,
        Text = body,
        TextColor3 = C.sub,
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        Parent = inner,
    })

    -- auto resize
    local function resize()
        local h = layout.AbsoluteContentSize.Y + 16
        inner.Size = UDim2.new(1, -16, 0, h)
        row.Size = UDim2.new(1, 0, 0, h)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)
    task.defer(resize)

    return {
        SetTitle = function(_, t) titleLbl.Text = t end,
        SetBody  = function(_, b) bodyLbl.Text = b end,
    }
end

-- ─── Stats ───────────────────────────────────────────────
function ElementFactory:Stats(data)
    local keys = {}
    for k in pairs(data) do table.insert(keys, k) end

    local col = math.min(#keys, 4)
    local rowH = 44
    local row = makeRow(self._container, rowH)

    local grid = new("Frame", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Parent = row,
    })

    local refs = {}

    for i, k in ipairs(keys) do
        local cell = new("Frame", {
            Size = UDim2.new(1 / col, -4, 1, 0),
            Position = UDim2.new((i - 1) / col, 2, 0, 0),
            BackgroundColor3 = C.bg4,
            BackgroundTransparency = 0.1,
            BorderSizePixel = 0,
            Parent = grid,
        })
        corner(cell, 8)
        stroke(cell, C.stroke2, 1, 0.5)

        new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 14),
            Position = UDim2.new(0, 0, 0, 6),
            BackgroundTransparency = 1,
            Text = k,
            TextColor3 = C.sub,
            TextSize = 8,
            Font = Enum.Font.GothamBold,
            Parent = cell,
        })

        local valLbl = new("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            Position = UDim2.new(0, 0, 0, 20),
            BackgroundTransparency = 1,
            Text = tostring(data[k]),
            TextColor3 = C.blue2,
            TextSize = 13,
            Font = Enum.Font.GothamBold,
            Parent = cell,
        })

        refs[k] = valLbl
    end

    return {
        Update = function(_, newData)
            for k, v in pairs(newData) do
                if refs[k] then refs[k].Text = tostring(v) end
            end
        end,
    }
end

-- ─── Code ────────────────────────────────────────────────
function ElementFactory:Code(source)
    local lines = {}
    for line in (source .. "\n"):gmatch("(.-)\n") do
        table.insert(lines, line)
    end
    local lineH = 14
    local totalH = math.max(#lines * lineH + 16, 30)
    local row = makeRow(self._container, totalH)

    local codeBox = new("Frame", {
        Size = UDim2.new(1, -16, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundColor3 = Color3.fromRGB(10, 10, 18),
        BackgroundTransparency = 0.02,
        BorderSizePixel = 0,
        Parent = row,
    })
    corner(codeBox, 8)
    stroke(codeBox, C.blueD, 1, 0.35)

    -- left gutter accent
    local gutter = new("Frame", {
        Size = UDim2.new(0, 3, 0.7, 0),
        Position = UDim2.new(0, 5, 0.15, 0),
        BackgroundColor3 = C.blueD,
        BorderSizePixel = 0,
        Parent = codeBox,
    })
    corner(gutter, 2)

    local codeLbl = new("TextLabel", {
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
        BackgroundTransparency = 1,
        Text = source,
        TextColor3 = C.cyan,
        TextSize = 10,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = codeBox,
    })
    padding(codeLbl, 7, 7, 0, 0)
end

-- ─── Divider ─────────────────────────────────────────────
function ElementFactory:Divider()
    local row = makeRow(self._container, 14)

    local line = new("Frame", {
        Size = UDim2.new(1, -20, 0, 1),
        Position = UDim2.new(0, 10, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = C.stroke,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Parent = row,
    })
    gradient(line, C.stroke, C.bg, 0)
end

-- ─── Group ───────────────────────────────────────────────
function ElementFactory:Group(label)
    local wrapper = new("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        BackgroundColor3 = C.bg3,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        Parent = self._container,
    })
    corner(wrapper, 10)
    stroke(wrapper, C.stroke2, 1, 0.45)
    padding(wrapper, 10, 8, 0, 0)

    new("TextLabel", {
        Size = UDim2.new(1, -16, 0, 16),
        Position = UDim2.new(0, 8, 0, -8),
        BackgroundColor3 = C.bg3,
        BackgroundTransparency = 0,
        Text = " " .. label .. " ",
        TextColor3 = C.blue2,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 2,
        Parent = wrapper,
    })

    local inner = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent = wrapper,
    })
    listLayout(inner, Enum.FillDirection.Vertical, 4)

    -- auto resize wrapper
    local layout = inner:FindFirstChildOfClass("UIListLayout")
    local function resize()
        local h = layout.AbsoluteContentSize.Y + 20
        inner.Size = UDim2.new(1, 0, 0, h)
        wrapper.Size = UDim2.new(1, 0, 0, h + 14)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)
    task.defer(resize)

    local group = setmetatable({_container = inner}, ElementFactory)
    return group
end

--------------------------------------------------------------
-- SECTION (labeled collapsible group)
--------------------------------------------------------------
local Section = setmetatable({}, {__index = ElementFactory})
Section.__index = Section

local function createSection(parent, label)
    local self = setmetatable({}, Section)

    local wrapper = new("Frame", {
        Size = UDim2.new(1, 0, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = parent,
    })

    -- header
    local header = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundColor3 = C.bg4,
        BackgroundTransparency = 0.1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = wrapper,
    })
    corner(header, 8)
    stroke(header, C.stroke2, 1, 0.45)

    local accentBar = new("Frame", {
        Size = UDim2.new(0, 3, 0.6, 0),
        Position = UDim2.new(0, 8, 0.2, 0),
        BackgroundColor3 = C.blue,
        BorderSizePixel = 0,
        Parent = header,
    })
    corner(accentBar, 2)

    new("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = C.text,
        TextSize = 11,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })

    local arrowLbl = new("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(1, -26, 0, 0),
        BackgroundTransparency = 1,
        Text = "▾",
        TextColor3 = C.sub,
        TextSize = 10,
        Font = Enum.Font.GothamBold,
        Parent = header,
    })

    local content = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
        Parent = wrapper,
    })
    padding(content, 4, 4, 0, 0)
    local contentLayout = listLayout(content, Enum.FillDirection.Vertical, 3)

    self._container = content
    local collapsed = false

    local function resize()
        if collapsed then
            wrapper.Size = UDim2.new(1, 0, 0, 28)
        else
            local h = contentLayout.AbsoluteContentSize.Y + 8
            content.Size = UDim2.new(1, 0, 0, h)
            wrapper.Size = UDim2.new(1, 0, 0, 28 + h + 4)
        end
    end
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)

    header.MouseButton1Click:Connect(function()
        collapsed = not collapsed
        tween(arrowLbl, {Rotation = collapsed and -90 or 0}, 0.2)
        tween(content, {BackgroundTransparency = collapsed and 1 or 0}, 0.1)
        resize()
    end)

    task.defer(resize)
    return self
end

--------------------------------------------------------------
-- TAB
--------------------------------------------------------------
local Tab = setmetatable({}, {__index = ElementFactory})
Tab.__index = Tab

local function createTab(scrollFrame)
    local self = setmetatable({}, Tab)

    local inner = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = scrollFrame,
    })
    padding(inner, 6, 6, 6, 6)
    listLayout(inner, Enum.FillDirection.Vertical, 6)
    autoResize(scrollFrame)

    self._container = inner
    self._scroll = scrollFrame

    -- rebind autoResize to inner's layout
    local layout = inner:FindFirstChildOfClass("UIListLayout")
    local function update()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 12)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)

    function self:Section(label)
        return createSection(self._container, label)
    end

    return self
end

--------------------------------------------------------------
-- SIDEBAR HELPERS
--------------------------------------------------------------
local function makeSideLabel(sidebar, text)
    local lbl = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = string.upper(text),
        TextColor3 = C.dim,
        TextSize = 8,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sidebar,
    })
    padding(lbl, 0, 0, 12, 0)
    return lbl
end

local function makeSideButton(sidebar, icon, label, onClick)
    local btn = new("TextButton", {
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = C.bg3,
        BackgroundTransparency = 0.7,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        Parent = sidebar,
    })
    corner(btn, 8)

    local iconLbl = new("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = icon,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        Parent = btn,
    })

    local textLbl = new("TextLabel", {
        Size = UDim2.new(1, -36, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1,
        Text = label,
        TextColor3 = C.sub,
        TextSize = 11,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = btn,
    })

    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundTransparency = 0.1, BackgroundColor3 = C.bg4}, 0.15)
        tween(textLbl, {TextColor3 = C.text}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundTransparency = 0.7, BackgroundColor3 = C.bg3}, 0.15)
        tween(textLbl, {TextColor3 = C.sub}, 0.15)
    end)
    btn.MouseButton1Click:Connect(function() pcall(onClick) end)
    return btn
end

local function makeSideDivider(sidebar)
    local div = new("Frame", {
        Size = UDim2.new(1, -8, 0, 1),
        BackgroundColor3 = C.stroke,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Parent = sidebar,
    })
    return div
end

--------------------------------------------------------------
-- KEY SYSTEM
--------------------------------------------------------------
local function showKeySystem(config, onComplete)
    local FREE_KEY = config.Key or "free_key"
    local PREM_KEY = config.PremiumKey or ""
    local DISCORD  = config.Discord or ""

    pcall(function()
        local old = CG:FindFirstChild("ZethUI_KEY")
        if old then old:Destroy() end
    end)

    local screen = new("ScreenGui", {
        Name = "ZethUI_KEY",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        Parent = CG,
    })

    local overlay = new("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = screen,
    })
    tween(overlay, {BackgroundTransparency = 0.25}, 1, Enum.EasingStyle.Sine)

    local function makeGlow(pos, color, size, tr)
        local g = new("Frame", {
            Size = UDim2.new(0, size, 0, size),
            Position = pos,
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = color,
            BackgroundTransparency = tr or 0.92,
            BorderSizePixel = 0,
            ZIndex = 0,
            Parent = screen,
        })
        corner(g, size / 2)
        return g
    end

    local glow1 = makeGlow(UDim2.new(0.3, 0, 0.3, 0), C.blueGlow, 400, 0.94)
    local glow2 = makeGlow(UDim2.new(0.7, 0, 0.7, 0), C.purple,   350, 0.95)

    task.spawn(function()
        while screen and screen.Parent do
            tween(glow1, {Position = UDim2.new(0.35, 0, 0.35, 0)}, 4, Enum.EasingStyle.Sine)
            tween(glow2, {Position = UDim2.new(0.65, 0, 0.65, 0)}, 4, Enum.EasingStyle.Sine)
            task.wait(4)
            tween(glow1, {Position = UDim2.new(0.3, 0, 0.3, 0)}, 4, Enum.EasingStyle.Sine)
            tween(glow2, {Position = UDim2.new(0.7, 0, 0.7, 0)}, 4, Enum.EasingStyle.Sine)
            task.wait(4)
        end
    end)

    local card = new("Frame", {
        Size = UDim2.new(0, 440, 0, 510),
        Position = UDim2.new(0.5, 0, 0.5, 70),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = C.glass,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 2,
        Parent = screen,
    })
    corner(card, 22)
    shadow(card, 60, 0.6)
    local cardStroke = stroke(card, C.blueD, 1.5, 1)

    local innerGlass = new("Frame", {
        Size = UDim2.new(1, -2, 1, -2),
        Position = UDim2.new(0, 1, 0, 1),
        BackgroundColor3 = C.bg,
        BackgroundTransparency = 0.15,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = card,
    })
    corner(innerGlass, 21)

    task.delay(0.05, function()
        tween(card, {BackgroundTransparency = 0.08, Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.85, Enum.EasingStyle.Quint)
        tween(cardStroke, {Transparency = 0.05}, 0.9)
    end)

    local topLine = new("Frame", {
        Size = UDim2.new(0, 0, 0, 3),
        BackgroundColor3 = C.blue,
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = card,
    })
    gradient(topLine, C.blue, C.purple, 0)
    corner(topLine, 2)
    task.delay(0.35, function()
        tween(topLine, {Size = UDim2.new(1, 0, 0, 3)}, 0.9, Enum.EasingStyle.Quint)
    end)

    local upperGlow = new("Frame", {
        Size = UDim2.new(1, 0, 0, 100),
        Position = UDim2.new(0, 0, 0, 3),
        BackgroundColor3 = C.blueD,
        BackgroundTransparency = 0.9,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = card,
    })

    -- Logo
    local logoHolder = new("Frame", {
        Size = UDim2.new(0, 56, 0, 56),
        Position = UDim2.new(0.5, 0, 0, 28),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = C.bg3,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = card,
    })
    corner(logoHolder, 28)
    stroke(logoHolder, C.blueD, 1.5, 0.3)

    local logoGlow = new("Frame", {
        Size = UDim2.new(1, 16, 1, 16),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = C.blueGlow,
        BackgroundTransparency = 0.85,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = logoHolder,
    })
    corner(logoGlow, 36)

    local logoLbl = new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = config.Logo or "Z",
        TextColor3 = C.blue2,
        TextTransparency = 1,
        TextSize = 28,
        Font = Enum.Font.GothamBold,
        ZIndex = 5,
        Parent = logoHolder,
    })
    task.delay(0.25, function()
        tween(logoHolder, {BackgroundTransparency = 0.15}, 0.5)
        tween(logoLbl, {TextTransparency = 0}, 0.5)
    end)

    local function fadeText(obj, delay_)
        task.delay(delay_ or 0.3, function() tween(obj, {TextTransparency = 0}, 0.4) end)
    end

    local titleLbl = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 92),
        BackgroundTransparency = 1,
        Text = config.Title or "Hub",
        TextColor3 = C.text,
        TextTransparency = 1,
        TextSize = 26,
        Font = Enum.Font.GothamBold,
        ZIndex = 4,
        Parent = card,
    })
    fadeText(titleLbl, 0.35)

    local subLbl = new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 120),
        BackgroundTransparency = 1,
        Text = (config.Title or "Hub") .. "  ·  " .. (config.Subtitle or "v1.0"),
        TextColor3 = C.dim,
        TextTransparency = 1,
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        ZIndex = 4,
        Parent = card,
    })
    fadeText(subLbl, 0.42)

    local divLine = new("Frame", {
        Size = UDim2.new(0, 0, 0, 1),
        Position = UDim2.new(0.5, 0, 0, 148),
        AnchorPoint = Vector2.new(0.5, 0),
        BackgroundColor3 = C.stroke,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = card,
    })
    task.delay(0.5, function() tween(divLine, {Size = UDim2.new(0.72, 0, 0, 1)}, 0.6) end)

    local keyLabel = new("TextLabel", {
        Size = UDim2.new(0.72, 0, 0, 12),
        Position = UDim2.new(0.14, 0, 0, 168),
        BackgroundTransparency = 1,
        Text = "ENTER KEY",
        TextColor3 = C.sub,
        TextTransparency = 1,
        TextSize = 9,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = card,
    })
    fadeText(keyLabel, 0.52)

    local inputContainer = new("Frame", {
        Size = UDim2.new(0.72, 0, 0, 48),
        Position = UDim2.new(0.14, 0, 0, 184),
        BackgroundColor3 = C.bg3,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = card,
    })
    corner(inputContainer, 12)
    local inputStroke = stroke(inputContainer, C.stroke, 1, 0.4)
    task.delay(0.55, function()
        tween(inputContainer, {BackgroundTransparency = 0.05}, 0.4)
        tween(inputStroke, {Transparency = 0.1}, 0.4)
    end)

    new("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        Position = UDim2.new(0, 12, 0, 0),
        BackgroundTransparency = 1,
        Text = "🔑",
        TextSize = 14,
        ZIndex = 5,
        Parent = inputContainer,
    })

    local inputBox = new("TextBox", {
        Size = UDim2.new(1, -44, 1, 0),
        Position = UDim2.new(0, 36, 0, 0),
        BackgroundTransparency = 1,
        PlaceholderText = "paste your key here...",
        PlaceholderColor3 = C.dim2,
        Text = "",
        TextColor3 = C.text,
        TextSize = 14,
        Font = Enum.Font.GothamMedium,
        ClearTextOnFocus = false,
        ZIndex = 5,
        Parent = inputContainer,
    })

    inputBox.Focused:Connect(function()
        tween(inputStroke, {Color = C.blue, Transparency = 0}, 0.2)
        tween(inputContainer, {BackgroundColor3 = C.bg4}, 0.2)
    end)
    inputBox.FocusLost:Connect(function()
        tween(inputStroke, {Color = C.stroke, Transparency = 0.1}, 0.25)
        tween(inputContainer, {BackgroundColor3 = C.bg3}, 0.25)
    end)

    local statusLbl = new("TextLabel", {
        Size = UDim2.new(0.72, 0, 0, 14),
        Position = UDim2.new(0.14, 0, 0, 238),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = C.red,
        TextSize = 10,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 4,
        Parent = card,
    })

    local valBtn = new("TextButton", {
        Size = UDim2.new(0.72, 0, 0, 48),
        Position = UDim2.new(0.14, 0, 0, 260),
        BackgroundColor3 = C.blue,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 4,
        Parent = card,
    })
    corner(valBtn, 12)
    gradient(valBtn, C.blue, C.purple, 30)
    shadow(valBtn, 20, 0.7)

    local valText = new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "⚡  VALIDATE KEY",
        TextColor3 = C.white,
        TextTransparency = 1,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        ZIndex = 5,
        Parent = valBtn,
    })
    task.delay(0.6, function()
        tween(valBtn, {BackgroundTransparency = 0}, 0.4)
        tween(valText, {TextTransparency = 0}, 0.4)
    end)

    local vNorm = UDim2.new(0.72, 0, 0, 48)
    valBtn.MouseEnter:Connect(function() tweenBack(valBtn, {Size = UDim2.new(0.74, 0, 0, 50)}, 0.2) end)
    valBtn.MouseLeave:Connect(function() tween(valBtn, {Size = vNorm}, 0.15) end)

    -- Discord button
    local dcBtn = new("TextButton", {
        Size = UDim2.new(0.72, 0, 0, 44),
        Position = UDim2.new(0.14, 0, 0, 344),
        BackgroundColor3 = C.disc,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 4,
        Parent = card,
    })
    corner(dcBtn, 12)

    local dcText = new("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "🎮  DISCORD  ·  GET FREE KEY",
        TextColor3 = C.white,
        TextTransparency = 1,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        ZIndex = 5,
        Parent = dcBtn,
    })
    task.delay(0.7, function()
        tween(dcBtn, {BackgroundTransparency = 0}, 0.4)
        tween(dcText, {TextTransparency = 0}, 0.4)
    end)

    dcBtn.MouseEnter:Connect(function() tweenBack(dcBtn, {Size = UDim2.new(0.74, 0, 0, 46)}, 0.2) end)
    dcBtn.MouseLeave:Connect(function() tween(dcBtn, {Size = UDim2.new(0.72, 0, 0, 44)}, 0.15) end)
    dcBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(DISCORD) end)
        statusLbl.TextColor3 = C.green
        statusLbl.Text = "✓ discord link copied to clipboard!"
    end)

    -- feature breakdown
    local featFrame = new("Frame", {
        Size = UDim2.new(0.72, 0, 0, 60),
        Position = UDim2.new(0.14, 0, 0, 400),
        BackgroundColor3 = C.bg3,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = card,
    })
    corner(featFrame, 10)
    stroke(featFrame, C.stroke, 1, 0.6)

    local freeF = new("TextLabel", {
        Size = UDim2.new(0.5, -4, 1, 0),
        Position = UDim2.new(0, 8, 0, 0),
        BackgroundTransparency = 1,
        Text = "FREE\n• basic features",
        TextColor3 = C.sub,
        TextTransparency = 1,
        TextSize = 8,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
        ZIndex = 5,
        Parent = featFrame,
    })
    local premF = new("TextLabel", {
        Size = UDim2.new(0.5, -4, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = "PREMIUM\n• all features unlocked",
        TextColor3 = C.gold,
        TextTransparency = 1,
        TextSize = 8,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
        ZIndex = 5,
        Parent = featFrame,
    })
    task.delay(0.8, function()
        tween(featFrame, {BackgroundTransparency = 0.1}, 0.4)
        tween(freeF, {TextTransparency = 0}, 0.4)
        tween(premF, {TextTransparency = 0}, 0.4)
    end)

    -- or divider
    local orLbl = new("TextLabel", {
        Size = UDim2.new(0.72, 0, 0, 14),
        Position = UDim2.new(0.14, 0, 0, 320),
        BackgroundTransparency = 1,
        Text = "━━━━━━━  or  ━━━━━━━",
        TextColor3 = C.dim2,
        TextTransparency = 1,
        TextSize = 9,
        Font = Enum.Font.Gotham,
        ZIndex = 4,
        Parent = card,
    })
    task.delay(0.65, function() tween(orLbl, {TextTransparency = 0.3}, 0.3) end)

    new("TextLabel", {
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -16),
        BackgroundTransparency = 1,
        Text = (config.Title or "Hub") .. "  ·  " .. (config.Subtitle or "v1.0"),
        TextColor3 = C.dim2,
        TextTransparency = 0.5,
        TextSize = 7,
        Font = Enum.Font.Gotham,
        ZIndex = 4,
        Parent = card,
    })

    local function closeKeyGui(tier)
        local flash = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = tier == "premium" and C.gold or C.blue,
            BackgroundTransparency = 0.8,
            BorderSizePixel = 0,
            ZIndex = 10,
            Parent = card,
        })
        tween(flash, {BackgroundTransparency = 1}, 0.6)
        tween(topLine, {Size = UDim2.new(1, 0, 1, 0)}, 0.4)
        task.delay(0.3, function()
            tween(card, {BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, -60)}, 0.5, Enum.EasingStyle.Quint)
            tween(cardStroke, {Transparency = 1}, 0.4)
            tween(overlay, {BackgroundTransparency = 1}, 0.6)
            tween(glow1, {BackgroundTransparency = 1}, 0.4)
            tween(glow2, {BackgroundTransparency = 1}, 0.4)
        end)
        task.delay(0.8, function()
            pcall(function() screen:Destroy() end)
            onComplete(tier)
        end)
    end

    valBtn.MouseButton1Click:Connect(function()
        local key = inputBox.Text:gsub("%s+", "")
        if key == "" then
            statusLbl.TextColor3 = C.red
            statusLbl.Text = "⚠ enter a key"
            return
        end

        tween(valBtn, {Size = UDim2.new(0.68, 0, 0, 44)}, 0.06)
        task.delay(0.06, function() tweenBack(valBtn, {Size = vNorm}, 0.25) end)

        if key == FREE_KEY then
            statusLbl.TextColor3 = C.green
            statusLbl.Text = "✓ FREE TIER UNLOCKED"
            for _, ch in ipairs(topLine:GetChildren()) do
                if ch:IsA("UIGradient") then ch:Destroy() end
            end
            gradient(topLine, C.green, C.cyan, 0)
            task.delay(1, function() closeKeyGui("free") end)

        elseif PREM_KEY ~= "" and key == PREM_KEY then
            statusLbl.TextColor3 = C.gold
            statusLbl.Text = "★ PREMIUM UNLOCKED"
            for _, ch in ipairs(topLine:GetChildren()) do
                if ch:IsA("UIGradient") then ch:Destroy() end
            end
            gradient(topLine, C.gold, C.orange, 0)
            task.delay(1, function() closeKeyGui("premium") end)

        else
            statusLbl.TextColor3 = C.red
            statusLbl.Text = "✗ invalid key"
            local origPos = inputContainer.Position
            for _, offset in ipairs({-12, 12, -8, 8, -4, 0}) do
                tween(inputContainer, {Position = UDim2.new(origPos.X.Scale, origPos.X.Offset + offset, origPos.Y.Scale, origPos.Y.Offset)}, 0.035)
                task.wait(0.035)
            end
        end
    end)
end

--------------------------------------------------------------
-- WINDOW
--------------------------------------------------------------
local Window = {}
Window.__index = Window

function ZethUI:CreateWindow(config)
    config = config or {}
    local self = setmetatable({}, Window)
    self._tabs = {}
    self._activeTab = nil

    -- cleanup old
    pcall(function()
        local old = CG:FindFirstChild("ZethUI_Main")
        if old then old:Destroy() end
    end)

    local screen = new("ScreenGui", {
        Name = "ZethUI_Main",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
        Parent = CG,
    })

    ensureToastContainer(screen)

    local isPremium = false

    local function buildMainUI()
        -- ── Main window frame ──
        local win = new("Frame", {
            Size = UDim2.new(0, 680, 0, 480),
            Position = UDim2.new(0.5, 0, 0.5, 30),
            AnchorPoint = Vector2.new(0.5, 0.5),
            BackgroundColor3 = C.bg,
            BackgroundTransparency = 0.04,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = screen,
        })
        corner(win, 16)
        stroke(win, C.stroke2, 1, 0.2)
        shadow(win, 40, 0.55)

        -- top accent line
        local topLine = new("Frame", {
            Size = UDim2.new(0, 0, 0, 3),
            BackgroundColor3 = C.blue,
            BorderSizePixel = 0,
            ZIndex = 3,
            Parent = win,
        })
        corner(topLine, 2)
        gradient(topLine, C.blue, C.purple, 0)
        task.delay(0.1, function()
            tween(topLine, {Size = UDim2.new(1, 0, 0, 3)}, 0.7, Enum.EasingStyle.Quint)
        end)

        -- entrance animation
        win.BackgroundTransparency = 1
        tween(win, {BackgroundTransparency = 0.04, Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.6, Enum.EasingStyle.Quint)

        -- upper glow
        new("Frame", {
            Size = UDim2.new(1, 0, 0, 80),
            Position = UDim2.new(0, 0, 0, 3),
            BackgroundColor3 = C.blueD,
            BackgroundTransparency = 0.92,
            BorderSizePixel = 0,
            ZIndex = 0,
            Parent = win,
        })

        -- ── Title bar ──
        local titleBar = new("Frame", {
            Size = UDim2.new(1, 0, 0, 44),
            Position = UDim2.new(0, 0, 0, 3),
            BackgroundTransparency = 1,
            Parent = win,
        })

        local titleLbl = new("TextLabel", {
            Size = UDim2.new(0, 200, 1, 0),
            Position = UDim2.new(0, 16, 0, 0),
            BackgroundTransparency = 1,
            Text = config.Title or "Hub",
            TextColor3 = C.text,
            TextSize = 16,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = titleBar,
        })

        local subLbl = new("TextLabel", {
            Size = UDim2.new(0, 200, 1, 0),
            Position = UDim2.new(0, 16, 0, 20),
            BackgroundTransparency = 1,
            Text = config.Subtitle or "v1.0",
            TextColor3 = C.dim,
            TextSize = 9,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = titleBar,
        })

        -- tier badge
        local tierBadge = new("Frame", {
            Size = UDim2.new(0, 0, 0, 18),
            Position = UDim2.new(0, 130, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = isPremium and C.goldD or C.blueD,
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            Parent = titleBar,
        })
        corner(tierBadge, 9)

        local tierText = new("TextLabel", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = isPremium and " ★ PREMIUM " or " FREE ",
            TextColor3 = isPremium and C.gold or C.blue2,
            TextSize = 8,
            Font = Enum.Font.GothamBold,
            Parent = tierBadge,
        })

        task.defer(function()
            tweenBack(tierBadge, {Size = UDim2.new(0, tierText.TextBounds.X + 4, 0, 18)}, 0.4)
        end)

        -- close button
        local closeBtn = new("TextButton", {
            Size = UDim2.new(0, 28, 0, 28),
            Position = UDim2.new(1, -38, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = C.bg4,
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            Text = "✕",
            TextColor3 = C.sub,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
            Parent = titleBar,
        })
        corner(closeBtn, 8)

        closeBtn.MouseEnter:Connect(function()
            tween(closeBtn, {BackgroundColor3 = C.red, TextColor3 = C.white}, 0.15)
        end)
        closeBtn.MouseLeave:Connect(function()
            tween(closeBtn, {BackgroundColor3 = C.bg4, TextColor3 = C.sub}, 0.15)
        end)
        closeBtn.MouseButton1Click:Connect(function()
            tween(win, {BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, 30)}, 0.4, Enum.EasingStyle.Quint)
            task.delay(0.45, function() pcall(function() screen:Destroy() end) end)
        end)

        -- minimize button
        local minBtn = new("TextButton", {
            Size = UDim2.new(0, 28, 0, 28),
            Position = UDim2.new(1, -70, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = C.bg4,
            BackgroundTransparency = 0.2,
            BorderSizePixel = 0,
            Text = "—",
            TextColor3 = C.sub,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
            Parent = titleBar,
        })
        corner(minBtn, 8)

        local minimized = false
        minBtn.MouseEnter:Connect(function()
            tween(minBtn, {BackgroundColor3 = C.bg5, TextColor3 = C.text}, 0.15)
        end)
        minBtn.MouseLeave:Connect(function()
            tween(minBtn, {BackgroundColor3 = C.bg4, TextColor3 = C.sub}, 0.15)
        end)
        minBtn.MouseButton1Click:Connect(function()
            minimized = not minimized
            if minimized then
                tween(win, {Size = UDim2.new(0, 680, 0, 47)}, 0.35, Enum.EasingStyle.Quint)
            else
                tweenBack(win, {Size = UDim2.new(0, 680, 0, 480)}, 0.4)
            end
        end)

        -- divider below title
        local titleDiv = new("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0, 47),
            BackgroundColor3 = C.stroke,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            Parent = win,
        })

        -- ── Sidebar ──
        local sidebar = new("Frame", {
            Size = UDim2.new(0, 160, 1, -48),
            Position = UDim2.new(0, 0, 0, 48),
            BackgroundColor3 = C.bg2,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            Parent = win,
        })

        local sideDiv = new("Frame", {
            Size = UDim2.new(0, 1, 1, 0),
            Position = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = C.stroke,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            Parent = sidebar,
        })

        local sideList = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Parent = sidebar,
        })
        padding(sideList, 8, 8, 8, 8)
        listLayout(sideList, Enum.FillDirection.Vertical, 3)

        -- ── Content area ──
        local contentArea = new("Frame", {
            Size = UDim2.new(1, -160, 1, -48),
            Position = UDim2.new(0, 160, 0, 48),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Parent = win,
        })

        -- ── Tab nav row ──
        local tabNav = new("Frame", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = C.bg3,
            BackgroundTransparency = 0.3,
            BorderSizePixel = 0,
            Parent = contentArea,
        })

        local tabNavList = new("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Parent = tabNav,
        })
        padding(tabNavList, 0, 0, 8, 8)
        listLayout(tabNavList, Enum.FillDirection.Horizontal, 4)

        local tabNavDiv = new("Frame", {
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 1, -1),
            BackgroundColor3 = C.stroke,
            BackgroundTransparency = 0.35,
            BorderSizePixel = 0,
            Parent = tabNav,
        })

        -- scroll container
        local scrollContainer = new("Frame", {
            Size = UDim2.new(1, 0, 1, -36),
            Position = UDim2.new(0, 0, 0, 36),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Parent = contentArea,
        })

        -- drag window
        local dragging, dragStart, startPos = false, nil, nil
        titleBar.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = inp.Position
                startPos = win.Position
            end
        end)
        UIS.InputChanged:Connect(function(inp)
            if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = inp.Position - dragStart
                win.Position = UDim2.new(
                    startPos.X.Scale,
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale,
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
        UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

                -- ── Open Button (flotante) ──────────────────────
        local openBtn = new("TextButton", {
            Size = UDim2.new(0, 44, 0, 44),
            Position = UDim2.new(0, 120, 0, 120),
            BackgroundColor3 = C.bg,
            BackgroundTransparency = 0.05,
            BorderSizePixel = 0,
            Text = "+",
            TextColor3 = C.blue2,
            TextSize = 24,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
            ZIndex = 10,
            Parent = screen,
        })
        corner(openBtn, 12)
        stroke(openBtn, C.blueD, 1, 0.3)

        local openVisible = true
        openBtn.MouseButton1Click:Connect(function()
            win.Visible = not win.Visible
            openBtn.Text = "+"
            tween(openBtn, {BackgroundTransparency = win.Visible and 0.05 or 0.5}, 0.2)
        end)

        openBtn.MouseEnter:Connect(function()
            tweenBack(openBtn, {Size = UDim2.new(0, 48, 0, 48)}, 0.2)
        end)
        openBtn.MouseLeave:Connect(function()
            tween(openBtn, {Size = UDim2.new(0, 44, 0, 44)}, 0.15)
        end)

        -- Drag del OpenButton (Click Derecho)
        local obDrag, obStart, obPos = false, nil, nil
        openBtn.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton2 then
                obDrag = true
                obStart = inp.Position
                obPos = openBtn.Position
            end
        end)
        UIS.InputChanged:Connect(function(inp)
            if obDrag and inp.UserInputType == Enum.UserInputType.MouseMovement then
                local d = inp.Position - obStart
                openBtn.Position = UDim2.new(obPos.X.Scale, obPos.X.Offset + d.X, obPos.Y.Scale, obPos.Y.Offset + d.Y)
            end
        end)
        UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton2 then
                obDrag = false
            end
        end)
        
        -- ── Methods ──

        -- Notify
        self.Notify = function(_, text, color, duration)
            toast(text, color, duration)
        end

        -- Watermark
        self.Watermark = function(_, template)
            local wm = new("Frame", {
                Size = UDim2.new(0, 0, 0, 24),
                Position = UDim2.new(0, 16, 0, 16),
                BackgroundColor3 = C.bg,
                BackgroundTransparency = 0.04,
                BorderSizePixel = 0,
                Parent = screen,
            })
            corner(wm, 12)
            stroke(wm, C.stroke2, 1, 0.3)
            shadow(wm, 14, 0.7)

            local wmLbl = new("TextLabel", {
                Size = UDim2.new(1, -16, 1, 0),
                Position = UDim2.new(0, 8, 0, 0),
                BackgroundTransparency = 1,
                Text = template,
                TextColor3 = C.sub,
                TextSize = 10,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = wm,
            })

            task.defer(function()
                tweenBack(wm, {Size = UDim2.new(0, wmLbl.TextBounds.X + 20, 0, 24)}, 0.5)
            end)

            -- fps/ping refresh
            task.spawn(function()
                while wm and wm.Parent do
                    local fps = math.floor(1 / RS.RenderStepped:Wait())
                    local text = template
                        :gsub("{fps}", tostring(fps))
                        :gsub("{ping}", tostring(math.floor(LP:GetNetworkPing() * 1000)))
                    wmLbl.Text = text
                    tweenBack(wm, {Size = UDim2.new(0, wmLbl.TextBounds.X + 20, 0, 24)}, 0.15)
                    task.wait(0.5)
                end
            end)
        end

        -- SideBarLabel
        self.SideBarLabel = function(_, text)
            makeSideLabel(sideList, text)
        end

        -- SideBarButton
        self.SideBarButton = function(_, icon, label, onClick)
            makeSideButton(sideList, icon, label, onClick)
        end

        -- SideBarDivider
        self.SideBarDivider = function(_)
            makeSideDivider(sideList)
        end

        -- Toggle (window-level, in sidebar)
        self.Toggle = function(_, label, default, callback)
            local state = default or false
            local btn = new("TextButton", {
                Size = UDim2.new(1, 0, 0, 32),
                BackgroundColor3 = state and C.blueD or C.bg4,
                BackgroundTransparency = state and 0.2 or 0.5,
                BorderSizePixel = 0,
                Text = "",
                AutoButtonColor = false,
                Parent = sideList,
            })
            corner(btn, 8)
            stroke(btn, state and C.blueD or C.stroke2, 1, 0.4)

            local dotF = new("Frame", {
                Size = UDim2.new(0, 7, 0, 7),
                Position = UDim2.new(0, 9, 0.5, 0),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = state and C.green or C.dim,
                BorderSizePixel = 0,
                Parent = btn,
            })
            corner(dotF, 4)

            new("TextLabel", {
                Size = UDim2.new(1, -24, 1, 0),
                Position = UDim2.new(0, 22, 0, 0),
                BackgroundTransparency = 1,
                Text = label,
                TextColor3 = state and C.text or C.sub,
                TextSize = 11,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = btn,
            })

            btn.MouseButton1Click:Connect(function()
                state = not state
                tween(btn, {BackgroundColor3 = state and C.blueD or C.bg4, BackgroundTransparency = state and 0.2 or 0.5}, 0.2)
                tween(dotF, {BackgroundColor3 = state and C.green or C.dim}, 0.2)
                pcall(callback, state)
            end)
        end

        -- Tab
        self.Tab = function(_, label)
            local scroll = new("ScrollingFrame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = C.stroke2,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                Visible = false,
                Parent = scrollContainer,
            })

            local tab = createTab(scroll)
            local tabData = {scroll = scroll, tab = tab, label = label}
            table.insert(self._tabs, tabData)

            -- nav button
            local navBtn = new("TextButton", {
                Size = UDim2.new(0, 10, 1, -8),
                Position = UDim2.new(0, 0, 0, 4),
                BackgroundTransparency = 1,
                BackgroundColor3 = C.bg3,
                BorderSizePixel = 0,
                Text = label,
                TextColor3 = C.dim,
                TextSize = 11,
                Font = Enum.Font.GothamMedium,
                AutoButtonColor = false,
                Parent = tabNavList,
            })
            corner(navBtn, 8)
            padding(navBtn, 0, 0, 10, 10)

            task.defer(function()
                navBtn.Size = UDim2.new(0, navBtn.TextBounds.X + 24, 1, -8)
            end)

            local indicator = new("Frame", {
                Size = UDim2.new(0, 0, 0, 2),
                Position = UDim2.new(0.5, 0, 1, -1),
                AnchorPoint = Vector2.new(0.5, 0),
                BackgroundColor3 = C.blue,
                BorderSizePixel = 0,
                Parent = navBtn,
            })
            corner(indicator, 1)

            local function activate()
                -- deactivate all
                for _, td in ipairs(self._tabs) do
                    td.scroll.Visible = false
                end
                -- activate this
                scroll.Visible = true
                self._activeTab = tabData
                tween(navBtn, {TextColor3 = C.text, BackgroundTransparency = 0.6}, 0.18)
                tweenBack(indicator, {Size = UDim2.new(1, -12, 0, 2)}, 0.3)
            end

            navBtn.MouseButton1Click:Connect(activate)
            navBtn.MouseEnter:Connect(function()
                if self._activeTab ~= tabData then
                    tween(navBtn, {TextColor3 = C.sub, BackgroundTransparency = 0.8}, 0.15)
                end
            end)
            navBtn.MouseLeave:Connect(function()
                if self._activeTab ~= tabData then
                    tween(navBtn, {TextColor3 = C.dim, BackgroundTransparency = 1}, 0.15)
                end
            end)

            -- auto-activate first tab
            if #self._tabs == 1 then activate() end

            return tab
        end
    end

    -- boot with key or directly
    if config.Key then
        showKeySystem(config, function(tier)
            isPremium = (tier == "premium")
            buildMainUI()
            toast((config.Title or "Hub") .. " loaded — " .. (isPremium and "★ PREMIUM" or "FREE"), isPremium and C.gold or C.blue, 4)
        end)
    else
        buildMainUI()
    end

    return self
end

-- Standalone notify
function ZethUI:Notify(text, color, duration)
    toast(text, color, duration)
end

--------------------------------------------------------------
return ZethUI
