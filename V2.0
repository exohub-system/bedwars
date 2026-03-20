-- ╔═══════════════════════════════════╗
--   EXO HUB | BEDWARS v2.0
--   discord.gg/6QzV9pTWs
-- ╚═══════════════════════════════════╝

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local lp               = Players.LocalPlayer

local T = {
    Accent      = Color3.fromRGB(0, 85, 170),
    AccentLight = Color3.fromRGB(0, 180, 255),
    Bg          = Color3.fromRGB(8, 10, 20),
    SidebarBg   = Color3.fromRGB(6, 8, 18),
    RowBg       = Color3.fromRGB(18, 22, 40),
    Border      = Color3.fromRGB(30, 50, 110),
    Text        = Color3.fromRGB(210, 225, 255),
    SubText     = Color3.fromRGB(90, 110, 170),
    ToggleOff   = Color3.fromRGB(30, 35, 60),
    SecLabel    = Color3.fromRGB(60, 85, 145),
}

local ICON_ID = "rbxassetid://71483961072989"
local SIDE_W  = 130
local W_W, W_H = 420, 400

-- features
local nowe=false; local flySpeed=60; local tpwalk=false
local espActive=false; local espObjs={}; local espConn=nil
local speedActive=false; local antiVoid=false; local autoBuy=false

local function getChar() return lp.Character end
local function getHRP() local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum() local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

-- FLY
local function startFly()
    local char=getChar(); if not char then return end
    local hum=char:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
    local isR6=hum.RigType==Enum.HumanoidRigType.R6
    local torso=isR6 and char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso"); if not torso then return end
    pcall(function() char.Animate.Disabled=true end)
    for _,t in pairs(hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(0) end
    for _,s in pairs(Enum.HumanoidStateType:GetEnumItems()) do pcall(function() hum:SetStateEnabled(s,false) end) end
    hum:ChangeState(Enum.HumanoidStateType.Swimming); hum.PlatformStand=true
    tpwalk=true
    task.spawn(function()
        while tpwalk do RunService.Heartbeat:Wait()
            if hum and hum.MoveDirection.Magnitude>0 then char:TranslateBy(hum.MoveDirection) end
        end
    end)
    local bg=Instance.new("BodyGyro",torso); bg.P=9e4; bg.maxTorque=Vector3.new(9e9,9e9,9e9); bg.cframe=torso.CFrame
    local bv=Instance.new("BodyVelocity",torso); bv.velocity=Vector3.new(0,0.1,0); bv.maxForce=Vector3.new(9e9,9e9,9e9)
    local ctrl={f=0,b=0,l=0,r=0}; local lc={f=0,b=0,l=0,r=0}; local spd=0
    local conn; conn=RunService.RenderStepped:Connect(function()
        if not nowe then conn:Disconnect(); bg:Destroy(); bv:Destroy(); hum.PlatformStand=false
            pcall(function() char.Animate.Disabled=false end); tpwalk=false
            for _,s in pairs(Enum.HumanoidStateType:GetEnumItems()) do pcall(function() hum:SetStateEnabled(s,true) end) end
            hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics); return end
        ctrl.f=UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0
        ctrl.b=UserInputService:IsKeyDown(Enum.KeyCode.S) and -1 or 0
        ctrl.l=UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0
        ctrl.r=UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0
        local ms=flySpeed
        if ctrl.l+ctrl.r~=0 or ctrl.f+ctrl.b~=0 then spd=math.min(spd+0.5+(spd/ms),ms) else spd=math.max(spd-1,0) end
        local cam=workspace.CurrentCamera.CoordinateFrame
        if (ctrl.l+ctrl.r)~=0 or (ctrl.f+ctrl.b)~=0 then
            bv.velocity=((cam.lookVector*(ctrl.f+ctrl.b))+((cam*CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p)-cam.p))*spd
            lc={f=ctrl.f,b=ctrl.b,l=ctrl.l,r=ctrl.r}
        elseif spd~=0 then
            bv.velocity=((cam.lookVector*(lc.f+lc.b))+((cam*CFrame.new(lc.l+lc.r,(lc.f+lc.b)*.2,0).p)-cam.p))*spd
        else bv.velocity=Vector3.new(0,0,0) end
        bg.cframe=cam*CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*spd/ms),0,0)
    end)
end

-- ESP
local function clearESP() for _,o in pairs(espObjs) do pcall(function() o:Destroy() end) end; espObjs={} end
local function startESP()
    espConn=RunService.Heartbeat:Connect(function()
        if not espActive then clearESP(); return end; clearESP()
        for _,p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local root=p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,70,0,26)
                    bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true; bb.Adornee=root; bb.Parent=workspace
                    local lbl=Instance.new("TextLabel",bb); lbl.Size=UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency=1; lbl.Text=p.DisplayName
                    lbl.TextColor3=Color3.fromRGB(0,180,255); lbl.TextStrokeTransparency=0
                    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12
                    local hl=Instance.new("SelectionBox"); hl.Adornee=p.Character
                    hl.Color3=Color3.fromRGB(0,120,255); hl.LineThickness=0.04
                    hl.SurfaceTransparency=0.85; hl.Parent=workspace
                    table.insert(espObjs,bb); table.insert(espObjs,hl)
                end
            end
        end
    end)
end

RunService.Heartbeat:Connect(function()
    if not antiVoid then return end
    local hrp=getHRP(); if not hrp then return end
    if hrp.Position.Y < -80 then hrp.CFrame=CFrame.new(0,50,0) end
end)

task.spawn(function()
    while true do task.wait(2)
        if autoBuy then pcall(function()
            for _,obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                    local n=obj.Name:lower()
                    if n:find("buy") or n:find("purchase") then
                        pcall(function() if obj:IsA("RemoteFunction") then obj:InvokeServer() else obj:FireServer() end end)
                    end
                end
            end
        end) end
    end
end)

lp.CharacterAdded:Connect(function()
    task.wait(1)
    if nowe then nowe=false; task.wait(0.1); nowe=true; startFly() end
    if speedActive then local h=getHum(); if h then h.WalkSpeed=80 end end
end)

-- ══════════════════════════════════════
--  GUI
-- ══════════════════════════════════════
if lp.PlayerGui:FindFirstChild("ExoHubUI") then lp.PlayerGui.ExoHubUI:Destroy() end

local SG=Instance.new("ScreenGui")
SG.Name="ExoHubUI"; SG.ResetOnSpawn=false; SG.DisplayOrder=999
SG.IgnoreGuiInset=true; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
SG.Parent=lp.PlayerGui

local win=Instance.new("Frame",SG)
win.Size=UDim2.new(0,W_W,0,0)
win.Position=UDim2.new(0.5,-(W_W/2),0.5,-(W_H/2))
win.BackgroundColor3=T.Bg
win.BorderSizePixel=0
win.Active=true
win.Draggable=true
Instance.new("UICorner",win).CornerRadius=UDim.new(0,12)
Instance.new("UIStroke",win).Color=T.Border

-- shimmer bar
local shimmer=Instance.new("Frame",win)
shimmer.Size=UDim2.new(1,0,0,2); shimmer.BackgroundColor3=T.Accent; shimmer.BorderSizePixel=0; shimmer.ZIndex=2
local sg=Instance.new("UIGradient",shimmer)
sg.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),ColorSequenceKeypoint.new(0.3,T.Accent),ColorSequenceKeypoint.new(0.7,T.AccentLight),ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0))})
task.spawn(function() local t=0; while SG.Parent do t+=0.03; sg.Offset=Vector2.new(math.sin(t)*0.8,0); task.wait(0.03) end end)

-- SIDEBAR
local sb=Instance.new("Frame",win)
sb.Size=UDim2.new(0,SIDE_W,1,0); sb.BackgroundColor3=T.SidebarBg; sb.BorderSizePixel=0; sb.ZIndex=2
Instance.new("UICorner",sb).CornerRadius=UDim.new(0,12)
local fix=Instance.new("Frame",sb); fix.Size=UDim2.new(0,12,1,0); fix.Position=UDim2.new(1,-12,0,0); fix.BackgroundColor3=T.SidebarBg; fix.BorderSizePixel=0; fix.ZIndex=2
local sbl=Instance.new("Frame",sb); sbl.Size=UDim2.new(0,1,1,0); sbl.Position=UDim2.new(1,0,0,0); sbl.BackgroundColor3=T.Border; sbl.BorderSizePixel=0; sbl.ZIndex=3

-- logo
local logoImg=Instance.new("ImageLabel",sb); logoImg.Size=UDim2.new(0,24,0,24); logoImg.Position=UDim2.new(0,8,0,9)
logoImg.BackgroundTransparency=1; logoImg.Image=ICON_ID; logoImg.ZIndex=3
Instance.new("UICorner",logoImg).CornerRadius=UDim.new(0,6)
local titleLbl=Instance.new("TextLabel",sb); titleLbl.Size=UDim2.new(1,-36,0,13); titleLbl.Position=UDim2.new(0,36,0,10)
titleLbl.BackgroundTransparency=1; titleLbl.Text="EXO HUB"; titleLbl.Font=Enum.Font.GothamBlack; titleLbl.TextSize=12
titleLbl.TextXAlignment=Enum.TextXAlignment.Left; titleLbl.ZIndex=3
Instance.new("UIGradient",titleLbl).Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.AccentLight),ColorSequenceKeypoint.new(1,T.Text)})
local discLbl=Instance.new("TextLabel",sb); discLbl.Size=UDim2.new(1,-8,0,9); discLbl.Position=UDim2.new(0,8,0,25)
discLbl.BackgroundTransparency=1; discLbl.Text="discord.gg/6QzV9pTWs"; discLbl.Font=Enum.Font.GothamMedium; discLbl.TextSize=7
discLbl.TextColor3=T.SubText; discLbl.TextXAlignment=Enum.TextXAlignment.Left; discLbl.ZIndex=3

local div=Instance.new("Frame",sb); div.Size=UDim2.new(1,-10,0,1); div.Position=UDim2.new(0,5,0,38)
div.BackgroundColor3=T.Border; div.BorderSizePixel=0; div.ZIndex=3

local tabList=Instance.new("Frame",sb); tabList.Size=UDim2.new(1,0,1,-44); tabList.Position=UDim2.new(0,0,0,42)
tabList.BackgroundTransparency=1; tabList.ZIndex=3
local tabLL=Instance.new("UIListLayout",tabList); tabLL.SortOrder=Enum.SortOrder.LayoutOrder; tabLL.Padding=UDim.new(0,2)
local tabPad=Instance.new("UIPadding",tabList)
tabPad.PaddingLeft=UDim.new(0,4); tabPad.PaddingRight=UDim.new(0,4); tabPad.PaddingTop=UDim.new(0,2)

-- TOPBAR
local topBar=Instance.new("Frame",win)
topBar.Size=UDim2.new(1,-SIDE_W,0,34); topBar.Position=UDim2.new(0,SIDE_W,0,0)
topBar.BackgroundTransparency=1; topBar.ZIndex=3

local pageLbl=Instance.new("TextLabel",topBar); pageLbl.Size=UDim2.new(1,-80,1,0); pageLbl.Position=UDim2.new(0,10,0,0)
pageLbl.BackgroundTransparency=1; pageLbl.Font=Enum.Font.GothamBold; pageLbl.TextSize=12; pageLbl.TextColor3=T.SubText
pageLbl.TextXAlignment=Enum.TextXAlignment.Left; pageLbl.ZIndex=4

local verLbl=Instance.new("TextLabel",topBar); verLbl.Size=UDim2.new(0,28,1,0); verLbl.Position=UDim2.new(1,-92,0,0)
verLbl.BackgroundTransparency=1; verLbl.Text="v2.0"; verLbl.Font=Enum.Font.GothamBold; verLbl.TextSize=9
verLbl.TextColor3=T.SubText; verLbl.ZIndex=4

local closeBtn=Instance.new("TextButton",topBar); closeBtn.Size=UDim2.new(0,22,0,22)
closeBtn.Position=UDim2.new(1,-26,0.5,-11); closeBtn.BackgroundColor3=Color3.fromRGB(190,40,55)
closeBtn.Text="×"; closeBtn.TextColor3=Color3.fromRGB(255,255,255); closeBtn.Font=Enum.Font.GothamBlack
closeBtn.TextSize=14; closeBtn.BorderSizePixel=0; closeBtn.ZIndex=4
Instance.new("UICorner",closeBtn).CornerRadius=UDim.new(0,6)

local miniBtn=Instance.new("TextButton",topBar); miniBtn.Size=UDim2.new(0,22,0,22)
miniBtn.Position=UDim2.new(1,-52,0.5,-11); miniBtn.BackgroundColor3=Color3.fromRGB(18,22,40)
miniBtn.Text="─"; miniBtn.TextColor3=Color3.fromRGB(200,200,210); miniBtn.Font=Enum.Font.GothamBold
miniBtn.TextSize=10; miniBtn.BorderSizePixel=0; miniBtn.ZIndex=4
Instance.new("UICorner",miniBtn).CornerRadius=UDim.new(0,6)
Instance.new("UIStroke",miniBtn).Color=T.Border

local topDiv=Instance.new("Frame",win); topDiv.Size=UDim2.new(1,-SIDE_W,0,1); topDiv.Position=UDim2.new(0,SIDE_W,0,33)
topDiv.BackgroundColor3=T.Border; topDiv.BorderSizePixel=0; topDiv.ZIndex=3

local mini=false
miniBtn.MouseButton1Click:Connect(function()
    mini=not mini; miniBtn.Text=mini and "+" or "─"
    TweenService:Create(win,TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,W_W,0,mini and 34 or W_H)}):Play()
end)
closeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(win,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.new(0,W_W,0,0)}):Play()
    task.wait(0.3); SG:Destroy()
end)

-- NOTIFY
local function Notify(cfg)
    cfg=cfg or {}
    local n=Instance.new("Frame",SG); n.Size=UDim2.new(0,240,0,54)
    n.Position=UDim2.new(1,10,1,-68); n.BackgroundColor3=T.SidebarBg; n.BorderSizePixel=0; n.ZIndex=100
    Instance.new("UICorner",n).CornerRadius=UDim.new(0,10)
    Instance.new("UIStroke",n).Color=T.Accent
    local ab=Instance.new("Frame",n); ab.Size=UDim2.new(0,3,1,-12); ab.Position=UDim2.new(0,6,0,6)
    ab.BackgroundColor3=T.Accent; ab.BorderSizePixel=0; ab.ZIndex=101
    Instance.new("UICorner",ab).CornerRadius=UDim.new(1,0)
    local nt=Instance.new("TextLabel",n); nt.Size=UDim2.new(1,-20,0,16); nt.Position=UDim2.new(0,15,0,8)
    nt.BackgroundTransparency=1; nt.Font=Enum.Font.GothamBold; nt.TextSize=11; nt.TextColor3=T.Text
    nt.TextXAlignment=Enum.TextXAlignment.Left; nt.ZIndex=101; nt.Text=cfg.Title or "EXO HUB"
    local nd=Instance.new("TextLabel",n); nd.Size=UDim2.new(1,-20,0,14); nd.Position=UDim2.new(0,15,0,28)
    nd.BackgroundTransparency=1; nd.Font=Enum.Font.GothamMedium; nd.TextSize=9; nd.TextColor3=T.SubText
    nd.TextXAlignment=Enum.TextXAlignment.Left; nd.ZIndex=101; nd.Text=cfg.Content or ""
    TweenService:Create(n,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Position=UDim2.new(1,-250,1,-68)}):Play()
    task.delay(cfg.Duration or 3,function()
        TweenService:Create(n,TweenInfo.new(0.25),{Position=UDim2.new(1,10,1,-68)}):Play()
        task.wait(0.3); n:Destroy()
    end)
end

-- ICONS
local ICONS={sword="⚔️",zap="⚡",eye="👁",settings="⚙️",fly="🕊️",speed="💨",
    shield="🛡️",bed="🛏️",buy="🛒",bridge="🧱",heart="❤️",bolt="⚡",star="⭐",target="🎯"}
local function ico(i) return ICONS[i] or "◆" end

-- CONTENT AREA
local contentArea=Instance.new("Frame",win)
contentArea.Size=UDim2.new(1,-SIDE_W,1,-34)
contentArea.Position=UDim2.new(0,SIDE_W,0,34)
contentArea.BackgroundTransparency=1
contentArea.ZIndex=3

-- TAB BUILDER
local pages={}; local tabN=0; local firstTab=true

local function makeTab(title, icon)
    tabN+=1; local key=tabN; local isFirst=firstTab; firstTab=false

    local btn=Instance.new("TextButton",tabList)
    btn.Size=UDim2.new(1,0,0,28); btn.BackgroundColor3=Color3.fromRGB(0,0,0)
    btn.BackgroundTransparency=1; btn.Text=""; btn.BorderSizePixel=0; btn.ZIndex=3; btn.LayoutOrder=key
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)
    local bIco=Instance.new("TextLabel",btn); bIco.Size=UDim2.new(0,20,1,0); bIco.Position=UDim2.new(0,5,0,0)
    bIco.BackgroundTransparency=1; bIco.Text=ico(icon); bIco.TextSize=11; bIco.Font=Enum.Font.GothamBold; bIco.TextColor3=T.SubText; bIco.ZIndex=4
    local bLbl=Instance.new("TextLabel",btn); bLbl.Size=UDim2.new(1,-26,1,0); bLbl.Position=UDim2.new(0,24,0,0)
    bLbl.BackgroundTransparency=1; bLbl.Text=title; bLbl.Font=Enum.Font.GothamBold; bLbl.TextSize=10
    bLbl.TextColor3=T.SubText; bLbl.TextXAlignment=Enum.TextXAlignment.Left; bLbl.ZIndex=4

    local scroll=Instance.new("ScrollingFrame",contentArea)
    scroll.Size=UDim2.new(1,0,1,0)
    scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0
    scroll.ScrollBarThickness=3; scroll.ScrollBarImageColor3=T.Accent
    scroll.CanvasSize=UDim2.new(0,0,0,0); scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
    scroll.Visible=false; scroll.ZIndex=3
    local sl=Instance.new("UIListLayout",scroll); sl.SortOrder=Enum.SortOrder.LayoutOrder; sl.Padding=UDim.new(0,5)
    local sp=Instance.new("UIPadding",scroll)
    sp.PaddingLeft=UDim.new(0,8); sp.PaddingRight=UDim.new(0,12); sp.PaddingTop=UDim.new(0,6); sp.PaddingBottom=UDim.new(0,8)

    pages[key]={btn=btn,scroll=scroll,ico=bIco,lbl=bLbl}

    local function activate()
        for k,d in pairs(pages) do
            local on=k==key
            d.btn.BackgroundTransparency=on and 0 or 1
            d.btn.BackgroundColor3=on and T.Accent or Color3.fromRGB(0,0,0)
            d.lbl.TextColor3=on and Color3.fromRGB(255,255,255) or T.SubText
            d.ico.TextColor3=on and Color3.fromRGB(255,255,255) or T.SubText
            d.scroll.Visible=on
        end
        pageLbl.Text=title
    end

    btn.MouseButton1Click:Connect(activate)
    if isFirst then activate() end

    local rowN=0

    local tabObj={}

    function tabObj:Section(name)
        rowN+=1
        local hdr=Instance.new("Frame",scroll); hdr.Size=UDim2.new(1,0,0,18)
        hdr.BackgroundTransparency=1; hdr.LayoutOrder=rowN; hdr.ZIndex=4
        local hL=Instance.new("TextLabel",hdr); hL.Size=UDim2.new(1,0,1,0)
        hL.BackgroundTransparency=1; hL.Text=name:upper(); hL.Font=Enum.Font.GothamBold
        hL.TextSize=8; hL.LetterSpacing=1; hL.TextColor3=T.SecLabel
        hL.TextXAlignment=Enum.TextXAlignment.Left; hL.ZIndex=5
        rowN+=1000
    end

    local function addRow(h)
        rowN+=1
        local row=Instance.new("Frame",scroll)
        row.Size=UDim2.new(1,0,0,h)
        row.BackgroundColor3=T.RowBg
        row.BorderSizePixel=0
        row.LayoutOrder=rowN
        row.ZIndex=4
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
        local stroke=Instance.new("UIStroke",row); stroke.Color=T.Border; stroke.Thickness=1
        return row,stroke
    end

    function tabObj:Toggle(cfg)
        local row,stroke=addRow(46)
        local iL=Instance.new("TextLabel",row); iL.Size=UDim2.new(0,18,1,0); iL.Position=UDim2.new(0,7,0,0)
        iL.BackgroundTransparency=1; iL.Text=ico(cfg.Icon); iL.TextSize=12; iL.Font=Enum.Font.GothamBold; iL.TextColor3=T.SubText; iL.ZIndex=5
        local nL=Instance.new("TextLabel",row); nL.Size=UDim2.new(1,-64,0,15); nL.Position=UDim2.new(0,28,0,7)
        nL.BackgroundTransparency=1; nL.Text=cfg.Title or ""; nL.Font=Enum.Font.GothamBold; nL.TextSize=11; nL.TextColor3=T.Text; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.ZIndex=5
        local dL=Instance.new("TextLabel",row); dL.Size=UDim2.new(1,-64,0,11); dL.Position=UDim2.new(0,28,0,25)
        dL.BackgroundTransparency=1; dL.Text=cfg.Desc or ""; dL.Font=Enum.Font.GothamMedium; dL.TextSize=9; dL.TextColor3=T.SubText; dL.TextXAlignment=Enum.TextXAlignment.Left; dL.ZIndex=5
        local pill=Instance.new("Frame",row); pill.Size=UDim2.new(0,36,0,20); pill.AnchorPoint=Vector2.new(1,0.5); pill.Position=UDim2.new(1,-8,0.5,0)
        pill.BackgroundColor3=T.ToggleOff; pill.BorderSizePixel=0; pill.ZIndex=5
        Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
        local ps=Instance.new("UIStroke",pill); ps.Color=T.Border; ps.Thickness=1
        local dot=Instance.new("Frame",pill); dot.Size=UDim2.new(0,12,0,12); dot.AnchorPoint=Vector2.new(0.5,0.5); dot.Position=UDim2.new(0.28,0,0.5,0)
        dot.BackgroundColor3=T.SubText; dot.BorderSizePixel=0; dot.ZIndex=6
        Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
        local cb=Instance.new("TextButton",row); cb.Size=UDim2.new(1,0,1,0); cb.BackgroundTransparency=1; cb.Text=""; cb.ZIndex=7
        local on=cfg.Value or false
        local ti=TweenInfo.new(0.18,Enum.EasingStyle.Quart)
        local function set(v)
            on=v
            TweenService:Create(pill,ti,{BackgroundColor3=on and T.Accent or T.ToggleOff}):Play()
            TweenService:Create(ps,ti,{Color=on and T.Accent or T.Border,Transparency=on and 0.5 or 0}):Play()
            TweenService:Create(dot,ti,{Position=on and UDim2.new(0.72,0,0.5,0) or UDim2.new(0.28,0,0.5,0),BackgroundColor3=on and Color3.fromRGB(255,255,255) or T.SubText}):Play()
            TweenService:Create(stroke,ti,{Color=on and T.Accent or T.Border,Transparency=on and 0.5 or 0}):Play()
            if cfg.Callback then cfg.Callback(on) end
        end
        if on then task.defer(function() set(true) end) end
        cb.MouseButton1Click:Connect(function() set(not on) end)
        local o={}; function o:Set(v) set(v) end; return o
    end

    function tabObj:Button(cfg)
        local row,stroke=addRow(46)
        local iL=Instance.new("TextLabel",row); iL.Size=UDim2.new(0,18,1,0); iL.Position=UDim2.new(0,7,0,0)
        iL.BackgroundTransparency=1; iL.Text=ico(cfg.Icon); iL.TextSize=12; iL.Font=Enum.Font.GothamBold; iL.TextColor3=T.SubText; iL.ZIndex=5
        local nL=Instance.new("TextLabel",row); nL.Size=UDim2.new(1,-54,0,15); nL.Position=UDim2.new(0,28,0,7)
        nL.BackgroundTransparency=1; nL.Text=cfg.Title or ""; nL.Font=Enum.Font.GothamBold; nL.TextSize=11; nL.TextColor3=T.Text; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.ZIndex=5
        local dL=Instance.new("TextLabel",row); dL.Size=UDim2.new(1,-54,0,11); dL.Position=UDim2.new(0,28,0,25)
        dL.BackgroundTransparency=1; dL.Text=cfg.Desc or ""; dL.Font=Enum.Font.GothamMedium; dL.TextSize=9; dL.TextColor3=T.SubText; dL.TextXAlignment=Enum.TextXAlignment.Left; dL.ZIndex=5
        local ib=Instance.new("Frame",row); ib.Size=UDim2.new(0,20,0,20); ib.AnchorPoint=Vector2.new(1,0.5); ib.Position=UDim2.new(1,-8,0.5,0)
        ib.BackgroundColor3=T.ToggleOff; ib.BorderSizePixel=0; ib.ZIndex=5
        Instance.new("UICorner",ib).CornerRadius=UDim.new(0,5); Instance.new("UIStroke",ib).Color=T.Border
        local il=Instance.new("TextLabel",ib); il.Size=UDim2.new(1,0,1,0); il.BackgroundTransparency=1; il.Text="▶"; il.TextSize=7; il.Font=Enum.Font.GothamBold; il.TextColor3=T.Accent; il.ZIndex=6
        local cb=Instance.new("TextButton",row); cb.Size=UDim2.new(1,0,1,0); cb.BackgroundTransparency=1; cb.Text=""; cb.ZIndex=7
        cb.MouseButton1Click:Connect(function()
            TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=Color3.fromRGB(16,20,38)}):Play()
            task.wait(0.12); TweenService:Create(row,TweenInfo.new(0.15),{BackgroundColor3=T.RowBg}):Play()
            if cfg.Callback then cfg.Callback() end
        end)
    end

    function tabObj:Slider(cfg)
        local row,stroke=addRow(52)
        local iL=Instance.new("TextLabel",row); iL.Size=UDim2.new(0,18,0,18); iL.Position=UDim2.new(0,7,0,6)
        iL.BackgroundTransparency=1; iL.Text=ico(cfg.Icon); iL.TextSize=12; iL.Font=Enum.Font.GothamBold; iL.TextColor3=T.SubText; iL.ZIndex=5
        local nL=Instance.new("TextLabel",row); nL.Size=UDim2.new(1,-56,0,14); nL.Position=UDim2.new(0,28,0,6)
        nL.BackgroundTransparency=1; nL.Text=cfg.Title or ""; nL.Font=Enum.Font.GothamBold; nL.TextSize=11; nL.TextColor3=T.Text; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.ZIndex=5
        local vL=Instance.new("TextLabel",row); vL.Size=UDim2.new(0,38,0,14); vL.Position=UDim2.new(1,-44,0,6)
        vL.BackgroundTransparency=1; vL.Text=tostring(cfg.Value or cfg.Min or 0); vL.Font=Enum.Font.GothamBold; vL.TextSize=11; vL.TextColor3=T.Accent; vL.TextXAlignment=Enum.TextXAlignment.Right; vL.ZIndex=5
        local track=Instance.new("Frame",row); track.Size=UDim2.new(1,-20,0,4); track.Position=UDim2.new(0,10,0,38)
        track.BackgroundColor3=T.ToggleOff; track.BorderSizePixel=0; track.ZIndex=5
        Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
        local mn,mx=cfg.Min or 0,cfg.Max or 100; local pct=((cfg.Value or mn)-mn)/(mx-mn)
        local fill=Instance.new("Frame",track); fill.Size=UDim2.new(pct,0,1,0); fill.BackgroundColor3=T.Accent; fill.BorderSizePixel=0; fill.ZIndex=6
        Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
        Instance.new("UIGradient",fill).Color=ColorSequence.new({ColorSequenceKeypoint.new(0,T.Accent),ColorSequenceKeypoint.new(1,T.AccentLight)})
        local thumb=Instance.new("Frame",track); thumb.Size=UDim2.new(0,12,0,12); thumb.AnchorPoint=Vector2.new(0.5,0.5); thumb.Position=UDim2.new(pct,0,0.5,0)
        thumb.BackgroundColor3=Color3.fromRGB(220,235,255); thumb.BorderSizePixel=0; thumb.ZIndex=7
        Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)
        local drag=false
        thumb.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true end end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end end)
        UserInputService.InputChanged:Connect(function(i)
            if not drag then return end
            if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
            local rel=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
            local val=math.floor(mn+rel*(mx-mn)); fill.Size=UDim2.new(rel,0,1,0); thumb.Position=UDim2.new(rel,0,0.5,0); vL.Text=tostring(val)
            if cfg.Callback then cfg.Callback(val) end
        end)
    end

    return tabObj
end

-- open anim
TweenService:Create(win,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,W_W,0,W_H)}):Play()

-- BUILD TABS
local Combat  =makeTab("Combat",   "sword")
local Movement=makeTab("Movement", "fly")
local Visuals =makeTab("Visuals",  "eye")
local Misc    =makeTab("Misc",     "settings")

Combat:Section("Combat")
Combat:Toggle({Title="Auto Buy",    Desc="Buys from shop",      Icon="buy",    Value=false, Callback=function(s) autoBuy=s; Notify({Title="EXO HUB",Content="Auto Buy: "..(s and "ON 🔥" or "OFF"),Duration=2}) end})
Combat:Toggle({Title="Auto Bridge", Desc="Auto place blocks",   Icon="bridge", Value=false, Callback=function(s) Notify({Title="EXO HUB",Content="Auto Bridge: "..(s and "ON 🔥" or "OFF"),Duration=2}) end})
Combat:Button({Title="Destroy Bed", Desc="TP to enemy bed",     Icon="bed",    Callback=function()
    local hrp=getHRP(); if not hrp then return end
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("bed") and obj:IsA("BasePart") then hrp.CFrame=obj.CFrame+Vector3.new(0,5,0); Notify({Title="EXO HUB",Content="Teleported to bed! 🛏️",Duration=2}); break end
    end
end})

Movement:Section("Movement")
Movement:Toggle({Title="Fly",       Desc="Fly around the map",  Icon="fly",    Value=false, Callback=function(s) nowe=s; if s then startFly() end; Notify({Title="EXO HUB",Content="Fly: "..(s and "ON 🔥" or "OFF"),Duration=2}) end})
Movement:Toggle({Title="Speed Hack",Desc="Boost your speed",    Icon="speed",  Value=false, Callback=function(s) speedActive=s; local h=getHum(); if h then h.WalkSpeed=s and 80 or 16 end; Notify({Title="EXO HUB",Content="Speed: "..(s and "ON 🔥" or "OFF"),Duration=2}) end})
Movement:Toggle({Title="Anti Void", Desc="No falling off map",  Icon="shield", Value=false, Callback=function(s) antiVoid=s; Notify({Title="EXO HUB",Content="Anti Void: "..(s and "ON 🔥" or "OFF"),Duration=2}) end})
Movement:Slider({Title="Fly Speed", Icon="bolt", Min=10, Max=200, Value=60, Callback=function(v) flySpeed=v end})

Visuals:Section("ESP")
Visuals:Toggle({Title="Player ESP", Desc="See all players",     Icon="eye",    Value=false, Callback=function(s)
    espActive=s; if s then startESP() else if espConn then espConn:Disconnect(); espConn=nil end; clearESP() end
    Notify({Title="EXO HUB",Content="ESP: "..(s and "ON 🔥" or "OFF"),Duration=2})
end})

Misc:Section("Misc")
Misc:Button({Title="Spawn TP",     Desc="Go to your island",    Icon="target", Callback=function() local h=getHRP(); if h then h.CFrame=CFrame.new(0,50,0) end; Notify({Title="EXO HUB",Content="Teleported!",Duration=2}) end})
Misc:Button({Title="Heal",         Desc="Restore full HP",      Icon="heart",  Callback=function() local h=getHum(); if h then h.Health=h.MaxHealth end; Notify({Title="EXO HUB",Content="Healed! ❤️",Duration=2}) end})
Misc:Button({Title="Join Discord",  Desc="discord.gg/6QzV9pTWs",Icon="star",   Callback=function() Notify({Title="EXO HUB",Content="discord.gg/6QzV9pTWs 🔥",Duration=4}) end})

task.wait(0.5)
Notify({Title="EXO HUB",Content="Bedwars v2.0 loaded! 🔥",Duration=4})
print("[EXO HUB] Bedwars v2.0 | discord.gg/6QzV9pTWs")
