-- ============================================================
-- TzeUI | Roblox UI Library | By tze
-- Dark Midnight Theme | No external dependencies
-- ============================================================

local TzeUI = {}
TzeUI.__index = TzeUI

-- ── Services ──────────────────────────────────────────────
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local CoreGui          = game:GetService("CoreGui")

-- ── Theme ─────────────────────────────────────────────────
local T = {
    -- Backgrounds
    BG          = Color3.fromRGB(10,  10,  16 ),
    BG2         = Color3.fromRGB(15,  15,  23 ),
    BG3         = Color3.fromRGB(20,  20,  30 ),
    BG4         = Color3.fromRGB(26,  26,  38 ),
    BG5         = Color3.fromRGB(32,  32,  46 ),
    -- Accents
    Accent      = Color3.fromRGB(99,  102, 241),
    Accent2     = Color3.fromRGB(129, 132, 255),
    AccentDark  = Color3.fromRGB(67,  70,  185),
    -- Text
    Text        = Color3.fromRGB(225, 225, 240),
    TextSub     = Color3.fromRGB(140, 140, 165),
    TextDim     = Color3.fromRGB(80,  80,  105),
    -- States
    Green       = Color3.fromRGB(52,  211, 153),
    Red         = Color3.fromRGB(248, 113, 113),
    Orange      = Color3.fromRGB(251, 146, 60 ),
    Yellow      = Color3.fromRGB(250, 204, 21 ),
    -- Borders
    Border      = Color3.fromRGB(38,  38,  55 ),
    Border2     = Color3.fromRGB(50,  50,  70 ),
    -- Misc
    White       = Color3.fromRGB(255, 255, 255),
    Black       = Color3.fromRGB(0,   0,   0  ),
    Shadow      = Color3.fromRGB(0,   0,   0  ),
}

-- ── Tween Helper ──────────────────────────────────────────
local function tween(obj, props, dur, style, dir)
    if not obj or not obj.Parent then return end
    TweenService:Create(
        obj,
        TweenInfo.new(dur or 0.2, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

-- ── Instance Helpers ──────────────────────────────────────
local function new(class, props, parent)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        pcall(function() obj[k] = v end)
    end
    if parent then obj.Parent = parent end
    return obj
end

local function corner(parent, r)
    return new("UICorner", { CornerRadius = UDim.new(0, r or 8) }, parent)
end

local function stroke(parent, color, thick, transp)
    return new("UIStroke", {
        Color = color or T.Border,
        Thickness = thick or 1,
        Transparency = transp or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    }, parent)
end

local function padding(parent, t, b, l, r)
    return new("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
        PaddingRight  = UDim.new(0, r or 0),
    }, parent)
end

local function listLayout(parent, dir, pad, align)
    return new("UIListLayout", {
        FillDirection       = dir or Enum.FillDirection.Vertical,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Padding             = UDim.new(0, pad or 4),
        HorizontalAlignment = align or Enum.HorizontalAlignment.Left,
    }, parent)
end

local function makeLabel(txt, color, size, font, parent, props)
    local lbl = new("TextLabel", {
        Text                   = txt or "",
        TextColor3             = color or T.Text,
        TextSize               = size or 13,
        Font                   = font or Enum.Font.GothamMedium,
        BackgroundTransparency = 1,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextTruncate           = Enum.TextTruncate.AtEnd,
    }, parent)
    if props then for k,v in pairs(props) do pcall(function() lbl[k]=v end) end end
    return lbl
end

-- ── Auto-resize canvas ────────────────────────────────────
local function autoCanvas(scrollFrame, layoutObj)
    local function update()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, layoutObj.AbsoluteContentSize.Y + 12)
    end
    layoutObj:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(update)
    update()
end

-- ── Drag ──────────────────────────────────────────────────
local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
    handle.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
           or inp.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = inp.Position
            startPos  = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1
           or inp.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
           or inp.UserInputType == Enum.UserInputType.Touch) then
            local delta = inp.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ════════════════════════════════════════════════════════════
local notifHolder = nil

local function ensureNotifHolder()
    if notifHolder and notifHolder.Parent then return end
    local sg = new("ScreenGui", {
        Name = "TzeUI_Notifs",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9999,
    })
    pcall(function() sg.Parent = CoreGui end)
    if not sg.Parent then sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

    notifHolder = new("Frame", {
        Size = UDim2.new(0, 290, 1, -20),
        Position = UDim2.new(1, -306, 0, 10),
        BackgroundTransparency = 1,
    }, sg)
    listLayout(notifHolder, Enum.FillDirection.Vertical, 6)
end

local function Notify(opts)
    ensureNotifHolder()
    local title    = opts.Title    or "TzeUI"
    local content  = opts.Content  or ""
    local duration = opts.Duration or 3
    local iconChar = opts.Icon     or "•"

    local pill = new("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = T.BG3,
        BackgroundTransparency = 0.05,
        ClipsDescendants = true,
    }, notifHolder)
    corner(pill, 10)
    stroke(pill, T.Accent, 1, 0.4)

    local accentLine = new("Frame", {
        Size = UDim2.new(0, 3, 0.7, 0),
        Position = UDim2.new(0, 8, 0.15, 0),
        BackgroundColor3 = T.Accent,
    }, pill)
    corner(accentLine, 2)

    local titleLbl = makeLabel(title, T.Accent2, 12, Enum.Font.GothamBold, pill, {
        Size = UDim2.new(1, -28, 0, 14),
        Position = UDim2.new(0, 18, 0, 8),
    })
    local contentLbl = makeLabel(content, T.TextSub, 11, Enum.Font.Gotham, pill, {
        Size = UDim2.new(1, -28, 0, 14),
        Position = UDim2.new(0, 18, 0, 24),
        TextWrapped = true,
    })

    -- Animate in
    tween(pill, { Size = UDim2.new(1, 0, 0, 46) }, 0.3)

    -- Animate out
    task.delay(duration, function()
        tween(pill, { Size = UDim2.new(1, 0, 0, 0) }, 0.25)
        task.delay(0.3, function()
            pcall(function() pill:Destroy() end)
        end)
    end)
end

-- ════════════════════════════════════════════════════════════
-- WINDOW
-- ════════════════════════════════════════════════════════════
function TzeUI:CreateWindow(opts)
    opts = opts or {}
    local title        = opts.Title        or "TzeUI"
    local author       = opts.Author       or ""
    local watermarkTxt = opts.Watermark and opts.Watermark.Text or (title .. " | " .. author)
    local toggleKey    = opts.ToggleKey    or Enum.KeyCode.RightAlt
    local sidebarW     = opts.SideBarWidth or 180
    local winSize      = opts.Size         or UDim2.fromOffset(720, 480)

    -- ── Root ScreenGui ────────────────────────────────────
    local sg = new("ScreenGui", {
        Name = "TzeUI_" .. title,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 100,
        IgnoreGuiInset = true,
    })
    pcall(function() sg.Parent = CoreGui end)
    if not sg.Parent then sg.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

    -- ── Main Window Frame ─────────────────────────────────
    local win = new("Frame", {
        Size = winSize,
        Position = UDim2.new(0.5, -winSize.X.Offset/2, 0.5, -winSize.Y.Offset/2),
        BackgroundColor3 = T.BG,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, sg)
    corner(win, 12)
    stroke(win, T.Border, 1, 0)

    -- subtle shadow
    local shadowImg = new("ImageLabel", {
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -16),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = T.Black,
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49,49,450,450),
        ZIndex = 0,
    }, win)

    -- ── Topbar ────────────────────────────────────────────
    local topbar = new("Frame", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = T.BG2,
        BorderSizePixel = 0,
        ZIndex = 5,
    }, win)
    corner(topbar, 12)
    -- fix bottom corners of topbar
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 12),
        Position = UDim2.new(0, 0, 1, -12),
        BackgroundColor3 = T.BG2,
        BorderSizePixel = 0,
    }, topbar)

    stroke(topbar, T.Border, 1, 0.5)
    makeDraggable(win, topbar)

    -- Title
    local titleLabel = makeLabel(title, T.Text, 14, Enum.Font.GothamBold, topbar, {
        Size = UDim2.new(0.6, 0, 1, 0),
        Position = UDim2.new(0, 14, 0, 0),
    })

    -- Author badge
    if author ~= "" then
        local authorBadge = new("Frame", {
            Size = UDim2.new(0, 0, 0, 20),
            Position = UDim2.new(0, 14 + titleLabel.TextBounds.X + 8, 0.5, -10),
            BackgroundColor3 = T.AccentDark,
            AutomaticSize = Enum.AutomaticSize.X,
        }, topbar)
        corner(authorBadge, 10)
        padding(authorBadge, 0, 0, 8, 8)
        makeLabel(author, T.Accent2, 10, Enum.Font.GothamBold, authorBadge, {
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
        })
    end

    -- Close Button
    local closeBtn = new("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -36, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(200, 50, 50),
        Text = "×",
        TextColor3 = T.White,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 6,
    }, topbar)
    corner(closeBtn, 7)
    closeBtn.MouseEnter:Connect(function()
        tween(closeBtn, { BackgroundColor3 = Color3.fromRGB(240, 80, 80) }, 0.15)
    end)
    closeBtn.MouseLeave:Connect(function()
        tween(closeBtn, { BackgroundColor3 = Color3.fromRGB(200, 50, 50) }, 0.15)
    end)
    closeBtn.MouseButton1Click:Connect(function()
        tween(win, { Size = UDim2.new(win.Size.X.Scale, win.Size.X.Offset, 0, 0) }, 0.25)
        task.delay(0.3, function() sg:Destroy() end)
    end)

    -- Minimize Button
    local minimized = false
    local fullSize  = win.Size
    local minBtn = new("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -70, 0.5, -14),
        BackgroundColor3 = T.BG4,
        Text = "–",
        TextColor3 = T.TextSub,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
        ZIndex = 6,
    }, topbar)
    corner(minBtn, 7)
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            fullSize = win.Size
            tween(win, { Size = UDim2.new(win.Size.X.Scale, win.Size.X.Offset, 0, 42) }, 0.25)
        else
            tween(win, { Size = fullSize }, 0.25)
        end
    end)

    -- ── Body ─────────────────────────────────────────────
    local body = new("Frame", {
        Size = UDim2.new(1, 0, 1, -42),
        Position = UDim2.new(0, 0, 0, 42),
        BackgroundTransparency = 1,
    }, win)

    -- ── Sidebar ───────────────────────────────────────────
    local sidebar = new("Frame", {
        Size = UDim2.new(0, sidebarW, 1, 0),
        BackgroundColor3 = T.BG2,
        BorderSizePixel = 0,
    }, body)
    -- right border
    new("Frame", {
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(1, -1, 0, 0),
        BackgroundColor3 = T.Border,
    }, sidebar)

    local sidebarScroll = new("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, -8),
        Position = UDim2.new(0, 0, 0, 8),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = T.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    }, sidebar)
    local sidebarLayout = listLayout(sidebarScroll, Enum.FillDirection.Vertical, 2)
    padding(sidebarScroll, 4, 4, 6, 6)
    autoCanvas(sidebarScroll, sidebarLayout)

    -- ── Tab content area ──────────────────────────────────
    local contentArea = new("Frame", {
        Size = UDim2.new(1, -sidebarW, 1, -44),
        Position = UDim2.new(0, sidebarW, 0, 0),
        BackgroundTransparency = 1,
    }, body)

    -- ── Tab buttons (horizontal, top of content) ──────────
    local tabBar = new("Frame", {
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = T.BG3,
        BorderSizePixel = 0,
    }, contentArea)
    new("Frame", {
        Size = UDim2.new(1, 0, 0, 1),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.Border,
    }, tabBar)
    local tabBarScroll = new("ScrollingFrame", {
        Size = UDim2.new(1, -8, 1, 0),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
    }, tabBar)
    local tabBarLayout = listLayout(tabBarScroll, Enum.FillDirection.Horizontal, 2)
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,2), VerticalAlignment = Enum.VerticalAlignment.Center }, tabBarScroll)
    padding(tabBarScroll, 0, 0, 4, 4)

    local tabPages = new("Frame", {
        Size = UDim2.new(1, 0, 1, -36),
        Position = UDim2.new(0, 0, 0, 36),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
    }, contentArea)

    -- ── Watermark ─────────────────────────────────────────
    local wmFrame = new("Frame", {
        Size = UDim2.new(0, 0, 0, 22),
        Position = UDim2.new(1, -8, 1, -30),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundColor3 = T.BG3,
        BackgroundTransparency = 0.1,
        AutomaticSize = Enum.AutomaticSize.X,
    }, sg)
    corner(wmFrame, 6)
    stroke(wmFrame, T.Border, 1, 0.5)
    padding(wmFrame, 0, 0, 8, 8)
    makeLabel(watermarkTxt, T.TextDim, 10, Enum.Font.Gotham, wmFrame, {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
    })

    -- ── Tags ──────────────────────────────────────────────
    local tagHolder = new("Frame", {
        Size = UDim2.new(0, 0, 0, 22),
        Position = UDim2.new(1, -80, 0.5, -11),
        BackgroundTransparency = 1,
        AutomaticSize = Enum.AutomaticSize.X,
    }, topbar)
    new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,4), VerticalAlignment = Enum.VerticalAlignment.Center }, tagHolder)

    -- ── Shortcut toggler ──────────────────────────────────
    local shortcuts = {}
    UserInputService.InputBegan:Connect(function(inp, gp)
        if inp.KeyCode == toggleKey then
            win.Visible = not win.Visible
        end
        for _, sc in ipairs(shortcuts) do
            if inp.KeyCode == sc.key then
                pcall(sc.cb)
            end
        end
    end)

    -- ─────────────────────────────────────────────────────
    -- Window API object
    -- ─────────────────────────────────────────────────────
    local W = {}
    W._sg          = sg
    W._win         = win
    W._sidebarList = sidebarScroll
    W._sidebarLayout = sidebarLayout
    W._tabBar      = tabBarScroll
    W._tabPages    = tabPages
    W._activeTab   = nil
    W._tabButtons  = {}
    W._notify      = Notify

    function W:Toggle() win.Visible = not win.Visible end
    function W:SetVisible(v) win.Visible = v end

    function W:Notify(opts) Notify(opts) end

    function W:BindShortcut(keyName, cb, info)
        local ok, key = pcall(function() return Enum.KeyCode[keyName] end)
        if ok and key then
            table.insert(shortcuts, { key = key, cb = cb, info = info })
        end
    end

    function W:Tag(opts)
        local tagFrame = new("Frame", {
            Size = UDim2.new(0, 0, 1, -4),
            BackgroundColor3 = opts.Color or T.Accent,
            BackgroundTransparency = 0.7,
            AutomaticSize = Enum.AutomaticSize.X,
        }, tagHolder)
        corner(tagFrame, 10)
        padding(tagFrame, 0, 0, 6, 6)
        makeLabel(opts.Title or "", opts.Color or T.Accent2, 9, Enum.Font.GothamBold, tagFrame, {
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
        })
    end

    function W:SetBackgroundImage(id)
        local img = new("ImageLabel", {
            Size = UDim2.fromScale(1,1),
            BackgroundTransparency = 1,
            Image = id,
            ImageTransparency = 0.94,
            ScaleType = Enum.ScaleType.Crop,
            ZIndex = 0,
        }, win)
    end

    function W:ToggleTransparency(enabled)
        win.BackgroundTransparency = enabled and 0.08 or 0
    end

    -- ── Sidebar elements ──────────────────────────────────
    function W:SideBarLabel(opts)
        local f = new("Frame", {
            Size = UDim2.new(1, 0, 0, 22),
            BackgroundTransparency = 1,
        }, self._sidebarList)
        makeLabel(opts.Title or "", T.TextDim, 10, Enum.Font.GothamBold, f, {
            Size = UDim2.fromScale(1,1),
            TextXAlignment = Enum.TextXAlignment.Left,
        })
    end

    function W:SideBarDivider()
        new("Frame", {
            Size = UDim2.new(1, -8, 0, 1),
            BackgroundColor3 = T.Border,
            BorderSizePixel = 0,
        }, self._sidebarList)
    end

    function W:SideBarButton(opts)
        local btn = new("TextButton", {
            Size = UDim2.new(1, 0, 0, 30),
            BackgroundColor3 = T.BG3,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
        }, self._sidebarList)
        corner(btn, 7)
        padding(btn, 0, 0, 8, 8)

        makeLabel(opts.Title or "", T.TextSub, 12, Enum.Font.GothamMedium, btn, {
            Size = UDim2.fromScale(1,1),
        })
        btn.MouseEnter:Connect(function()
            tween(btn, { BackgroundTransparency = 0, BackgroundColor3 = T.BG4 }, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, { BackgroundTransparency = 1 }, 0.15)
        end)
        btn.MouseButton1Click:Connect(function()
            pcall(opts.Callback or function() end)
        end)
        return btn
    end

    -- ── OpenButton (floating toggle) ──────────────────────
    function W:OpenButton(opts)
        opts = opts or {}
        local ob = new("TextButton", {
            Size = UDim2.new(0, 110, 0, 36),
            Position = opts.Position or UDim2.new(0, 120, 0, 120),
            BackgroundColor3 = T.BG3,
            Text = opts.Title or "TzeUI",
            TextColor3 = T.Accent2,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            AutoButtonColor = false,
            ZIndex = 50,
        }, sg)
        corner(ob, 10)
        stroke(ob, T.Accent, 1, 0.3)
        if opts.Draggable then makeDraggable(ob) end
        ob.MouseButton1Click:Connect(function() self:Toggle() end)
        return ob
    end

    -- ── Tabs ──────────────────────────────────────────────
    function W:Tab(opts)
        local tabTitle = opts.Title or "Tab"
        local order    = #self._tabButtons + 1

        -- Tab button
        local tabBtn = new("TextButton", {
            Size = UDim2.new(0, 0, 1, -8),
            BackgroundColor3 = T.BG3,
            BackgroundTransparency = 1,
            Text = tabTitle,
            TextColor3 = T.TextDim,
            TextSize = 12,
            Font = Enum.Font.GothamMedium,
            AutoButtonColor = false,
            AutomaticSize = Enum.AutomaticSize.X,
            LayoutOrder = order,
        }, self._tabBar)
        corner(tabBtn, 7)
        padding(tabBtn, 0, 0, 10, 10)

        -- Active underline
        local underline = new("Frame", {
            Size = UDim2.new(1, 0, 0, 2),
            Position = UDim2.new(0, 0, 1, -2),
            BackgroundColor3 = T.Accent,
            BackgroundTransparency = 1,
        }, tabBtn)

        -- Tab page
        local page = new("ScrollingFrame", {
            Size = UDim2.fromScale(1,1),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = T.Accent,
            Visible = false,
            CanvasSize = UDim2.new(0,0,0,0),
        }, self._tabPages)
        local pageLayout = listLayout(page, Enum.FillDirection.Vertical, 6)
        padding(page, 8, 8, 10, 10)
        autoCanvas(page, pageLayout)

        -- Switch logic
        table.insert(self._tabButtons, { btn = tabBtn, page = page, ul = underline })

        local function activate()
            for _, t in ipairs(self._tabButtons) do
                t.page.Visible = false
                tween(t.btn, { TextColor3 = T.TextDim, BackgroundTransparency = 1 }, 0.15)
                tween(t.ul, { BackgroundTransparency = 1 }, 0.15)
            end
            page.Visible = true
            self._activeTab = page
            tween(tabBtn, { TextColor3 = T.Accent2, BackgroundTransparency = 0 }, 0.15)
            tween(underline, { BackgroundTransparency = 0 }, 0.15)
        end

        tabBtn.MouseButton1Click:Connect(activate)
        tabBtn.MouseEnter:Connect(function()
            if page.Visible then return end
            tween(tabBtn, { TextColor3 = T.TextSub }, 0.1)
        end)
        tabBtn.MouseLeave:Connect(function()
            if page.Visible then return end
            tween(tabBtn, { TextColor3 = T.TextDim }, 0.1)
        end)

        -- Auto-select first tab
        if order == 1 then activate() end

        -- ── Tab API ───────────────────────────────────────
        local Tab = {}
        Tab._page   = page
        Tab._window = self

        local function addToPage(el) el.Parent = page end

        -- Divider
        function Tab:Divider()
            new("Frame", {
                Size = UDim2.new(1, -8, 0, 1),
                BackgroundColor3 = T.Border,
                BorderSizePixel = 0,
            }, page)
        end

        -- Paragraph
        function Tab:Paragraph(opts)
            local f = new("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = T.BG3,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y,
            }, page)
            corner(f, 8)
            stroke(f, T.Border)
            padding(f, 10, 10, 12, 12)
            local inner = new("Frame", { Size = UDim2.new(1,0,0,0), BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y }, f)
            listLayout(inner, Enum.FillDirection.Vertical, 4)

            if opts.Title then
                makeLabel(opts.Title, T.Text, 13, Enum.Font.GothamBold, inner, {
                    Size = UDim2.new(1,0,0,16), AutomaticSize = Enum.AutomaticSize.Y,
                    TextWrapped = true
                })
            end
            if opts.Desc then
                makeLabel(opts.Desc, T.TextSub, 11, Enum.Font.Gotham, inner, {
                    Size = UDim2.new(1,0,0,0), AutomaticSize = Enum.AutomaticSize.Y,
                    TextWrapped = true
                })
            end
            if opts.Buttons then
                local btnRow = new("Frame", { Size=UDim2.new(1,0,0,28), BackgroundTransparency=1 }, inner)
                new("UIListLayout", { FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,4) }, btnRow)
                for _, b in ipairs(opts.Buttons) do
                    local bb = new("TextButton", {
                        Size = UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
                        BackgroundColor3 = T.Accent,
                        Text = b.Title or "", TextColor3 = T.White,
                        TextSize = 11, Font = Enum.Font.GothamBold,
                        AutoButtonColor = false,
                    }, btnRow)
                    corner(bb, 6)
                    padding(bb,0,0,8,8)
                    bb.MouseButton1Click:Connect(function() pcall(b.Callback or function()end) end)
                end
            end
        end

        -- Stats
        function Tab:Stats(opts)
            local f = new("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = T.BG3,
                AutomaticSize = Enum.AutomaticSize.Y,
                BorderSizePixel = 0,
            }, page)
            corner(f, 8)
            stroke(f, T.Border)
            padding(f, 8, 8, 12, 12)
            local inner = new("Frame", { Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y }, f)
            listLayout(inner, Enum.FillDirection.Vertical, 3)

            if opts.Title then
                makeLabel(opts.Title, T.Text, 12, Enum.Font.GothamBold, inner, {
                    Size = UDim2.new(1,0,0,16)
                })
            end
            if opts.Items then
                for _, item in ipairs(opts.Items) do
                    local row = new("Frame", { Size=UDim2.new(1,0,0,18), BackgroundTransparency=1 }, inner)
                    makeLabel(item.Key .. ":", T.TextSub, 11, Enum.Font.Gotham, row, {
                        Size = UDim2.new(0.5,0,1,0),
                    })
                    makeLabel(tostring(item.Value), T.Accent2, 11, Enum.Font.GothamMedium, row, {
                        Size = UDim2.new(0.5,0,1,0),
                        Position = UDim2.new(0.5,0,0,0),
                    })
                end
            end
        end

        -- Code block
        function Tab:Code(opts)
            local f = new("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = T.BG4,
                AutomaticSize = Enum.AutomaticSize.Y,
                BorderSizePixel = 0,
            }, page)
            corner(f, 8)
            stroke(f, T.Border)
            padding(f, 8, 8, 10, 10)

            local titleRow = new("Frame", { Size=UDim2.new(1,0,0,18), BackgroundTransparency=1 }, f)
            if opts.Title then
                makeLabel(opts.Title, T.TextSub, 10, Enum.Font.GothamBold, titleRow, {
                    Size = UDim2.new(1,-60,1,0),
                })
            end

            -- Copy button
            local copyBtn = new("TextButton", {
                Size = UDim2.new(0,50,0,18),
                Position = UDim2.new(1,-50,0,0),
                BackgroundColor3 = T.Accent,
                Text = "Copy",
                TextColor3 = T.White,
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                AutoButtonColor = false,
            }, titleRow)
            corner(copyBtn, 4)

            local codeBox = new("TextLabel", {
                Size = UDim2.new(1,0,0,0),
                BackgroundColor3 = T.BG5,
                Text = opts.Code or "",
                TextColor3 = Color3.fromRGB(130,200,130),
                TextSize = 10,
                Font = Enum.Font.Code,
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                AutomaticSize = Enum.AutomaticSize.Y,
            }, f)
            corner(codeBox, 6)
            padding(codeBox, 6, 6, 8, 8)

            copyBtn.MouseButton1Click:Connect(function()
                pcall(function() setclipboard(opts.Code or "") end)
                copyBtn.Text = "✓"
                task.delay(1.5, function() copyBtn.Text = "Copy" end)
                pcall(opts.OnCopy or function()end)
            end)
        end

        -- Section
        function Tab:Section(opts)
            local sectionFrame = new("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = T.BG3,
                BackgroundTransparency = opts.Box and 0 or 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                BorderSizePixel = 0,
                ClipsDescendants = false,
            }, page)
            corner(sectionFrame, 8)
            if opts.Box then stroke(sectionFrame, opts.BoxBorder and T.Border2 or T.Border) end

            -- Header
            local header = new("TextButton", {
                Size = UDim2.new(1,0,0,34),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false,
            }, sectionFrame)

            local headerTitle = makeLabel(opts.Title or "", T.Text, 12, Enum.Font.GothamBold, header, {
                Size = UDim2.new(1,-30,1,0),
                Position = UDim2.new(0,10,0,0),
            })
            if opts.Desc then
                makeLabel(opts.Desc, T.TextDim, 10, Enum.Font.Gotham, header, {
                    Size = UDim2.new(1,-30,0,12),
                    Position = UDim2.new(0,10,0.5,0),
                })
            end

            -- Collapse arrow
            local arrow = makeLabel("▾", T.TextSub, 14, Enum.Font.GothamBold, header, {
                Size = UDim2.new(0,20,1,0),
                Position = UDim2.new(1,-24,0,0),
                TextXAlignment = Enum.TextXAlignment.Center,
            })

            -- Content container
            local content = new("Frame", {
                Size = UDim2.new(1,-12,0,0),
                Position = UDim2.new(0,6,0,34),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
            }, sectionFrame)
            local contentLayout = listLayout(content, Enum.FillDirection.Vertical, 4)
            padding(content, 0, 6, 0, 0)

            local open = opts.Opened ~= false
            local function setOpen(v)
                open = v
                content.Visible = v
                arrow.Text = v and "▾" or "▸"
            end
            setOpen(open)

            header.MouseButton1Click:Connect(function()
                setOpen(not open)
            end)

            -- Section element API (mirrors Tab API)
            local S = {}
            S._content = content

            local function addEl(el) el.Parent = content end

            -- reuse same element builders but target section content
            local function buildToggle(parent, opts2)
                local row = new("Frame", {
                    Size = UDim2.new(1,0,0,34),
                    BackgroundColor3 = T.BG4,
                    BorderSizePixel = 0,
                }, parent)
                corner(row, 7)

                makeLabel(opts2.Title or "", T.Text, 12, Enum.Font.GothamMedium, row, {
                    Size = UDim2.new(1,-60,0,18), Position = UDim2.new(0,10,0,4),
                })
                if opts2.Desc then
                    makeLabel(opts2.Desc, T.TextDim, 10, Enum.Font.Gotham, row, {
                        Size = UDim2.new(1,-60,0,12), Position = UDim2.new(0,10,0,20),
                    })
                end

                -- Toggle pill
                local pill = new("Frame", {
                    Size = UDim2.new(0,36,0,18),
                    Position = UDim2.new(1,-46,0.5,-9),
                    BackgroundColor3 = T.BG5,
                }, row)
                corner(pill, 9)

                local knob = new("Frame", {
                    Size = UDim2.new(0,14,0,14),
                    Position = UDim2.new(0,2,0.5,-7),
                    BackgroundColor3 = T.TextDim,
                }, pill)
                corner(knob, 7)

                local state = opts2.Value or false
                local function setState(v)
                    state = v
                    tween(knob, {
                        Position = v and UDim2.new(0,20,0.5,-7) or UDim2.new(0,2,0.5,-7),
                        BackgroundColor3 = v and T.White or T.TextDim,
                    }, 0.15)
                    tween(pill, { BackgroundColor3 = v and T.Accent or T.BG5 }, 0.15)
                    pcall(function() opts2.Callback(v) end)
                end
                setState(state)

                local clickArea = new("TextButton", {
                    Size = UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", AutoButtonColor=false,
                }, row)
                clickArea.MouseButton1Click:Connect(function() setState(not state) end)

                return row
            end

            local function buildButton(parent, opts2)
                local btn = new("TextButton", {
                    Size = UDim2.new(1,0,0, opts2.Desc and 42 or 32),
                    BackgroundColor3 = T.BG4,
                    Text = "",
                    AutoButtonColor = false,
                    BorderSizePixel = 0,
                }, parent)
                corner(btn, 7)

                makeLabel(opts2.Title or "", T.Text, 12, Enum.Font.GothamMedium, btn, {
                    Size = UDim2.new(1,-12,0,16), Position = UDim2.new(0,10,0, opts2.Desc and 6 or 8),
                })
                if opts2.Desc then
                    makeLabel(opts2.Desc, T.TextDim, 10, Enum.Font.Gotham, btn, {
                        Size = UDim2.new(1,-12,0,14), Position = UDim2.new(0,10,0,22),
                    })
                end
                btn.MouseEnter:Connect(function() tween(btn, { BackgroundColor3 = T.BG5 }, 0.12) end)
                btn.MouseLeave:Connect(function() tween(btn, { BackgroundColor3 = T.BG4 }, 0.12) end)
                btn.MouseButton1Click:Connect(function() pcall(opts2.Callback or function()end) end)
                return btn
            end

            local function buildSlider(parent, opts2)
                local range   = opts2.Value or { Min=0, Max=100, Default=50 }
                local step    = opts2.Step or 1
                local suffix  = opts2.Suffix or ""
                local current = range.Default or range.Min

                local f = new("Frame", {
                    Size = UDim2.new(1,0,0,52),
                    BackgroundColor3 = T.BG4,
                    BorderSizePixel = 0,
                }, parent)
                corner(f, 7)

                makeLabel(opts2.Title or "", T.Text, 12, Enum.Font.GothamMedium, f, {
                    Size = UDim2.new(1,-60,0,16), Position = UDim2.new(0,10,0,6),
                })

                local valLabel = makeLabel(tostring(current)..suffix, T.Accent2, 11, Enum.Font.GothamBold, f, {
                    Size = UDim2.new(0,50,0,16), Position = UDim2.new(1,-58,0,6),
                    TextXAlignment = Enum.TextXAlignment.Right,
                })

                local track = new("Frame", {
                    Size = UDim2.new(1,-20,0,4),
                    Position = UDim2.new(0,10,0,32),
                    BackgroundColor3 = T.BG5,
                    BorderSizePixel = 0,
                }, f)
                corner(track, 2)

                local fill = new("Frame", {
                    Size = UDim2.new((current-range.Min)/(range.Max-range.Min),0,1,0),
                    BackgroundColor3 = T.Accent,
                    BorderSizePixel = 0,
                }, track)
                corner(fill, 2)

                local knob = new("Frame", {
                    Size = UDim2.new(0,12,0,12),
                    BackgroundColor3 = T.White,
                    BorderSizePixel = 0,
                }, track)
                corner(knob, 6)

                local function updateKnob(alpha)
                    knob.Position = UDim2.new(alpha, -6, 0.5, -6)
                    fill.Size     = UDim2.new(alpha, 0, 1, 0)
                end
                updateKnob((current-range.Min)/(range.Max-range.Min))

                local dragging = false
                local hitbox = new("TextButton", {
                    Size = UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", AutoButtonColor=false,
                }, track)

                local function applyPosition(x)
                    local alpha = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    local raw   = range.Min + alpha*(range.Max-range.Min)
                    local steps = math.round((raw-range.Min)/step)
                    current     = math.clamp(range.Min + steps*step, range.Min, range.Max)
                    alpha       = (current-range.Min)/(range.Max-range.Min)
                    updateKnob(alpha)
                    valLabel.Text = string.format(step < 1 and "%.1f" or "%d", current) .. suffix
                    pcall(function() opts2.Callback(current) end)
                end

                hitbox.InputBegan:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                       or inp.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        applyPosition(inp.Position.X)
                    end
                end)
                hitbox.InputEnded:Connect(function(inp)
                    if inp.UserInputType == Enum.UserInputType.MouseButton1
                       or inp.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                UserInputService.InputChanged:Connect(function(inp)
                    if dragging and (inp.UserInputType == Enum.UserInputType.MouseMovement
                       or inp.UserInputType == Enum.UserInputType.Touch) then
                        applyPosition(inp.Position.X)
                    end
                end)

                if opts2.IsTextbox then
                    local tb = new("TextBox", {
                        Size = UDim2.new(0,46,0,16),
                        Position = UDim2.new(1,-54,0,6),
                        BackgroundColor3 = T.BG5,
                        Text = tostring(current),
                        TextColor3 = T.Accent2,
                        TextSize = 11,
                        Font = Enum.Font.GothamBold,
                        ClearTextOnFocus = false,
                        BorderSizePixel = 0,
                    }, f)
                    corner(tb, 4)
                    -- hide valLabel, use textbox instead
                    valLabel.Visible = false
                    tb.FocusLost:Connect(function()
                        local v = tonumber(tb.Text)
                        if v then
                            current = math.clamp(v, range.Min, range.Max)
                            local alpha = (current-range.Min)/(range.Max-range.Min)
                            updateKnob(alpha)
                            tb.Text = string.format(step < 1 and "%.1f" or "%d", current) .. suffix
                            pcall(function() opts2.Callback(current) end)
                        else
                            tb.Text = tostring(current)
                        end
                    end)
                end

                return f
            end

            local function buildDropdown(parent, opts2)
                local values  = opts2.Values or {}
                local current = opts2.Value  or (values[1] or "")
                local open2   = false

                local f = new("Frame", {
                    Size = UDim2.new(1,0,0,34),
                    BackgroundColor3 = T.BG4,
                    BorderSizePixel = 0,
                    ZIndex = 10,
                    ClipsDescendants = false,
                }, parent)
                corner(f, 7)

                makeLabel(opts2.Title or "", T.Text, 12, Enum.Font.GothamMedium, f, {
                    Size = UDim2.new(0.55,0,1,0), Position = UDim2.new(0,10,0,0),
                })

                local selectedBtn = new("TextButton", {
                    Size = UDim2.new(0.42,0,0,24),
                    Position = UDim2.new(0.57,0,0.5,-12),
                    BackgroundColor3 = T.BG5,
                    Text = current,
                    TextColor3 = T.Accent2,
                    TextSize = 11,
                    Font = Enum.Font.GothamMedium,
                    AutoButtonColor = false,
                    ZIndex = 11,
                }, f)
                corner(selectedBtn, 6)

                local dropdown = new("Frame", {
                    Size = UDim2.new(0.42,0,0,0),
                    Position = UDim2.new(0.57,0,1,2),
                    BackgroundColor3 = T.BG4,
                    BorderSizePixel = 0,
                    ZIndex = 20,
                    ClipsDescendants = true,
                    Visible = false,
                }, f)
                corner(dropdown, 7)
                stroke(dropdown, T.Border)

                local dropList = new("Frame", {
                    Size = UDim2.new(1,0,0,0),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                }, dropdown)
                listLayout(dropList, Enum.FillDirection.Vertical, 1)
                padding(dropList, 2, 2, 2, 2)

                local function buildOptions()
                    dropList:ClearAllChildren()
                    listLayout(dropList, Enum.FillDirection.Vertical, 1)
                    padding(dropList, 2, 2, 2, 2)
                    for _, v in ipairs(values) do
                        local optBtn = new("TextButton", {
                            Size = UDim2.new(1,0,0,26),
                            BackgroundColor3 = T.BG4,
                            BackgroundTransparency = 1,
                            Text = tostring(v),
                            TextColor3 = v == current and T.Accent2 or T.TextSub,
                            TextSize = 11,
                            Font = Enum.Font.GothamMedium,
                            AutoButtonColor = false,
                            ZIndex = 21,
                        }, dropList)
                        corner(optBtn, 5)
                        optBtn.MouseEnter:Connect(function() tween(optBtn,{BackgroundTransparency=0,BackgroundColor3=T.BG5},0.1) end)
                        optBtn.MouseLeave:Connect(function() tween(optBtn,{BackgroundTransparency=1},0.1) end)
                        optBtn.MouseButton1Click:Connect(function()
                            current = v
                            selectedBtn.Text = tostring(v)
                            pcall(function() opts2.Callback(v) end)
                            open2 = false
                            tween(dropdown, { Size = UDim2.new(0.42,0,0,0) }, 0.15)
                            task.delay(0.15, function() dropdown.Visible = false end)
                        end)
                    end
                end
                buildOptions()

                selectedBtn.MouseButton1Click:Connect(function()
                    open2 = not open2
                    if open2 then
                        dropdown.Visible = true
                        local h = math.min(#values * 28 + 4, 160)
                        tween(dropdown, { Size = UDim2.new(0.42,0,0,h) }, 0.15)
                    else
                        tween(dropdown, { Size = UDim2.new(0.42,0,0,0) }, 0.15)
                        task.delay(0.15, function() dropdown.Visible = false end)
                    end
                end)

                return f, function(newVals)
                    values = newVals; buildOptions()
                end
            end

            local function buildInput(parent, opts2)
                local f = new("Frame", {
                    Size = UDim2.new(1,0,0,48),
                    BackgroundColor3 = T.BG4,
                    BorderSizePixel = 0,
                }, parent)
                corner(f, 7)

                makeLabel(opts2.Title or "", T.Text, 12, Enum.Font.GothamMedium, f, {
                    Size = UDim2.new(1,-12,0,16), Position = UDim2.new(0,10,0,4),
                })
                local tb = new("TextBox", {
                    Size = UDim2.new(1,-20,0,20),
                    Position = UDim2.new(0,10,0,24),
                    BackgroundColor3 = T.BG5,
                    PlaceholderText = opts2.Placeholder or "",
                    PlaceholderColor3 = T.TextDim,
                    Text = "",
                    TextColor3 = T.Text,
                    TextSize = 12,
                    Font = Enum.Font.GothamMedium,
                    ClearTextOnFocus = false,
                    BorderSizePixel = 0,
                }, f)
                corner(tb, 5)
                padding(tb, 0, 0, 6, 6)

                local inputStroke = stroke(tb, T.Border)
                tb.Focused:Connect(function() tween(inputStroke,{Color=T.Accent},0.15) end)
                tb.FocusLost:Connect(function()
                    tween(inputStroke,{Color=T.Border},0.15)
                    if tb.Text ~= "" then pcall(function() opts2.Callback(tb.Text) end) end
                end)
                return f
            end

            local function buildGroup(parent, opts2)
                local gf = new("Frame", {
                    Size = UDim2.new(1,0,0,0),
                    BackgroundTransparency = 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                }, parent)
                local gl = listLayout(gf, Enum.FillDirection.Horizontal, 4)

                local G2 = {}
                function G2:Button(o)
                    local bb = new("TextButton", {
                        Size = UDim2.new(0,0,0,30),
                        BackgroundColor3 = T.BG4,
                        Text = "",
                        AutoButtonColor = false,
                        AutomaticSize = Enum.AutomaticSize.X,
                        BorderSizePixel = 0,
                    }, gf)
                    corner(bb, 7)
                    padding(bb,0,0,10,10)
                    makeLabel(o.Title or "", T.Text, 12, Enum.Font.GothamMedium, bb, {
                        Size = UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X
                    })
                    bb.MouseEnter:Connect(function() tween(bb,{BackgroundColor3=T.BG5},0.12) end)
                    bb.MouseLeave:Connect(function() tween(bb,{BackgroundColor3=T.BG4},0.12) end)
                    bb.MouseButton1Click:Connect(function() pcall(o.Callback or function()end) end)
                end
                return G2, gf
            end

            -- Section public methods
            function S:Toggle(o)    addEl(buildToggle(content, o)) end
            function S:Button(o)    addEl(buildButton(content, o)) end
            function S:Slider(o)    addEl(buildSlider(content, o)) end
            function S:Input(o)     addEl(buildInput(content, o)) end
            function S:Divider()
                new("Frame",{ Size=UDim2.new(1,-8,0,1), BackgroundColor3=T.Border, BorderSizePixel=0 }, content)
            end
            function S:Dropdown(o)
                local el, refresh = buildDropdown(content, o)
                addEl(el)
                return { Refresh = refresh }
            end
            function S:Group(o)
                local G2, gf = buildGroup(content, o or {})
                addEl(gf)
                return G2
            end
            function S:Paragraph(o)
                local pf = new("Frame",{
                    Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y
                }, content)
                local pl = listLayout(pf, Enum.FillDirection.Vertical, 2)
                if o.Title then makeLabel(o.Title, T.Text,12,Enum.Font.GothamBold,pf,{Size=UDim2.new(1,0,0,16)}) end
                if o.Desc  then makeLabel(o.Desc,  T.TextSub,10,Enum.Font.Gotham,pf,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true}) end
                addEl(pf)
            end

            return S
        end

        -- Tab-level elements (pass through to page directly)
        function Tab:Toggle(o)
            local s = self:Section({ Box = false, Opened = true })
            s:Toggle(o)
        end
        function Tab:Button(o)
            local s = self:Section({ Box = false, Opened = true })
            s:Button(o)
        end
        function Tab:Slider(o)
            local s = self:Section({ Box = false, Opened = true })
            s:Slider(o)
        end
        function Tab:Input(o)
            local s = self:Section({ Box = false, Opened = true })
            s:Input(o)
        end
        function Tab:Dropdown(o)
            local s = self:Section({ Box = false, Opened = true })
            return s:Dropdown(o)
        end
        function Tab:Group(o)
            local s = self:Section({ Box = false, Opened = true })
            return s:Group(o)
        end
        function Tab:Stats(o)   self:Stats(o)   end
        function Tab:Code(o)    self:Code(o)    end
        function Tab:Paragraph(o) self:Paragraph(o) end

        return Tab
    end

    -- SelectTab by reference
    function W:SelectTab(tab)
        for _, t in ipairs(self._tabButtons) do
            if t.page == tab._page then
                t.btn:GetPropertyChangedSignal and nil
                t.btn.MouseButton1Click:Fire()
                -- fire manually
                for _, tt in ipairs(self._tabButtons) do
                    tt.page.Visible = false
                end
                tab._page.Visible = true
                break
            end
        end
    end

    return W
end

-- ── Expose Notify at top level ────────────────────────────
function TzeUI:Notify(opts) Notify(opts) end

return TzeUI
