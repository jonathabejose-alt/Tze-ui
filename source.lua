-- ╔══════════════════════════════════════════════════════════╗
-- ║        TZEUI PRO v2 — Glassmorphism UI Library          ║
-- ║        By tze | No external dependencies                ║
-- ╚══════════════════════════════════════════════════════════╝

local TzeUI = {}

-- ── SERVICES ──────────────────────────────────────────────────
local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CG = game:GetService("CoreGui")
local PL = game:GetService("Players")

-- ── PALETTE ───────────────────────────────────────────────────
local C = {
    bg       = Color3.fromRGB(6,6,12),
    bg2      = Color3.fromRGB(12,12,20),
    bg3      = Color3.fromRGB(18,18,30),
    bg4      = Color3.fromRGB(24,24,40),
    bg5      = Color3.fromRGB(32,32,50),
    stroke   = Color3.fromRGB(38,38,55),
    stroke2  = Color3.fromRGB(50,50,72),
    sub      = Color3.fromRGB(120,120,155),
    text     = Color3.fromRGB(225,225,245),
    white    = Color3.fromRGB(255,255,255),
    accent   = Color3.fromRGB(85,130,255),
    accent2  = Color3.fromRGB(110,160,255),
    accentD  = Color3.fromRGB(50,90,200),
    green    = Color3.fromRGB(45,215,90),
    red      = Color3.fromRGB(255,55,55),
}

-- ── HELPERS ───────────────────────────────────────────────────
local function N(class,props)
    local o=Instance.new(class)
    for k,v in pairs(props or {})do if k~="Parent"then pcall(function()o[k]=v end)end end
    if props and props.Parent then o.Parent=props.Parent end
    return o
end

local function tw(obj,props,dur)
    if not obj or not obj.Parent then return end
    TS:Create(obj,TweenInfo.new(dur or 0.3,Enum.EasingStyle.Quint,Enum.EasingDirection.Out),props):Play()
end

local function twBack(obj,props,dur)
    TS:Create(obj,TweenInfo.new(dur or 0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),props):Play()
end

local function corner(p,r)return N("UICorner",{CornerRadius=UDim.new(0,r or 8),Parent=p})end
local function stroke(p,col,th)return N("UIStroke",{Color=col or C.stroke,Thickness=th or 1,Transparency=0.5,ApplyStrokeMode=Enum.ApplyStrokeMode.Border,Parent=p})end
local function pad(p,t,b,l,r)return N("UIPadding",{PaddingTop=UDim.new(0,t or 0),PaddingBottom=UDim.new(0,b or 0),PaddingLeft=UDim.new(0,l or 0),PaddingRight=UDim.new(0,r or 0),Parent=p})end
local function label(txt,col,sz,font,parent)
    local l=N("TextLabel",{Text=txt or "",TextColor3=col or C.text,TextSize=sz or 13,Font=font or Enum.Font.GothamMedium,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd},parent)
    return l
end
local function list(p,dir,sp)return N("UIListLayout",{FillDirection=dir or Enum.FillDirection.Vertical,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,sp or 4)},p)end
local function autoCanvas(sf,layout)
    local function u()sf.CanvasSize=UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+10)end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(u)
    u()
end
local function drag(frame,handle)
    handle=handle or frame
    local d,ds,sp=false,nil,nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=true;ds=i.Position;sp=frame.Position end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then d=false end
    end)
    UIS.InputChanged:Connect(function(i)
        if d and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then
            local delta=i.Position-ds
            frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+delta.X,sp.Y.Scale,sp.Y.Offset+delta.Y)
        end
    end)
end

-- ── TOAST NOTIFICATIONS ──────────────────────────────────────
local toastHolder=nil
local function createToastHolder(parent)
    if toastHolder and toastHolder.Parent then return end
    toastHolder=N("Frame",{Size=UDim2.new(0,280,1,0),Position=UDim2.new(1,-16,0,16),AnchorPoint=Vector2.new(1,0),BackgroundTransparency=1},parent)
    list(toastHolder,Enum.FillDirection.Vertical,8)
end
local function toast(text,color,dur)
    if not toastHolder then return end
    local pill=N("Frame",{Size=UDim2.new(1,0,0,0),BackgroundColor3=C.bg2,BackgroundTransparency=0.05,BorderSizePixel=0,ClipsDescendants=true},toastHolder)
    corner(pill,10);stroke(pill,color or C.accent,1)
    local bar=N("Frame",{Size=UDim2.new(0,3,0.6,0),Position=UDim2.new(0,8,0.2,0),BackgroundColor3=color or C.accent,BorderSizePixel=0},pill);corner(bar,2)
    local lbl=N("TextLabel",{Size=UDim2.new(1,-28,1,0),Position=UDim2.new(0,18,0,0),BackgroundTransparency=1,Text=text,TextColor3=C.text,TextSize=11,Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,TextTransparency=1},pill)
    twBack(pill,{Size=UDim2.new(1,0,0,36)},0.35);task.delay(0.1,function()tw(lbl,{TextTransparency=0},0.25)end)
    task.delay(dur or 3,function()tw(lbl,{TextTransparency=1},0.2);tw(pill,{Size=UDim2.new(1,0,0,0)},0.3);task.delay(0.35,function()pcall(function()pill:Destroy()end)end)end)
end

-- ── WINDOW ───────────────────────────────────────────────────
function TzeUI:CreateWindow(opts)
    opts=opts or{}
    local winW=opts.Size and opts.Size.X.Offset or 640
    local winH=opts.Size and opts.Size.Y.Offset or 460
    local title=opts.Title or"TzeUI"
    local auth=opts.Author or""
    local sg=N("ScreenGui",{Name="TzeUI",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=100,IgnoreGuiInset=true})
    pcall(function()sg.Parent=CG end)if not sg.Parent then sg.Parent=PL.LocalPlayer:WaitForChild("PlayerGui")end
    createToastHolder(sg)

    -- Main
    local win=N("Frame",{Size=UDim2.fromOffset(winW,winH),Position=UDim2.new(0.5,-winW/2,0.5,-winH/2),BackgroundColor3=C.bg,BorderSizePixel=0,ClipsDescendants=true},sg)
    corner(win,16);stroke(win,C.stroke,1)

    -- Topbar
    local topH=46
    local topbar=N("Frame",{Size=UDim2.new(1,0,0,topH),BackgroundColor3=C.bg2,BorderSizePixel=0,ZIndex=3},win)
    corner(topbar,16);N("Frame",{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,1,-16),BackgroundColor3=C.bg2},topbar)
    stroke(topbar,C.stroke,1);drag(win,topbar)

    -- Title
    local tp=N("Frame",{Size=UDim2.new(0,0,0,26),Position=UDim2.new(0,12,0.5,-13),BackgroundColor3=C.accentD,AutomaticSize=Enum.AutomaticSize.X},topbar)
    corner(tp,13);pad(tp,0,0,10,10);label(title,C.accent2,12,Enum.Font.GothamBold,tp,{Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X})
    if auth~=""then label("by "..auth,C.sub,10,Enum.Font.Gotham,topbar,{Size=UDim2.new(0,120,1,0),Position=UDim2.new(0,140,0,0)})end

    -- Buttons
    local function wb(col,txt,x)
        local b=N("TextButton",{Size=UDim2.new(0,26,0,26),Position=UDim2.new(1,x,0.5,-13),BackgroundColor3=col,Text=txt,TextColor3=C.white,TextSize=14,Font=Enum.Font.GothamBold,AutoButtonColor=false,ZIndex=5},topbar)
        corner(b,13);return b
    end
    local closeBtn=wb(Color3.fromRGB(220,60,60),"×",-36)
    local minBtn=wb(Color3.fromRGB(230,170,40),"–",-66)
    local minimized=false
    local fullSize=win.Size
    closeBtn.MouseButton1Click:Connect(function()tw(win,{Size=UDim2.fromOffset(winW,0)},0.25);task.delay(0.28,function()sg:Destroy()end)end)
    minBtn.MouseButton1Click:Connect(function()
        minimized=not minimized
        if minimized then fullSize=win.Size;tw(win,{Size=UDim2.fromOffset(winW,topH)},0.22)else tw(win,{Size=fullSize},0.22)end
    end)

    -- Accent line
    local al=N("Frame",{Size=UDim2.new(0,0,0,3),Position=UDim2.new(0,0,0,0),BackgroundColor3=C.accent,BorderSizePixel=0,ZIndex=5},win)
    corner(al,2);N("UIGradient",{Color=ColorSequence.new{ColorSequenceKeypoint.new(0,C.accent),ColorSequenceKeypoint.new(1,C.accentD)},Parent=al})
    task.delay(0.15,function()tw(al,{Size=UDim2.new(1,0,0,3)},0.6,Enum.EasingStyle.Quint)end)

    -- Body
    local body=N("Frame",{Size=UDim2.new(1,0,1,-topH),Position=UDim2.new(0,0,0,topH),BackgroundTransparency=1},win)

    -- Tab bar
    local tabH=38
    local tabBar=N("Frame",{Size=UDim2.new(1,0,0,tabH),BackgroundColor3=C.bg2,BorderSizePixel=0},body)
    N("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=C.stroke},tabBar)
    local tabScroll=N("ScrollingFrame",{Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,4,0,0),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=0,CanvasSize=UDim2.new(0,0,0,0)},tabBar)
    list(tabScroll,Enum.FillDirection.Horizontal,2,nil,Enum.VerticalAlignment.Center);pad(tabScroll,0,0,4,4)
    local tabPages=N("Frame",{Size=UDim2.new(1,0,1,-tabH),Position=UDim2.new(0,0,0,tabH),BackgroundTransparency=1,ClipsDescendants=true},body)

    -- ── WINDOW API ─────────────────────────────────────────
    local W={_tabs={},_sg=sg,_win=win}
    function W:Notify(text,dur)toast(text,C.accent,dur or 3)end
    function W:Toggle()win.Visible=not win.Visible end

    -- ── TABS ──────────────────────────────────────────────
    function W:Tab(opts)
        local order=#self._tabs+1
        local ttl=opts.Title or"Tab"
        local tabBtn=N("TextButton",{Size=UDim2.new(0,0,1,-8),AutomaticSize=Enum.AutomaticSize.X,BackgroundColor3=C.bg4,BackgroundTransparency=1,Text=ttl,TextColor3=C.sub,TextSize=12,Font=Enum.Font.GothamMedium,AutoButtonColor=false,LayoutOrder=order},tabScroll)
        corner(tabBtn,7);pad(tabBtn,0,0,12,12)
        local ul=N("Frame",{Size=UDim2.new(1,0,0,2),Position=UDim2.new(0,0,1,-2),BackgroundColor3=C.accent,BackgroundTransparency=1},tabBtn)
        local page=N("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=C.accent,CanvasSize=UDim2.new(0,0,0,0),Visible=false},tabPages)
        local pl=list(page,Enum.FillDirection.Vertical,6);pad(page,10,10,10,10);autoCanvas(page,pl)
        table.insert(self._tabs,{btn=tabBtn,page=page,ul=ul})
        local function act()
            for _,t in ipairs(self._tabs)do t.page.Visible=false;tw(t.btn,{TextColor3=C.sub,BackgroundTransparency=1},0.15);tw(t.ul,{BackgroundTransparency=1},0.15)end
            page.Visible=true;tw(tabBtn,{TextColor3=C.accent2,BackgroundTransparency=0},0.15);tw(ul,{BackgroundTransparency=0},0.15)
        end
        tabBtn.MouseButton1Click:Connect(act)
        if order==1 then act()end

        local Tab={_page=page,_win=self}

        -- ── DIVIDER ────────────────────────────────────────
        function Tab:Divider()N("Frame",{Size=UDim2.new(1,-6,0,1),BackgroundColor3=C.stroke,BorderSizePixel=0},page)end

        -- ── TOGGLE ─────────────────────────────────────────
        function Tab:Toggle(o)
            local row=N("Frame",{Size=UDim2.new(1,0,0,o.Desc and 42 or 34),BackgroundColor3=C.bg3,BackgroundTransparency=0.1,BorderSizePixel=0},page)
            corner(row,8);stroke(row,C.stroke,1)
            label(o.Title or"",C.text,12,Enum.Font.GothamMedium,row,{Size=UDim2.new(1,-60,0,16),Position=UDim2.new(0,12,0,o.Desc and 6 or 9)})
            if o.Desc then label(o.Desc,C.sub,10,Enum.Font.Gotham,row,{Size=UDim2.new(1,-60,0,12),Position=UDim2.new(0,12,0,22)})end
            local pill=N("Frame",{Size=UDim2.new(0,38,0,20),Position=UDim2.new(1,-50,0.5,-10),BackgroundColor3=C.bg5},row);corner(pill,10)
            local knob=N("Frame",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,2,0.5,-8),BackgroundColor3=C.sub},pill);corner(knob,8)
            local state=o.Value or false
            local function set(v)
                state=v
                tw(knob,{Position=v and UDim2.new(0,20,0.5,-8)or UDim2.new(0,2,0.5,-8),BackgroundColor3=v and C.white or C.sub},0.15)
                tw(pill,{BackgroundColor3=v and C.accent or C.bg5},0.15)
                pcall(function()o.Callback(v)end)
            end
            set(state)
            local hit=N("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false},row)
            hit.MouseButton1Click:Connect(function()set(not state)end)
        end

        -- ── BUTTON ─────────────────────────────────────────
        function Tab:Button(o)
            local btn=N("TextButton",{Size=UDim2.new(1,0,0,o.Desc and 42 or 34),BackgroundColor3=C.bg3,BackgroundTransparency=0.1,BorderSizePixel=0,Text="",AutoButtonColor=false},page)
            corner(btn,8);stroke(btn,C.stroke,1)
            label(o.Title or"",C.text,12,Enum.Font.GothamMedium,btn,{Size=UDim2.new(1,-24,0,16),Position=UDim2.new(0,12,0,o.Desc and 7 or 9)})
            if o.Desc then label(o.Desc,C.sub,10,Enum.Font.Gotham,btn,{Size=UDim2.new(1,-24,0,14),Position=UDim2.new(0,12,0,23)})end
            btn.MouseEnter:Connect(function()tw(btn,{BackgroundColor3=C.bg4},0.1)end)
            btn.MouseLeave:Connect(function()tw(btn,{BackgroundColor3=C.bg3},0.1)end)
            btn.MouseButton1Click:Connect(function()tw(btn,{BackgroundColor3=C.accentD},0.06);task.delay(0.1,function()tw(btn,{BackgroundColor3=C.bg4},0.1)end);pcall(o.Callback or function()end)end)
        end

        -- ── SLIDER ─────────────────────────────────────────
        function Tab:Slider(o)
            local r=o.Value or{Min=0,Max=100,Default=50}
            local step=o.Step or 1
            local suffix=o.Suffix or""
            local cur=r.Default or r.Min
            local fmt=step<1 and"%.1f"or"%d"
            local f=N("Frame",{Size=UDim2.new(1,0,0,56),BackgroundColor3=C.bg3,BackgroundTransparency=0.1,BorderSizePixel=0},page)
            corner(f,8);stroke(f,C.stroke,1);pad(f,0,0,12,12)
            label(o.Title or"",C.text,12,Enum.Font.GothamMedium,f,{Size=UDim2.new(1,-60,0,16),Position=UDim2.new(0,0,0,6)})
            local vl=label(string.format(fmt,cur)..suffix,C.accent2,11,Enum.Font.GothamBold,f,{Size=UDim2.new(0,52,0,18),Position=UDim2.new(1,-52,0,5),TextXAlignment=Enum.TextXAlignment.Right})
            local track=N("Frame",{Size=UDim2.new(1,0,0,4),Position=UDim2.new(0,0,0,36),BackgroundColor3=C.bg5},f);corner(track,2)
            local fill=N("Frame",{Size=UDim2.new((cur-r.Min)/(r.Max-r.Min),0,1,0),BackgroundColor3=C.accent},track);corner(fill,2)
            local knob=N("Frame",{Size=UDim2.new(0,14,0,14),BackgroundColor3=C.white},track);corner(knob,7)
            local function uv(a)tw(fill,{Size=UDim2.new(a,0,1,0)},0.05);tw(knob,{Position=UDim2.new(a,-7,0.5,-7)},0.05)end
            uv((cur-r.Min)/(r.Max-r.Min))
            local dragging=false
            local hit=N("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false},track)
            local function sc(x)
                local a=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
                local raw=r.Min+a*(r.Max-r.Min)
                cur=math.clamp(r.Min+math.round((raw-r.Min)/step)*step,r.Min,r.Max)
                a=(cur-r.Min)/(r.Max-r.Min);uv(a);vl.Text=string.format(fmt,cur)..suffix
                pcall(function()o.Callback(cur)end)
            end
            hit.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true;sc(i.Position.X)end end)
            hit.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
            UIS.InputChanged:Connect(function(i)if dragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then sc(i.Position.X)end end)
        end

        -- ═══════════════════════════════════════════════════
        -- PARTE 2 — DROPDOWN + INPUT + SECTION
        -- ═══════════════════════════════════════════════════

        -- ── DROPDOWN ───────────────────────────────────────
        function Tab:Dropdown(o)
            local vals=o.Values or{}
            local cur=o.Value or(vals[1]or"Select...")
            local open=false
            local f=N("Frame",{Size=UDim2.new(1,0,0,36),BackgroundColor3=C.bg3,BackgroundTransparency=0.1,BorderSizePixel=0,ZIndex=5,ClipsDescendants=false},page)
            corner(f,8);stroke(f,C.stroke,1)
            label(o.Title or"",C.text,12,Enum.Font.GothamMedium,f,{Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,10,0,0)})
            local sel=N("TextButton",{Size=UDim2.new(0.46,0,0,24),Position=UDim2.new(0.53,0,0.5,-12),BackgroundColor3=C.bg5,Text=tostring(cur),TextColor3=C.accent2,TextSize=11,Font=Enum.Font.GothamMedium,AutoButtonColor=false,ZIndex=6},f)
            corner(sel,6)
            local dd=N("Frame",{Size=UDim2.new(0.46,0,0,0),Position=UDim2.new(0.53,0,1,4),BackgroundColor3=C.bg4,BorderSizePixel=0,ZIndex=20,ClipsDescendants=true,Visible=false},f)
            corner(dd,8);stroke(dd,C.stroke2,1)
            local dl=N("Frame",{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y},dd)
            list(dl,Enum.FillDirection.Vertical,1);pad(dl,2,2,2,2)
            local function build()
                dl:ClearAllChildren();list(dl,Enum.FillDirection.Vertical,1);pad(dl,2,2,2,2)
                for _,v in ipairs(vals)do
                    local opt=N("TextButton",{Size=UDim2.new(1,0,0,26),BackgroundColor3=C.bg4,BackgroundTransparency=1,Text=tostring(v),TextColor3=v==cur and C.accent2 or C.sub,TextSize=11,Font=Enum.Font.GothamMedium,AutoButtonColor=false,ZIndex=21},dl)
                    corner(opt,5)
                    opt.MouseEnter:Connect(function()tw(opt,{BackgroundTransparency=0,BackgroundColor3=C.bg5},0.1)end)
                    opt.MouseLeave:Connect(function()tw(opt,{BackgroundTransparency=1},0.1)end)
                    opt.MouseButton1Click:Connect(function()
                        cur=v;sel.Text=tostring(v);open=false
                        tw(dd,{Size=UDim2.new(0.46,0,0,0)},0.15);task.delay(0.15,function()dd.Visible=false end)
                        pcall(function()o.Callback(v)end)
                    end)
                end
            end
            build()
            sel.MouseButton1Click:Connect(function()
                open=not open
                if open then dd.Visible=true;twBack(dd,{Size=UDim2.new(0.46,0,0,math.min(#vals*28+4,160))},0.18)
                else tw(dd,{Size=UDim2.new(0.46,0,0,0)},0.15);task.delay(0.15,function()dd.Visible=false end)end
            end)
            return{Refresh=function(nv)vals=nv;build()end}
        end

        -- ── INPUT ───────────────────────────────────────────
        function Tab:Input(o)
            local f=N("Frame",{Size=UDim2.new(1,0,0,50),BackgroundColor3=C.bg3,BackgroundTransparency=0.1,BorderSizePixel=0},page)
            corner(f,8);stroke(f,C.stroke,1);pad(f,0,0,12,12)
            label(o.Title or"",C.text,12,Enum.Font.GothamMedium,f,{Size=UDim2.new(1,0,0,16),Position=UDim2.new(0,0,0,5)})
            local tf=N("Frame",{Size=UDim2.new(1,0,0,22),Position=UDim2.new(0,0,1,-26),BackgroundColor3=C.bg5},f)
            corner(tf,6);local ts=stroke(tf,C.stroke,1)
            local tb=N("TextBox",{Size=UDim2.new(1,-10,1,0),Position=UDim2.new(0,5,0,0),BackgroundTransparency=1,PlaceholderText=o.Placeholder or"",PlaceholderColor3=C.sub,Text="",TextColor3=C.text,TextSize=11,Font=Enum.Font.GothamMedium,ClearTextOnFocus=false},tf)
            tb.Focused:Connect(function()tw(ts,{Color=C.accent},0.15)end)
            tb.FocusLost:Connect(function()tw(ts,{Color=C.stroke},0.15);if tb.Text~=""then pcall(function()o.Callback(tb.Text)end)end end)
        end

        -- ── SECTION (COLLAPSIBLE) ──────────────────────────
        function Tab:Section(o)
            local sf=N("Frame",{Size=UDim2.new(1,0,0,0),BackgroundColor3=C.bg3,BackgroundTransparency=o.Box and 0.1 or 1,AutomaticSize=Enum.AutomaticSize.Y,BorderSizePixel=0,ClipsDescendants=false},page)
            if o.Box then corner(sf,10);stroke(sf,C.stroke,1)end
            local hdr=N("TextButton",{Size=UDim2.new(1,0,0,o.Desc and 42 or 36),BackgroundTransparency=1,Text="",AutoButtonColor=false},sf);pad(hdr,0,0,12,8)
            label(o.Title or"",C.text,12,Enum.Font.GothamBold,hdr,{Size=UDim2.new(1,-30,0,16),Position=UDim2.new(0,0,0,o.Desc and 6 or 10)})
            if o.Desc then label(o.Desc,C.sub,10,Enum.Font.Gotham,hdr,{Size=UDim2.new(1,-30,0,14),Position=UDim2.new(0,0,0,24)})end
            local arrow=label("▾",C.sub,12,Enum.Font.GothamBold,hdr,{Size=UDim2.new(0,20,1,0),Position=UDim2.new(1,-22,0,0),TextXAlignment=Enum.TextXAlignment.Center})
            local cf=N("Frame",{Size=UDim2.new(1,-16,0,0),Position=UDim2.new(0,8,0,o.Desc and 42 or 36),BackgroundTransparency=1,AutomaticSize=Enum.AutomaticSize.Y},sf)
            list(cf,Enum.FillDirection.Vertical,4);pad(cf,0,8,0,0)
            local open=o.Opened~=false
            local function so(v)open=v;cf.Visible=v;arrow.Text=v and"▾"or"▸"end
            so(open);hdr.MouseButton1Click:Connect(function()so(not open)end)
            local S={}
            function S:Toggle(o2)
                local row=N("Frame",{Size=UDim2.new(1,0,0,o2.Desc and 42 or 34),BackgroundColor3=C.bg4,BackgroundTransparency=0.2,BorderSizePixel=0},cf)
                corner(row,8);stroke(row,C.stroke,1)
                label(o2.Title or"",C.text,12,Enum.Font.GothamMedium,row,{Size=UDim2.new(1,-60,0,16),Position=UDim2.new(0,10,0,o2.Desc and 6 or 9)})
                if o2.Desc then label(o2.Desc,C.sub,10,Enum.Font.Gotham,row,{Size=UDim2.new(1,-60,0,12),Position=UDim2.new(0,10,0,22)})end
                local pill=N("Frame",{Size=UDim2.new(0,38,0,20),Position=UDim2.new(1,-50,0.5,-10),BackgroundColor3=C.bg5},row);corner(pill,10)
                local knob=N("Frame",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,2,0.5,-8),BackgroundColor3=C.sub},pill);corner(knob,8)
                local st=o2.Value or false
                local function set(v)
                    st=v
                    tw(knob,{Position=v and UDim2.new(0,20,0.5,-8)or UDim2.new(0,2,0.5,-8),BackgroundColor3=v and C.white or C.sub},0.15)
                    tw(pill,{BackgroundColor3=v and C.accent or C.bg5},0.15)
                    pcall(function()o2.Callback(v)end)
                end
                set(st)
                local hit=N("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false},row)
                hit.MouseButton1Click:Connect(function()set(not st)end)
            end
            function S:Button(o2)
                local btn=N("TextButton",{Size=UDim2.new(1,0,0,o2.Desc and 42 or 34),BackgroundColor3=C.bg4,BackgroundTransparency=0.2,BorderSizePixel=0,Text="",AutoButtonColor=false},cf)
                corner(btn,8);stroke(btn,C.stroke,1)
                label(o2.Title or"",C.text,12,Enum.Font.GothamMedium,btn,{Size=UDim2.new(1,-24,0,16),Position=UDim2.new(0,10,0,o2.Desc and 7 or 9)})
                if o2.Desc then label(o2.Desc,C.sub,10,Enum.Font.Gotham,btn,{Size=UDim2.new(1,-24,0,14),Position=UDim2.new(0,10,0,23)})end
                btn.MouseEnter:Connect(function()tw(btn,{BackgroundColor3=C.bg5},0.1)end)
                btn.MouseLeave:Connect(function()tw(btn,{BackgroundColor3=C.bg4},0.1)end)
                btn.MouseButton1Click:Connect(function()pcall(o2.Callback or function()end)end)
            end
            function S:Slider(o2)
                local r=o2.Value or{Min=0,Max=100,Default=50};local step=o2.Step or 1;local suffix=o2.Suffix or"";local cur=r.Default or r.Min;local fmt=step<1 and"%.1f"or"%d"
                local f=N("Frame",{Size=UDim2.new(1,0,0,56),BackgroundColor3=C.bg4,BackgroundTransparency=0.2,BorderSizePixel=0},cf)
                corner(f,8);stroke(f,C.stroke,1);pad(f,0,0,10,10)
                label(o2.Title or"",C.text,12,Enum.Font.GothamMedium,f,{Size=UDim2.new(1,-60,0,16),Position=UDim2.new(0,0,0,6)})
                local vl=label(string.format(fmt,cur)..suffix,C.accent2,11,Enum.Font.GothamBold,f,{Size=UDim2.new(0,52,0,18),Position=UDim2.new(1,-52,0,5),TextXAlignment=Enum.TextXAlignment.Right})
                local track=N("Frame",{Size=UDim2.new(1,0,0,4),Position=UDim2.new(0,0,0,36),BackgroundColor3=C.bg5},f);corner(track,2)
                local fill=N("Frame",{Size=UDim2.new((cur-r.Min)/(r.Max-r.Min),0,1,0),BackgroundColor3=C.accent},track);corner(fill,2)
                local knob=N("Frame",{Size=UDim2.new(0,14,0,14),BackgroundColor3=C.white},track);corner(knob,7)
                local function uv(a)tw(fill,{Size=UDim2.new(a,0,1,0)},0.05);tw(knob,{Position=UDim2.new(a,-7,0.5,-7)},0.05)end
                uv((cur-r.Min)/(r.Max-r.Min))
                local dragging=false
                local hit=N("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false},track)
                local function sc(x)
                    local a=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
                    local raw=r.Min+a*(r.Max-r.Min)
                    cur=math.clamp(r.Min+math.round((raw-r.Min)/step)*step,r.Min,r.Max)
                    a=(cur-r.Min)/(r.Max-r.Min);uv(a);vl.Text=string.format(fmt,cur)..suffix
                    pcall(function()o2.Callback(cur)end)
                end
                hit.InputBegan:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true;sc(i.Position.X)end end)
                hit.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
                UIS.InputChanged:Connect(function(i)if dragging and(i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch)then sc(i.Position.X)end end)
            end
            function S:Divider()N("Frame",{Size=UDim2.new(1,-4,0,1),BackgroundColor3=C.stroke,BorderSizePixel=0},cf)end
            return S
        end

        return Tab
    end

    W:Notify("TzeUI Pro loaded!")
    return W
end

-- ── TOP LEVEL NOTIFY ────────────────────────────────────────
function TzeUI:Notify(text,dur)toast(text,C.accent,dur or 3)end

return TzeUI
