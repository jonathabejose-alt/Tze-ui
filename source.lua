-- ╔══════════════════════════════════════════════════════╗
-- ║           TzeUI  —  Modern Roblox UI Library         ║
-- ║           Dark Glass Theme  |  By tze                ║
-- ╚══════════════════════════════════════════════════════╝

local TzeUI = {}

-- ── Services ──────────────────────────────────────────────────────────────────
local TS   = game:GetService("TweenService")
local UIS  = game:GetService("UserInputService")
local RS   = game:GetService("RunService")
local CG   = game:GetService("CoreGui")
local PL   = game:GetService("Players")

-- ── Palette ───────────────────────────────────────────────────────────────────
local C = {
    -- Base layers
    Base        = Color3.fromRGB(8,   8,  14),
    Surface     = Color3.fromRGB(13,  13,  20),
    Elevated    = Color3.fromRGB(18,  18,  28),
    Raised      = Color3.fromRGB(24,  24,  36),
    Overlay     = Color3.fromRGB(30,  30,  46),
    -- Accent
    Accent      = Color3.fromRGB(110, 115, 255),
    AccentBright= Color3.fromRGB(140, 145, 255),
    AccentGlow  = Color3.fromRGB(70,  75,  200),
    AccentDim   = Color3.fromRGB(50,  52,  140),
    -- Text
    Text        = Color3.fromRGB(230, 230, 245),
    TextSub     = Color3.fromRGB(150, 150, 175),
    TextMute    = Color3.fromRGB(75,  75,  100),
    -- Borders
    Border      = Color3.fromRGB(35,  35,  52),
    BorderBright= Color3.fromRGB(55,  55,  78),
    -- States
    Green       = Color3.fromRGB(52,  211, 153),
    Red         = Color3.fromRGB(248, 113, 113),
    Yellow      = Color3.fromRGB(250, 204, 21),
    Orange      = Color3.fromRGB(251, 146, 60),
    -- Pure
    White       = Color3.fromRGB(255, 255, 255),
    Black       = Color3.fromRGB(0,   0,   0),
}

-- ── Tween ─────────────────────────────────────────────────────────────────────
local function tw(obj, props, t, style, dir)
    if not obj or not obj.Parent then return end
    TS:Create(obj, TweenInfo.new(
        t     or 0.2,
        style or Enum.EasingStyle.Quint,
        dir   or Enum.EasingDirection.Out
    ), props):Play()
end

-- ── Instance factory ──────────────────────────────────────────────────────────
local function N(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do pcall(function() o[k] = v end) end
    if parent then o.Parent = parent end
    return o
end

local function corner(p, r) return N("UICorner",  { CornerRadius = UDim.new(0, r or 8)       }, p) end
local function uistroke(p, col, th) return N("UIStroke", { Color=col or C.Border, Thickness=th or 1, ApplyStrokeMode=Enum.ApplyStrokeMode.Border }, p) end
local function pad(p, t,b,l,r) return N("UIPadding",{ PaddingTop=UDim.new(0,t or 0), PaddingBottom=UDim.new(0,b or 0), PaddingLeft=UDim.new(0,l or 0), PaddingRight=UDim.new(0,r or 0) }, p) end
local function list(p, dir, sp, ha, va)
    return N("UIListLayout", {
        FillDirection       = dir or Enum.FillDirection.Vertical,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Padding             = UDim.new(0, sp or 4),
        HorizontalAlignment = ha or Enum.HorizontalAlignment.Left,
        VerticalAlignment   = va or Enum.VerticalAlignment.Top,
    }, p)
end

local function label(txt, col, sz, font, parent, extra)
    local l = N("TextLabel", {
        Text                   = txt or "",
        TextColor3             = col or C.Text,
        TextSize               = sz  or 13,
        Font                   = font or Enum.Font.GothamMedium,
        BackgroundTransparency = 1,
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextYAlignment         = Enum.TextYAlignment.Center,
        TextTruncate           = Enum.TextTruncate.AtEnd,
        RichText               = false,
    }, parent)
    if extra then for k,v in pairs(extra) do pcall(function() l[k]=v end) end end
    return l
end

local function autoCanvas(sf, layout)
    local function upd() sf.CanvasSize = UDim2.new(0,0,0, layout.AbsoluteContentSize.Y + 10) end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd)
    upd()
end

-- ── Drag ──────────────────────────────────────────────────────────────────────
local function drag(frame, handle)
    handle = handle or frame
    local dragging, ds, sp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; ds=i.Position; sp=frame.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=false
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d = i.Position - ds
            frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset+d.X, sp.Y.Scale, sp.Y.Offset+d.Y)
        end
    end)
end

-- ── Screen helper ─────────────────────────────────────────────────────────────
local function getParent()
    local sg = N("ScreenGui", {
        Name="TzeUI", ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        DisplayOrder=100, IgnoreGuiInset=true
    })
    local ok = pcall(function() sg.Parent = CG end)
    if not ok or not sg.Parent then
        sg.Parent = PL.LocalPlayer:WaitForChild("PlayerGui")
    end
    return sg
end

-- ══════════════════════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ══════════════════════════════════════════════════════════════════════════════
local _notifSG, _notifHolder

local function ensureNotifs()
    if _notifHolder and _notifHolder.Parent then return end
    _notifSG = N("ScreenGui", { Name="TzeUI_Notifs", ResetOnSpawn=false, DisplayOrder=9999, IgnoreGuiInset=true })
    pcall(function() _notifSG.Parent = CG end)
    if not _notifSG.Parent then _notifSG.Parent = PL.LocalPlayer:WaitForChild("PlayerGui") end
    _notifHolder = N("Frame", {
        Size=UDim2.new(0,300,1,-20), Position=UDim2.new(1,-314,0,10),
        BackgroundTransparency=1, AnchorPoint=Vector2.new(1,0)
    }, _notifSG)
    list(_notifHolder, Enum.FillDirection.Vertical, 8)
end

local iconMap = {
    info = "●", check = "✓", ["alert-triangle"] = "⚠", x = "✕",
    copy = "⎘", bird = "✦", zap = "⚡", shield = "◉", crosshair = "⊕",
    eye = "◎", sun = "☀", star = "★", gauge = "◈", rotate = "↻",
}

local function Notify(opts)
    ensureNotifs()
    local title   = opts.Title    or "TzeUI"
    local content = opts.Content  or ""
    local dur     = opts.Duration or 3
    local icon    = iconMap[opts.Icon] or opts.Icon or "●"
    local accentC = opts.Color or C.Accent

    local pill = N("Frame", {
        Size=UDim2.new(1,0,0,0), BackgroundColor3=C.Elevated,
        BackgroundTransparency=0.08, ClipsDescendants=true,
    }, _notifHolder)
    corner(pill, 12)
    uistroke(pill, accentC, 1)
    -- left accent bar
    local bar = N("Frame", { Size=UDim2.new(0,3,0,0), Position=UDim2.new(0,0,0.5,0), AnchorPoint=Vector2.new(0,0.5), BackgroundColor3=accentC }, pill)
    corner(bar, 2)
    -- icon
    label(icon, accentC, 13, Enum.Font.GothamBold, pill, { Size=UDim2.new(0,20,0,36), Position=UDim2.new(0,10,0,0) })
    -- text
    label(title, C.Text, 12, Enum.Font.GothamBold, pill, { Size=UDim2.new(1,-40,0,18), Position=UDim2.new(0,32,0,5), TextTruncate=Enum.TextTruncate.AtEnd })
    label(content, C.TextSub, 11, Enum.Font.Gotham, pill, { Size=UDim2.new(1,-40,0,14), Position=UDim2.new(0,32,0,22), TextWrapped=true, TextTruncate=Enum.TextTruncate.None })

    -- animate in
    tw(pill, { Size=UDim2.new(1,0,0,42) }, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tw(bar,  { Size=UDim2.new(0,3,0.7,0) }, 0.3)

    task.delay(dur, function()
        tw(pill, { Size=UDim2.new(1,0,0,0) }, 0.22)
        task.delay(0.25, function() pcall(function() pill:Destroy() end) end)
    end)
end

-- ══════════════════════════════════════════════════════════════════════════════
-- WINDOW
-- ══════════════════════════════════════════════════════════════════════════════
function TzeUI:CreateWindow(opts)
    opts = opts or {}
    local winW  = opts.Size and opts.Size.X.Offset or 740
    local winH  = opts.Size and opts.Size.Y.Offset or 520
    local swW   = opts.SideBarWidth or 190
    local wm    = opts.Watermark
    local title = opts.Title  or "TzeUI"
    local auth  = opts.Author or ""

    local sg = getParent()

    -- ── Main frame ────────────────────────────────────────────────────────────
    local win = N("Frame", {
        Size     = UDim2.fromOffset(winW, winH),
        Position = UDim2.new(0.5,-winW/2, 0.5,-winH/2),
        BackgroundColor3 = C.Base,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ClipsDescendants = true,
    }, sg)
    corner(win, 14)
    uistroke(win, C.Border, 1)

    -- glow behind window
    N("ImageLabel", {
        Size=UDim2.new(1,80,1,80), Position=UDim2.new(0,-40,0,-40),
        BackgroundTransparency=1,
        Image="rbxassetid://6014261993",
        ImageColor3=C.Black, ImageTransparency=0.55,
        ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(49,49,450,450),
        ZIndex=0,
    }, win)

    -- subtle noise texture overlay
    N("Frame", {
        Size=UDim2.fromScale(1,1), BackgroundColor3=C.White,
        BackgroundTransparency=0.97, BorderSizePixel=0, ZIndex=0,
    }, win)

    -- ── Top bar ───────────────────────────────────────────────────────────────
    local topH = 44
    local topbar = N("Frame", {
        Size=UDim2.new(1,0,0,topH), BackgroundColor3=C.Surface, BorderSizePixel=0, ZIndex=3,
    }, win)
    -- bottom separator
    N("Frame", { Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BackgroundColor3=C.Border, BorderSizePixel=0 }, topbar)
    drag(win, topbar)

    -- logo pill
    local logoPill = N("Frame", {
        Size=UDim2.new(0,0,0,26), Position=UDim2.new(0,12,0.5,-13),
        BackgroundColor3=C.AccentDim, AutomaticSize=Enum.AutomaticSize.X,
    }, topbar)
    corner(logoPill, 13)
    pad(logoPill, 0,0,10,10)
    label(title, C.AccentBright, 12, Enum.Font.GothamBold, logoPill, {
        Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X
    })

    -- author
    if auth~="" then
        label("by "..auth, C.TextMute, 10, Enum.Font.Gotham, topbar, {
            Size=UDim2.new(0,120,1,0), Position=UDim2.new(0,120+16,0,0)
        })
    end

    -- tag holder (right of title)
    local tagHolder = N("Frame", {
        Size=UDim2.new(0,0,1,0), Position=UDim2.new(0,200,0,0),
        BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.X,
    }, topbar)
    N("UIListLayout",{ FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,4), VerticalAlignment=Enum.VerticalAlignment.Center }, tagHolder)

    -- window buttons (right side)
    local function winBtn(col, icon, xPos)
        local b = N("TextButton", {
            Size=UDim2.new(0,24,0,24),
            Position=UDim2.new(1,xPos,0.5,-12),
            BackgroundColor3=col, Text=icon,
            TextColor3=C.White, TextSize=13,
            Font=Enum.Font.GothamBold, AutoButtonColor=false, ZIndex=5,
        }, topbar)
        corner(b, 12)
        b.MouseEnter:Connect(function() tw(b,{BackgroundTransparency=0.25},0.1) end)
        b.MouseLeave:Connect(function() tw(b,{BackgroundTransparency=0},0.1) end)
        return b
    end

    local closeBtn = winBtn(Color3.fromRGB(220,60,60),  "×", -36)
    local minBtn   = winBtn(Color3.fromRGB(230,170,40), "–", -66)

    local minimized = false
    local fullSize  = win.Size
    closeBtn.MouseButton1Click:Connect(function()
        tw(win,{BackgroundTransparency=1,Size=UDim2.fromOffset(winW,0)},0.25)
        task.delay(0.28,function() sg:Destroy() end)
    end)
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then fullSize=win.Size; tw(win,{Size=UDim2.fromOffset(winW,topH)},0.22)
        else tw(win,{Size=fullSize},0.22) end
    end)

    -- ── Body ──────────────────────────────────────────────────────────────────
    local body = N("Frame", {
        Size=UDim2.new(1,0,1,-topH), Position=UDim2.new(0,0,0,topH),
        BackgroundTransparency=1,
    }, win)

    -- ── Sidebar ───────────────────────────────────────────────────────────────
    local sidebar = N("Frame", {
        Size=UDim2.new(0,swW,1,0), BackgroundColor3=C.Surface, BorderSizePixel=0,
    }, body)
    N("Frame",{ Size=UDim2.new(0,1,1,0), Position=UDim2.new(1,-1,0,0), BackgroundColor3=C.Border }, sidebar)

    local sbScroll = N("ScrollingFrame",{
        Size=UDim2.new(1,0,1,0), BackgroundTransparency=1,
        BorderSizePixel=0, ScrollBarThickness=2,
        ScrollBarImageColor3=C.Accent, CanvasSize=UDim2.new(0,0,0,0),
    }, sidebar)
    local sbLayout = list(sbScroll, Enum.FillDirection.Vertical, 2)
    pad(sbScroll, 6,6,6,6)
    autoCanvas(sbScroll, sbLayout)

    -- ── Tab bar (horizontal strip) ────────────────────────────────────────────
    local tabBarH = 38
    local contentArea = N("Frame",{
        Size=UDim2.new(1,-swW,1,0), Position=UDim2.new(0,swW,0,0),
        BackgroundTransparency=1,
    }, body)

    local tabBar = N("Frame",{
        Size=UDim2.new(1,0,0,tabBarH), BackgroundColor3=C.Surface, BorderSizePixel=0,
    }, contentArea)
    N("Frame",{ Size=UDim2.new(1,0,0,1), Position=UDim2.new(0,0,1,-1), BackgroundColor3=C.Border }, tabBar)

    local tabBarScroll = N("ScrollingFrame",{
        Size=UDim2.new(1,-8,1,0), Position=UDim2.new(0,4,0,0),
        BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=0,
        CanvasSize=UDim2.new(0,0,0,0),
    }, tabBar)
    N("UIListLayout",{
        FillDirection=Enum.FillDirection.Horizontal, SortOrder=Enum.SortOrder.LayoutOrder,
        Padding=UDim.new(0,2), VerticalAlignment=Enum.VerticalAlignment.Center,
    }, tabBarScroll)
    pad(tabBarScroll, 0,0,4,4)

    local tabPages = N("Frame",{
        Size=UDim2.new(1,0,1,-tabBarH), Position=UDim2.new(0,0,0,tabBarH),
        BackgroundTransparency=1, ClipsDescendants=true,
    }, contentArea)

    -- ── Watermark ─────────────────────────────────────────────────────────────
    if wm and wm.Enabled then
        local wmTxt = wm.Text or title
        local wmF = N("Frame",{
            Size=UDim2.new(0,0,0,22), Position=UDim2.new(1,-8,1,-28),
            AnchorPoint=Vector2.new(1,0), BackgroundColor3=C.Elevated,
            BackgroundTransparency=0.1, AutomaticSize=Enum.AutomaticSize.X,
        }, sg)
        corner(wmF, 6)
        uistroke(wmF, C.Border)
        pad(wmF, 0,0,8,8)
        label(wmTxt, C.TextMute, 10, Enum.Font.Gotham, wmF, {
            Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X
        })
    end

    -- ══════════════════════════════════════════════════════════════════════════
    -- Window object
    -- ══════════════════════════════════════════════════════════════════════════
    local W = { _tabs={}, _sg=sg, _win=win }
    local shortcuts = {}

    function W:Notify(o) Notify(o) end
    function W:Toggle()  win.Visible = not win.Visible end

    function W:BindShortcut(keyName, cb, info)
        local ok,key = pcall(function() return Enum.KeyCode[keyName] end)
        if ok and key then table.insert(shortcuts,{key=key,cb=cb}) end
    end
    UIS.InputBegan:Connect(function(inp,gp)
        for _,sc in ipairs(shortcuts) do
            if inp.KeyCode==sc.key then pcall(sc.cb) end
        end
    end)

    function W:SetBackgroundImage(id)
        N("ImageLabel",{ Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
            Image=id, ImageTransparency=0.93, ScaleType=Enum.ScaleType.Crop, ZIndex=0 }, win)
    end
    function W:ToggleTransparency(v) win.BackgroundTransparency = v and 0.06 or 0 end

    function W:Tag(opts)
        local tf = N("Frame",{
            Size=UDim2.new(0,0,0,20), BackgroundColor3=opts.Color or C.Accent,
            BackgroundTransparency=0.75, AutomaticSize=Enum.AutomaticSize.X,
        }, tagHolder)
        corner(tf,10)
        pad(tf,0,0,7,7)
        label(opts.Title or "", opts.Color or C.AccentBright, 9, Enum.Font.GothamBold, tf,{
            Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X
        })
    end

    -- ── Sidebar API ───────────────────────────────────────────────────────────
    function W:SideBarLabel(opts)
        local f = N("Frame",{ Size=UDim2.new(1,0,0,20), BackgroundTransparency=1 }, sbScroll)
        pad(f, 0,0,6,0)
        label(opts.Title or "", C.TextMute, 10, Enum.Font.GothamBold, f,{
            Size=UDim2.fromScale(1,1), TextTransparency=0
        })
    end

    function W:SideBarDivider()
        N("Frame",{ Size=UDim2.new(1,-12,0,1), BackgroundColor3=C.Border, BorderSizePixel=0 }, sbScroll)
    end

    function W:SideBarButton(opts)
        local b = N("TextButton",{
            Size=UDim2.new(1,0,0,32), BackgroundColor3=C.Raised,
            BackgroundTransparency=1, Text="", AutoButtonColor=false,
        }, sbScroll)
        corner(b, 8)
        pad(b, 0,0,8,8)
        label(opts.Title or "", C.TextSub, 12, Enum.Font.GothamMedium, b,{
            Size=UDim2.fromScale(1,1)
        })
        b.MouseEnter:Connect(function() tw(b,{BackgroundTransparency=0, BackgroundColor3=C.Overlay},0.12) end)
        b.MouseLeave:Connect(function() tw(b,{BackgroundTransparency=1},0.12) end)
        b.MouseButton1Click:Connect(function() pcall(opts.Callback or function()end) end)
        return b
    end

    -- ── OpenButton ────────────────────────────────────────────────────────────
    function W:OpenButton(opts)
        opts = opts or {}
        local ob = N("TextButton",{
            Size=UDim2.fromOffset(opts.Scale and 110*opts.Scale or 110, 34),
            Position=opts.Position or UDim2.new(0,120,0,120),
            BackgroundColor3=C.Elevated, Text=opts.Title or "TzeUI",
            TextColor3=C.AccentBright, TextSize=12, Font=Enum.Font.GothamBold,
            AutoButtonColor=false, ZIndex=99,
        }, sg)
        corner(ob, 10)
        uistroke(ob, C.Accent, 1)
        if opts.Draggable~=false then drag(ob) end
        ob.MouseEnter:Connect(function() tw(ob,{BackgroundColor3=C.Raised},0.12) end)
        ob.MouseLeave:Connect(function() tw(ob,{BackgroundColor3=C.Elevated},0.12) end)
        ob.MouseButton1Click:Connect(function() self:Toggle() end)
        return ob
    end

    -- ── TABS ──────────────────────────────────────────────────────────────────
    function W:Tab(opts)
        local order = #self._tabs + 1
        local ttl   = opts.Title or "Tab"

        -- Tab button
        local tabBtn = N("TextButton",{
            Size=UDim2.new(0,0,1,-8), AutomaticSize=Enum.AutomaticSize.X,
            BackgroundColor3=C.Overlay, BackgroundTransparency=1,
            Text=ttl, TextColor3=C.TextMute,
            TextSize=12, Font=Enum.Font.GothamMedium,
            AutoButtonColor=false, LayoutOrder=order,
        }, tabBarScroll)
        corner(tabBtn, 7)
        pad(tabBtn, 0,0,12,12)

        local underline = N("Frame",{
            Size=UDim2.new(1,0,0,2), Position=UDim2.new(0,0,1,-2),
            BackgroundColor3=C.Accent, BackgroundTransparency=1,
        }, tabBtn)

        -- Page
        local page = N("ScrollingFrame",{
            Size=UDim2.fromScale(1,1), BackgroundTransparency=1,
            BorderSizePixel=0, ScrollBarThickness=3,
            ScrollBarImageColor3=C.Accent, CanvasSize=UDim2.new(0,0,0,0),
            Visible=false,
        }, tabPages)
        local pageLayout = list(page, Enum.FillDirection.Vertical, 6)
        pad(page, 10,10,10,10)
        autoCanvas(page, pageLayout)

        table.insert(self._tabs,{ btn=tabBtn, page=page, ul=underline })

        local function activate()
            for _,t in ipairs(self._tabs) do
                t.page.Visible = false
                tw(t.btn,{TextColor3=C.TextMute, BackgroundTransparency=1},0.15)
                tw(t.ul,{BackgroundTransparency=1},0.15)
            end
            page.Visible = true
            tw(tabBtn,{TextColor3=C.AccentBright, BackgroundTransparency=0},0.15)
            tw(underline,{BackgroundTransparency=0},0.15)
        end

        tabBtn.MouseButton1Click:Connect(activate)
        tabBtn.MouseEnter:Connect(function()
            if page.Visible then return end
            tw(tabBtn,{TextColor3=C.TextSub},0.1)
        end)
        tabBtn.MouseLeave:Connect(function()
            if page.Visible then return end
            tw(tabBtn,{TextColor3=C.TextMute},0.1)
        end)
        if order==1 then activate() end

        -- ── TAB API ──────────────────────────────────────────────────────────
        local Tab = { _page=page, _win=self }

        function Tab:Divider()
            N("Frame",{ Size=UDim2.new(1,-6,0,1), BackgroundColor3=C.Border, BorderSizePixel=0 }, page)
        end

        -- ── PARAGRAPH ────────────────────────────────────────────────────────
        function Tab:Paragraph(opts2)
            local f = N("Frame",{
                Size=UDim2.new(1,0,0,0), BackgroundColor3=C.Elevated,
                AutomaticSize=Enum.AutomaticSize.Y, BorderSizePixel=0,
            }, page)
            corner(f, 10)
            uistroke(f, C.Border)
            pad(f, 10,10,12,12)
            local inner = N("Frame",{ Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y }, f)
            list(inner, Enum.FillDirection.Vertical, 4)
            if opts2.Title then label(opts2.Title, C.Text, 13, Enum.Font.GothamBold, inner,{ Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, TextWrapped=true }) end
            if opts2.Desc  then label(opts2.Desc, C.TextSub, 11, Enum.Font.Gotham, inner,{ Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y, TextWrapped=true }) end
            if opts2.Buttons then
                local br = N("Frame",{ Size=UDim2.new(1,0,0,28), BackgroundTransparency=1 }, inner)
                N("UIListLayout",{ FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,5) }, br)
                for _,b in ipairs(opts2.Buttons) do
                    local bb = N("TextButton",{
                        Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X,
                        BackgroundColor3=C.Accent, Text=b.Title or "",
                        TextColor3=C.White, TextSize=11, Font=Enum.Font.GothamBold, AutoButtonColor=false,
                    }, br)
                    corner(bb,6); pad(bb,0,0,10,10)
                    bb.MouseEnter:Connect(function() tw(bb,{BackgroundColor3=C.AccentBright},0.1) end)
                    bb.MouseLeave:Connect(function() tw(bb,{BackgroundColor3=C.Accent},0.1) end)
                    bb.MouseButton1Click:Connect(function() pcall(b.Callback or function()end) end)
                end
            end
        end

        -- ── STATS ────────────────────────────────────────────────────────────
        function Tab:Stats(opts2)
            local f = N("Frame",{ Size=UDim2.new(1,0,0,0), BackgroundColor3=C.Elevated, AutomaticSize=Enum.AutomaticSize.Y, BorderSizePixel=0 }, page)
            corner(f,10); uistroke(f,C.Border); pad(f,8,10,12,12)
            local inner = N("Frame",{ Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y }, f)
            list(inner, Enum.FillDirection.Vertical, 3)
            if opts2.Title then label(opts2.Title, C.Text,12,Enum.Font.GothamBold,inner,{Size=UDim2.new(1,0,0,16)}) end
            for _,item in ipairs(opts2.Items or {}) do
                local row = N("Frame",{ Size=UDim2.new(1,0,0,18), BackgroundTransparency=1 }, inner)
                label(item.Key..":", C.TextSub,11,Enum.Font.Gotham,row,{Size=UDim2.new(0.5,0,1,0)})
                label(tostring(item.Value), C.AccentBright,11,Enum.Font.GothamBold,row,{Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0.5,0,0,0)})
            end
        end

        -- ── CODE ─────────────────────────────────────────────────────────────
        function Tab:Code(opts2)
            local f = N("Frame",{ Size=UDim2.new(1,0,0,0), BackgroundColor3=C.Elevated, AutomaticSize=Enum.AutomaticSize.Y, BorderSizePixel=0 }, page)
            corner(f,10); uistroke(f,C.Border); pad(f,8,10,10,10)
            local inner = N("Frame",{ Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y }, f)
            list(inner, Enum.FillDirection.Vertical, 4)
            local hdr = N("Frame",{ Size=UDim2.new(1,0,0,20), BackgroundTransparency=1 }, inner)
            if opts2.Title then label(opts2.Title, C.TextSub,10,Enum.Font.GothamBold,hdr,{Size=UDim2.new(1,-55,1,0)}) end
            local cpBtn = N("TextButton",{
                Size=UDim2.new(0,48,0,18), Position=UDim2.new(1,-48,0,1),
                BackgroundColor3=C.AccentDim, Text="Copy",
                TextColor3=C.AccentBright, TextSize=10, Font=Enum.Font.GothamBold, AutoButtonColor=false,
            }, hdr)
            corner(cpBtn,5)
            local codeBox = label(opts2.Code or "", Color3.fromRGB(130,210,130), 10, Enum.Font.Code, inner,{
                Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
                BackgroundColor3=C.Base, BackgroundTransparency=0, TextWrapped=true,
            })
            corner(codeBox,6); pad(codeBox,6,6,8,8)
            cpBtn.MouseButton1Click:Connect(function()
                pcall(function() setclipboard(opts2.Code or "") end)
                cpBtn.Text="✓"; task.delay(1.5,function() cpBtn.Text="Copy" end)
                pcall(opts2.OnCopy or function()end)
            end)
        end

        -- ── SECTION ──────────────────────────────────────────────────────────
        function Tab:Section(opts2)
            local sf = N("Frame",{
                Size=UDim2.new(1,0,0,0), BackgroundColor3=C.Elevated,
                BackgroundTransparency=opts2.Box and 0 or 1,
                AutomaticSize=Enum.AutomaticSize.Y, BorderSizePixel=0, ClipsDescendants=false,
            }, page)
            if opts2.Box then corner(sf,10); uistroke(sf, opts2.BoxBorder and C.BorderBright or C.Border) end

            -- Header button
            local hdr = N("TextButton",{
                Size=UDim2.new(1,0,0,opts2.Desc and 42 or 36),
                BackgroundTransparency=1, Text="", AutoButtonColor=false,
            }, sf)
            pad(hdr, 0,0,12,8)

            -- accent left bar
            if opts2.Box then
                local ab = N("Frame",{ Size=UDim2.new(0,3,0,18), Position=UDim2.new(0,0,0.5,-9), BackgroundColor3=C.Accent }, sf)
                corner(ab,2)
            end

            label(opts2.Title or "", C.Text, 12, Enum.Font.GothamBold, hdr,{
                Size=UDim2.new(1,-30,0,16), Position=UDim2.new(0, opts2.Box and 14 or 0, 0, opts2.Desc and 6 or 10)
            })
            if opts2.Desc then
                label(opts2.Desc, C.TextMute, 10, Enum.Font.Gotham, hdr,{
                    Size=UDim2.new(1,-30,0,14), Position=UDim2.new(0, opts2.Box and 14 or 0, 0, 24)
                })
            end

            local arrow = label("▾", C.TextSub, 12, Enum.Font.GothamBold, hdr,{
                Size=UDim2.new(0,20,1,0), Position=UDim2.new(1,-22,0,0), TextXAlignment=Enum.TextXAlignment.Center
            })

            -- Content
            local contentF = N("Frame",{
                Size=UDim2.new(1,-16,0,0), Position=UDim2.new(0,8,0, opts2.Desc and 42 or 36),
                BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y,
            }, sf)
            list(contentF, Enum.FillDirection.Vertical, 4)
            pad(contentF, 0,8,0,0)

            local open = opts2.Opened ~= false
            local function setOpen(v)
                open=v; contentF.Visible=v; arrow.Text = v and "▾" or "▸"
            end
            setOpen(open)
            hdr.MouseButton1Click:Connect(function() setOpen(not open) end)

            -- ── SECTION elements ──────────────────────────────────────────────
            local S = {}

            -- ── Toggle ────────────────────────────────────────────────────────
            function S:Toggle(o)
                local row = N("Frame",{
                    Size=UDim2.new(1,0,0, o.Desc and 42 or 34),
                    BackgroundColor3=C.Raised, BorderSizePixel=0,
                }, contentF)
                corner(row, 8)

                label(o.Title or "", C.Text,12,Enum.Font.GothamMedium,row,{
                    Size=UDim2.new(1,-52,0,16), Position=UDim2.new(0,10,0, o.Desc and 6 or 9)
                })
                if o.Desc then label(o.Desc, C.TextMute,10,Enum.Font.Gotham,row,{
                    Size=UDim2.new(1,-52,0,12), Position=UDim2.new(0,10,0,22)
                }) end

                -- pill
                local pill = N("Frame",{ Size=UDim2.new(0,38,0,20), Position=UDim2.new(1,-48,0.5,-10), BackgroundColor3=C.Overlay }, row)
                corner(pill,10)
                local knob = N("Frame",{ Size=UDim2.new(0,16,0,16), Position=UDim2.new(0,2,0.5,-8), BackgroundColor3=C.TextMute }, pill)
                corner(knob,8)

                local state = o.Value or false
                local function set(v)
                    state=v
                    tw(knob,{ Position=v and UDim2.new(0,20,0.5,-8) or UDim2.new(0,2,0.5,-8), BackgroundColor3=v and C.White or C.TextMute },0.15)
                    tw(pill,{ BackgroundColor3=v and C.Accent or C.Overlay },0.15)
                    pcall(function() o.Callback(v) end)
                end
                set(state)

                local hit = N("TextButton",{ Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", AutoButtonColor=false }, row)
                hit.MouseButton1Click:Connect(function() set(not state) end)
                row.MouseEnter:Connect(function() tw(row,{BackgroundColor3=C.Overlay},0.1) end)
                row.MouseLeave:Connect(function() tw(row,{BackgroundColor3=C.Raised},0.1) end)
            end

            -- ── Button ────────────────────────────────────────────────────────
            function S:Button(o)
                local h = o.Desc and 42 or 34
                local btn = N("TextButton",{
                    Size=UDim2.new(1,0,0,h), BackgroundColor3=C.Raised,
                    Text="", AutoButtonColor=false, BorderSizePixel=0,
                }, contentF)
                corner(btn,8)
                label(o.Title or "", C.Text,12,Enum.Font.GothamMedium,btn,{
                    Size=UDim2.new(1,-12,0,16), Position=UDim2.new(0,10,0, o.Desc and 7 or 9)
                })
                if o.Desc then label(o.Desc, C.TextMute,10,Enum.Font.Gotham,btn,{
                    Size=UDim2.new(1,-12,0,14), Position=UDim2.new(0,10,0,23)
                }) end

                -- right arrow indicator
                label("›", C.TextMute,16,Enum.Font.GothamBold,btn,{ Size=UDim2.new(0,20,1,0), Position=UDim2.new(1,-24,0,0), TextXAlignment=Enum.TextXAlignment.Center })

                btn.MouseEnter:Connect(function() tw(btn,{BackgroundColor3=C.Overlay},0.1) end)
                btn.MouseLeave:Connect(function() tw(btn,{BackgroundColor3=C.Raised},0.1) end)
                btn.MouseButton1Click:Connect(function()
                    tw(btn,{BackgroundColor3=C.AccentDim},0.06)
                    task.delay(0.1,function() tw(btn,{BackgroundColor3=C.Overlay},0.1) end)
                    pcall(o.Callback or function()end)
                end)
            end

            -- ── Slider ────────────────────────────────────────────────────────
            function S:Slider(o)
                local range  = o.Value or {Min=0,Max=100,Default=50}
                local step   = o.Step  or 1
                local suffix = o.Suffix or ""
                local cur    = range.Default or range.Min
                local fmt    = step < 1 and "%.1f" or "%d"

                local f = N("Frame",{ Size=UDim2.new(1,0,0,56), BackgroundColor3=C.Raised, BorderSizePixel=0 }, contentF)
                corner(f,8)
                pad(f,0,0,10,10)

                label(o.Title or "", C.Text,12,Enum.Font.GothamMedium,f,{ Size=UDim2.new(1,-64,0,16), Position=UDim2.new(0,0,0,6) })

                -- value display / textbox
                local valDisplay
                if o.IsTextbox then
                    valDisplay = N("TextBox",{
                        Size=UDim2.new(0,52,0,18), Position=UDim2.new(1,-52,0,5),
                        BackgroundColor3=C.Overlay, Text=string.format(fmt,cur)..suffix,
                        TextColor3=C.AccentBright, TextSize=11, Font=Enum.Font.GothamBold,
                        ClearTextOnFocus=false, BorderSizePixel=0,
                    }, f)
                    corner(valDisplay,5); pad(valDisplay,0,0,4,4)
                    uistroke(valDisplay, C.Border)
                else
                    valDisplay = label(string.format(fmt,cur)..suffix, C.AccentBright,11,Enum.Font.GothamBold,f,{
                        Size=UDim2.new(0,52,0,18), Position=UDim2.new(1,-52,0,5), TextXAlignment=Enum.TextXAlignment.Right
                    })
                end

                -- track
                local track = N("Frame",{ Size=UDim2.new(1,0,0,4), Position=UDim2.new(0,0,0,36), BackgroundColor3=C.Overlay, BorderSizePixel=0 }, f)
                corner(track,2)
                local fill = N("Frame",{ Size=UDim2.new((cur-range.Min)/(range.Max-range.Min),0,1,0), BackgroundColor3=C.Accent, BorderSizePixel=0 }, track)
                corner(fill,2)
                local knob = N("Frame",{ Size=UDim2.new(0,14,0,14), BackgroundColor3=C.White, BorderSizePixel=0 }, track)
                corner(knob,7)
                -- knob glow
                N("UIStroke",{ Color=C.Accent, Thickness=2, Transparency=0.5 }, knob)

                local function updateVisual(alpha)
                    tw(fill,{Size=UDim2.new(alpha,0,1,0)},0.05)
                    tw(knob,{Position=UDim2.new(alpha,-7,0.5,-7)},0.05)
                end
                updateVisual((cur-range.Min)/(range.Max-range.Min))

                local function setCur(x)
                    local alpha = math.clamp((x - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
                    local raw   = range.Min + alpha*(range.Max-range.Min)
                    local steps = math.round((raw-range.Min)/step)
                    cur = math.clamp(range.Min + steps*step, range.Min, range.Max)
                    local a2 = (cur-range.Min)/(range.Max-range.Min)
                    updateVisual(a2)
                    if o.IsTextbox then valDisplay.Text = string.format(fmt,cur)..suffix
                    else valDisplay.Text = string.format(fmt,cur)..suffix end
                    pcall(function() o.Callback(cur) end)
                end

                local dragging2 = false
                local hit = N("TextButton",{ Size=UDim2.fromScale(1,1), BackgroundTransparency=1, Text="", AutoButtonColor=false }, track)
                hit.InputBegan:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
                        dragging2=true; setCur(i.Position.X)
                    end
                end)
                hit.InputEnded:Connect(function(i)
                    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging2=false end
                end)
                UIS.InputChanged:Connect(function(i)
                    if dragging2 and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
                        setCur(i.Position.X)
                    end
                end)

                if o.IsTextbox then
                    valDisplay.FocusLost:Connect(function()
                        local v = tonumber(valDisplay.Text:gsub(suffix,""))
                        if v then
                            cur = math.clamp(v, range.Min, range.Max)
                            local a2 = (cur-range.Min)/(range.Max-range.Min)
                            updateVisual(a2)
                            valDisplay.Text = string.format(fmt,cur)..suffix
                            pcall(function() o.Callback(cur) end)
                        else valDisplay.Text = string.format(fmt,cur)..suffix end
                    end)
                end

                f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=C.Overlay},0.1) end)
                f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=C.Raised},0.1) end)
            end

            -- ── Dropdown ──────────────────────────────────────────────────────
            function S:Dropdown(o)
                local values = o.Values or {}
                local cur    = o.Value  or (values[1] or "Select...")
                local isOpen = false

                local f = N("Frame",{ Size=UDim2.new(1,0,0,36), BackgroundColor3=C.Raised, BorderSizePixel=0, ZIndex=5, ClipsDescendants=false }, contentF)
                corner(f,8)

                label(o.Title or "", C.Text,12,Enum.Font.GothamMedium,f,{ Size=UDim2.new(0.5,0,1,0), Position=UDim2.new(0,10,0,0) })

                local selBtn = N("TextButton",{
                    Size=UDim2.new(0.46,0,0,24), Position=UDim2.new(0.53,0,0.5,-12),
                    BackgroundColor3=C.Overlay, Text=tostring(cur),
                    TextColor3=C.AccentBright, TextSize=11, Font=Enum.Font.GothamMedium,
                    AutoButtonColor=false, ZIndex=6,
                }, f)
                corner(selBtn,6)
                label("▾", C.AccentBright,10,Enum.Font.GothamBold,selBtn,{
                    Size=UDim2.new(0,16,1,0), Position=UDim2.new(1,-18,0,0), TextXAlignment=Enum.TextXAlignment.Center
                })

                local ddFrame = N("Frame",{
                    Size=UDim2.new(0.46,0,0,0), Position=UDim2.new(0.53,0,1,4),
                    BackgroundColor3=C.Overlay, BorderSizePixel=0,
                    ZIndex=20, ClipsDescendants=true, Visible=false,
                }, f)
                corner(ddFrame,8); uistroke(ddFrame, C.BorderBright)

                local ddList = N("Frame",{ Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y }, ddFrame)
                list(ddList, Enum.FillDirection.Vertical, 1)
                pad(ddList, 2,2,2,2)

                local function buildOpts()
                    ddList:ClearAllChildren(); list(ddList, Enum.FillDirection.Vertical, 1); pad(ddList,2,2,2,2)
                    for _,v in ipairs(values) do
                        local ob = N("TextButton",{
                            Size=UDim2.new(1,0,0,26), BackgroundColor3=C.Overlay,
                            BackgroundTransparency=1, Text=tostring(v),
                            TextColor3=v==cur and C.AccentBright or C.TextSub,
                            TextSize=11, Font=Enum.Font.GothamMedium,
                            AutoButtonColor=false, ZIndex=21,
                        }, ddList)
                        corner(ob,5)
                        ob.MouseEnter:Connect(function() tw(ob,{BackgroundTransparency=0,BackgroundColor3=C.Raised},0.1) end)
                        ob.MouseLeave:Connect(function() tw(ob,{BackgroundTransparency=1},0.1) end)
                        ob.MouseButton1Click:Connect(function()
                            cur=v; selBtn.Text=tostring(v)
                            isOpen=false
                            tw(ddFrame,{Size=UDim2.new(0.46,0,0,0)},0.15)
                            task.delay(0.15,function() ddFrame.Visible=false end)
                            pcall(function() o.Callback(v) end)
                        end)
                    end
                end
                buildOpts()

                selBtn.MouseButton1Click:Connect(function()
                    isOpen=not isOpen
                    if isOpen then
                        ddFrame.Visible=true
                        local h = math.min(#values*28+4,160)
                        tw(ddFrame,{Size=UDim2.new(0.46,0,0,h)},0.18,Enum.EasingStyle.Back)
                    else
                        tw(ddFrame,{Size=UDim2.new(0.46,0,0,0)},0.15)
                        task.delay(0.15,function() ddFrame.Visible=false end)
                    end
                end)

                f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=C.Overlay},0.1) end)
                f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=C.Raised},0.1) end)

                return { Refresh=function(newVals) values=newVals; buildOpts() end }
            end

            -- ── Input ─────────────────────────────────────────────────────────
            function S:Input(o)
                local f = N("Frame",{ Size=UDim2.new(1,0,0,50), BackgroundColor3=C.Raised, BorderSizePixel=0 }, contentF)
                corner(f,8); pad(f,0,0,10,10)
                label(o.Title or "", C.Text,12,Enum.Font.GothamMedium,f,{ Size=UDim2.new(1,0,0,16), Position=UDim2.new(0,0,0,5) })
                if o.Desc then label(o.Desc, C.TextMute,10,Enum.Font.Gotham,f,{ Size=UDim2.new(1,0,0,12), Position=UDim2.new(0,0,0,22) }) end
                local tbF = N("Frame",{ Size=UDim2.new(1,0,0,22), Position=UDim2.new(0,0,1,-26), BackgroundColor3=C.Overlay, BorderSizePixel=0 }, f)
                corner(tbF,6)
                local tbStroke = uistroke(tbF, C.Border)
                local tb = N("TextBox",{
                    Size=UDim2.new(1,-10,1,0), Position=UDim2.new(0,5,0,0),
                    BackgroundTransparency=1, PlaceholderText=o.Placeholder or "",
                    PlaceholderColor3=C.TextMute, Text="",
                    TextColor3=C.Text, TextSize=11, Font=Enum.Font.GothamMedium,
                    ClearTextOnFocus=false,
                }, tbF)
                tb.Focused:Connect(function() tw(tbStroke,{Color=C.Accent},0.15) end)
                tb.FocusLost:Connect(function()
                    tw(tbStroke,{Color=C.Border},0.15)
                    if tb.Text~="" then pcall(function() o.Callback(tb.Text) end) end
                end)
                f.MouseEnter:Connect(function() tw(f,{BackgroundColor3=C.Overlay},0.1) end)
                f.MouseLeave:Connect(function() tw(f,{BackgroundColor3=C.Raised},0.1) end)
            end

            -- ── Group ─────────────────────────────────────────────────────────
            function S:Group(o)
                local gf = N("Frame",{ Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y }, contentF)
                N("UIListLayout",{ FillDirection=Enum.FillDirection.Horizontal, Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder }, gf)
                local G = {}
                function G:Button(o2)
                    local bb = N("TextButton",{
                        Size=UDim2.new(0,0,0,30), AutomaticSize=Enum.AutomaticSize.X,
                        BackgroundColor3=C.Raised, Text="", AutoButtonColor=false, BorderSizePixel=0,
                    }, gf)
                    corner(bb,8); pad(bb,0,0,12,12)
                    label(o2.Title or "", C.Text,12,Enum.Font.GothamMedium,bb,{ Size=UDim2.new(0,0,1,0), AutomaticSize=Enum.AutomaticSize.X })
                    bb.MouseEnter:Connect(function() tw(bb,{BackgroundColor3=C.Overlay},0.1) end)
                    bb.MouseLeave:Connect(function() tw(bb,{BackgroundColor3=C.Raised},0.1) end)
                    bb.MouseButton1Click:Connect(function() pcall(o2.Callback or function()end) end)
                end
                return G
            end

            -- ── Divider ───────────────────────────────────────────────────────
            function S:Divider()
                N("Frame",{ Size=UDim2.new(1,-4,0,1), BackgroundColor3=C.Border, BorderSizePixel=0 }, contentF)
            end

            -- ── Paragraph (in section) ────────────────────────────────────────
            function S:Paragraph(o2)
                local pf = N("Frame",{ Size=UDim2.new(1,0,0,0), BackgroundTransparency=1, AutomaticSize=Enum.AutomaticSize.Y }, contentF)
                list(pf, Enum.FillDirection.Vertical, 3)
                if o2.Title then label(o2.Title,C.Text,12,Enum.Font.GothamBold,pf,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true}) end
                if o2.Desc  then label(o2.Desc,C.TextSub,10,Enum.Font.Gotham,pf,{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,TextWrapped=true}) end
            end

            return S
        end

        -- Tab-level passthrough (creates invisible section)
        local function tabSection() return Tab:Section({ Box=false, Opened=true }) end
        function Tab:Toggle(o)    tabSection():Toggle(o) end
        function Tab:Button(o)    tabSection():Button(o) end
        function Tab:Slider(o)    tabSection():Slider(o) end
        function Tab:Input(o)     tabSection():Input(o) end
        function Tab:Dropdown(o)  return tabSection():Dropdown(o) end
        function Tab:Group(o)     return tabSection():Group(o) end
        function Tab:Divider()    Tab:Divider() end

        return Tab
    end

    -- SelectTab
    function W:SelectTab(tab)
        for _, t in ipairs(self._tabs) do
            if t.page == tab._page then
                t.btn.MouseButton1Click:Fire()
                break
            end
        end
    end

    -- animate window in
    win.Size = UDim2.fromOffset(winW, 0)
    tw(win, { Size=UDim2.fromOffset(winW, winH) }, 0.35, Enum.EasingStyle.Back)

    return W
end

-- top-level Notify
function TzeUI:Notify(opts) Notify(opts) end

return TzeUI
