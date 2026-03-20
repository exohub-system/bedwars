-- ╔═══════════════════════════════════╗
--   EXO HUB | BEDWARS
--   Compact UI | discord.gg/6QzV9pTWs
-- ╚═══════════════════════════════════╝

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local lp               = Players.LocalPlayer

-- ══════════════════════════════════════
--  THEME
-- ══════════════════════════════════════
local T = {
    Accent      = Color3.fromRGB(0, 85, 170),
    AccentLight = Color3.fromRGB(0, 180, 255),
    Bg          = Color3.fromRGB(8, 10, 20),
    SidebarBg   = Color3.fromRGB(6, 8, 18),
    RowBg       = Color3.fromRGB(13, 16, 30),
    RowHover    = Color3.fromRGB(16, 20, 38),
    Border      = Color3.fromRGB(0, 45, 100),
    Text        = Color3.fromRGB(210, 225, 255),
    SubText     = Color3.fromRGB(70, 95, 150),
    ToggleOff   = Color3.fromRGB(30, 35, 60),
    SecLabel    = Color3.fromRGB(50, 75, 130),
}

local ICON_ID  = "rbxassetid://71483961072989"
local SIDE_W   = 130
local W_W, W_H = 420, 380

-- ══════════════════════════════════════
--  FEATURES STATE
-- ══════════════════════════════════════
local flyActive      = false
local flySpeed       = 50
local espActive      = false
local speedActive    = false
local antiVoidActive = false
local autoBuyActive  = false
local autoBridgeActive = false
local flyConn        = nil
local espConn        = nil
local espObjects     = {}
local nowe           = false
local tpwalking      = false

local function getChar() return lp.Character end
local function getHRP()  local c=getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function getHum()  local c=getChar(); return c and c:FindFirstChildOfClass("Humanoid") end

-- ══════════════════════════════════════
--  FLY
-- ══════════════════════════════════════
local function startTpWalking()
    tpwalking = false
    spawn(function()
        local hb = RunService.Heartbeat
        tpwalking = true
        local chr = getChar()
        local hum = chr and chr:FindFirstChildWhichIsA("Humanoid")
        while tpwalking and hb:Wait() and chr and hum and hum.Parent do
            if hum.MoveDirection.Magnitude > 0 then
                chr:TranslateBy(hum.MoveDirection)
            end
        end
    end)
end

local function disableStates(hum)
    for _, s in pairs(Enum.HumanoidStateType:GetEnumItems()) do
        pcall(function() hum:SetStateEnabled(s, false) end)
    end
    hum:ChangeState(Enum.HumanoidStateType.Swimming)
end

local function enableStates(hum)
    for _, s in pairs(Enum.HumanoidStateType:GetEnumItems()) do
        pcall(function() hum:SetStateEnabled(s, true) end)
    end
    hum:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
end

local function startFly()
    local char = getChar(); if not char then return end
    local hum = char:FindFirstChildWhichIsA("Humanoid"); if not hum then return end
    local isR6 = hum.RigType == Enum.HumanoidRigType.R6
    local torso = isR6 and char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not torso then return end
    char.Animate.Disabled = true
    for _, t in pairs(hum:GetPlayingAnimationTracks()) do t:AdjustSpeed(0) end
    disableStates(hum); startTpWalking(); hum.PlatformStand = true
    local bg = Instance.new("BodyGyro", torso)
    bg.P=9e4; bg.maxTorque=Vector3.new(9e9,9e9,9e9); bg.cframe=torso.CFrame
    local bv = Instance.new("BodyVelocity", torso)
    bv.velocity=Vector3.new(0,0.1,0); bv.maxForce=Vector3.new(9e9,9e9,9e9)
    local ctrl={f=0,b=0,l=0,r=0}; local lastctrl={f=0,b=0,l=0,r=0}
    local maxspeed=flySpeed; local spd=0
    flyConn = RunService.RenderStepped:Connect(function()
        if not nowe then
            flyConn:Disconnect(); flyConn=nil
            bg:Destroy(); bv:Destroy()
            hum.PlatformStand=false
            char.Animate.Disabled=false
            tpwalking=false; enableStates(hum); return
        end
        maxspeed=flySpeed
        ctrl.f=UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0
        ctrl.b=UserInputService:IsKeyDown(Enum.KeyCode.S) and -1 or 0
        ctrl.l=UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0
        ctrl.r=UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0
        if ctrl.l+ctrl.r~=0 or ctrl.f+ctrl.b~=0 then
            spd=math.min(spd+0.5+(spd/maxspeed),maxspeed)
        else spd=math.max(spd-1,0) end
        local cam=workspace.CurrentCamera.CoordinateFrame
        if (ctrl.l+ctrl.r)~=0 or (ctrl.f+ctrl.b)~=0 then
            bv.velocity=((cam.lookVector*(ctrl.f+ctrl.b))+((cam*CFrame.new(ctrl.l+ctrl.r,(ctrl.f+ctrl.b)*.2,0).p)-cam.p))*spd
            lastctrl={f=ctrl.f,b=ctrl.b,l=ctrl.l,r=ctrl.r}
        elseif spd~=0 then
            bv.velocity=((cam.lookVector*(lastctrl.f+lastctrl.b))+((cam*CFrame.new(lastctrl.l+lastctrl.r,(lastctrl.f+lastctrl.b)*.2,0).p)-cam.p))*spd
        else bv.velocity=Vector3.new(0,0,0) end
        bg.cframe=cam*CFrame.Angles(-math.rad((ctrl.f+ctrl.b)*50*spd/maxspeed),0,0)
    end)
end

local function stopFly() nowe=false; tpwalking=false end

-- ══════════════════════════════════════
--  ESP
-- ══════════════════════════════════════
local function clearESP()
    for _, o in pairs(espObjects) do pcall(function() o:Destroy() end) end
    espObjects={}
end

local function startESP()
    espActive=true
    espConn=RunService.Heartbeat:Connect(function()
        if not espActive then clearESP(); return end
        clearESP()
        for _, p in ipairs(Players:GetPlayers()) do
            if p~=lp and p.Character then
                local root=p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,70,0,28)
                    bb.StudsOffset=Vector3.new(0,3,0); bb.AlwaysOnTop=true
                    bb.Adornee=root; bb.Parent=workspace
                    local lbl=Instance.new("TextLabel",bb); lbl.Size=UDim2.new(1,0,1,0)
                    lbl.BackgroundTransparency=1; lbl.Text=p.DisplayName
                    lbl.TextColor3=Color3.fromRGB(0,180,255); lbl.TextStrokeTransparency=0
                    lbl.TextStrokeColor3=Color3.fromRGB(0,0,0)
                    lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12
                    local hl=Instance.new("SelectionBox"); hl.Adornee=p.Character
                    hl.Color3=Color3.fromRGB(0,120,255); hl.LineThickness=0.04
                    hl.SurfaceTransparency=0.85; hl.SurfaceColor3=Color3.fromRGB(0,100,255)
                    hl.Parent=workspace
                    table.insert(espObjects,bb); table.insert(espObjects,hl)
                end
            end
        end
        -- Bed ESP
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("bed") and obj:IsA("BasePart") then
                local bb=Instance.new("BillboardGui"); bb.Size=UDim2.new(0,60,0,24)
                bb.StudsOffset=Vector3.new(0,2,0); bb.AlwaysOnTop=true
                bb.Adornee=obj; bb.Parent=workspace
                local lbl=Instance.new("TextLabel",bb); lbl.Size=UDim2.new(1,0,1,0)
                lbl.BackgroundTransparency=1; lbl.Text="🛏️ BED"
                lbl.TextColor3=Color3.fromRGB(255,80,80); lbl.TextStrokeTransparency=0
                lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12
                table.insert(espObjects,bb)
            end
        end
    end)
end

local function stopESP()
    espActive=false
    if espConn then espConn:Disconnect(); espConn=nil end
    clearESP()
end

-- ══════════════════════════════════════
--  ANTI VOID
-- ══════════════════════════════════════
local antiVoidConn=nil
local function startAntiVoid()
    antiVoidConn=RunService.Heartbeat:Connect(function()
        if not antiVoidActive then return end
        local hrp=getHRP(); if not hrp then return end
        if hrp.Position.Y < -80 then
            hrp.CFrame=CFrame.new(0,50,0)
        end
    end)
end

-- ══════════════════════════════════════
--  AUTO BUY
-- ══════════════════════════════════════
local autoBuyConn=nil
local function startAutoBuy()
    autoBuyConn=task.spawn(function()
        while autoBuyActive do
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        local n=obj.Name:lower()
                        if n:find("buy") or n:find("shop") or n:find("purchase") then
                            pcall(function()
                                if obj:IsA("RemoteFunction") then obj:InvokeServer()
                                else obj:FireServer() end
                            end)
                        end
                    end
                end
            end)
            task.wait(2)
        end
    end)
end

-- ══════════════════════════════════════
--  AUTO BRIDGE
-- ══════════════════════════════════════
local bridgeConn=nil
local function startAutoBridge()
    bridgeConn=RunService.Heartbeat:Connect(function()
        if not autoBridgeActive then return end
        pcall(function()
            local hrp=getHRP(); if not hrp then return end
            local hum=getHum(); if not hum then return end
            if hum.MoveDirection.Magnitude>0 then
                local tool=lp.Character and lp.Character:FindFirstChildOfClass("Tool")
                if tool then
                    local remote=tool:FindFirstChildOfClass("RemoteEvent")
                    if remote then remote:FireServer() end
                end
            end
        end)
    end)
end

-- respawn handler
lp.CharacterAdded:Connect(function()
    task.wait(1)
    if nowe then nowe=false; task.wait(0.1); nowe=true; startFly() end
    if espActive then stopESP(); startESP() end
    if speedActive then
        local hum=getHum(); if hum then hum.WalkSpeed=80 end
    end
end)

-- ══════════════════════════════════════
--  DESTROY OLD
-- ══════════════════════════════════════
if lp.PlayerGui:FindFirstChild("ExoHubUI") then
    lp.PlayerGui.ExoHubUI:Destroy()
end

-- ══════════════════════════════════════
--  SCREEN GUI
-- ══════════════════════════════════════
local SG=Instance.new("ScreenGui"); SG.Name="ExoHubUI"; SG.ResetOnSpawn=false
SG.DisplayOrder=999; SG.IgnoreGuiInset=true; SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
SG.Parent=lp.PlayerGui

-- ══════════════════════════════════════
--  WINDOW
-- ══════════════════════════════════════
local win=Instance.new("Frame"); win.Size=UDim2.new(0,W_W,0,0)
win.Position=UDim2.new(0.5,-(W_W/2),0.5,-(W_H/2)); win.BackgroundColor3=T.Bg
win.BorderSizePixel=0; win.ClipsDescendants=true; win.Active=true; win.Draggable=true
win.Parent=SG
Instance.new("UICorner",win).CornerRadius=UDim.new(0,12)
local wStroke=Instance.new("UIStroke",win); wStroke.Color=T.Border; wStroke.Thickness=1.2

local shimmer=Instance.new("Frame",win); shimmer.Size=UDim2.new(1,0,0,2)
shimmer.BackgroundColor3=T.Accent; shimmer.BorderSizePixel=0; shimmer.ZIndex=10
local sGrad=Instance.new("UIGradient",shimmer)
sGrad.Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.3,T.Accent),
    ColorSequenceKeypoint.new(0.7,T.AccentLight),
    ColorSequenceKeypoint.new(1,Color3.fromRGB(0,0,0)),
})
task.spawn(function()
    local t=0; while SG.Parent do
        t+=0.03; sGrad.Offset=Vector2.new(math.sin(t)*0.8,0); task.wait(0.03)
    end
end)

-- ══════════════════════════════════════
--  SIDEBAR
-- ══════════════════════════════════════
local sb=Instance.new("Frame",win); sb.Size=UDim2.new(0,SIDE_W,1,0)
sb.BackgroundColor3=T.SidebarBg; sb.BorderSizePixel=0; sb.ZIndex=2
Instance.new("UICorner",sb).CornerRadius=UDim.new(0,12)
local sbp=Instance.new("Frame",sb); sbp.Size=UDim2.new(0,12,1,0)
sbp.Position=UDim2.new(1,-12,0,0); sbp.BackgroundColor3=T.SidebarBg; sbp.BorderSizePixel=0
local sbl=Instance.new("Frame",sb); sbl.Size=UDim2.new(0,1,1,0)
sbl.Position=UDim2.new(1,0,0,0); sbl.BackgroundColor3=T.Border; sbl.BorderSizePixel=0; sbl.ZIndex=3

-- logo
local logoF=Instance.new("Frame",sb); logoF.Size=UDim2.new(1,0,0,50)
logoF.BackgroundTransparency=1; logoF.ZIndex=4
local logoImg=Instance.new("ImageLabel",logoF); logoImg.Size=UDim2.new(0,24,0,24)
logoImg.Position=UDim2.new(0,8,0.5,-12); logoImg.BackgroundTransparency=1
logoImg.Image=ICON_ID; logoImg.ZIndex=5
Instance.new("UICorner",logoImg).CornerRadius=UDim.new(0,6)
local hubTitle=Instance.new("TextLabel",logoF); hubTitle.Size=UDim2.new(1,-38,0,14)
hubTitle.Position=UDim2.new(0,36,0,10); hubTitle.BackgroundTransparency=1
hubTitle.Text="EXO HUB"; hubTitle.Font=Enum.Font.GothamBlack; hubTitle.TextSize=12
hubTitle.TextColor3=T.Text; hubTitle.TextXAlignment=Enum.TextXAlignment.Left; hubTitle.ZIndex=5
Instance.new("UIGradient",hubTitle).Color=ColorSequence.new({
    ColorSequenceKeypoint.new(0,T.AccentLight); ColorSequenceKeypoint.new(1,T.Text)
})
local discLbl=Instance.new("TextLabel",logoF); discLbl.Size=UDim2.new(1,-38,0,10)
discLbl.Position=UDim2.new(0,36,0,26); discLbl.BackgroundTransparency=1
discLbl.Text="discord.gg/6QzV9pTWs"; discLbl.Font=Enum.Font.GothamMedium; discLbl.TextSize=7
discLbl.TextColor3=T.SubText; discLbl.TextXAlignment=Enum.TextXAlignment.Left; discLbl.ZIndex=5

local ld=Instance.new("Frame",sb); ld.Size=UDim2.new(1,-10,0,1)
ld.Position=UDim2.new(0,5,0,50); ld.BackgroundColor3=T.Border; ld.BorderSizePixel=0

-- tab list
local tabScroll=Instance.new("ScrollingFrame",sb); tabScroll.Size=UDim2.new(1,0,1,-58)
tabScroll.Position=UDim2.new(0,0,0,56); tabScroll.BackgroundTransparency=1
tabScroll.BorderSizePixel=0; tabScroll.ScrollBarThickness=0
tabScroll.CanvasSize=UDim2.new(0,0,0,0); tabScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
tabScroll.ZIndex=4
local tLL=Instance.new("UIListLayout",tabScroll); tLL.SortOrder=Enum.SortOrder.LayoutOrder
tLL.Padding=UDim.new(0,2)
local tPad=Instance.new("UIPadding",tabScroll)
tPad.PaddingLeft=UDim.new(0,4); tPad.PaddingRight=UDim.new(0,4); tPad.PaddingTop=UDim.new(0,2)

-- ══════════════════════════════════════
--  CONTENT
-- ══════════════════════════════════════
local content=Instance.new("Frame",win); content.Size=UDim2.new(1,-SIDE_W,1,-36)
content.Position=UDim2.new(0,SIDE_W,0,36); content.BackgroundTransparency=1
content.ClipsDescendants=false; content.ZIndex=3

local topBarF=Instance.new("Frame",win); topBarF.Size=UDim2.new(1,-SIDE_W,0,36)
topBarF.Position=UDim2.new(0,SIDE_W,0,0); topBarF.BackgroundTransparency=1; topBarF.ZIndex=8

local pageLbl=Instance.new("TextLabel",topBarF); pageLbl.Size=UDim2.new(1,-60,1,0)
pageLbl.Position=UDim2.new(0,10,0,0); pageLbl.BackgroundTransparency=1
pageLbl.Font=Enum.Font.GothamBold; pageLbl.TextSize=12; pageLbl.TextColor3=T.SubText
pageLbl.TextXAlignment=Enum.TextXAlignment.Left; pageLbl.ZIndex=9

local hDiv=Instance.new("Frame",win); hDiv.Size=UDim2.new(1,-SIDE_W,0,1)
hDiv.Position=UDim2.new(0,SIDE_W,0,35); hDiv.BackgroundColor3=T.Border; hDiv.BorderSizePixel=0; hDiv.ZIndex=8

local function mkBtn(txt,col,xOff)
    local b=Instance.new("TextButton",topBarF); b.Size=UDim2.new(0,18,0,18)
    b.Position=UDim2.new(1,xOff,0.5,-9); b.BackgroundColor3=col; b.Text=txt
    b.TextColor3=Color3.fromRGB(200,200,210); b.Font=Enum.Font.GothamBold; b.TextSize=7
    b.BorderSizePixel=0; b.ZIndex=10; Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
    return b
end
local closeBtn=mkBtn("✕",Color3.fromRGB(180,40,55),-20)
local miniBtn=mkBtn("─",Color3.fromRGB(18,22,40),-42)
Instance.new("UIStroke",miniBtn).Color=T.Border

local mini=false
miniBtn.MouseButton1Click:Connect(function()
    mini=not mini; miniBtn.Text=mini and "+" or "─"
    TweenService:Create(win,TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{
        Size=UDim2.new(0,W_W,0,mini and 36 or W_H)
    }):Play()
end)
closeBtn.MouseButton1Click:Connect(function()
    TweenService:Create(win,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{
        Size=UDim2.new(0,W_W,0,0)
    }):Play()
    task.wait(0.3); SG:Destroy()
end)

-- ══════════════════════════════════════
--  NOTIFY
-- ══════════════════════════════════════
local function Notify(cfg)
    cfg=cfg or {}
    local n=Instance.new("Frame",SG); n.Size=UDim2.new(0,240,0,54)
    n.Position=UDim2.new(1,10,1,-68); n.BackgroundColor3=T.SidebarBg; n.BorderSizePixel=0; n.ZIndex=100
    Instance.new("UICorner",n).CornerRadius=UDim.new(0,10)
    local ns=Instance.new("UIStroke",n); ns.Color=T.Accent; ns.Thickness=1.2
    local ab=Instance.new("Frame",n); ab.Size=UDim2.new(0,3,1,-12)
    ab.Position=UDim2.new(0,6,0,6); ab.BackgroundColor3=T.Accent; ab.BorderSizePixel=0
    Instance.new("UICorner",ab).CornerRadius=UDim.new(1,0)
    local nt=Instance.new("TextLabel",n); nt.Size=UDim2.new(1,-20,0,16)
    nt.Position=UDim2.new(0,15,0,8); nt.BackgroundTransparency=1
    nt.Font=Enum.Font.GothamBold; nt.TextSize=11; nt.TextColor3=T.Text
    nt.TextXAlignment=Enum.TextXAlignment.Left; nt.ZIndex=101; nt.Text=cfg.Title or "EXO HUB"
    local nd=Instance.new("TextLabel",n); nd.Size=UDim2.new(1,-20,0,14)
    nd.Position=UDim2.new(0,15,0,28); nd.BackgroundTransparency=1
    nd.Font=Enum.Font.GothamMedium; nd.TextSize=9; nd.TextColor3=T.SubText
    nd.TextXAlignment=Enum.TextXAlignment.Left; nd.ZIndex=101; nd.Text=cfg.Content or ""
    TweenService:Create(n,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
        Position=UDim2.new(1,-250,1,-68)
    }):Play()
    task.delay(cfg.Duration or 3,function()
        TweenService:Create(n,TweenInfo.new(0.25),{Position=UDim2.new(1,10,1,-68)}):Play()
        task.wait(0.3); n:Destroy()
    end)
end

-- ══════════════════════════════════════
--  TAB + SECTION SYSTEM
-- ══════════════════════════════════════
local ICONS={sword="⚔️",zap="⚡",eye="👁",settings="⚙️",shield="🛡️",plane="✈️",
    star="⭐",target="🎯",skull="💀",fire="🔥",speed="💨",fly="🕊️",
    bed="🛏️",buy="🛒",bridge="🧱",heart="❤️",bolt="⚡",circle="●"}
local function ico(i) return ICONS[i] or "◆" end

local allTabs={}; local tabN=0; local isFirst=true

local function makeTab(cfg)
    tabN+=1; local key=tostring(tabN); local first=isFirst; isFirst=false

    local btn=Instance.new("TextButton",tabScroll); btn.Size=UDim2.new(1,0,0,28)
    btn.BackgroundColor3=Color3.fromRGB(0,0,0); btn.BackgroundTransparency=1
    btn.Text=""; btn.BorderSizePixel=0; btn.ZIndex=5; btn.LayoutOrder=tabN
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,6)

    local bIco=Instance.new("TextLabel",btn); bIco.Size=UDim2.new(0,20,1,0)
    bIco.Position=UDim2.new(0,6,0,0); bIco.BackgroundTransparency=1
    bIco.Text=ico(cfg.Icon); bIco.TextSize=12; bIco.Font=Enum.Font.GothamBold
    bIco.TextColor3=T.SubText; bIco.ZIndex=6

    local bLbl=Instance.new("TextLabel",btn); bLbl.Size=UDim2.new(1,-28,1,0)
    bLbl.Position=UDim2.new(0,26,0,0); bLbl.BackgroundTransparency=1
    bLbl.Text=cfg.Title or "Tab"; bLbl.Font=Enum.Font.GothamBold; bLbl.TextSize=10
    bLbl.TextColor3=T.SubText; bLbl.TextXAlignment=Enum.TextXAlignment.Left; bLbl.ZIndex=6

    local scroll=Instance.new("ScrollingFrame",content); scroll.Size=UDim2.new(1,0,1,0)
    scroll.BackgroundTransparency=1; scroll.BorderSizePixel=0; scroll.ScrollBarThickness=3
    scroll.ScrollBarImageColor3=T.Accent; scroll.CanvasSize=UDim2.new(0,0,0,0)
    scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y; scroll.Visible=false; scroll.ZIndex=4
    local sl=Instance.new("UIListLayout",scroll); sl.SortOrder=Enum.SortOrder.LayoutOrder; sl.Padding=UDim.new(0,4)
    local sp=Instance.new("UIPadding",scroll)
    sp.PaddingLeft=UDim.new(0,7); sp.PaddingRight=UDim.new(0,10)
    sp.PaddingTop=UDim.new(0,6); sp.PaddingBottom=UDim.new(0,6)

    allTabs[key]={btn=btn,scroll=scroll,ico=bIco,lbl=bLbl}

    local function activate()
        for k,d in pairs(allTabs) do
            local on=k==key
            TweenService:Create(d.btn,TweenInfo.new(0.15),{
                BackgroundColor3=on and T.Accent or Color3.fromRGB(0,0,0),
                BackgroundTransparency=on and 0 or 1,
            }):Play()
            TweenService:Create(d.lbl,TweenInfo.new(0.15),{TextColor3=on and Color3.fromRGB(255,255,255) or T.SubText}):Play()
            TweenService:Create(d.ico,TweenInfo.new(0.15),{TextColor3=on and Color3.fromRGB(255,255,255) or T.SubText}):Play()
            d.scroll.Visible=on
        end
        pageLbl.Text=cfg.Title or ""
    end

    btn.MouseButton1Click:Connect(activate)
    if first then activate() end

    local rowN=0
    local function mkRow(h)
        rowN+=1
        local row=Instance.new("Frame",scroll); row.Size=UDim2.new(1,0,0,h)
        row.BackgroundColor3=T.RowBg; row.BorderSizePixel=0; row.ZIndex=5; row.LayoutOrder=rowN
        Instance.new("UICorner",row).CornerRadius=UDim.new(0,8)
        local rs=Instance.new("UIStroke",row); rs.Color=T.Border; rs.Thickness=1
        return row,rs
    end

    local tObj={}

    function tObj:Section(sCfg)
        sCfg=sCfg or {}; rowN+=1
        local hdr=Instance.new("Frame",scroll); hdr.Size=UDim2.new(1,0,0,18)
        hdr.BackgroundTransparency=1; hdr.ZIndex=5; hdr.LayoutOrder=rowN*100
        local hL=Instance.new("TextLabel",hdr); hL.Size=UDim2.new(1,0,1,0)
        hL.BackgroundTransparency=1; hL.Text=(sCfg.Title or ""):upper()
        hL.Font=Enum.Font.GothamBold; hL.TextSize=8; hL.LetterSpacing=1
        hL.TextColor3=T.SecLabel; hL.TextXAlignment=Enum.TextXAlignment.Left; hL.ZIndex=6

        local sObj={}

        function sObj:Toggle(cfg)
            local row,rs=mkRow(44)
            local iL=Instance.new("TextLabel",row); iL.Size=UDim2.new(0,18,1,0)
            iL.Position=UDim2.new(0,7,0,0); iL.BackgroundTransparency=1
            iL.Text=ico(cfg.Icon); iL.TextSize=12; iL.Font=Enum.Font.GothamBold
            iL.TextColor3=T.SubText; iL.ZIndex=6
            local nL=Instance.new("TextLabel",row); nL.Size=UDim2.new(1,-62,0,14)
            nL.Position=UDim2.new(0,28,0,7); nL.BackgroundTransparency=1
            nL.Text=cfg.Title or ""; nL.Font=Enum.Font.GothamBold; nL.TextSize=11
            nL.TextColor3=T.Text; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.ZIndex=6
            local dL=Instance.new("TextLabel",row); dL.Size=UDim2.new(1,-62,0,10)
            dL.Position=UDim2.new(0,28,0,24); dL.BackgroundTransparency=1
            dL.Text=cfg.Desc or ""; dL.Font=Enum.Font.GothamMedium; dL.TextSize=8
            dL.TextColor3=T.SubText; dL.TextXAlignment=Enum.TextXAlignment.Left; dL.ZIndex=6
            local pill=Instance.new("Frame",row); pill.Size=UDim2.new(0,36,0,20)
            pill.AnchorPoint=Vector2.new(1,0.5); pill.Position=UDim2.new(1,-8,0.5,0)
            pill.BackgroundColor3=T.ToggleOff; pill.BorderSizePixel=0; pill.ZIndex=6
            Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
            local ps=Instance.new("UIStroke",pill); ps.Color=T.Border; ps.Thickness=1
            local dot=Instance.new("Frame",pill); dot.Size=UDim2.new(0,12,0,12)
            dot.AnchorPoint=Vector2.new(0.5,0.5); dot.Position=UDim2.new(0.28,0,0.5,0)
            dot.BackgroundColor3=T.SubText; dot.BorderSizePixel=0; dot.ZIndex=7
            Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
            local cb=Instance.new("TextButton",row); cb.Size=UDim2.new(1,0,1,0)
            cb.BackgroundTransparency=1; cb.Text=""; cb.ZIndex=8
            local on=cfg.Value or false
            local ti=TweenInfo.new(0.18,Enum.EasingStyle.Quart)
            local function set(v)
                on=v
                TweenService:Create(pill,ti,{BackgroundColor3=on and T.Accent or T.ToggleOff}):Play()
                TweenService:Create(ps,  ti,{Color=on and T.Accent or T.Border,Transparency=on and 0.5 or 0}):Play()
                TweenService:Create(dot, ti,{Position=on and UDim2.new(0.72,0,0.5,0) or UDim2.new(0.28,0,0.5,0),BackgroundColor3=on and Color3.fromRGB(255,255,255) or T.SubText}):Play()
                TweenService:Create(rs,  ti,{Color=on and T.Accent or T.Border,Transparency=on and 0.5 or 0}):Play()
                if cfg.Callback then cfg.Callback(on) end
            end
            if on then task.defer(function() set(true) end) end
            cb.MouseButton1Click:Connect(function() set(not on) end)
            local o={}; function o:Set(v) set(v) end; return o
        end

        function sObj:Button(cfg)
            local row,rs=mkRow(44)
            local iL=Instance.new("TextLabel",row); iL.Size=UDim2.new(0,18,1,0)
            iL.Position=UDim2.new(0,7,0,0); iL.BackgroundTransparency=1
            iL.Text=ico(cfg.Icon); iL.TextSize=12; iL.Font=Enum.Font.GothamBold
            iL.TextColor3=T.SubText; iL.ZIndex=6
            local nL=Instance.new("TextLabel",row); nL.Size=UDim2.new(1,-52,0,14)
            nL.Position=UDim2.new(0,28,0,7); nL.BackgroundTransparency=1
            nL.Text=cfg.Title or ""; nL.Font=Enum.Font.GothamBold; nL.TextSize=11
            nL.TextColor3=T.Text; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.ZIndex=6
            local dL=Instance.new("TextLabel",row); dL.Size=UDim2.new(1,-52,0,10)
            dL.Position=UDim2.new(0,28,0,24); dL.BackgroundTransparency=1
            dL.Text=cfg.Desc or ""; dL.Font=Enum.Font.GothamMedium; dL.TextSize=8
            dL.TextColor3=T.SubText; dL.TextXAlignment=Enum.TextXAlignment.Left; dL.ZIndex=6
            local ib=Instance.new("Frame",row); ib.Size=UDim2.new(0,20,0,20)
            ib.AnchorPoint=Vector2.new(1,0.5); ib.Position=UDim2.new(1,-8,0.5,0)
            ib.BackgroundColor3=T.ToggleOff; ib.BorderSizePixel=0; ib.ZIndex=6
            Instance.new("UICorner",ib).CornerRadius=UDim.new(0,5)
            Instance.new("UIStroke",ib).Color=T.Border
            local il=Instance.new("TextLabel",ib); il.Size=UDim2.new(1,0,1,0)
            il.BackgroundTransparency=1; il.Text="▶"; il.TextSize=7
            il.Font=Enum.Font.GothamBold; il.TextColor3=T.Accent; il.ZIndex=7
            local cb=Instance.new("TextButton",row); cb.Size=UDim2.new(1,0,1,0)
            cb.BackgroundTransparency=1; cb.Text=""; cb.ZIndex=8
            cb.MouseButton1Click:Connect(function()
                TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=T.RowHover}):Play()
                task.wait(0.12)
                TweenService:Create(row,TweenInfo.new(0.15),{BackgroundColor3=T.RowBg}):Play()
                if cfg.Callback then cfg.Callback() end
            end)
        end

        function sObj:Slider(cfg)
            local row,rs=mkRow(52)
            local iL=Instance.new("TextLabel",row); iL.Size=UDim2.new(0,18,0,18)
            iL.Position=UDim2.new(0,7,0,7); iL.BackgroundTransparency=1
            iL.Text=ico(cfg.Icon); iL.TextSize=12; iL.Font=Enum.Font.GothamBold
            iL.TextColor3=T.SubText; iL.ZIndex=6
            local nL=Instance.new("TextLabel",row); nL.Size=UDim2.new(1,-56,0,14)
            nL.Position=UDim2.new(0,28,0,7); nL.BackgroundTransparency=1
            nL.Text=cfg.Title or ""; nL.Font=Enum.Font.GothamBold; nL.TextSize=11
            nL.TextColor3=T.Text; nL.TextXAlignment=Enum.TextXAlignment.Left; nL.ZIndex=6
            local vL=Instance.new("TextLabel",row); vL.Size=UDim2.new(0,40,0,14)
            vL.Position=UDim2.new(1,-46,0,7); vL.BackgroundTransparency=1
            vL.Text=tostring(cfg.Value or cfg.Min or 0); vL.Font=Enum.Font.GothamBold
            vL.TextSize=11; vL.TextColor3=T.Accent; vL.TextXAlignment=Enum.TextXAlignment.Right; vL.ZIndex=6
            local track=Instance.new("Frame",row); track.Size=UDim2.new(1,-20,0,4)
            track.Position=UDim2.new(0,10,0,38); track.BackgroundColor3=T.ToggleOff
            track.BorderSizePixel=0; track.ZIndex=6
            Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
            local mn,mx=cfg.Min or 0,cfg.Max or 100
            local pct=((cfg.Value or mn)-mn)/(mx-mn)
            local fill=Instance.new("Frame",track); fill.Size=UDim2.new(pct,0,1,0)
            fill.BackgroundColor3=T.Accent; fill.BorderSizePixel=0; fill.ZIndex=7
            Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
            Instance.new("UIGradient",fill).Color=ColorSequence.new({
                ColorSequenceKeypoint.new(0,T.Accent); ColorSequenceKeypoint.new(1,T.AccentLight)
            })
            local thumb=Instance.new("Frame",track); thumb.Size=UDim2.new(0,12,0,12)
            thumb.AnchorPoint=Vector2.new(0.5,0.5); thumb.Position=UDim2.new(pct,0,0.5,0)
            thumb.BackgroundColor3=Color3.fromRGB(220,235,255); thumb.BorderSizePixel=0; thumb.ZIndex=8
            Instance.new("UICorner",thumb).CornerRadius=UDim.new(1,0)
            local drag=false
            thumb.InputBegan:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if not drag then return end
                if i.UserInputType~=Enum.UserInputType.MouseMovement and i.UserInputType~=Enum.UserInputType.Touch then return end
                local rel=math.clamp((i.Position.X-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
                local val=math.floor(mn+rel*(mx-mn))
                fill.Size=UDim2.new(rel,0,1,0); thumb.Position=UDim2.new(rel,0,0.5,0)
                vL.Text=tostring(val)
                if cfg.Callback then cfg.Callback(val) end
            end)
        end

        return sObj
    end

    return tObj
end

-- ══════════════════════════════════════
--  OPEN ANIMATION
-- ══════════════════════════════════════
TweenService:Create(win,TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{
    Size=UDim2.new(0,W_W,0,W_H)
}):Play()

-- ══════════════════════════════════════
--  TABS
-- ══════════════════════════════════════
local CombatTab  = makeTab({Title="Combat",   Icon="sword"})
local MoveTab    = makeTab({Title="Movement", Icon="fly"})
local VisTab     = makeTab({Title="Visuals",  Icon="eye"})
local MiscTab    = makeTab({Title="Misc",     Icon="settings"})

-- ── COMBAT ──
local C1=CombatTab:Section({Title="Combat"})
C1:Toggle({Title="Auto Buy",    Desc="Auto buys from shop",    Icon="buy",    Value=false, Callback=function(s)
    autoBuyActive=s
    if s then startAutoBuy() end
    Notify({Title="EXO HUB", Content="Auto Buy: "..(s and "ON 🔥" or "OFF"), Duration=2})
end})
C1:Toggle({Title="Auto Bridge", Desc="Auto places blocks",     Icon="bridge", Value=false, Callback=function(s)
    autoBridgeActive=s
    if s then startAutoBridge() else if bridgeConn then bridgeConn:Disconnect() end end
    Notify({Title="EXO HUB", Content="Auto Bridge: "..(s and "ON 🔥" or "OFF"), Duration=2})
end})
C1:Button({Title="Destroy Bed", Desc="Teleport to enemy bed", Icon="bed", Callback=function()
    local hrp=getHRP(); if not hrp then return end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("bed") and obj:IsA("BasePart") then
            hrp.CFrame=obj.CFrame+Vector3.new(0,5,0)
            Notify({Title="EXO HUB", Content="Teleported to bed! 🛏️", Duration=2})
            break
        end
    end
end})

-- ── MOVEMENT ──
local M1=MoveTab:Section({Title="Movement"})
M1:Toggle({Title="Fly",        Desc="Fly around the map",  Icon="fly",   Value=false, Callback=function(s)
    nowe=s
    if s then startFly() else stopFly() end
    Notify({Title="EXO HUB", Content="Fly: "..(s and "ON 🔥" or "OFF"), Duration=2})
end})
M1:Toggle({Title="Speed Hack", Desc="Boost your speed",    Icon="speed", Value=false, Callback=function(s)
    speedActive=s
    local hum=getHum()
    if hum then hum.WalkSpeed=s and 80 or 16 end
    Notify({Title="EXO HUB", Content="Speed: "..(s and "ON 🔥" or "OFF"), Duration=2})
end})
M1:Toggle({Title="Anti Void",  Desc="Prevents falling off", Icon="shield",Value=false, Callback=function(s)
    antiVoidActive=s
    if s then startAntiVoid() end
    Notify({Title="EXO HUB", Content="Anti Void: "..(s and "ON 🔥" or "OFF"), Duration=2})
end})
M1:Slider({Title="Fly Speed", Icon="bolt", Min=10, Max=200, Value=50, Callback=function(v)
    flySpeed=v
end})

-- ── VISUALS ──
local V1=VisTab:Section({Title="ESP"})
V1:Toggle({Title="Player ESP", Desc="See players + beds",  Icon="eye",    Value=false, Callback=function(s)
    if s then startESP() else stopESP() end
    Notify({Title="EXO HUB", Content="ESP: "..(s and "ON 🔥" or "OFF"), Duration=2})
end})
V1:Toggle({Title="Bed ESP",    Desc="Highlight all beds",  Icon="bed",    Value=false, Callback=function(s)
    espActive=s
    if s then startESP() else stopESP() end
end})

-- ── MISC ──
local Mc1=MiscTab:Section({Title="Misc"})
Mc1:Button({Title="Rejoin",      Desc="Rejoin the server",   Icon="bolt",   Callback=function()
    game:GetService("TeleportService"):Teleport(game.PlaceId,lp)
end})
Mc1:Button({Title="Spawn TP",    Desc="Go to your island",   Icon="target", Callback=function()
    local hrp=getHRP(); if hrp then hrp.CFrame=CFrame.new(0,50,0) end
    Notify({Title="EXO HUB", Content="Teleported to spawn!", Duration=2})
end})
Mc1:Button({Title="Join Discord", Desc="discord.gg/6QzV9pTWs", Icon="star", Callback=function()
    Notify({Title="EXO HUB", Content="discord.gg/6QzV9pTWs 🔥", Duration=4})
end})

task.wait(0.5)
Notify({Title="EXO HUB", Content="Bedwars loaded! 🔥 discord.gg/6QzV9pTWs", Duration=4})
print("[EXO HUB] Bedwars | discord.gg/6QzV9pTWs")
