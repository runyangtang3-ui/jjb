local WasUIPro = loadstring(game:HttpGet("https://github.com/WasKKal/WasUI-For-Roblox/raw/refs/heads/main/test.lua"))()
local v1 = game:GetService("UserInputService")
local v2 = game:GetService("Players")
local v3 = game:GetService("RunService")
local v4 = game:GetService("Lighting")
local v5 = game:GetService("ReplicatedStorage")
local v6 = game:GetService("Workspace")

WasUIPro:SetDefaultTheme("Dark")
WasUIPro:SetLanguage("中文")

local mainWindow = WasUIPro:CreateWindow({
    Title = "TrashHub-死亡轨迹",
    WelcomeText = "欢迎使用 TrashHub-死亡轨迹",
    MinimizedText = "TrashHub",
    Theme = "Dark",
    RainbowMode = "流动",
    DialogTitle = "确认关闭 TrashHub?",
    GroupText = "加入 TrashHub 主群",
    GroupCopy = "786284990",
    TitleTag = {
        { text = "齐楚乾", backgroundColor = Color3.fromRGB(255,80,80), textColor = Color3.fromRGB(255,255,255) },
        { text = "Was", backgroundColor = Color3.fromRGB(0,152,211), textColor = Color3.fromRGB(255,255,255) }
    }
})

local t1 = mainWindow:Tab({ Title = "刷物品" })
local t2 = mainWindow:Tab({ Title = "自动功能" })
local t3 = mainWindow:Tab({ Title = "杀戮光环" })
local t4 = mainWindow:Tab({ Title = "视觉功能" })

local c1 = t1:Category({ Title = "刷物品", IconName = "package" })
local c2 = t2:Category({ Title = "自动功能", IconName = "cpu" })
local c3 = t3:Category({ Title = "杀戮光环", IconName = "sword" })
local c4 = t4:Category({ Title = "视觉功能", IconName = "eye" })

local r1 = false
local r2 = nil
local r3 = false
local r4 = nil
local r5 = false
local r6 = nil
local r7 = false
local r8 = nil
local r9 = false
local r10 = nil
local r11 = {}
local r12 = false
local r13 = nil
local r14 = nil
local r15 = false
local r16 = nil
local r17 = false
local r18 = nil
local r19 = false
local r20 = nil
local r21 = false
local r22 = nil
local r23 = false
local r24 = nil

c1:Toggle({
    Title = "无限刷物品",
    Value = false,
    FeatureName = "AutoPickup",
    Icon = "rotate-cw",
    ConfigKey = "auto_pickup",
    Callback = function(s)
        r1 = s
        if r1 then
            r2 = v3.Heartbeat:Connect(function()
                if not r1 then if r2 then r2:Disconnect() r2 = nil end return end
                local p = v2.LocalPlayer
                local c = p.Character
                if not c then return end
                local hrp = c:FindFirstChild("HumanoidRootPart")
                if not hrp then return end
                local om = v6:FindFirstChild("ObjectModels")
                if not om then return end
                local models = om:GetChildren()
                local closest = nil
                local dist = math.huge
                for _, m in ipairs(models) do
                    if m:IsA("Model") then
                        local es = m:GetAttribute("entity_server")
                        if es and type(es) == "number" then
                            local pos = m:GetPivot().Position
                            local d = (hrp.Position - pos).Magnitude
                            if d < dist then dist = d; closest = m end
                        end
                    end
                end
                if closest then
                    local es = closest:GetAttribute("entity_server")
                    v5:WaitForChild("Shared"):WaitForChild("Universe"):WaitForChild("Network"):WaitForChild("RemoteEvent"):WaitForChild("Pickup"):FireServer(es)
                end
            end)
        else
            if r2 then r2:Disconnect() r2 = nil end
        end
    end
})

c2:Toggle({
    Title = "自动拾取物品",
    Value = false,
    FeatureName = "AutoActionable",
    Icon = "package",
    ConfigKey = "auto_actionable",
    Callback = function(s)
        r3 = s
        if r3 then
            r4 = task.spawn(function()
                while r3 do
                    local p = v2.LocalPlayer
                    local c = p.Character
                    if c then
                        local hrp = c:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local om = v6:FindFirstChild("ObjectModels")
                            if om then
                                local models = om:GetChildren()
                                local closest = nil
                                local dist = math.huge
                                local es = nil
                                for _, m in ipairs(models) do
                                    if m:IsA("Model") then
                                        local e = m:GetAttribute("entity_server")
                                        if e and type(e) == "number" then
                                            local pos = m:GetPivot().Position
                                            local d = (hrp.Position - pos).Magnitude
                                            if d < dist then dist = d; closest = m; es = e end
                                        end
                                    end
                                end
                                if closest then
                                    v5:WaitForChild("Shared"):WaitForChild("Universe"):WaitForChild("Network"):WaitForChild("RemoteEvent"):WaitForChild("Actionable"):FireServer(es)
                                end
                            end
                        end
                    end
                    task.wait(0.05)
                end
            end)
        else
            r3 = false
            if r4 then coroutine.close(r4); r4 = nil end
        end
    end
})

c3:Toggle({
    Title = "近战杀戮光环",
    Value = false,
    FeatureName = "MeleeAura",
    Icon = "sword",
    ConfigKey = "melee_aura",
    Callback = function(s)
        r5 = s
        if r5 then
            r6 = task.spawn(function()
                while r5 do
                    local p = v2.LocalPlayer
                    local c = p.Character
                    if c then
                        local tool = c:FindFirstChildWhichIsA("Tool")
                        if tool then
                            local args = { tool, 1775247516.34581, vector.create(-0.3535350263118744, -0.4776463210582733, 0.8042804002761841) }
                            v5:WaitForChild("Shared"):WaitForChild("Universe"):WaitForChild("Network"):WaitForChild("RemoteEvent"):WaitForChild("SwingMelee"):FireServer(unpack(args))
                        end
                    end
                    task.wait(0.05)
                end
            end)
        else
            r5 = false
            if r6 then coroutine.close(r6); r6 = nil end
        end
    end
})

c4:Toggle({
    Title = "无雾效果",
    Value = false,
    FeatureName = "NoFog",
    Icon = "eye-off",
    ConfigKey = "no_fog",
    Callback = function(s)
        r7 = s
        if r7 then
            r8 = task.spawn(function()
                while r7 do
                    pcall(function()
                        v4.FogStart = 100000
                        v4.FogEnd = 200000
                        v4.FogColor = Color3.fromRGB(0,0,0)
                        for _, v in pairs(v4:GetChildren()) do
                            if v.ClassName == 'Atmosphere' then
                                v.Density = 0
                                v.Haze = 0
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        else
            r7 = false
            if r8 then coroutine.close(r8); r8 = nil end
            pcall(function()
                v4.FogStart = 0
                v4.FogEnd = 1000
                for _, v in pairs(v4:GetChildren()) do
                    if v.ClassName == 'Atmosphere' then
                        v.Density = 0.3
                        v.Haze = 1
                    end
                end
            end)
        end
    end
})

c4:Toggle({
    Title = "夜视",
    Value = false,
    FeatureName = "FullBright",
    Icon = "sun",
    ConfigKey = "full_bright",
    Callback = function(s)
        r9 = s
        if r9 then
            r11 = {
                Brightness = v4.Brightness,
                ClockTime = v4.ClockTime,
                FogEnd = v4.FogEnd,
                GlobalShadows = v4.GlobalShadows,
                OutdoorAmbient = v4.OutdoorAmbient,
            }
            r10 = task.spawn(function()
                while r9 do
                    pcall(function()
                        v4.Brightness = 2
                        v4.ClockTime = 14
                        v4.FogEnd = 100000
                        v4.GlobalShadows = false
                        v4.OutdoorAmbient = Color3.fromRGB(128,128,128)
                        if v4:FindFirstChild("Sky") then v4.Sky:Destroy() end
                    end)
                    task.wait(0.5)
                end
            end)
        else
            r9 = false
            if r10 then coroutine.close(r10); r10 = nil end
            pcall(function()
                for k, v in pairs(r11) do v4[k] = v end
            end)
        end
    end
})

c4:Toggle({
    Title = "迷你世界画质",
    Value = false,
    FeatureName = "FPSBoost",
    Icon = "zap",
    ConfigKey = "fps_boost",
    Callback = function(s)
        r12 = s
        if r12 then
            r13 = task.spawn(function()
                local Terrain = v6:FindFirstChildOfClass('Terrain')
                if Terrain then
                    Terrain.WaterWaveSize = 0
                    Terrain.WaterWaveSpeed = 0
                    Terrain.WaterReflectance = 0
                    Terrain.WaterTransparency = 1
                end
                v4.GlobalShadows = false
                v4.FogEnd = 9e9
                v4.FogStart = 9e9
                pcall(function() settings().Rendering.QualityLevel = 1 end)
                for i, v in pairs(game:GetDescendants()) do
                    if v:IsA("BasePart") then
                        v.Material = "Plastic"
                        v.Reflectance = 0
                    elseif v:IsA("Decal") then
                        v.Transparency = 1
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                        v.Lifetime = NumberRange.new(0)
                    end
                end
                for i, v in pairs(v4:GetDescendants()) do
                    if v:IsA("PostEffect") then
                        v.Enabled = false
                    end
                end
                r14 = v6.DescendantAdded:Connect(function(child)
                    task.spawn(function()
                        if r12 and (child:IsA('ForceField') or child:IsA('Sparkles') or child:IsA('Smoke') or child:IsA('Fire') or child:IsA('Beam')) then
                            v3.Heartbeat:Wait()
                            child:Destroy()
                        end
                    end)
                end)
            end)
        else
            r12 = false
            if r14 then r14:Disconnect(); r14 = nil end
            if r13 then coroutine.close(r13); r13 = nil end
            pcall(function()
                local Terrain = v6:FindFirstChildOfClass('Terrain')
                if Terrain then
                    Terrain.WaterWaveSize = 0.5
                    Terrain.WaterWaveSpeed = 0.5
                    Terrain.WaterReflectance = 0.2
                    Terrain.WaterTransparency = 0.7
                end
                v4.GlobalShadows = true
                v4.FogEnd = 1000
                v4.FogStart = 0
                settings().Rendering.QualityLevel = 4
            end)
        end
    end
})

c4:Toggle({
    Title = "时间显示",
    Value = false,
    FeatureName = "TimeDisplay",
    Icon = "clock",
    ConfigKey = "time_display",
    Callback = function(s)
        r15 = s
        if r15 then
            r16 = task.spawn(function()
                local gui = Instance.new("ScreenGui")
                gui.Name = "TimeDial_Monitor"
                gui.Parent = (gethui and gethui()) or v2.LocalPlayer:WaitForChild("PlayerGui")
                gui.ResetOnSpawn = false
                local frame = Instance.new("Frame")
                frame.Size = UDim2.new(0,160,0,45)
                frame.Position = UDim2.new(0.5,-80,0,50)
                frame.BackgroundColor3 = Color3.fromRGB(15,15,15)
                frame.BackgroundTransparency = 0.2
                frame.BorderSizePixel = 0
                frame.Parent = gui
                Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)
                Instance.new("UIStroke", frame).Thickness = 1.5
                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1,0,1,0)
                label.BackgroundTransparency = 1
                label.TextColor3 = Color3.fromRGB(255,255,255)
                label.Font = Enum.Font.GothamBold
                label.TextSize = 20
                label.Text = "等待加载..."
                label.Parent = frame
                local dragging, dragStart, startPos
                frame.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragStart = input.Position
                        startPos = frame.Position
                    end
                end)
                v1.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local delta = input.Position - dragStart
                        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    end
                end)
                v1.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                while r15 do
                    pcall(function()
                        local target = v6:FindFirstChild("default")
                        if target then
                            target = target:FindFirstChild("RequiredComponents")
                            if target then
                                target = target:FindFirstChild("Controls")
                                if target then
                                    target = target:FindFirstChild("TimeDial")
                                    if target then
                                        target = target:FindFirstChild("SurfaceGui")
                                        if target then
                                            target = target:FindFirstChild("TextLabel")
                                            if target then
                                                label.Text = "Time " .. target.Text
                                                local ts = target.Text
                                                if ts:find("0:") then
                                                    local secs = tonumber(ts:match(":(%d+)"))
                                                    if secs and secs <= 30 then
                                                        label.TextColor3 = Color3.fromRGB(255,80,80)
                                                    else
                                                        label.TextColor3 = Color3.fromRGB(255,255,255)
                                                    end
                                                else
                                                    label.TextColor3 = Color3.fromRGB(255,255,255)
                                                end
                                            else
                                                label.Text = "未找到 TextLabel"
                                            end
                                        else
                                            label.Text = "未找到 SurfaceGui"
                                        end
                                    else
                                        label.Text = "未找到 TimeDial"
                                    end
                                else
                                    label.Text = "未找到 Controls"
                                end
                            else
                                label.Text = "未找到 RequiredComponents"
                            end
                        else
                            label.Text = "未找到 default"
                        end
                    end)
                    task.wait(0.1)
                end
            end)
        else
            r15 = false
            if r16 then coroutine.close(r16); r16 = nil end
            local gui = (gethui and gethui() or v2.LocalPlayer:FindFirstChild("PlayerGui")):FindFirstChild("TimeDial_Monitor")
            if gui then gui:Destroy() end
        end
    end
})

c4:Toggle({
    Title = "区域物品清单",
    Value = false,
    FeatureName = "AreaList",
    Icon = "list",
    ConfigKey = "area_list",
    Callback = function(s)
        r17 = s
        if r17 then
            r18 = task.spawn(function()
                local gui = Instance.new("ScreenGui")
                gui.Name = "Area_Resource_List"
                gui.Parent = (gethui and gethui()) or v2.LocalPlayer:WaitForChild("PlayerGui")
                gui.ResetOnSpawn = false
                local btn = Instance.new("TextButton")
                btn.Parent = gui
                btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
                btn.Position = UDim2.new(0.1,0,0.5,0)
                btn.Size = UDim2.new(0,140,0,40)
                btn.Text = "区域清单: 关"
                btn.TextColor3 = Color3.fromRGB(255,255,255)
                btn.Font = Enum.Font.SourceSansBold
                btn.TextSize = 14
                Instance.new("UICorner", btn)
                local espFolder = nil
                local showList = false
                local function updateList()
                    if espFolder then espFolder:Destroy() end
                    if not showList then return end
                    local root = v6:FindFirstChild("ObjectModels")
                    if not root or #root:GetChildren() == 0 then return end
                    espFolder = Instance.new("Folder")
                    espFolder.Name = "Area_ESP_Folder"
                    espFolder.Parent = game:GetService("CoreGui")
                    local stats = {}
                    local firstObj = nil
                    for _, obj in ipairs(root:GetChildren()) do
                        if not firstObj then firstObj = obj end
                        stats[obj.Name] = (stats[obj.Name] or 0) + 1
                    end
                    local anchor = firstObj:IsA("BasePart") and firstObj or (firstObj.PrimaryPart or firstObj:FindFirstChildOfClass("BasePart", true))
                    if not anchor then return end
                    local bill = Instance.new("BillboardGui")
                    bill.Name = "GlobalList"
                    bill.AlwaysOnTop = true
                    bill.Size = UDim2.new(0,200,0,300)
                    bill.Adornee = anchor
                    bill.MaxDistance = 20000
                    bill.ExtentsOffset = Vector3.new(0,5,0)
                    bill.Parent = espFolder
                    local f = Instance.new("Frame")
                    f.Size = UDim2.new(1,0,1,0)
                    f.BackgroundTransparency = 1
                    f.Parent = bill
                    local layout = Instance.new("UIListLayout")
                    layout.Parent = f
                    layout.SortOrder = Enum.SortOrder.LayoutOrder
                    layout.Padding = UDim.new(0,2)
                    local title = Instance.new("TextLabel")
                    title.Size = UDim2.new(1,0,0,20)
                    title.BackgroundColor3 = Color3.fromRGB(0,0,0)
                    title.BackgroundTransparency = 0.3
                    title.Text = "--- 区域物品清单 ---"
                    title.TextColor3 = Color3.fromRGB(255,215,0)
                    title.Font = Enum.Font.SourceSansBold
                    title.TextSize = 14
                    title.Parent = f
                    Instance.new("UICorner", title)
                    for name, count in pairs(stats) do
                        local row = Instance.new("TextLabel")
                        row.Size = UDim2.new(1,0,0,18)
                        row.BackgroundColor3 = Color3.fromRGB(20,20,20)
                        row.BackgroundTransparency = 0.5
                        row.Text = string.format(" %s x%d", name, count)
                        row.TextColor3 = Color3.fromRGB(255,255,255)
                        row.TextXAlignment = Enum.TextXAlignment.Left
                        row.Font = Enum.Font.SourceSans
                        row.TextSize = 13
                        row.Parent = f
                        Instance.new("UICorner", row)
                    end
                end
                btn.MouseButton1Click:Connect(function()
                    showList = not showList
                    btn.Text = showList and "区域清单: 开" or "区域清单: 关"
                    btn.TextColor3 = showList and Color3.fromRGB(0,255,127) or Color3.fromRGB(255,255,255)
                    updateList()
                end)
                local dragging, dragStart, startPos
                btn.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        dragStart = input.Position
                        startPos = btn.Position
                    end
                end)
                v1.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local delta = input.Position - dragStart
                        btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                    end
                end)
                v1.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)
                while r17 do
                    if showList then updateList() end
                    task.wait(3)
                end
            end)
        else
            r17 = false
            if r18 then coroutine.close(r18); r18 = nil end
            local gui = (gethui and gethui() or v2.LocalPlayer:FindFirstChild("PlayerGui")):FindFirstChild("Area_Resource_List")
            if gui then gui:Destroy() end
            local folder = game:GetService("CoreGui"):FindFirstChild("Area_ESP_Folder")
            if folder then folder:Destroy() end
        end
    end
})

c4:Toggle({
    Title = "穿墙",
    Value = false,
    FeatureName = "Noclip",
    Icon = "move",
    ConfigKey = "noclip",
    Callback = function(s)
        r19 = s
        if r19 then
            r20 = v3.Heartbeat:Connect(function()
                local p = v2.LocalPlayer
                local c = p.Character
                if c then
                    for _, part in ipairs(c:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if r20 then r20:Disconnect(); r20 = nil end
            local p = v2.LocalPlayer
            local c = p.Character
            if c then
                for _, part in ipairs(c:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})

c4:Toggle({
    Title = "删除天空盒",
    Value = false,
    FeatureName = "RemoveSky",
    Icon = "cloud-off",
    ConfigKey = "remove_sky",
    Callback = function(s)
        r21 = s
        if r21 then
            r22 = task.spawn(function()
                while r21 do
                    pcall(function()
                        local sky = v4:FindFirstChild("Sky")
                        if sky then sky:Destroy() end
                        local stars = v4:FindFirstChild("Stars")
                        if stars then stars:Destroy() end
                        local sunRays = v4:FindFirstChild("SunRays")
                        if sunRays then sunRays:Destroy() end
                        local skybox = v4:FindFirstChild("Skybox")
                        if skybox then skybox:Destroy() end
                    end)
                    task.wait(1)
                end
            end)
        else
            r21 = false
            if r22 then coroutine.close(r22); r22 = nil end
            pcall(function()
                if not v4:FindFirstChild("Sky") then
                    local sky = Instance.new("Sky")
                    sky.Parent = v4
                end
            end)
        end
    end
})

local vis = true
v1.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        vis = not vis
        mainWindow:SetVisible(vis)
    end
end)

WasUIPro:Notify({ Title = "TrashHub", Content = "加载完成", Duration = 3 })