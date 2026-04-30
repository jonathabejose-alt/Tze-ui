-- ╔══════════════════════════════════════════════════════════╗
-- ║        ZETHUI PRO — Complete Glassmorphism UI           ║
-- ║        By tze | No external dependencies                ║
-- ╚══════════════════════════════════════════════════════════╝

local ZethUI = {}

-- SERVICES --
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CG = game:GetService("CoreGui")
local PL = game:GetService("Players")

-- PALETTE --
local C = {
    bg = Color3.fromRGB(6,6,12),
    bg2 = Color3.fromRGB(12,12,20),
    bg3 = Color3.fromRGB(18,18,30),
    bg4 = Color3.fromRGB(24,24,40),
    bg5 = Color3.fromRGB(32,32,50),
    stroke = Color3.fromRGB(38,38,55),
    stroke2 = Color3.fromRGB(50,50,72),
    sub = Color3.fromRGB(120,120,155),
    text = Color3.fromRGB(225,225,245),
    white = Color3.fromRGB(255,255,255),
    accent = Color3.fromRGB(85,130,255),
    accent2 = Color3.fromRGB(110,160,255),
    accentD = Color3.fromRGB(50,90,200),
    green = Color3.fromRGB(45,215,90),
    red = Color3.fromRGB(255,55,55),
}

-- HELPERS --
local function N(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then pcall(function() o[k] = v end) end
    end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end

local function tw(obj, props, dur)
    if not obj or not obj.Parent then return end
    TS:Create(obj, TweenInfo.new(dur or 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

local function twBack(obj, props, dur)
    TS:Create(obj, TweenInfo.new(dur or 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), props):Play()
end

local function corner(p, r) return N("UICorner", {CornerRadius = UDim.new(0, r or 8), Parent = p}) end
local function stroke(p, col, th) return N("UIStroke", {Color = col or C.stroke, Thickness = th or 1, Transparency = 0.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = p}) end
local function pad(p, t, b, l, r) return N("UIPadding", {PaddingTop = UDim.new(0, t or 0), PaddingBottom = UDim.new(0, b or 0), PaddingLeft = UDim.new(0, l or 0), PaddingRight = UDim.new(0, r or 0), Parent = p}) end
local function label(txt, col, sz, font, parent)
    return N("TextLabel", {Text = txt or "", TextColor3 = col or C.text, TextSize = sz or 13, Font = font or Enum.Font.GothamMedium, BackgroundTransparency = 1, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd}, parent)
end
local function list(p, dir, sp) return N("UIListLayout", {FillDirection = dir or Enum.FillDirection.Vertical, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, sp or 4)}, p) end
local function autoCanvas(sf, layout)
    local function u() sf.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10) end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(u)
    u()
end
local function drag(frame, handle)
    handle = handle or frame
    local d, ds, sp = false, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            d = true; ds = i.Position; sp = frame.Position
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then d = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local delta = i.Position - ds
            frame.Position = UDim2.new(sp.X.Scale, sp.X.Offset + delta.X, sp.Y.Scale, sp.Y.Offset + delta.Y)
        end
    end)
end

-- TOAST --
local toastHolder = nil
local function createToastHolder(parent)
    if toastHolder and toastHolder.Parent then return end
    toastHolder = N("Frame", {Size = UDim2.new(0, 280, 1, 0), Position = UDim2.new(1, -16, 0, 16), AnchorPoint = Vector2.new(1, 0), BackgroundTransparency = 1}, parent)
    list(toastHolder, Enum.FillDirection.Vertical, 8)
end
local function toast(text, color, dur)
    if not toastHolder then return end
    local accent = color or C.accent
    local pill = N("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = C.bg2, BackgroundTransparency = 0.05, BorderSizePixel = 0, ClipsDescendants = true}, toastHolder)
    corner(pill, 10); stroke(pill, accent, 1, 0.3)
    local bar = N("Frame", {Size = UDim2.new(0, 3, 0.6, 0), Position = UDim2.new(0, 8, 0.2, 0), BackgroundColor3 = accent, BorderSizePixel = 0}, pill); corner(bar, 2)
    local lbl = N("TextLabel", {Size = UDim2.new(1, -28, 1, 0), Position = UDim2.new(0, 18, 0, 0), BackgroundTransparency = 1, Text = text, TextColor3 = C.text, TextSize = 11, Font = Enum.Font.GothamMedium, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true, TextTransparency = 1}, pill)
    twBack(pill, {Size = UDim2.new(1, 0, 0, 36)}, 0.35)
    task.delay(0.1, function() tw(lbl, {TextTransparency = 0}, 0.25) end)
    task.delay(dur or 3, function()
        tw(lbl, {TextTransparency = 1}, 0.2); tw(pill, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        task.delay(0.35, function() pcall(function() pill:Destroy() end) end)
    end)
end

-- WINDOW --
function ZethUI:CreateWindow(opts)
    opts = opts or {}
    local winW = opts.Size and opts.Size.X.Offset or 640
    local winH = opts.Size and opts.Size.Y.Offset or 460
    local title = opts.Title or "ZethUI"
    local auth = opts.Author or ""

    local sg = N("ScreenGui", {Name = "ZethUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 100, IgnoreGuiInset = true})
    pcall(function() sg.Parent = CG end)
    if not sg.Parent then sg.Parent = PL.LocalPlayer:WaitForChild("PlayerGui") end
    createToastHolder(sg)

    -- Main window
    local win = N("Frame", {Size = UDim2.fromOffset(winW, winH), Position = UDim2.new(0.5, -winW/2, 0.5, -winH/2), BackgroundColor3 = C.bg, BorderSizePixel = 0, ClipsDescendants = true}, sg)
    corner(win, 16); stroke(win, C.stroke, 1)

    -- Topbar
    local topH = 46
    local topbar = N("Frame", {Size = UDim2.new(1, 0, 0, topH), BackgroundColor3 = C.bg2, BorderSizePixel = 0, ZIndex = 3}, win)
    corner(topbar, 16)
    N("Frame", {Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 1, -16), BackgroundColor3 = C.bg2}, topbar)
    stroke(topbar, C.stroke, 1); drag(win, topbar)

    -- Title
    local tp = N("Frame", {Size = UDim2.new(0, 0, 0, 26), Position = UDim2.new(0, 12, 0.5, -13), BackgroundColor3 = C.accentD, AutomaticSize = Enum.AutomaticSize.X}, topbar)
    corner(tp, 13); pad(tp, 0, 0, 10, 10)
    label(title, C.accent2, 12, Enum.Font.GothamBold, tp, {Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X})
    if auth ~= "" then label("by " .. auth, C.sub, 10, Enum.Font.Gotham, topbar, {Size = UDim2.new(0, 120, 1, 0), Position = UDim2.new(0, 140, 0, 0)}) end

    -- Buttons
    local function wb(col, txt, x)
        local b = N("TextButton", {Size = UDim2.new(0, 26, 0, 26), Position = UDim2.new(1, x, 0.5, -13), BackgroundColor3 = col, Text = txt, TextColor3 = C.white, TextSize = 14, Font = Enum.Font.GothamBold, AutoButtonColor = false, ZIndex = 5}, topbar)
        corner(b, 13); return b
    end
    local closeBtn = wb(Color3.fromRGB(220, 60, 60), "×", -36)
    local minBtn = wb(Color3.fromRGB(230, 170, 40), "–", -66)
    local minimized = false
    local fullSize = win.Size
    closeBtn.MouseButton1Click:Connect(function()
        tw(win, {Size = UDim2.fromOffset(winW, 0)}, 0.25)
        task.delay(0.28, function() sg:Destroy() end)
    end)
    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then fullSize = win.Size; tw(win, {Size = UDim2.fromOffset(winW, topH)}, 0.22)
        else tw(win, {Size = fullSize}, 0.22) end
    end)

    -- Accent line
    local al = N("Frame", {Size = UDim2.new(0, 0, 0, 3), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = C.accent, BorderSizePixel = 0, ZIndex = 5}, win)
    corner(al, 2)
    N("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, C.accent), ColorSequenceKeypoint.new(1, C.accentD)}), Parent = al})
    task.delay(0.15, function() tw(al, {Size = UDim2.new(1, 0, 0, 3)}, 0.6, Enum.EasingStyle.Quint) end)

    -- Body
    local body = N("Frame", {Size = UDim2.new(1, 0, 1, -topH), Position = UDim2.new(0, 0, 0, topH), BackgroundTransparency = 1}, win)

    -- Tab bar
    local tabH = 38
    local tabBar = N("Frame", {Size = UDim2.new(1, 0, 0, tabH), BackgroundColor3 = C.bg2, BorderSizePixel = 0}, body)
    N("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = C.stroke}, tabBar)
    local tabScroll = N("ScrollingFrame", {Size = UDim2.new(1, -8, 1, 0), Position = UDim2.new(0, 4, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 0, CanvasSize = UDim2.new(0, 0, 0, 0)}, tabBar)
    list(tabScroll, Enum.FillDirection.Horizontal, 2, nil, Enum.VerticalAlignment.Center); pad(tabScroll, 0, 0, 4, 4)
    local tabPages = N("Frame", {Size = UDim2.new(1, 0, 1, -tabH), Position = UDim2.new(0, 0, 0, tabH), BackgroundTransparency = 1, ClipsDescendants = true}, body)

    -- Window API
    local W = {_tabs = {}, _sg = sg, _win = win}
    function W:Notify(text, dur) toast(text, C.accent, dur or 3) end
    function W:Toggle() win.Visible = not win.Visible end

    -- TABS
    function W:Tab(opts)
        local order = #self._tabs + 1
        local ttl = opts.Title or "Tab"
        local tabBtn = N("TextButton", {Size = UDim2.new(0, 0, 1, -8), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = C.bg4, BackgroundTransparency = 1, Text = ttl, TextColor3 = C.sub, TextSize = 12, Font = Enum.Font.GothamMedium, AutoButtonColor = false, LayoutOrder = order}, tabScroll)
        corner(tabBtn, 7); pad(tabBtn, 0, 0, 12, 12)
        local ul = N("Frame", {Size = UDim2.new(1, 0, 0, 2), Position = UDim2.new(0, 0, 1, -2), BackgroundColor3 = C.accent, BackgroundTransparency = 1}, tabBtn)
        local page = N("ScrollingFrame", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 3, ScrollBarImageColor3 = C.accent, CanvasSize = UDim2.new(0, 0, 0, 0), Visible = false}, tabPages)
        local pl = list(page, Enum.FillDirection.Vertical, 6); pad(page, 10, 10, 10, 10); autoCanvas(page, pl)
        table.insert(self._tabs, {btn = tabBtn, page = page, ul = ul})
        local function act()
            for _, t in ipairs(self._tabs) do
                t.page.Visible = false; tw(t.btn, {TextColor3 = C.sub, BackgroundTransparency = 1}, 0.15); tw(t.ul, {BackgroundTransparency = 1}, 0.15)
            end
            page.Visible = true; tw(tabBtn, {TextColor3 = C.accent2, BackgroundTransparency = 0}, 0.15); tw(ul, {BackgroundTransparency = 0}, 0.15)
        end
        tabBtn.MouseButton1Click:Connect(act)
        if order == 1 then act() end

        local Tab = {_page = page}

        -- DIVIDER
        function Tab:Divider() N("Frame", {Size = UDim2.new(1, -6, 0, 1), BackgroundColor3 = C.stroke, BorderSizePixel = 0}, page) end

        -- TOGGLE
        function Tab:Toggle(o)
            local row = N("Frame", {Size = UDim2.new(1, 0, 0, o.Desc and 42 or 34), BackgroundColor3 = C.bg3, BackgroundTransparency = 0.1, BorderSizePixel = 0}, page)
            corner(row, 8); stroke(row, C.stroke, 1)
            label(o.Title or "", C.text, 12, Enum.Font.GothamMedium, row, {Size = UDim2.new(1, -60, 0, 16), Position = UDim2.new(0, 12, 0, o.Desc and 6 or 9)})
            if o.Desc then label(o.Desc, C.sub, 10, Enum.Font.Gotham, row, {Size = UDim2.new(1, -60, 0, 12), Position = UDim2.new(0, 12, 0, 22)}) end
            local pill = N("Frame", {Size = UDim2.new(0, 38, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = C.bg5}, row); corner(pill, 10)
            local knob = N("Frame", {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = C.sub}, pill); corner(knob, 8)
            local state = o.Value or false
            local function set(v)
                state = v
                tw(knob, {Position = v and UDim2.new(0, 20, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = v and C.white or C.sub}, 0.15)
                tw(pill, {BackgroundColor3 = v and C.accent or C.bg5}, 0.15)
                pcall(function() o.Callback(v) end)
            end
            set(state)
            local hit = N("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, row)
            hit.MouseButton1Click:Connect(function() set(not state) end)
        end

        -- BUTTON
        function Tab:Button(o)
            local btn = N("TextButton", {Size = UDim2.new(1, 0, 0, o.Desc and 42 or 34), BackgroundColor3 = C.bg3, BackgroundTransparency = 0.1, BorderSizePixel = 0, Text = "", AutoButtonColor = false}, page)
            corner(btn, 8); stroke(btn, C.stroke, 1)
            label(o.Title or "", C.text, 12, Enum.Font.GothamMedium, btn, {Size = UDim2.new(1, -24, 0, 16), Position = UDim2.new(0, 12, 0, o.Desc and 7 or 9)})
            if o.Desc then label(o.Desc, C.sub, 10, Enum.Font.Gotham, btn, {Size = UDim2.new(1, -24, 0, 14), Position = UDim2.new(0, 12, 0, 23)}) end
            btn.MouseEnter:Connect(function() tw(btn, {BackgroundColor3 = C.bg4}, 0.1) end)
            btn.MouseLeave:Connect(function() tw(btn, {BackgroundColor3 = C.bg3}, 0.1) end)
            btn.MouseButton1Click:Connect(function()
                tw(btn, {BackgroundColor3 = C.accentD}, 0.06)
                task.delay(0.1, function() tw(btn, {BackgroundColor3 = C.bg4}, 0.1) end)
                pcall(o.Callback or function() end)
            end)
        end

        -- SLIDER
        function Tab:Slider(o)
            local r = o.Value or {Min = 0, Max = 100, Default = 50}
            local step = o.Step or 1; local suffix = o.Suffix or ""
            local cur = r.Default or r.Min; local fmt = step < 1 and "%.1f" or "%d"
            local f = N("Frame", {Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = C.bg3, BackgroundTransparency = 0.1, BorderSizePixel = 0}, page)
            corner(f, 8); stroke(f, C.stroke, 1); pad(f, 0, 0, 12, 12)
            label(o.Title or "", C.text, 12, Enum.Font.GothamMedium, f, {Size = UDim2.new(1, -60, 0, 16), Position = UDim2.new(0, 0, 0, 6)})
            local vl = label(string.format(fmt, cur) .. suffix, C.accent2, 11, Enum.Font.GothamBold, f, {Size = UDim2.new(0, 52, 0, 18), Position = UDim2.new(1, -52, 0, 5), TextXAlignment = Enum.TextXAlignment.Right})
            local track = N("Frame", {Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 0, 36), BackgroundColor3 = C.bg5}, f); corner(track, 2)
            local fill = N("Frame", {Size = UDim2.new((cur - r.Min) / (r.Max - r.Min), 0, 1, 0), BackgroundColor3 = C.accent}, track); corner(fill, 2)
            local knob = N("Frame", {Size = UDim2.new(0, 14, 0, 14), BackgroundColor3 = C.white}, track); corner(knob, 7)
            local function uv(a) tw(fill, {Size = UDim2.new(a, 0, 1, 0)}, 0.05); tw(knob, {Position = UDim2.new(a, -7, 0.5, -7)}, 0.05) end
            uv((cur - r.Min) / (r.Max - r.Min))
            local dragging = false
            local hit = N("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, track)
            local function sc(x)
                local a = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local raw = r.Min + a * (r.Max - r.Min)
                cur = math.clamp(r.Min + math.round((raw - r.Min) / step) * step, r.Min, r.Max)
                a = (cur - r.Min) / (r.Max - r.Min); uv(a); vl.Text = string.format(fmt, cur) .. suffix
                pcall(function() o.Callback(cur) end)
            end
            hit.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; sc(i.Position.X) end
            end)
            hit.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
            end)
            UIS.InputChanged:Connect(function(i)
                if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then sc(i.Position.X) end
            end)
        end

                -- ═══════════════════════════════════════════════════
        -- PARTE 2 — DROPDOWN + INPUT + SECTION + PARAGRAPH
        -- ═══════════════════════════════════════════════════

        -- DROPDOWN
        function Tab:Dropdown(o)
            local vals = o.Values or {}
            local cur = o.Value or (vals[1] or "Select...")
            local open = false
            local f = N("Frame", {Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = C.bg3, BackgroundTransparency = 0.1, BorderSizePixel = 0, ZIndex = 5, ClipsDescendants = false}, page)
            corner(f, 8); stroke(f, C.stroke, 1)
            label(o.Title or "", C.text, 12, Enum.Font.GothamMedium, f, {Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0)})
            local sel = N("TextButton", {Size = UDim2.new(0.46, 0, 0, 24), Position = UDim2.new(0.53, 0, 0.5, -12), BackgroundColor3 = C.bg5, Text = tostring(cur), TextColor3 = C.accent2, TextSize = 11, Font = Enum.Font.GothamMedium, AutoButtonColor = false, ZIndex = 6}, f)
            corner(sel, 6)
            local dd = N("Frame", {Size = UDim2.new(0.46, 0, 0, 0), Position = UDim2.new(0.53, 0, 1, 4), BackgroundColor3 = C.bg4, BorderSizePixel = 0, ZIndex = 20, ClipsDescendants = true, Visible = false}, f)
            corner(dd, 8); stroke(dd, C.stroke2, 1)
            local dl = N("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y}, dd)
            list(dl, Enum.FillDirection.Vertical, 1); pad(dl, 2, 2, 2, 2)
            local function build()
                dl:ClearAllChildren(); list(dl, Enum.FillDirection.Vertical, 1); pad(dl, 2, 2, 2, 2)
                for _, v in ipairs(vals) do
                    local opt = N("TextButton", {Size = UDim2.new(1, 0, 0, 26), BackgroundColor3 = C.bg4, BackgroundTransparency = 1, Text = tostring(v), TextColor3 = v == cur and C.accent2 or C.sub, TextSize = 11, Font = Enum.Font.GothamMedium, AutoButtonColor = false, ZIndex = 21}, dl)
                    corner(opt, 5)
                    opt.MouseEnter:Connect(function() tw(opt, {BackgroundTransparency = 0, BackgroundColor3 = C.bg5}, 0.1) end)
                    opt.MouseLeave:Connect(function() tw(opt, {BackgroundTransparency = 1}, 0.1) end)
                    opt.MouseButton1Click:Connect(function()
                        cur = v; sel.Text = tostring(v); open = false
                        tw(dd, {Size = UDim2.new(0.46, 0, 0, 0)}, 0.15); task.delay(0.15, function() dd.Visible = false end)
                        pcall(function() o.Callback(v) end)
                    end)
                end
            end
            build()
            sel.MouseButton1Click:Connect(function()
                open = not open
                if open then dd.Visible = true; twBack(dd, {Size = UDim2.new(0.46, 0, 0, math.min(#vals * 28 + 4, 160))}, 0.18)
                else tw(dd, {Size = UDim2.new(0.46, 0, 0, 0)}, 0.15); task.delay(0.15, function() dd.Visible = false end) end
            end)
            return {Refresh = function(nv) vals = nv; build() end}
        end

        -- INPUT
        function Tab:Input(o)
            local f = N("Frame", {Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = C.bg3, BackgroundTransparency = 0.1, BorderSizePixel = 0}, page)
            corner(f, 8); stroke(f, C.stroke, 1); pad(f, 0, 0, 12, 12)
            label(o.Title or "", C.text, 12, Enum.Font.GothamMedium, f, {Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 5)})
            local tf = N("Frame", {Size = UDim2.new(1, 0, 0, 22), Position = UDim2.new(0, 0, 1, -26), BackgroundColor3 = C.bg5}, f)
            corner(tf, 6); local ts = stroke(tf, C.stroke, 1)
            local tb = N("TextBox", {Size = UDim2.new(1, -10, 1, 0), Position = UDim2.new(0, 5, 0, 0), BackgroundTransparency = 1, PlaceholderText = o.Placeholder or "", PlaceholderColor3 = C.sub, Text = "", TextColor3 = C.text, TextSize = 11, Font = Enum.Font.GothamMedium, ClearTextOnFocus = false}, tf)
            tb.Focused:Connect(function() tw(ts, {Color = C.accent}, 0.15) end)
            tb.FocusLost:Connect(function() tw(ts, {Color = C.stroke}, 0.15); if tb.Text ~= "" then pcall(function() o.Callback(tb.Text) end) end end)
        end

        -- SECTION
        function Tab:Section(o)
            local sf = N("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = C.bg3, BackgroundTransparency = o.Box and 0.1 or 1, AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0, ClipsDescendants = false}, page)
            if o.Box then corner(sf, 10); stroke(sf, C.stroke, 1) end
            local hdr = N("TextButton", {Size = UDim2.new(1, 0, 0, o.Desc and 42 or 36), BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, sf); pad(hdr, 0, 0, 12, 8)
            label(o.Title or "", C.text, 12, Enum.Font.GothamBold, hdr, {Size = UDim2.new(1, -30, 0, 16), Position = UDim2.new(0, 0, 0, o.Desc and 6 or 10)})
            if o.Desc then label(o.Desc, C.sub, 10, Enum.Font.Gotham, hdr, {Size = UDim2.new(1, -30, 0, 14), Position = UDim2.new(0, 0, 0, 24)}) end
            local arrow = label("▾", C.sub, 12, Enum.Font.GothamBold, hdr, {Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(1, -22, 0, 0), TextXAlignment = Enum.TextXAlignment.Center})
            local cf = N("Frame", {Size = UDim2.new(1, -16, 0, 0), Position = UDim2.new(0, 8, 0, o.Desc and 42 or 36), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y}, sf)
            list(cf, Enum.FillDirection.Vertical, 4); pad(cf, 0, 8, 0, 0)
            local open = o.Opened ~= false
            local function so(v) open = v; cf.Visible = v; arrow.Text = v and "▾" or "▸" end
            so(open); hdr.MouseButton1Click:Connect(function() so(not open) end)
            local S = {}
            function S:Toggle(o2)
                local row = N("Frame", {Size = UDim2.new(1, 0, 0, o2.Desc and 42 or 34), BackgroundColor3 = C.bg4, BackgroundTransparency = 0.2, BorderSizePixel = 0}, cf)
                corner(row, 8); stroke(row, C.stroke, 1)
                label(o2.Title or "", C.text, 12, Enum.Font.GothamMedium, row, {Size = UDim2.new(1, -60, 0, 16), Position = UDim2.new(0, 10, 0, o2.Desc and 6 or 9)})
                if o2.Desc then label(o2.Desc, C.sub, 10, Enum.Font.Gotham, row, {Size = UDim2.new(1, -60, 0, 12), Position = UDim2.new(0, 10, 0, 22)}) end
                local pill = N("Frame", {Size = UDim2.new(0, 38, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = C.bg5}, row); corner(pill, 10)
                local knob = N("Frame", {Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = C.sub}, pill); corner(knob, 8)
                local st = o2.Value or false
                local function set(v)
                    st = v
                    tw(knob, {Position = v and UDim2.new(0, 20, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = v and C.white or C.sub}, 0.15)
                    tw(pill, {BackgroundColor3 = v and C.accent or C.bg5}, 0.15)
                    pcall(function() o2.Callback(v) end)
                end
                set(st)
                local hit = N("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, row)
                hit.MouseButton1Click:Connect(function() set(not st) end)
            end
            function S:Button(o2)
                local btn = N("TextButton", {Size = UDim2.new(1, 0, 0, o2.Desc and 42 or 34), BackgroundColor3 = C.bg4, BackgroundTransparency = 0.2, BorderSizePixel = 0, Text = "", AutoButtonColor = false}, cf)
                corner(btn, 8); stroke(btn, C.stroke, 1)
                label(o2.Title or "", C.text, 12, Enum.Font.GothamMedium, btn, {Size = UDim2.new(1, -24, 0, 16), Position = UDim2.new(0, 10, 0, o2.Desc and 7 or 9)})
                if o2.Desc then label(o2.Desc, C.sub, 10, Enum.Font.Gotham, btn, {Size = UDim2.new(1, -24, 0, 14), Position = UDim2.new(0, 10, 0, 23)}) end
                btn.MouseEnter:Connect(function() tw(btn, {BackgroundColor3 = C.bg5}, 0.1) end)
                btn.MouseLeave:Connect(function() tw(btn, {BackgroundColor3 = C.bg4}, 0.1) end)
                btn.MouseButton1Click:Connect(function() pcall(o2.Callback or function() end) end)
            end
            function S:Slider(o2)
                local r = o2.Value or {Min = 0, Max = 100, Default = 50}; local step = o2.Step or 1; local suffix = o2.Suffix or ""; local cur = r.Default or r.Min; local fmt = step < 1 and "%.1f" or "%d"
                local f = N("Frame", {Size = UDim2.new(1, 0, 0, 56), BackgroundColor3 = C.bg4, BackgroundTransparency = 0.2, BorderSizePixel = 0}, cf)
                corner(f, 8); stroke(f, C.stroke, 1); pad(f, 0, 0, 10, 10)
                label(o2.Title or "", C.text, 12, Enum.Font.GothamMedium, f, {Size = UDim2.new(1, -60, 0, 16), Position = UDim2.new(0, 0, 0, 6)})
                local vl = label(string.format(fmt, cur) .. suffix, C.accent2, 11, Enum.Font.GothamBold, f, {Size = UDim2.new(0, 52, 0, 18), Position = UDim2.new(1, -52, 0, 5), TextXAlignment = Enum.TextXAlignment.Right})
                local track = N("Frame", {Size = UDim2.new(1, 0, 0, 4), Position = UDim2.new(0, 0, 0, 36), BackgroundColor3 = C.bg5}, f); corner(track, 2)
                local fill = N("Frame", {Size = UDim2.new((cur - r.Min) / (r.Max - r.Min), 0, 1, 0), BackgroundColor3 = C.accent}, track); corner(fill, 2)
                local knob = N("Frame", {Size = UDim2.new(0, 14, 0, 14), BackgroundColor3 = C.white}, track); corner(knob, 7)
                local function uv(a) tw(fill, {Size = UDim2.new(a, 0, 1, 0)}, 0.05); tw(knob, {Position = UDim2.new(a, -7, 0.5, -7)}, 0.05) end
                uv((cur - r.Min) / (r.Max - r.Min))
                local dragging = false
                local hit = N("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, track)
                local function sc(x)
                    local a = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    local raw = r.Min + a * (r.Max - r.Min)
                    cur = math.clamp(r.Min + math.round((raw - r.Min) / step) * step, r.Min, r.Max)
                    a = (cur - r.Min) / (r.Max - r.Min); uv(a); vl.Text = string.format(fmt, cur) .. suffix
                    pcall(function() o2.Callback(cur) end)
                end
                hit.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; sc(i.Position.X) end end)
                hit.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
                UIS.InputChanged:Connect(function(i) if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then sc(i.Position.X) end end)
            end
            function S:Divider() N("Frame", {Size = UDim2.new(1, -4, 0, 1), BackgroundColor3 = C.stroke, BorderSizePixel = 0}, cf) end
            return S
        end

        -- PARAGRAPH
        function Tab:Paragraph(o)
            local f = N("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = C.bg3, BackgroundTransparency = 0.1, AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0}, page)
            corner(f, 10); stroke(f, C.stroke, 1); pad(f, 12, 12, 14, 14)
            local inner = N("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y}, f)
            list(inner, Enum.FillDirection.Vertical, 4)
            if o.Title then label(o.Title, C.text, 13, Enum.Font.GothamBold, inner, {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true}) end
            if o.Desc then label(o.Desc, C.sub, 11, Enum.Font.Gotham, inner, {Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true}) end
        end

                -- STATS
        function Tab:Stats(o)
            local f = N("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = C.bg3, BackgroundTransparency = 0.1, AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0}, page)
            corner(f, 10); stroke(f, C.stroke, 1); pad(f, 10, 10, 14, 14)
            local inner = N("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y}, f)
            list(inner, Enum.FillDirection.Vertical, 3)
            if o.Title then label(o.Title, C.text, 12, Enum.Font.GothamBold, inner, {Size = UDim2.new(1, 0, 0, 16)}) end
            if o.Items then
                for _, item in ipairs(o.Items) do
                    local row = N("Frame", {Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1}, inner)
                    label(item.Key .. ":", C.sub, 11, Enum.Font.Gotham, row, {Size = UDim2.new(0.5, 0, 1, 0)})
                    label(tostring(item.Value), C.accent2, 11, Enum.Font.GothamBold, row, {Size = UDim2.new(0.5, 0, 1, 0), Position = UDim2.new(0.5, 0, 0, 0), TextXAlignment = Enum.TextXAlignment.Right})
                end
            end
        end

        -- CODE
        function Tab:Code(o)
            local f = N("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = C.bg4, BackgroundTransparency = 0.1, AutomaticSize = Enum.AutomaticSize.Y, BorderSizePixel = 0}, page)
            corner(f, 10); stroke(f, C.stroke, 1); pad(f, 8, 8, 10, 10)
            if o.Title then label(o.Title, C.sub, 10, Enum.Font.GothamBold, f, {Size = UDim2.new(1, -60, 0, 16)}) end
            local copyBtn = N("TextButton", {Size = UDim2.new(0, 50, 0, 18), Position = UDim2.new(1, -50, 0, 4), BackgroundColor3 = C.accentD, Text = "Copy", TextColor3 = C.white, TextSize = 10, Font = Enum.Font.GothamBold, AutoButtonColor = false}, f)
            corner(copyBtn, 5)
            local codeBox = N("TextLabel", {Size = UDim2.new(1, 0, 0, 0), BackgroundColor3 = C.bg5, Text = o.Code or "", TextColor3 = Color3.fromRGB(130, 210, 130), TextSize = 10, Font = Enum.Font.Code, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, AutomaticSize = Enum.AutomaticSize.Y}, f)
            corner(codeBox, 6); pad(codeBox, 6, 6, 8, 8)
            copyBtn.MouseButton1Click:Connect(function()
                pcall(function() setclipboard(o.Code or "") end)
                copyBtn.Text = "✓"; task.delay(1.5, function() copyBtn.Text = "Copy" end)
            end)
        end

        -- GROUP
        function Tab:Group(o)
            local gf = N("Frame", {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.Y}, page)
            list(gf, Enum.FillDirection.Horizontal, 4)
            local G = {}
            function G:Button(o2)
                local bb = N("TextButton", {Size = UDim2.new(0, 0, 0, 30), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = C.bg3, BackgroundTransparency = 0.1, BorderSizePixel = 0, Text = "", AutoButtonColor = false}, gf)
                corner(bb, 8); stroke(bb, C.stroke, 1); pad(bb, 0, 0, 12, 12)
                label(o2.Title or "", C.text, 12, Enum.Font.GothamMedium, bb, {Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X})
                bb.MouseEnter:Connect(function() tw(bb, {BackgroundColor3 = C.bg4}, 0.1) end)
                bb.MouseLeave:Connect(function() tw(bb, {BackgroundColor3 = C.bg3}, 0.1) end)
                bb.MouseButton1Click:Connect(function() pcall(o2.Callback or function() end) end)
            end
            
            return G
        end

                -- ═══════════════════════════════════════════════════
        -- PARTE 5 — COLORPICKER
        -- ═══════════════════════════════════════════════════
        function Tab:Colorpicker(o)
            -- Preparamos la llamada al callback
            local function setColor(color)
                pcall(function() o.Callback(color) end)
            end

            -- Popup del selector
            local popupSG = N("ScreenGui", {Name = "ZethColorPicker", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999}, sg)
            
            local overlay = N("TextButton", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.black, BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, popupSG)
            tw(overlay, {BackgroundTransparency = 0.3}, 0.3)
            
            local card = N("Frame", {Size = UDim2.new(0, 260, 0, 280), Position = UDim2.new(0.5, 0, 0.5, 0), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = C.bg2, BackgroundTransparency = 0.05, BorderSizePixel = 0}, popupSG)
            corner(card, 14); stroke(card, C.stroke, 1)
            twBack(card, {Size = UDim2.new(0, 260, 0, 280)}, 0.3)
            
            -- Canvas de color (usamos una ImageLabel con un degradado)
            local colorCanvas = N("ImageLabel", {Size = UDim2.new(1, -20, 0, 200), Position = UDim2.new(0, 10, 0, 10), Image = "rbxassetid://4155801252", BackgroundColor3 = Color3.fromHSV(0, 1, 1), BackgroundTransparency = 0}, card)
            corner(colorCanvas, 8)
            
            -- Selector de tono (barra inferior)
            local hueBar = N("Frame", {Size = UDim2.new(1, -20, 0, 16), Position = UDim2.new(0, 10, 0, 220), BackgroundColor3 = C.white, BackgroundTransparency = 0}, card)
            corner(hueBar, 8)
            local hueGradient = N("UIGradient", {Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
            }), Parent = hueBar})
            
            -- Indicador de color seleccionado y botón de confirmar
            local preview = N("Frame", {Size = UDim2.new(0, 24, 0, 24), Position = UDim2.new(0, 0, 0, 245), BackgroundColor3 = o.Default or C.white, BorderSizePixel = 0}, card)
            corner(preview, 6)
            
            local okBtn = N("TextButton", {Size = UDim2.new(0, 60, 0, 26), Position = UDim2.new(1, -10, 0, 244), AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = C.accent, Text = "OK", TextColor3 = C.white, TextSize = 12, Font = Enum.Font.GothamBold, AutoButtonColor = false}, card)
            corner(okBtn, 6)
            
            local curH, curS, curV = 0, 1, 1
            
            -- Función para actualizar el preview
            local function updatePreview()
                local col = Color3.fromHSV(curH, curS, curV)
                preview.BackgroundColor3 = col
            end
            updatePreview()
            
            -- Lógica de arrastre en el canvas
            local draggingSatVal = false
            colorCanvas.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    draggingSatVal = true
                end
            end)
            UIS.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    draggingSatVal = false
                end
            end)
            UIS.InputChanged:Connect(function(inp)
                if draggingSatVal and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                    local relX = math.clamp((inp.Position.X - colorCanvas.AbsolutePosition.X) / colorCanvas.AbsoluteSize.X, 0, 1)
                    local relY = math.clamp((inp.Position.Y - colorCanvas.AbsolutePosition.Y) / colorCanvas.AbsoluteSize.Y, 0, 1)
                    curS = relX
                    curV = 1 - relY
                    updatePreview()
                end
            end)
            
            -- Lógica de arrastre en la barra de tono
            local draggingHue = false
            hueBar.InputBegan:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    draggingHue = true
                end
            end)
            UIS.InputEnded:Connect(function(inp)
                if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
                    draggingHue = false
                end
            end)
            UIS.InputChanged:Connect(function(inp)
                if draggingHue and (inp.UserInputType == Enum.UserInputType.MouseMovement or inp.UserInputType == Enum.UserInputType.Touch) then
                    local relX = math.clamp((inp.Position.X - hueBar.AbsolutePosition.X) / hueBar.AbsoluteSize.X, 0, 1)
                    curH = relX
                    colorCanvas.BackgroundColor3 = Color3.fromHSV(curH, 1, 1)
                    updatePreview()
                end
            end)
            
            -- Botón OK
            okBtn.MouseButton1Click:Connect(function()
                local finalColor = Color3.fromHSV(curH, curS, curV)
                setColor(finalColor)
                tw(card, {Size = UDim2.new(0, 260, 0, 0)}, 0.2)
                task.delay(0.2, function() popupSG:Destroy() end)
            end)
            
            -- Cerrar al hacer clic fuera
            overlay.MouseButton1Click:Connect(function()
                tw(card, {Size = UDim2.new(0, 260, 0, 0)}, 0.2)
                task.delay(0.2, function() popupSG:Destroy() end)
            end)
        end
        
        return Tab
    end

        -- SIDEBAR
    local sidebar = N("Frame", {Size = UDim2.new(0, 160, 1, -topH), Position = UDim2.new(0, 0, 0, topH), BackgroundColor3 = C.bg2, BackgroundTransparency = 0.3, BorderSizePixel = 0}, body)
    N("Frame", {Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, 0, 0, 0), BackgroundColor3 = C.stroke}, sidebar)
    local sidebarScroll = N("ScrollingFrame", {Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, ScrollBarImageColor3 = C.accent, CanvasSize = UDim2.new(0, 0, 0, 0)}, sidebar)
    local sidebarLayout = list(sidebarScroll, Enum.FillDirection.Vertical, 2); pad(sidebarScroll, 6, 6, 6, 6); autoCanvas(sidebarScroll, sidebarLayout)

    function W:SideBarLabel(o)
        local f = N("Frame", {Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1}, sidebarScroll)
        pad(f, 0, 0, 8, 0)
        label(o.Title or "", C.sub, 10, Enum.Font.GothamBold, f, {Size = UDim2.fromScale(1, 1)})
    end
    function W:SideBarDivider() N("Frame", {Size = UDim2.new(1, -12, 0, 1), BackgroundColor3 = C.stroke, BorderSizePixel = 0}, sidebarScroll) end
    function W:SideBarButton(o)
        local b = N("TextButton", {Size = UDim2.new(1, 0, 0, 32), BackgroundColor3 = C.bg3, BackgroundTransparency = 1, Text = "", AutoButtonColor = false}, sidebarScroll)
        corner(b, 8); pad(b, 0, 0, 10, 10)
        label(o.Title or "", C.sub, 12, Enum.Font.GothamMedium, b, {Size = UDim2.fromScale(1, 1)})
        b.MouseEnter:Connect(function() tw(b, {BackgroundTransparency = 0, BackgroundColor3 = C.bg4}, 0.12) end)
        b.MouseLeave:Connect(function() tw(b, {BackgroundTransparency = 1}, 0.12) end)
        b.MouseButton1Click:Connect(function() pcall(o.Callback or function() end) end)
    end

    -- WATERMARK
    if opts.Watermark and opts.Watermark.Enabled then
        local wmFrame = N("Frame", {Size = UDim2.new(0, 0, 0, 22), Position = UDim2.new(1, -8, 1, -28), AnchorPoint = Vector2.new(1, 0), BackgroundColor3 = C.bg3, BackgroundTransparency = 0.15, AutomaticSize = Enum.AutomaticSize.X}, sg)
        corner(wmFrame, 6); stroke(wmFrame, C.stroke, 1); pad(wmFrame, 0, 0, 8, 8)
        label(opts.Watermark.Text or title, C.sub, 10, Enum.Font.Gotham, wmFrame, {Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X})
    end

        -- ═══════════════════════════════════════════════════
    -- KEY SYSTEM (Glassmorphism Popup)
    -- ═══════════════════════════════════════════════════
    function W:KeySystem(cfg)
        cfg = cfg or {}
        local freeKey = cfg.Key or "free"
        local premKey = cfg.PremiumKey or ""
        local discord = cfg.Discord or ""
        local title = cfg.Title or title
        local onDone = cfg.Callback or function(tier) end

        local ksSG = N("ScreenGui", {Name = "ZethKey", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, DisplayOrder = 999}, sg)

        -- Overlay
        local overlay = N("Frame", {Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.black, BackgroundTransparency = 1, BorderSizePixel = 0}, ksSG)
        tw(overlay, {BackgroundTransparency = 0.25}, 1, Enum.EasingStyle.Sine)

        -- Glows
        local g1 = N("Frame", {Size = UDim2.new(0, 300, 0, 300), Position = UDim2.new(0.2, 0, 0.3, 0), BackgroundColor3 = C.accentD, BackgroundTransparency = 0.94, BorderSizePixel = 0, ZIndex = 0}, ksSG)
        corner(g1, 150)
        local g2 = N("Frame", {Size = UDim2.new(0, 250, 0, 250), Position = UDim2.new(0.7, 0, 0.6, 0), BackgroundColor3 = Color3.fromRGB(135, 65, 255), BackgroundTransparency = 0.95, BorderSizePixel = 0, ZIndex = 0}, ksSG)
        corner(g2, 125)
        
        task.spawn(function()
            while ksSG and ksSG.Parent do
                tw(g1, {Position = UDim2.new(0.25, 0, 0.35, 0)}, 4, Enum.EasingStyle.Sine)
                tw(g2, {Position = UDim2.new(0.65, 0, 0.55, 0)}, 4, Enum.EasingStyle.Sine)
                task.wait(4)
                tw(g1, {Position = UDim2.new(0.2, 0, 0.3, 0)}, 4, Enum.EasingStyle.Sine)
                tw(g2, {Position = UDim2.new(0.7, 0, 0.6, 0)}, 4, Enum.EasingStyle.Sine)
                task.wait(4)
            end
        end)

        -- Card
        local card = N("Frame", {Size = UDim2.new(0, 400, 0, 440), Position = UDim2.new(0.5, 0, 0.5, 60), AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = C.bg, BackgroundTransparency = 1, BorderSizePixel = 0, ClipsDescendants = true, ZIndex = 2}, ksSG)
        corner(card, 20)
        stroke(card, C.accentD, 1.5)

        tw(card, {BackgroundTransparency = 0.08, Position = UDim2.new(0.5, 0, 0.5, 0)}, 0.7, Enum.EasingStyle.Quint)

        -- Top accent line
        local topLine = N("Frame", {Size = UDim2.new(0, 0, 0, 3), BackgroundColor3 = C.accent, BorderSizePixel = 0, ZIndex = 5}, card)
        corner(topLine, 2)
        N("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, C.accent), ColorSequenceKeypoint.new(1, Color3.fromRGB(135, 65, 255))}), Parent = topLine})
        task.delay(0.2, function() tw(topLine, {Size = UDim2.new(1, 0, 0, 3)}, 0.8, Enum.EasingStyle.Quint) end)

        -- Logo
        local logo = N("Frame", {Size = UDim2.new(0, 50, 0, 50), Position = UDim2.new(0.5, 0, 0, 24), AnchorPoint = Vector2.new(0.5, 0), BackgroundColor3 = C.bg3, BackgroundTransparency = 0.15, BorderSizePixel = 0, ZIndex = 4}, card)
        corner(logo, 25)
        label(title:sub(1,1), C.accent2, 24, Enum.Font.GothamBold, logo, {Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center})

        -- Title
        local titleLbl = label(cfg.Title or title, C.text, 22, Enum.Font.GothamBold, card, {Size = UDim2.new(1, 0, 0, 26), Position = UDim2.new(0, 0, 0, 84), TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 1, ZIndex = 4, TextTransparency = 1})
        task.delay(0.3, function() tw(titleLbl, {TextTransparency = 0}, 0.4) end)

        local subLbl = label("Key System · Enter your key below", C.sub, 11, Enum.Font.Gotham, card, {Size = UDim2.new(1, 0, 0, 16), Position = UDim2.new(0, 0, 0, 112), TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 1, ZIndex = 4, TextTransparency = 1})
        task.delay(0.35, function() tw(subLbl, {TextTransparency = 0}, 0.4) end)

        -- Input
        local inputF = N("Frame", {Size = UDim2.new(0.75, 0, 0, 44), Position = UDim2.new(0.125, 0, 0, 155), BackgroundColor3 = C.bg3, BackgroundTransparency = 0.1, BorderSizePixel = 0, ZIndex = 4}, card)
        corner(inputF, 10)
        local inputStroke = stroke(inputF, C.stroke)
        local inputBox = N("TextBox", {Size = UDim2.new(1, -40, 1, 0), Position = UDim2.new(0, 36, 0, 0), BackgroundTransparency = 1, PlaceholderText = "Paste your key here...", PlaceholderColor3 = C.sub, Text = "", TextColor3 = C.text, TextSize = 13, Font = Enum.Font.GothamMedium, ClearTextOnFocus = false, ZIndex = 5}, inputF)
        N("TextLabel", {Size = UDim2.new(0, 20, 1, 0), Position = UDim2.new(0, 12, 0, 0), BackgroundTransparency = 1, Text = "🔑", TextSize = 14, ZIndex = 5}, inputF)
        inputBox.Focused:Connect(function() tw(inputStroke, {Color = C.accent}, 0.2) end)
        inputBox.FocusLost:Connect(function() tw(inputStroke, {Color = C.stroke}, 0.2) end)

        -- Status
        local statusLbl = label("", C.red, 10, Enum.Font.Gotham, card, {Size = UDim2.new(0.75, 0, 0, 14), Position = UDim2.new(0.125, 0, 0, 204), TextXAlignment = Enum.TextXAlignment.Left, BackgroundTransparency = 1, ZIndex = 4})

        -- Validate button
        local valBtn = N("TextButton", {Size = UDim2.new(0.75, 0, 0, 44), Position = UDim2.new(0.125, 0, 0, 225), BackgroundColor3 = C.accent, BackgroundTransparency = 0, BorderSizePixel = 0, Text = "⚡ VALIDATE KEY", TextColor3 = C.white, TextSize = 13, Font = Enum.Font.GothamBold, AutoButtonColor = false, ZIndex = 4}, card)
        corner(valBtn, 10)
        N("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, C.accent), ColorSequenceKeypoint.new(1, Color3.fromRGB(135, 65, 255))}), Rotation = 30, Parent = valBtn})

        -- Discord button
        local dcBtn = N("TextButton", {Size = UDim2.new(0.75, 0, 0, 40), Position = UDim2.new(0.125, 0, 0, 325), BackgroundColor3 = Color3.fromRGB(88, 101, 242), BorderSizePixel = 0, Text = "🎮 DISCORD · GET KEY", TextColor3 = C.white, TextSize = 11, Font = Enum.Font.GothamBold, AutoButtonColor = false, ZIndex = 4}, card)
        corner(dcBtn, 10)
        dcBtn.MouseButton1Click:Connect(function()
            pcall(function() setclipboard(discord) end)
            statusLbl.TextColor3 = C.green
            statusLbl.Text = "✓ Discord link copied!"
        end)

        -- Features
        local featF = N("Frame", {Size = UDim2.new(0.75, 0, 0, 50), Position = UDim2.new(0.125, 0, 0, 275), BackgroundColor3 = C.bg3, BackgroundTransparency = 0.1, BorderSizePixel = 0, ZIndex = 4}, card)
        corner(featF, 8)
        stroke(featF, C.stroke)
        label("FREE · Basic Features", C.sub, 9, Enum.Font.GothamBold, featF, {Size = UDim2.new(0.5, -4, 1, 0), Position = UDim2.new(0, 6, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center})
        label("PREMIUM · All Unlocked", C.gold, 9, Enum.Font.GothamBold, featF, {Size = UDim2.new(0.5, -4, 1, 0), Position = UDim2.new(0.5, 2, 0, 0), TextXAlignment = Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center})

        -- "or" text
        label("or", C.sub, 9, Enum.Font.Gotham, card, {Size = UDim2.new(0.75, 0, 0, 12), Position = UDim2.new(0.125, 0, 0, 310), TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 1, ZIndex = 4})

        -- Footer
        label(cfg.Title or title .. " · v1.0", C.sub, 8, Enum.Font.Gotham, card, {Size = UDim2.new(1, 0, 0, 12), Position = UDim2.new(0, 0, 1, -16), TextXAlignment = Enum.TextXAlignment.Center, BackgroundTransparency = 1, ZIndex = 4, TextTransparency = 0.6})

        -- Close function
        local function closeKeyGui(tier)
            tw(overlay, {BackgroundTransparency = 1}, 0.5)
            tw(card, {BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, -50)}, 0.5, Enum.EasingStyle.Quint)
            task.delay(0.55, function()
                ksSG:Destroy()
                onDone(tier)
            end)
        end

        -- Validate
        valBtn.MouseButton1Click:Connect(function()
            local key = inputBox.Text:gsub("%s+", "")
            if key == "" then
                statusLbl.TextColor3 = C.red
                statusLbl.Text = "⚠ Enter a key"
            elseif key == freeKey then
                statusLbl.TextColor3 = C.green
                statusLbl.Text = "✓ FREE UNLOCKED"
                for _, c in ipairs(topLine:GetChildren()) do if c:IsA("UIGradient") then c:Destroy() end end
                N("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, C.green), ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 205, 230))}), Parent = topLine})
                task.delay(0.8, function() closeKeyGui("free") end)
            elseif premKey ~= "" and key == premKey then
                statusLbl.TextColor3 = C.gold
                statusLbl.Text = "★ PREMIUM UNLOCKED"
                for _, c in ipairs(topLine:GetChildren()) do if c:IsA("UIGradient") then c:Destroy() end end
                N("UIGradient", {Color = ColorSequence.new({ColorSequenceKeypoint.new(0, C.gold), ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 140, 20))}), Parent = topLine})
                task.delay(0.8, function() closeKeyGui("premium") end)
            else
                statusLbl.TextColor3 = C.red
                statusLbl.Text = "✗ Invalid key"
                local origPos = inputF.Position
                for _, off in ipairs({-10, 10, -7, 7, -4, 0}) do
                    tw(inputF, {Position = UDim2.new(origPos.X.Scale, origPos.X.Offset + off, origPos.Y.Scale, origPos.Y.Offset)}, 0.03)
                    task.wait(0.03)
                end
            end
        end)
    end
    
    W:Notify("ZethUI Pro loaded!")
    return W
end

-- TOP LEVEL NOTIFY
function ZethUI:Notify(text, dur) toast(text, C.accent, dur or 3) end

return ZethUI
