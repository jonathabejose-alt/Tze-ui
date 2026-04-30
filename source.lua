--[[
╔══════════════════════════════════════════════════════════╗
║                ZETH UI LIBRARY  v2.0                     ║
║          Glassmorphism Dark — Fixed & Production         ║
╚══════════════════════════════════════════════════════════╝

USAGE:
    local ZethUI = loadstring(game:HttpGet("YOUR_URL"))()

    local win = ZethUI:CreateWindow({
        Title    = "My Hub",
        Subtitle = "v1.0",
        Key      = "free_key",
        PremiumKey = "prem_key",        -- optional
        Discord  = "https://discord.gg/xxx",
        Logo     = "Z",
    })

    -- optional sidebar extras
    win:Watermark("My Hub  ·  {fps} FPS  ·  {ping}ms")
    win:SideBarLabel("TOOLS")
    win:SideBarButton("⚙", "Settings", function() end)
    win:SideBarDivider()
    win:Toggle("Master", false, function(v) end)

    -- tabs
    local tab = win:Tab("Main")

    -- section inside tab
    local sec = tab:Section("Combat")
    sec:Toggle("Enable", false, function(v) end)
    sec:Button("Teleport", function() end)
    sec:Slider("Speed", 16, 0, 100, function(v) end)
    sec:Divider()

    -- elements directly on tab
    tab:Toggle("Option", false, function(v) end)
    tab:Button("Do Thing", function() end)
    tab:Slider("Value", 50, 0, 200, function(v) end)
    tab:Dropdown("Mode", {"Off","On","Auto"}, function(v) end)
    tab:Input("Name", "type here...", function(v) end)
    tab:Paragraph("Info", "Some body text here.")
    tab:Stats({FPS = 60, Ping = 30, Players = 12})
    tab:Code('print("hello world")')
    tab:Divider()

    local grp = tab:Group("My Group")
    grp:Toggle("Sub Option", false, function(v) end)
    grp:Button("Sub Button", function() end)
]]

--------------------------------------------------------------
local ZethUI   = {}
ZethUI.__index = ZethUI

local Players = game:GetService("Players")
local RS      = game:GetService("RunService")
local UIS     = game:GetService("UserInputService")
local TS      = game:GetService("TweenService")
local SG      = game:GetService("StarterGui")
local CG      = game:GetService("CoreGui")
local LP      = Players.LocalPlayer

--------------------------------------------------------------
-- PALETTE
--------------------------------------------------------------
local C = {
    bg       = Color3.fromRGB(8,8,14),
    bg2      = Color3.fromRGB(14,14,22),
    bg3      = Color3.fromRGB(20,20,30),
    bg4      = Color3.fromRGB(28,28,42),
    bg5      = Color3.fromRGB(35,35,50),
    stroke   = Color3.fromRGB(40,40,60),
    stroke2  = Color3.fromRGB(55,55,78),
    dim      = Color3.fromRGB(60,60,82),
    dim2     = Color3.fromRGB(45,45,62),
    sub      = Color3.fromRGB(120,120,150),
    text     = Color3.fromRGB(228,228,248),
    white    = Color3.fromRGB(255,255,255),
    blue     = Color3.fromRGB(70,135,255),
    blue2    = Color3.fromRGB(105,170,255),
    blueD    = Color3.fromRGB(40,90,200),
    blueGlow = Color3.fromRGB(30,70,180),
    purple   = Color3.fromRGB(135,65,255),
    gold     = Color3.fromRGB(255,185,40),
    gold2    = Color3.fromRGB(255,218,85),
    goldD    = Color3.fromRGB(190,135,15),
    green    = Color3.fromRGB(45,215,90),
    red      = Color3.fromRGB(255,50,50),
    orange   = Color3.fromRGB(255,145,25),
    cyan     = Color3.fromRGB(50,205,230),
    disc     = Color3.fromRGB(88,101,242),
    glass    = Color3.fromRGB(15,15,25),
}

--------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------
local function new(cls, props)
    local o = Instance.new(cls)
    for k,v in pairs(props) do
        if k ~= "Parent" then pcall(function() o[k]=v end) end
    end
    if props.Parent then o.Parent = props.Parent end
    return o
end

local function tw(obj, props, dur, sty, dir)
    if not obj or not obj.Parent then return end
    TS:Create(obj,
        TweenInfo.new(dur or .3, sty or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props):Play()
end

local function twBack(obj, props, dur)
    tw(obj, props, dur or .4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function mkCorner(p, r)
    new("UICorner",{CornerRadius=UDim.new(0,r or 8),Parent=p})
end

local function mkStroke(p, col, thick, tr)
    return new("UIStroke",{
        Color=col or C.stroke, Thickness=thick or 1,
        Transparency=tr or .5,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
        Parent=p
    })
end

local function mkPad(p, t,b,l,r)
    new("UIPadding",{
        PaddingTop=UDim.new(0,t or 0), PaddingBottom=UDim.new(0,b or 0),
        PaddingLeft=UDim.new(0,l or 0), PaddingRight=UDim.new(0,r or 0),
        Parent=p
    })
end

local function mkList(p, dir, gap)
    return new("UIListLayout",{
        FillDirection=dir or Enum.FillDirection.Vertical,
        SortOrder=Enum.SortOrder.LayoutOrder,
        Padding=UDim.new(0,gap or 4),
        Parent=p
    })
end

local function mkGrad(p, c1, c2, rot)
    new("UIGradient",{
        Color=ColorSequence.new{
            ColorSequenceKeypoint.new(0,c1),
            ColorSequenceKeypoint.new(1,c2)
        },
        Rotation=rot or 0, Parent=p
    })
end

local function mkShadow(p, sz, tr)
    new("ImageLabel",{
        Name="Shadow",
        Size=UDim2.new(1,sz or 30,1,sz or 30),
        Position=UDim2.new(.5,0,.5,4),
        AnchorPoint=Vector2.new(.5,.5),
        BackgroundTransparency=1,
        Image="rbxassetid://6014261993",
        ImageColor3=Color3.new(0,0,0),
        ImageTransparency=tr or .5,
        ScaleType=Enum.ScaleType.Slice,
        SliceCenter=Rect.new(49,49,450,450),
        ZIndex=-1, Parent=p
    })
end

--------------------------------------------------------------
-- TOAST
--------------------------------------------------------------
local _toastGui = nil

local function ensureToasts(screenGui)
    if _toastGui and _toastGui.Parent then return end
    local cont = new("Frame",{
        Name="ZethToasts",
        Size=UDim2.new(0,280,1,0),
        Position=UDim2.new(1,-16,0,16),
        AnchorPoint=Vector2.new(1,0),
        BackgroundTransparency=1,
        Parent=screenGui,
    })
    mkList(cont, Enum.FillDirection.Vertical, 8)
    _toastGui = cont
end

local function toast(text, col, dur)
    if not _toastGui or not _toastGui.Parent then return end
    local accent = col or C.blue

    local pill = new("Frame",{
        Size=UDim2.new(1,0,0,0),
        BackgroundColor3=C.bg2,
        BackgroundTransparency=.05,
        BorderSizePixel=0,
        ClipsDescendants=true,
        Parent=_toastGui,
    })
    mkCorner(pill,10)
    mkStroke(pill,accent,1,.3)

    new("Frame",{
        Size=UDim2.new(0,3,.6,0),
        Position=UDim2.new(0,8,.2,0),
        BackgroundColor3=accent,
        BorderSizePixel=0,
        Parent=pill,
    })

    local lbl = new("TextLabel",{
        Size=UDim2.new(1,-28,1,0),
        Position=UDim2.new(0,18,0,0),
        BackgroundTransparency=1,
        Text=text, TextColor3=C.text,
        TextSize=11, Font=Enum.Font.GothamMedium,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextWrapped=true, TextTransparency=1,
        Parent=pill,
    })

    twBack(pill,{Size=UDim2.new(1,0,0,36)},.35)
    task.delay(.1,function() tw(lbl,{TextTransparency=0},.25) end)
    task.delay(dur or 3,function()
        tw(lbl,{TextTransparency=1},.2)
        tw(pill,{Size=UDim2.new(1,0,0,0)},.3)
        task.delay(.35,function() pcall(function() pill:Destroy() end) end)
    end)
end

--------------------------------------------------------------
-- KEY SYSTEM  (identical style to original)
--------------------------------------------------------------
local function showKey(cfg, onDone)
    pcall(function()
        local o = CG:FindFirstChild("ZethUI_Key")
        if o then o:Destroy() end
    end)

    local scr = new("ScreenGui",{
        Name="ZethUI_Key", ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset=true, Parent=CG,
    })

    local overlay = new("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=Color3.new(0,0,0),
        BackgroundTransparency=1,
        BorderSizePixel=0, Parent=scr,
    })
    tw(overlay,{BackgroundTransparency=.25},1,Enum.EasingStyle.Sine)

    local function mkGlow(pos,col,sz,tr)
        local g=new("Frame",{
            Size=UDim2.new(0,sz,0,sz),Position=pos,
            AnchorPoint=Vector2.new(.5,.5),
            BackgroundColor3=col,BackgroundTransparency=tr or .92,
            BorderSizePixel=0,ZIndex=0,Parent=scr,
        })
        mkCorner(g,sz/2) return g
    end
    local g1=mkGlow(UDim2.new(.3,0,.3,0),C.blueGlow,400,.94)
    local g2=mkGlow(UDim2.new(.7,0,.7,0),C.purple,350,.95)
    task.spawn(function()
        while scr and scr.Parent do
            tw(g1,{Position=UDim2.new(.35,0,.35,0)},4,Enum.EasingStyle.Sine)
            tw(g2,{Position=UDim2.new(.65,0,.65,0)},4,Enum.EasingStyle.Sine)
            task.wait(4)
            tw(g1,{Position=UDim2.new(.3,0,.3,0)},4,Enum.EasingStyle.Sine)
            tw(g2,{Position=UDim2.new(.7,0,.7,0)},4,Enum.EasingStyle.Sine)
            task.wait(4)
        end
    end)

    local card = new("Frame",{
        Size=UDim2.new(0,440,0,510),
        Position=UDim2.new(.5,0,.5,70),
        AnchorPoint=Vector2.new(.5,.5),
        BackgroundColor3=C.glass,
        BackgroundTransparency=1,
        BorderSizePixel=0, ClipsDescendants=true,
        ZIndex=2, Parent=scr,
    })
    mkCorner(card,22)
    mkShadow(card,60,.6)
    local cStroke = mkStroke(card,C.blueD,1.5,1)

    new("Frame",{
        Size=UDim2.new(1,-2,1,-2),
        Position=UDim2.new(0,1,0,1),
        BackgroundColor3=C.bg,BackgroundTransparency=.15,
        BorderSizePixel=0,ZIndex=2,Parent=card,
    })
    -- corner on inner glass
    local igc = card:FindFirstChildOfClass("Frame")
    if igc then mkCorner(igc,21) end

    task.delay(.05,function()
        tw(card,{BackgroundTransparency=.08,Position=UDim2.new(.5,0,.5,0)},.85,Enum.EasingStyle.Quint)
        tw(cStroke,{Transparency=.05},.9)
    end)

    local topLine = new("Frame",{
        Size=UDim2.new(0,0,0,3),BackgroundColor3=C.blue,
        BorderSizePixel=0,ZIndex=5,Parent=card,
    })
    mkGrad(topLine,C.blue,C.purple,0) mkCorner(topLine,2)
    task.delay(.35,function() tw(topLine,{Size=UDim2.new(1,0,0,3)},.9,Enum.EasingStyle.Quint) end)

    new("Frame",{
        Size=UDim2.new(1,0,0,100),Position=UDim2.new(0,0,0,3),
        BackgroundColor3=C.blueD,BackgroundTransparency=.9,
        BorderSizePixel=0,ZIndex=3,Parent=card,
    })

    -- logo
    local lh = new("Frame",{
        Size=UDim2.new(0,56,0,56),Position=UDim2.new(.5,0,0,28),
        AnchorPoint=Vector2.new(.5,0),BackgroundColor3=C.bg3,
        BackgroundTransparency=1,BorderSizePixel=0,ZIndex=4,Parent=card,
    })
    mkCorner(lh,28) mkStroke(lh,C.blueD,1.5,.3)
    local lg=new("Frame",{
        Size=UDim2.new(1,16,1,16),Position=UDim2.new(.5,0,.5,0),
        AnchorPoint=Vector2.new(.5,.5),BackgroundColor3=C.blueGlow,
        BackgroundTransparency=.85,BorderSizePixel=0,ZIndex=3,Parent=lh,
    })
    mkCorner(lg,36)
    local logoLbl=new("TextLabel",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text=cfg.Logo or "Z",TextColor3=C.blue2,TextTransparency=1,
        TextSize=28,Font=Enum.Font.GothamBold,ZIndex=5,Parent=lh,
    })
    task.delay(.25,function()
        tw(lh,{BackgroundTransparency=.15},.5)
        tw(logoLbl,{TextTransparency=0},.5)
    end)

    local function fadeIn(obj,d)
        task.delay(d or .3,function() tw(obj,{TextTransparency=0},.4) end)
    end

    local tit=new("TextLabel",{
        Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,92),
        BackgroundTransparency=1,Text=cfg.Title or "Hub",
        TextColor3=C.text,TextTransparency=1,TextSize=26,
        Font=Enum.Font.GothamBold,ZIndex=4,Parent=card,
    })
    fadeIn(tit,.35)

    local sub=new("TextLabel",{
        Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,120),
        BackgroundTransparency=1,
        Text=(cfg.Title or "Hub").."  ·  "..(cfg.Subtitle or "v1.0"),
        TextColor3=C.dim,TextTransparency=1,TextSize=10,
        Font=Enum.Font.GothamMedium,ZIndex=4,Parent=card,
    })
    fadeIn(sub,.42)

    local divL=new("Frame",{
        Size=UDim2.new(0,0,0,1),Position=UDim2.new(.5,0,0,148),
        AnchorPoint=Vector2.new(.5,0),BackgroundColor3=C.stroke,
        BackgroundTransparency=.4,BorderSizePixel=0,ZIndex=4,Parent=card,
    })
    task.delay(.5,function() tw(divL,{Size=UDim2.new(.72,0,0,1)},.6) end)

    local kLbl=new("TextLabel",{
        Size=UDim2.new(.72,0,0,12),Position=UDim2.new(.14,0,0,168),
        BackgroundTransparency=1,Text="ENTER KEY",TextColor3=C.sub,
        TextTransparency=1,TextSize=9,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4,Parent=card,
    })
    fadeIn(kLbl,.52)

    local iCont=new("Frame",{
        Size=UDim2.new(.72,0,0,48),Position=UDim2.new(.14,0,0,184),
        BackgroundColor3=C.bg3,BackgroundTransparency=1,
        BorderSizePixel=0,ZIndex=4,Parent=card,
    })
    mkCorner(iCont,12)
    local iStroke=mkStroke(iCont,C.stroke,1,.4)
    task.delay(.55,function()
        tw(iCont,{BackgroundTransparency=.05},.4)
        tw(iStroke,{Transparency=.1},.4)
    end)
    new("TextLabel",{
        Size=UDim2.new(0,20,1,0),Position=UDim2.new(0,12,0,0),
        BackgroundTransparency=1,Text="🔑",TextSize=14,ZIndex=5,Parent=iCont,
    })
    local iBox=new("TextBox",{
        Size=UDim2.new(1,-44,1,0),Position=UDim2.new(0,36,0,0),
        BackgroundTransparency=1,
        PlaceholderText="paste your key here...",PlaceholderColor3=C.dim2,
        Text="",TextColor3=C.text,TextSize=14,Font=Enum.Font.GothamMedium,
        ClearTextOnFocus=false,ZIndex=5,Parent=iCont,
    })
    iBox.Focused:Connect(function()
        tw(iStroke,{Color=C.blue,Transparency=0},.2)
        tw(iCont,{BackgroundColor3=C.bg4},.2)
    end)
    iBox.FocusLost:Connect(function()
        tw(iStroke,{Color=C.stroke,Transparency=.1},.25)
        tw(iCont,{BackgroundColor3=C.bg3},.25)
    end)

    local statusLbl=new("TextLabel",{
        Size=UDim2.new(.72,0,0,14),Position=UDim2.new(.14,0,0,238),
        BackgroundTransparency=1,Text="",TextColor3=C.red,TextSize=10,
        Font=Enum.Font.GothamMedium,TextXAlignment=Enum.TextXAlignment.Left,
        ZIndex=4,Parent=card,
    })

    local vBtn=new("TextButton",{
        Size=UDim2.new(.72,0,0,48),Position=UDim2.new(.14,0,0,260),
        BackgroundColor3=C.blue,BackgroundTransparency=1,
        BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=4,Parent=card,
    })
    mkCorner(vBtn,12) mkGrad(vBtn,C.blue,C.purple,30) mkShadow(vBtn,20,.7)
    local vTxt=new("TextLabel",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text="⚡  VALIDATE KEY",TextColor3=C.white,TextTransparency=1,
        TextSize=14,Font=Enum.Font.GothamBold,ZIndex=5,Parent=vBtn,
    })
    task.delay(.6,function()
        tw(vBtn,{BackgroundTransparency=0},.4)
        tw(vTxt,{TextTransparency=0},.4)
    end)
    local vN=UDim2.new(.72,0,0,48)
    vBtn.MouseEnter:Connect(function() twBack(vBtn,{Size=UDim2.new(.74,0,0,50)},.2) end)
    vBtn.MouseLeave:Connect(function() tw(vBtn,{Size=vN},.15) end)

    local orLbl=new("TextLabel",{
        Size=UDim2.new(.72,0,0,14),Position=UDim2.new(.14,0,0,320),
        BackgroundTransparency=1,Text="━━━━━━━  or  ━━━━━━━",
        TextColor3=C.dim2,TextTransparency=1,TextSize=9,Font=Enum.Font.Gotham,
        ZIndex=4,Parent=card,
    })
    task.delay(.65,function() tw(orLbl,{TextTransparency=.3},.3) end)

    local dcBtn=new("TextButton",{
        Size=UDim2.new(.72,0,0,44),Position=UDim2.new(.14,0,0,344),
        BackgroundColor3=C.disc,BackgroundTransparency=1,
        BorderSizePixel=0,Text="",AutoButtonColor=false,ZIndex=4,Parent=card,
    })
    mkCorner(dcBtn,12)
    local dcTxt=new("TextLabel",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text="🎮  DISCORD  ·  GET FREE KEY",TextColor3=C.white,
        TextTransparency=1,TextSize=12,Font=Enum.Font.GothamBold,ZIndex=5,Parent=dcBtn,
    })
    task.delay(.7,function()
        tw(dcBtn,{BackgroundTransparency=0},.4)
        tw(dcTxt,{TextTransparency=0},.4)
    end)
    dcBtn.MouseEnter:Connect(function() twBack(dcBtn,{Size=UDim2.new(.74,0,0,46)},.2) end)
    dcBtn.MouseLeave:Connect(function() tw(dcBtn,{Size=UDim2.new(.72,0,0,44)},.15) end)
    dcBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard(cfg.Discord or "") end)
        statusLbl.TextColor3=C.green
        statusLbl.Text="✓ discord link copied!"
    end)

    local fF=new("Frame",{
        Size=UDim2.new(.72,0,0,60),Position=UDim2.new(.14,0,0,400),
        BackgroundColor3=C.bg3,BackgroundTransparency=1,
        BorderSizePixel=0,ZIndex=4,Parent=card,
    })
    mkCorner(fF,10) mkStroke(fF,C.stroke,1,.6)
    local fT1=new("TextLabel",{
        Size=UDim2.new(.5,-4,1,0),Position=UDim2.new(0,8,0,0),
        BackgroundTransparency=1,Text="FREE\n• basic features",
        TextColor3=C.sub,TextTransparency=1,TextSize=8,Font=Enum.Font.GothamMedium,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center,TextWrapped=true,
        ZIndex=5,Parent=fF,
    })
    local fT2=new("TextLabel",{
        Size=UDim2.new(.5,-4,1,0),Position=UDim2.new(.5,0,0,0),
        BackgroundTransparency=1,Text="PREMIUM\n• all features",
        TextColor3=C.gold,TextTransparency=1,TextSize=8,Font=Enum.Font.GothamMedium,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Center,TextWrapped=true,
        ZIndex=5,Parent=fF,
    })
    task.delay(.8,function()
        tw(fF,{BackgroundTransparency=.1},.4)
        tw(fT1,{TextTransparency=0},.4)
        tw(fT2,{TextTransparency=0},.4)
    end)

    new("TextLabel",{
        Size=UDim2.new(1,0,0,10),Position=UDim2.new(0,0,1,-16),
        BackgroundTransparency=1,
        Text=(cfg.Title or "Hub").."  ·  "..(cfg.Subtitle or "v1.0"),
        TextColor3=C.dim2,TextTransparency=.5,TextSize=7,Font=Enum.Font.Gotham,
        ZIndex=4,Parent=card,
    })

    local function closeKey(tier)
        local fl=new("Frame",{
            Size=UDim2.new(1,0,1,0),
            BackgroundColor3=tier=="premium" and C.gold or C.blue,
            BackgroundTransparency=.8,BorderSizePixel=0,ZIndex=10,Parent=card,
        })
        tw(fl,{BackgroundTransparency=1},.6)
        tw(topLine,{Size=UDim2.new(1,0,1,0)},.4)
        task.delay(.3,function()
            tw(card,{BackgroundTransparency=1,Position=UDim2.new(.5,0,.5,-60)},.5,Enum.EasingStyle.Quint)
            tw(cStroke,{Transparency=1},.4)
            tw(overlay,{BackgroundTransparency=1},.6)
            tw(g1,{BackgroundTransparency=1},.4)
            tw(g2,{BackgroundTransparency=1},.4)
        end)
        task.delay(.8,function()
            pcall(function() scr:Destroy() end)
            onDone(tier)
        end)
    end

    vBtn.MouseButton1Click:Connect(function()
        local k = iBox.Text:gsub("%s+","")
        if k=="" then
            statusLbl.TextColor3=C.red statusLbl.Text="⚠ enter a key" return
        end
        tw(vBtn,{Size=UDim2.new(.68,0,0,44)},.06)
        task.delay(.06,function() twBack(vBtn,{Size=vN},.25) end)

        if k==(cfg.Key or "") then
            statusLbl.TextColor3=C.green statusLbl.Text="✓ FREE TIER UNLOCKED"
            for _,ch in ipairs(topLine:GetChildren()) do
                if ch:IsA("UIGradient") then ch:Destroy() end
            end
            mkGrad(topLine,C.green,C.cyan,0)
            task.delay(1,function() closeKey("free") end)

        elseif cfg.PremiumKey and k==cfg.PremiumKey then
            statusLbl.TextColor3=C.gold statusLbl.Text="★ PREMIUM UNLOCKED"
            for _,ch in ipairs(topLine:GetChildren()) do
                if ch:IsA("UIGradient") then ch:Destroy() end
            end
            mkGrad(topLine,C.gold,C.orange,0)
            task.delay(1,function() closeKey("premium") end)

        else
            statusLbl.TextColor3=C.red statusLbl.Text="✗ invalid key"
            local op=iCont.Position
            for _,off in ipairs({-10,10,-6,6,-3,0}) do
                tw(iCont,{Position=UDim2.new(op.X.Scale,op.X.Offset+off,op.Y.Scale,op.Y.Offset)},.03)
                task.wait(.035)
            end
        end
    end)
end

--------------------------------------------------------------
-- ELEMENT BUILDER
-- All elements share this. _container = parent Frame.
-- Every element must parent rows into _container correctly.
--------------------------------------------------------------
local EB = {}
EB.__index = EB

-- Internal: create a fixed-height row inside _container
local function row(self, h)
    return new("Frame",{
        Size=UDim2.new(1,0,0,h or 34),
        BackgroundTransparency=1,
        BorderSizePixel=0,
        Parent=self._container,
    })
end

---------- Toggle ----------
function EB:Toggle(label, default, cb)
    local state = default == true
    local r = row(self, 34)

    new("TextLabel",{
        Size=UDim2.new(1,-56,1,0),
        Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1,
        Text=label, TextColor3=C.text,
        TextSize=12, Font=Enum.Font.GothamMedium,
        TextXAlignment=Enum.TextXAlignment.Left,
        Parent=r,
    })

    local track=new("Frame",{
        Size=UDim2.new(0,38,0,20),
        Position=UDim2.new(1,-48,.5,0),
        AnchorPoint=Vector2.new(0,.5),
        BackgroundColor3=C.bg4,BorderSizePixel=0,
        Parent=r,
    })
    mkCorner(track,10) mkStroke(track,C.stroke2,1,.3)

    local knob=new("Frame",{
        Size=UDim2.new(0,14,0,14),
        Position=UDim2.new(0,3,.5,0),
        AnchorPoint=Vector2.new(0,.5),
        BackgroundColor3=C.sub,BorderSizePixel=0,
        Parent=track,
    })
    mkCorner(knob,7)

    local function refresh(val, anim)
        if val then
            if anim then
                tw(track,{BackgroundColor3=C.blueD},.2)
                twBack(knob,{Position=UDim2.new(0,21,.5,0),BackgroundColor3=C.white},.25)
            else
                track.BackgroundColor3=C.blueD
                knob.Position=UDim2.new(0,21,.5,0)
                knob.BackgroundColor3=C.white
            end
        else
            if anim then
                tw(track,{BackgroundColor3=C.bg4},.2)
                twBack(knob,{Position=UDim2.new(0,3,.5,0),BackgroundColor3=C.sub},.25)
            else
                track.BackgroundColor3=C.bg4
                knob.Position=UDim2.new(0,3,.5,0)
                knob.BackgroundColor3=C.sub
            end
        end
    end
    refresh(state,false)

    local hit=new("TextButton",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",Parent=r,
    })
    hit.MouseButton1Click:Connect(function()
        state=not state refresh(state,true) pcall(cb,state)
    end)
    hit.MouseEnter:Connect(function()
        r.BackgroundTransparency=0 tw(r,{BackgroundColor3=C.bg3,BackgroundTransparency=.6},.12)
    end)
    hit.MouseLeave:Connect(function() tw(r,{BackgroundTransparency=1},.12) end)

    return {
        Set=function(_,v) state=v refresh(state,true) end,
        Get=function() return state end,
    }
end

---------- Button ----------
function EB:Button(label, cb)
    local r = row(self, 38)

    local btn=new("TextButton",{
        Size=UDim2.new(1,-16,0,28),
        Position=UDim2.new(0,8,.5,0),
        AnchorPoint=Vector2.new(0,.5),
        BackgroundColor3=C.bg4,BorderSizePixel=0,
        Text=label,TextColor3=C.text,TextSize=12,
        Font=Enum.Font.GothamMedium,
        AutoButtonColor=false,Parent=r,
    })
    mkCorner(btn,8) mkStroke(btn,C.stroke2,1,.4)

    local nSz=UDim2.new(1,-16,0,28)
    btn.MouseEnter:Connect(function()
        twBack(btn,{Size=UDim2.new(1,-12,0,30),BackgroundColor3=C.bg5},.18)
    end)
    btn.MouseLeave:Connect(function() tw(btn,{Size=nSz,BackgroundColor3=C.bg4},.15) end)
    btn.MouseButton1Down:Connect(function() tw(btn,{Size=UDim2.new(1,-20,0,26)},.07) end)
    btn.MouseButton1Up:Connect(function()
        twBack(btn,{Size=nSz},.2) pcall(cb)
    end)
end

---------- Slider ----------
function EB:Slider(label, default, min_, max_, cb)
    min_=min_ or 0 max_=max_ or 100
    local value=math.clamp(default or min_,min_,max_)
    local r=row(self,54)

    -- label row
    local topF=new("Frame",{
        Size=UDim2.new(1,0,0,22),BackgroundTransparency=1,Parent=r,
    })
    new("TextLabel",{
        Size=UDim2.new(.7,0,1,0),Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1,Text=label,TextColor3=C.text,
        TextSize=12,Font=Enum.Font.GothamMedium,
        TextXAlignment=Enum.TextXAlignment.Left,Parent=topF,
    })
    local valLbl=new("TextLabel",{
        Size=UDim2.new(.3,-10,1,0),Position=UDim2.new(.7,0,0,0),
        BackgroundTransparency=1,Text=tostring(value),
        TextColor3=C.blue2,TextSize=11,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Right,Parent=topF,
    })

    -- track
    local track=new("Frame",{
        Size=UDim2.new(1,-20,0,5),
        Position=UDim2.new(0,10,0,30),
        BackgroundColor3=C.bg4,BorderSizePixel=0,Parent=r,
    })
    mkCorner(track,3)
    local fill=new("Frame",{
        Size=UDim2.new(0,0,1,0),BackgroundColor3=C.blue,
        BorderSizePixel=0,Parent=track,
    })
    mkCorner(fill,3) mkGrad(fill,C.blue,C.purple,0)
    local knob=new("Frame",{
        Size=UDim2.new(0,13,0,13),AnchorPoint=Vector2.new(.5,.5),
        Position=UDim2.new(0,0,.5,0),BackgroundColor3=C.white,
        BorderSizePixel=0,ZIndex=2,Parent=track,
    })
    mkCorner(knob,7)

    local function setVal(v)
        value=math.clamp(math.round(v),min_,max_)
        local ratio=(value-min_)/(max_-min_)
        tw(fill,{Size=UDim2.new(ratio,0,1,0)},.08)
        tw(knob,{Position=UDim2.new(ratio,0,.5,0)},.08)
        valLbl.Text=tostring(value)
        pcall(cb,value)
    end
    setVal(value)

    -- invisible hitbox over track area
    local dragging=false
    local hit=new("TextButton",{
        Size=UDim2.new(1,-20,0,20),Position=UDim2.new(0,10,0,22),
        BackgroundTransparency=1,Text="",Parent=r,
    })
    hit.MouseButton1Down:Connect(function()
        dragging=true tw(knob,{Size=UDim2.new(0,16,0,16)},.1)
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            if dragging then
                dragging=false tw(knob,{Size=UDim2.new(0,13,0,13)},.1)
            end
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then
            local ap=track.AbsolutePosition
            local as=track.AbsoluteSize
            local rx=math.clamp((i.Position.X-ap.X)/as.X,0,1)
            setVal(min_+rx*(max_-min_))
        end
    end)

    return {
        Set=function(_,v) setVal(v) end,
        Get=function() return value end,
    }
end

---------- Dropdown ----------
function EB:Dropdown(label, opts, cb)
    local sel=opts[1] or ""
    local open=false
    local r=row(self,34)

    -- label
    new("TextLabel",{
        Size=UDim2.new(.44,0,1,0),Position=UDim2.new(0,10,0,0),
        BackgroundTransparency=1,Text=label,TextColor3=C.text,
        TextSize=12,Font=Enum.Font.GothamMedium,
        TextXAlignment=Enum.TextXAlignment.Left,Parent=r,
    })

    local trig=new("TextButton",{
        Size=UDim2.new(.53,0,0,26),Position=UDim2.new(.46,0,.5,0),
        AnchorPoint=Vector2.new(0,.5),
        BackgroundColor3=C.bg4,BorderSizePixel=0,
        Text="",AutoButtonColor=false,Parent=r,
    })
    mkCorner(trig,8) mkStroke(trig,C.stroke2,1,.4)

    local selLbl=new("TextLabel",{
        Size=UDim2.new(1,-24,1,0),Position=UDim2.new(0,8,0,0),
        BackgroundTransparency=1,Text=sel,TextColor3=C.blue2,
        TextSize=11,Font=Enum.Font.GothamMedium,
        TextXAlignment=Enum.TextXAlignment.Left,Parent=trig,
    })
    local arrow=new("TextLabel",{
        Size=UDim2.new(0,16,1,0),Position=UDim2.new(1,-18,0,0),
        BackgroundTransparency=1,Text="▾",TextColor3=C.sub,
        TextSize=10,Font=Enum.Font.GothamBold,Parent=trig,
    })

    -- The dropdown list is parented to the screenGui's top level
    -- to avoid ClipsDescendants cutting it off
    local iH=24
    local totalH=#opts*(iH+2)+8

    local dropFrame=new("Frame",{
        Size=UDim2.new(0,0,0,0),
        BackgroundColor3=C.bg2,BackgroundTransparency=.04,
        BorderSizePixel=0,ClipsDescendants=true,
        ZIndex=50,Visible=false,
    })
    mkCorner(dropFrame,8) mkStroke(dropFrame,C.stroke2,1,.2) mkShadow(dropFrame,14,.7)

    local dropInner=new("Frame",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ZIndex=51,Parent=dropFrame,
    })
    mkPad(dropInner,4,4,4,4)
    mkList(dropInner,Enum.FillDirection.Vertical,2)

    for _,opt in ipairs(opts) do
        local ob=new("TextButton",{
            Size=UDim2.new(1,0,0,iH),
            BackgroundColor3=C.bg4,BackgroundTransparency=.4,
            BorderSizePixel=0,Text="  "..opt,
            TextColor3=C.text,TextSize=11,Font=Enum.Font.GothamMedium,
            TextXAlignment=Enum.TextXAlignment.Left,
            AutoButtonColor=false,ZIndex=52,Parent=dropInner,
        })
        mkCorner(ob,6)
        ob.MouseEnter:Connect(function() tw(ob,{BackgroundTransparency=0,BackgroundColor3=C.bg5},.1) end)
        ob.MouseLeave:Connect(function() tw(ob,{BackgroundTransparency=.4,BackgroundColor3=C.bg4},.1) end)
        ob.MouseButton1Click:Connect(function()
            sel=opt selLbl.Text=opt open=false
            tw(dropFrame,{Size=UDim2.new(0,dropFrame.Size.X.Offset,0,0)},.18)
            tw(arrow,{Rotation=0},.18)
            task.delay(.2,function() dropFrame.Visible=false end)
            pcall(cb,opt)
        end)
    end

    -- position the dropdown below trigger on open
    local function positionDrop()
        local ap=trig.AbsolutePosition
        local as=trig.AbsoluteSize
        local w=as.X
        -- find the screenGui
        local sg2=r
        while sg2 and not sg2:IsA("ScreenGui") do sg2=sg2.Parent end
        if sg2 then
            dropFrame.Parent=sg2
        end
        dropFrame.Position=UDim2.new(0,ap.X,0,ap.Y+as.Y+4)
        dropFrame.Size=UDim2.new(0,w,0,0)
    end

    trig.MouseButton1Click:Connect(function()
        open=not open
        if open then
            positionDrop()
            dropFrame.Visible=true
            twBack(dropFrame,{Size=UDim2.new(0,trig.AbsoluteSize.X,0,totalH)},.28)
            tw(arrow,{Rotation=180},.2)
        else
            tw(dropFrame,{Size=UDim2.new(0,dropFrame.Size.X.Offset,0,0)},.18)
            tw(arrow,{Rotation=0},.18)
            task.delay(.2,function() dropFrame.Visible=false end)
        end
    end)

    return {
        Set=function(_,v) sel=v selLbl.Text=v end,
        Get=function() return sel end,
    }
end

---------- Input ----------
function EB:Input(label, placeholder, cb)
    local r=row(self,54)

    new("TextLabel",{
        Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,10,0,2),
        BackgroundTransparency=1,Text=label,TextColor3=C.sub,
        TextSize=9,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,Parent=r,
    })

    local box=new("Frame",{
        Size=UDim2.new(1,-16,0,30),Position=UDim2.new(0,8,0,18),
        BackgroundColor3=C.bg3,BackgroundTransparency=.1,
        BorderSizePixel=0,Parent=r,
    })
    mkCorner(box,8)
    local bStroke=mkStroke(box,C.stroke,1,.35)

    local inp=new("TextBox",{
        Size=UDim2.new(1,-18,1,0),Position=UDim2.new(0,9,0,0),
        BackgroundTransparency=1,
        PlaceholderText=placeholder or "",PlaceholderColor3=C.dim2,
        Text="",TextColor3=C.text,TextSize=12,Font=Enum.Font.GothamMedium,
        ClearTextOnFocus=false,Parent=box,
    })
    inp.Focused:Connect(function()
        tw(bStroke,{Color=C.blue,Transparency=0},.2)
        tw(box,{BackgroundColor3=C.bg4},.2)
    end)
    inp.FocusLost:Connect(function()
        tw(bStroke,{Color=C.stroke,Transparency=.35},.25)
        tw(box,{BackgroundColor3=C.bg3},.25)
        pcall(cb,inp.Text)
    end)

    return {
        Set=function(_,v) inp.Text=v end,
        Get=function() return inp.Text end,
    }
end

---------- Paragraph ----------
function EB:Paragraph(title, body)
    -- dynamic height row
    local r=new("Frame",{
        Size=UDim2.new(1,0,0,60),
        BackgroundTransparency=1,BorderSizePixel=0,
        Parent=self._container,
    })

    local inner=new("Frame",{
        Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),
        BackgroundColor3=C.bg3,BackgroundTransparency=.1,
        BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.Y,
        Parent=r,
    })
    mkCorner(inner,8) mkStroke(inner,C.stroke,1,.5) mkPad(inner,8,8,10,10)
    mkList(inner,Enum.FillDirection.Vertical,4)

    local tLbl=new("TextLabel",{
        Size=UDim2.new(1,0,0,14),
        BackgroundTransparency=1,Text=title,TextColor3=C.blue2,
        TextSize=11,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,Parent=inner,
    })
    local bLbl=new("TextLabel",{
        Size=UDim2.new(1,0,0,14),
        BackgroundTransparency=1,Text=body,TextColor3=C.sub,
        TextSize=10,Font=Enum.Font.GothamMedium,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextWrapped=true,AutomaticSize=Enum.AutomaticSize.Y,
        Parent=inner,
    })

    -- sync row height to inner
    local layout=inner:FindFirstChildOfClass("UIListLayout")
    local function resize()
        local h=(layout and layout.AbsoluteContentSize.Y or 40)+18
        r.Size=UDim2.new(1,0,0,h)
    end
    if layout then
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)
    end
    task.defer(resize)

    return {
        SetTitle=function(_,t) tLbl.Text=t task.defer(resize) end,
        SetBody=function(_,b) bLbl.Text=b task.defer(resize) end,
    }
end

---------- Stats ----------
function EB:Stats(data)
    local keys={}
    for k in pairs(data) do table.insert(keys,k) end
    local n=math.max(#keys,1)
    local r=row(self,48)

    local grid=new("Frame",{
        Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),
        BackgroundTransparency=1,Parent=r,
    })

    local refs={}
    for i,k in ipairs(keys) do
        local cell=new("Frame",{
            Size=UDim2.new(1/n,-4,1,0),
            Position=UDim2.new((i-1)/n,2,0,0),
            BackgroundColor3=C.bg4,BackgroundTransparency=.1,
            BorderSizePixel=0,Parent=grid,
        })
        mkCorner(cell,8) mkStroke(cell,C.stroke2,1,.5)
        new("TextLabel",{
            Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,0,6),
            BackgroundTransparency=1,Text=k,TextColor3=C.sub,
            TextSize=8,Font=Enum.Font.GothamBold,Parent=cell,
        })
        local vL=new("TextLabel",{
            Size=UDim2.new(1,0,0,18),Position=UDim2.new(0,0,0,20),
            BackgroundTransparency=1,Text=tostring(data[k]),
            TextColor3=C.blue2,TextSize=13,Font=Enum.Font.GothamBold,
            Parent=cell,
        })
        refs[k]=vL
    end

    return {
        Update=function(_,nd)
            for k,v in pairs(nd) do
                if refs[k] then refs[k].Text=tostring(v) end
            end
        end,
    }
end

---------- Code ----------
function EB:Code(src)
    local lines=0
    for _ in (src.."\n"):gmatch(".-\n") do lines=lines+1 end
    local h=math.max(lines*14+18,32)
    local r=row(self,h)

    local box=new("Frame",{
        Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),
        BackgroundColor3=Color3.fromRGB(10,10,18),BackgroundTransparency=.02,
        BorderSizePixel=0,Parent=r,
    })
    mkCorner(box,8) mkStroke(box,C.blueD,1,.35)
    new("Frame",{
        Size=UDim2.new(0,3,.7,0),Position=UDim2.new(0,5,.15,0),
        BackgroundColor3=C.blueD,BorderSizePixel=0,Parent=box,
    })
    local cL=new("TextLabel",{
        Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,14,0,0),
        BackgroundTransparency=1,Text=src,TextColor3=C.cyan,
        TextSize=10,Font=Enum.Font.Code,
        TextXAlignment=Enum.TextXAlignment.Left,
        TextYAlignment=Enum.TextYAlignment.Top,
        TextWrapped=true,Parent=box,
    })
    mkPad(cL,7,7,0,0)
end

---------- Divider ----------
function EB:Divider()
    local r=row(self,14)
    local ln=new("Frame",{
        Size=UDim2.new(1,-20,0,1),
        Position=UDim2.new(0,10,.5,0),
        AnchorPoint=Vector2.new(0,.5),
        BackgroundColor3=C.stroke,BackgroundTransparency=.4,
        BorderSizePixel=0,Parent=r,
    })
    mkGrad(ln,C.stroke2,C.bg,0)
end

---------- Group ----------
function EB:Group(label)
    -- outer wrapper
    local wrap=new("Frame",{
        Size=UDim2.new(1,0,0,36),
        BackgroundColor3=C.bg3,BackgroundTransparency=.12,
        BorderSizePixel=0,Parent=self._container,
    })
    mkCorner(wrap,10) mkStroke(wrap,C.stroke2,1,.45)
    mkPad(wrap,14,8,0,0)

    -- floating label
    local lF=new("Frame",{
        Size=UDim2.new(0,0,0,14),Position=UDim2.new(0,10,0,-7),
        BackgroundColor3=C.bg3,BackgroundTransparency=0,
        BorderSizePixel=0,AutomaticSize=Enum.AutomaticSize.X,
        ZIndex=2,Parent=wrap,
    })
    mkPad(lF,0,0,4,4)
    new("TextLabel",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text=label,TextColor3=C.blue2,TextSize=9,Font=Enum.Font.GothamBold,
        ZIndex=3,Parent=lF,
    })

    local inner=new("Frame",{
        Size=UDim2.new(1,0,1,-14),Position=UDim2.new(0,0,0,0),
        BackgroundTransparency=1,Parent=wrap,
    })
    mkList(inner,Enum.FillDirection.Vertical,3)

    local layout=inner:FindFirstChildOfClass("UIListLayout")
    local function resize()
        local h=(layout and layout.AbsoluteContentSize.Y or 0)+24
        inner.Size=UDim2.new(1,0,0,h)
        wrap.Size=UDim2.new(1,0,0,h+14)
    end
    if layout then
        layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)
    end
    task.defer(resize)

    local g=setmetatable({_container=inner},EB)
    return g
end

---------- Section ----------
function EB:Section(label)
    local wrap=new("Frame",{
        Size=UDim2.new(1,0,0,32),
        BackgroundTransparency=1,BorderSizePixel=0,
        Parent=self._container,
    })

    local header=new("TextButton",{
        Size=UDim2.new(1,0,0,28),
        BackgroundColor3=C.bg4,BackgroundTransparency=.1,
        BorderSizePixel=0,Text="",AutoButtonColor=false,
        Parent=wrap,
    })
    mkCorner(header,8) mkStroke(header,C.stroke2,1,.45)

    new("Frame",{
        Size=UDim2.new(0,3,.6,0),Position=UDim2.new(0,8,.2,0),
        BackgroundColor3=C.blue,BorderSizePixel=0,Parent=header,
    })
    new("TextLabel",{
        Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,18,0,0),
        BackgroundTransparency=1,Text=label,TextColor3=C.text,
        TextSize=11,Font=Enum.Font.GothamBold,
        TextXAlignment=Enum.TextXAlignment.Left,Parent=header,
    })
    local arr=new("TextLabel",{
        Size=UDim2.new(0,20,1,0),Position=UDim2.new(1,-26,0,0),
        BackgroundTransparency=1,Text="▾",TextColor3=C.sub,
        TextSize=10,Font=Enum.Font.GothamBold,Parent=header,
    })

    local cont=new("Frame",{
        Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,0,30),
        BackgroundTransparency=1,ClipsDescendants=false,
        Parent=wrap,
    })
    mkPad(cont,2,4,0,0)
    mkList(cont,Enum.FillDirection.Vertical,3)
    local cLayout=cont:FindFirstChildOfClass("UIListLayout")

    local collapsed=false
    local function resize()
        if collapsed then
            wrap.Size=UDim2.new(1,0,0,28)
            cont.Visible=false
        else
            cont.Visible=true
            local h=(cLayout and cLayout.AbsoluteContentSize.Y or 0)+8
            cont.Size=UDim2.new(1,0,0,h)
            wrap.Size=UDim2.new(1,0,0,30+h+2)
        end
    end
    if cLayout then
        cLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)
    end
    header.MouseButton1Click:Connect(function()
        collapsed=not collapsed
        tw(arr,{Rotation=collapsed and -90 or 0},.2)
        resize()
    end)
    task.defer(resize)

    local s=setmetatable({_container=cont},EB)
    return s
end

--------------------------------------------------------------
-- WINDOW
--------------------------------------------------------------
function ZethUI:CreateWindow(cfg)
    cfg=cfg or {}

    pcall(function()
        local o=CG:FindFirstChild("ZethUI_Main")
        if o then o:Destroy() end
    end)

    local screen=new("ScreenGui",{
        Name="ZethUI_Main",ResetOnSpawn=false,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset=true,Parent=CG,
    })
    ensureToasts(screen)

    local win={_screen=screen, _tabs={}, _activeTab=nil}

    local function buildUI(isPrem)
        -- ── main frame ──
        local mf=new("Frame",{
            Size=UDim2.new(0,700,0,490),
            Position=UDim2.new(.5,0,.5,30),
            AnchorPoint=Vector2.new(.5,.5),
            BackgroundColor3=C.bg,BackgroundTransparency=1,
            BorderSizePixel=0,ClipsDescendants=false,
            Parent=screen,
        })
        mkCorner(mf,16) mkStroke(mf,C.stroke2,1,.2) mkShadow(mf,40,.55)

        -- inner clip frame (so content doesnt overflow rounded corners)
        local clip=new("Frame",{
            Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
            ClipsDescendants=true,Parent=mf,
        })
        mkCorner(clip,16)

        tw(mf,{BackgroundTransparency=.04,Position=UDim2.new(.5,0,.5,0)},.6,Enum.EasingStyle.Quint)

        -- top accent line
        local tLine=new("Frame",{
            Size=UDim2.new(0,0,0,3),BackgroundColor3=C.blue,
            BorderSizePixel=0,ZIndex=5,Parent=clip,
        })
        mkGrad(tLine,C.blue,C.purple,0) mkCorner(tLine,2)
        task.delay(.1,function() tw(tLine,{Size=UDim2.new(1,0,0,3)},.7,Enum.EasingStyle.Quint) end)

        -- upper glow
        new("Frame",{
            Size=UDim2.new(1,0,0,80),Position=UDim2.new(0,0,0,3),
            BackgroundColor3=C.blueD,BackgroundTransparency=.92,
            BorderSizePixel=0,ZIndex=0,Parent=clip,
        })

        -- ── title bar ──
        local tb=new("Frame",{
            Size=UDim2.new(1,0,0,44),Position=UDim2.new(0,0,0,3),
            BackgroundTransparency=1,ZIndex=3,Parent=clip,
        })

        new("TextLabel",{
            Size=UDim2.new(0,200,0,24),Position=UDim2.new(0,16,0,8),
            BackgroundTransparency=1,
            Text=cfg.Title or "Hub",TextColor3=C.text,
            TextSize=16,Font=Enum.Font.GothamBold,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3,Parent=tb,
        })
        new("TextLabel",{
            Size=UDim2.new(0,200,0,12),Position=UDim2.new(0,16,0,28),
            BackgroundTransparency=1,
            Text=cfg.Subtitle or "v1.0",TextColor3=C.dim,
            TextSize=9,Font=Enum.Font.GothamMedium,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=3,Parent=tb,
        })

        -- tier badge
        local badge=new("Frame",{
            Size=UDim2.new(0,50,0,16),Position=UDim2.new(0,134,.5,0),
            AnchorPoint=Vector2.new(0,.5),
            BackgroundColor3=isPrem and C.goldD or C.blueD,
            BackgroundTransparency=.2,BorderSizePixel=0,
            ClipsDescendants=true,ZIndex=3,Parent=tb,
        })
        mkCorner(badge,8)
        local bT=new("TextLabel",{
            Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
            Text=isPrem and "★ PREMIUM" or " FREE",
            TextColor3=isPrem and C.gold or C.blue2,
            TextSize=8,Font=Enum.Font.GothamBold,ZIndex=4,Parent=badge,
        })
        task.defer(function()
            badge.Size=UDim2.new(0,bT.TextBounds.X+14,0,16)
        end)

        -- close
        local cl=new("TextButton",{
            Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-38,.5,0),
            AnchorPoint=Vector2.new(0,.5),
            BackgroundColor3=C.bg4,BackgroundTransparency=.2,
            BorderSizePixel=0,Text="✕",TextColor3=C.sub,
            TextSize=11,Font=Enum.Font.GothamBold,AutoButtonColor=false,
            ZIndex=4,Parent=tb,
        })
        mkCorner(cl,8)
        cl.MouseEnter:Connect(function() tw(cl,{BackgroundColor3=C.red,TextColor3=C.white},.15) end)
        cl.MouseLeave:Connect(function() tw(cl,{BackgroundColor3=C.bg4,TextColor3=C.sub},.15) end)
        cl.MouseButton1Click:Connect(function()
            tw(mf,{BackgroundTransparency=1,Position=UDim2.new(.5,0,.5,30)},.4,Enum.EasingStyle.Quint)
            task.delay(.45,function() pcall(function() screen:Destroy() end) end)
        end)

        -- minimize
        local mn=new("TextButton",{
            Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-70,.5,0),
            AnchorPoint=Vector2.new(0,.5),
            BackgroundColor3=C.bg4,BackgroundTransparency=.2,
            BorderSizePixel=0,Text="—",TextColor3=C.sub,
            TextSize=11,Font=Enum.Font.GothamBold,AutoButtonColor=false,
            ZIndex=4,Parent=tb,
        })
        mkCorner(mn,8)
        local minned=false
        mn.MouseEnter:Connect(function() tw(mn,{BackgroundColor3=C.bg5,TextColor3=C.text},.15) end)
        mn.MouseLeave:Connect(function() tw(mn,{BackgroundColor3=C.bg4,TextColor3=C.sub},.15) end)
        mn.MouseButton1Click:Connect(function()
            minned=not minned
            if minned then
                tw(mf,{Size=UDim2.new(0,700,0,47)},.3,Enum.EasingStyle.Quint)
            else
                twBack(mf,{Size=UDim2.new(0,700,0,490)},.4)
            end
        end)

        -- title div
        new("Frame",{
            Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0,47),
            BackgroundColor3=C.stroke,BackgroundTransparency=.3,
            BorderSizePixel=0,Parent=clip,
        })

        -- drag
        local dragOn,dragStart,startPos=false,nil,nil
        tb.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                dragOn=true dragStart=i.Position startPos=mf.Position
            end
        end)
        UIS.InputChanged:Connect(function(i)
            if dragOn and i.UserInputType==Enum.UserInputType.MouseMovement then
                local d=i.Position-dragStart
                mf.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,
                                      startPos.Y.Scale,startPos.Y.Offset+d.Y)
            end
        end)
        UIS.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then dragOn=false end
        end)

        -- ── sidebar ──
        local sidebar=new("Frame",{
            Size=UDim2.new(0,155,1,-48),Position=UDim2.new(0,0,0,48),
            BackgroundColor3=C.bg2,BackgroundTransparency=.3,
            BorderSizePixel=0,ZIndex=2,Parent=clip,
        })
        new("Frame",{
            Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),
            BackgroundColor3=C.stroke,BackgroundTransparency=.3,
            BorderSizePixel=0,Parent=sidebar,
        })
        local sideInner=new("Frame",{
            Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=sidebar,
        })
        mkPad(sideInner,8,8,8,8)
        mkList(sideInner,Enum.FillDirection.Vertical,3)

        -- ── content area ──
        local ca=new("Frame",{
            Size=UDim2.new(1,-155,1,-48),Position=UDim2.new(0,155,0,48),
            BackgroundTransparency=1,ClipsDescendants=true,Parent=clip,
        })

        -- tab nav
        local tabNav=new("Frame",{
            Size=UDim2.new(1,0,0,34),
            BackgroundColor3=C.bg3,BackgroundTransparency=.3,
            BorderSizePixel=0,Parent=ca,
        })
        local tabNavInner=new("Frame",{
            Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Parent=tabNav,
        })
        mkPad(tabNavInner,0,0,8,8)
        mkList(tabNavInner,Enum.FillDirection.Horizontal,4)
        new("Frame",{
            Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
            BackgroundColor3=C.stroke,BackgroundTransparency=.35,
            BorderSizePixel=0,Parent=tabNav,
        })

        -- scroll host
        local scrollHost=new("Frame",{
            Size=UDim2.new(1,0,1,-34),Position=UDim2.new(0,0,0,34),
            BackgroundTransparency=1,ClipsDescendants=true,Parent=ca,
        })

        -- ── WINDOW API ──

        function win:Notify(text, col, dur)
            toast(text,col,dur)
        end

        function win:Watermark(tmpl)
            local wm=new("Frame",{
                Size=UDim2.new(0,30,0,24),Position=UDim2.new(0,16,0,16),
                BackgroundColor3=C.bg,BackgroundTransparency=.04,
                BorderSizePixel=0,Parent=screen,
            })
            mkCorner(wm,12) mkStroke(wm,C.stroke2,1,.3) mkShadow(wm,14,.7)
            local wLbl=new("TextLabel",{
                Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),
                BackgroundTransparency=1,Text=tmpl,TextColor3=C.sub,
                TextSize=10,Font=Enum.Font.GothamMedium,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=wm,
            })
            task.spawn(function()
                while wm and wm.Parent do
                    task.wait(.5)
                    local fps=math.floor(1/(RS.RenderStepped:Wait()))
                    local ping=math.floor(pcall(function() return LP:GetNetworkPing()*1000 end) and LP:GetNetworkPing()*1000 or 0)
                    wLbl.Text=tmpl:gsub("{fps}",fps):gsub("{ping}",ping)
                    wm.Size=UDim2.new(0,wLbl.TextBounds.X+20,0,24)
                end
            end)
        end

        function win:SideBarLabel(text)
            local lbl=new("TextLabel",{
                Size=UDim2.new(1,0,0,18),BackgroundTransparency=1,
                Text=string.upper(text),TextColor3=C.dim,
                TextSize=8,Font=Enum.Font.GothamBold,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=sideInner,
            })
            mkPad(lbl,0,0,2,0)
        end

        function win:SideBarButton(icon, label, onClick)
            local btn=new("TextButton",{
                Size=UDim2.new(1,0,0,32),
                BackgroundColor3=C.bg3,BackgroundTransparency=.7,
                BorderSizePixel=0,Text="",AutoButtonColor=false,
                Parent=sideInner,
            })
            mkCorner(btn,8)
            new("TextLabel",{
                Size=UDim2.new(0,20,1,0),Position=UDim2.new(0,8,0,0),
                BackgroundTransparency=1,Text=icon,TextSize=13,Parent=btn,
            })
            local tLbl=new("TextLabel",{
                Size=UDim2.new(1,-34,1,0),Position=UDim2.new(0,30,0,0),
                BackgroundTransparency=1,Text=label,TextColor3=C.sub,
                TextSize=11,Font=Enum.Font.GothamMedium,
                TextXAlignment=Enum.TextXAlignment.Left,Parent=btn,
            })
            btn.MouseEnter:Connect(function()
                tw(btn,{BackgroundTransparency=.1,BackgroundColor3=C.bg4},.15)
                tw(tLbl,{TextColor3=C.text},.15)
            end)
            btn.MouseLeave:Connect(function()
                tw(btn,{BackgroundTransparency=.7,BackgroundColor3=C.bg3},.15)
                tw(tLbl,{TextColor3=C.sub},.15)
            end)
            btn.MouseButton1Click:Connect(function() pcall(onClick) end)
        end

        function win:SideBarDivider()
            new("Frame",{
                Size=UDim2.new(1,-8,0,1),
                BackgroundColor3=C.stroke,BackgroundTransparency=.4,
                BorderSizePixel=0,Parent=sideInner,
            })
        end

        -- window-level Toggle (goes in sidebar)
        function win:Toggle(label, default, cb)
            local eb=setmetatable({_container=sideInner},EB)
            return eb:Toggle(label,default,cb)
        end

        -- Tab
        function win:Tab(label)
            local scroll=new("ScrollingFrame",{
                Size=UDim2.new(1,0,1,0),
                BackgroundTransparency=1,BorderSizePixel=0,
                ScrollBarThickness=3,
                ScrollBarImageColor3=C.stroke2,
                CanvasSize=UDim2.new(0,0,0,0),
                Visible=false,Parent=scrollHost,
            })

            -- inner frame that holds all elements
            local inner=new("Frame",{
                Size=UDim2.new(1,0,0,0),
                BackgroundTransparency=1,Parent=scroll,
            })
            mkPad(inner,6,6,6,6)
            mkList(inner,Enum.FillDirection.Vertical,5)

            -- auto-resize scroll canvas
            local layout=inner:FindFirstChildOfClass("UIListLayout")
            local function updateCanvas()
                scroll.CanvasSize=UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+14)
            end
            layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

            -- nav button
            local navBtn=new("TextButton",{
                Size=UDim2.new(0,60,1,-8),Position=UDim2.new(0,0,0,4),
                BackgroundTransparency=1,BackgroundColor3=C.bg3,
                BorderSizePixel=0,
                Text=label,TextColor3=C.dim,TextSize=11,
                Font=Enum.Font.GothamMedium,AutoButtonColor=false,
                Parent=tabNavInner,
            })
            mkCorner(navBtn,8) mkPad(navBtn,0,0,10,10)
            task.defer(function()
                navBtn.Size=UDim2.new(0,navBtn.TextBounds.X+24,1,-8)
            end)

            local indicator=new("Frame",{
                Size=UDim2.new(0,0,0,2),
                Position=UDim2.new(.5,0,1,-1),
                AnchorPoint=Vector2.new(.5,0),
                BackgroundColor3=C.blue,BorderSizePixel=0,
                Parent=navBtn,
            })
            mkCorner(indicator,1)

            local tabData={scroll=scroll,inner=inner,navBtn=navBtn,indicator=indicator}
            table.insert(win._tabs,tabData)

            local function activate()
                for _,td in ipairs(win._tabs) do
                    td.scroll.Visible=false
                    tw(td.navBtn,{TextColor3=C.dim,BackgroundTransparency=1},.15)
                    tw(td.indicator,{Size=UDim2.new(0,0,0,2)},.15)
                end
                scroll.Visible=true
                win._activeTab=tabData
                tw(navBtn,{TextColor3=C.text,BackgroundTransparency=.6},.15)
                twBack(indicator,{Size=UDim2.new(1,-12,0,2)},.3)
            end

            navBtn.MouseButton1Click:Connect(activate)
            navBtn.MouseEnter:Connect(function()
                if win._activeTab~=tabData then
                    tw(navBtn,{TextColor3=C.sub,BackgroundTransparency=.85},.12)
                end
            end)
            navBtn.MouseLeave:Connect(function()
                if win._activeTab~=tabData then
                    tw(navBtn,{TextColor3=C.dim,BackgroundTransparency=1},.12)
                end
            end)

            if #win._tabs==1 then task.defer(activate) end

            -- The Tab object — inherits all EB methods, _container = inner
            local tabObj=setmetatable({_container=inner},EB)

            -- Override Section so it uses our inner as parent
            function tabObj:Section(lbl)
                local s=setmetatable({_container=nil},EB)
                -- build section wrapper in inner
                local wrap=new("Frame",{
                    Size=UDim2.new(1,0,0,32),
                    BackgroundTransparency=1,BorderSizePixel=0,
                    Parent=inner,
                })
                local header=new("TextButton",{
                    Size=UDim2.new(1,0,0,28),
                    BackgroundColor3=C.bg4,BackgroundTransparency=.1,
                    BorderSizePixel=0,Text="",AutoButtonColor=false,
                    Parent=wrap,
                })
                mkCorner(header,8) mkStroke(header,C.stroke2,1,.45)
                new("Frame",{
                    Size=UDim2.new(0,3,.6,0),Position=UDim2.new(0,8,.2,0),
                    BackgroundColor3=C.blue,BorderSizePixel=0,Parent=header,
                })
                new("TextLabel",{
                    Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,18,0,0),
                    BackgroundTransparency=1,Text=lbl,TextColor3=C.text,
                    TextSize=11,Font=Enum.Font.GothamBold,
                    TextXAlignment=Enum.TextXAlignment.Left,Parent=header,
                })
                local arr=new("TextLabel",{
                    Size=UDim2.new(0,20,1,0),Position=UDim2.new(1,-26,0,0),
                    BackgroundTransparency=1,Text="▾",TextColor3=C.sub,
                    TextSize=10,Font=Enum.Font.GothamBold,Parent=header,
                })
                local cont=new("Frame",{
                    Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,0,30),
                    BackgroundTransparency=1,ClipsDescendants=false,Parent=wrap,
                })
                mkPad(cont,2,4,0,0)
                mkList(cont,Enum.FillDirection.Vertical,3)
                local cL=cont:FindFirstChildOfClass("UIListLayout")
                local collapsed=false
                local function rsz()
                    if collapsed then
                        wrap.Size=UDim2.new(1,0,0,28) cont.Visible=false
                    else
                        cont.Visible=true
                        local h=(cL and cL.AbsoluteContentSize.Y or 0)+8
                        cont.Size=UDim2.new(1,0,0,h)
                        wrap.Size=UDim2.new(1,0,0,30+h+2)
                    end
                end
                if cL then cL:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(rsz) end
                header.MouseButton1Click:Connect(function()
                    collapsed=not collapsed
                    tw(arr,{Rotation=collapsed and -90 or 0},.2)
                    rsz()
                end)
                task.defer(rsz)
                s._container=cont
                return s
            end

            return tabObj
        end
    end

    -- boot
    if cfg.Key then
        showKey(cfg,function(tier)
            local isPrem=(tier=="premium")
            buildUI(isPrem)
            toast((cfg.Title or "Hub").." loaded — "..(isPrem and "★ PREMIUM" or "FREE"),
                  isPrem and C.gold or C.blue, 4)
        end)
    else
        buildUI(false)
    end

    return win
end

function ZethUI:Notify(text, col, dur)
    toast(text,col,dur)
end

return ZethUI
