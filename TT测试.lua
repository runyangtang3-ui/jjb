
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

local Gun = require(ReplicatedStorage.Modules.Client.Controllers.GunController)
local BulletController = require(ReplicatedStorage.Modules.Client.Controllers.BulletController)
local SpreadUtil = require(ReplicatedStorage.Modules.Shared.SpreadUtil)

local LocalPlayer = Players.LocalPlayer
local target, targetPart
local isShooting = false
local lastShotTime = 0

-- 共享运行时功能开关
local settings = {
    silentAim = false,
    autoShoot = false,
    infiniteAmmo = false,
    fireRate = 0.1,             -- 射击间隔（秒），0.1 = 每秒10发
    fov = 120,
    fovCircle = false,
    maxDist = 2000,
    wallcheck = false,
    espEnabled = false,
    rainbowSpeed = 0.5,
    tracerOrigin = "Bottom"
}

-- 初始化 Rayfield Gen2 UI 库（与模板直接匹配）
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/gen2"))()
local window = Rayfield:CreateWindow({
    name = "TTK Testing",
    subtitle = "By luhscripter",
})

-- 标签页 1：主要功能设置
local mainTab = window:CreateTab({ name = "Main", icon = 93364949241311 })

mainTab:CreateToggle({
    name = "静默自瞄",
    callback = function(value) settings.silentAim = value end,
})

mainTab:CreateToggle({
    name = "自动射击（触发机器人）",
    callback = function(value) settings.autoShoot = value end,
})

mainTab:CreateToggle({
    name = "无限弹药",
    callback = function(value) settings.infiniteAmmo = value end,
})

mainTab:CreateToggle({
    name = "墙壁检测",
    callback = function(value) settings.wallcheck = value end,
})

mainTab:CreateSlider({
    name = "射击速度（秒/发）",
    range = {0.01, 1},
    increment = 0.01,
    default = settings.fireRate,
    callback = function(value) settings.fireRate = value end,
})

-- 标签页 2：视觉配置设置
local visualsTab = window:CreateTab({ name = "Visuals", icon = 4370345699 })

visualsTab:CreateToggle({
    name = "详细 ESP 透视",
    callback = function(value) settings.espEnabled = value end,
})

visualsTab:CreateToggle({
    name = "显示自瞄范围圈",
    callback = function(value) settings.fovCircle = value end,
})

visualsTab:CreateSlider({
    name = "自瞄范围半径",
    range = {10, 600},
    increment = 5,
    default = settings.fov,
    callback = function(value) settings.fov = value end,
})

visualsTab:CreateDropdown({
    name = "追踪线屏幕起点",
    options = {"Bottom", "Center", "Top"},
    callback = function(value) settings.tracerOrigin = value end,
})

visualsTab:CreateSlider({
    name = "彩虹颜色变化速度",
    range = {0.1, 2},
    increment = 0.1,
    default = settings.rainbowSpeed,
    callback = function(value) settings.rainbowSpeed = value end,
})

-- 骨骼映射
local R15_BONES = {
    {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"},
    {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"},
    {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}
local R6_BONES = {
    {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}

local sg = LocalPlayer.PlayerGui:FindFirstChild("ScreenGui")
if sg and sg:FindFirstChild("LocalScript") then
    sg.LocalScript:Destroy()
end

local CameraPOV
pcall(function() CameraPOV = require(ReplicatedStorage.Modules.Client.CameraPOV) end)

local fovCircle = Drawing.new("Circle")
fovCircle.Filled = false
fovCircle.Thickness = 1
fovCircle.Color = Color3.new(1, 1, 1)

local espCache = {}
local function getEspDrawings(player)
    if espCache[player] then return espCache[player] end
    local box = Drawing.new("Square")
    box.Thickness = 1; box.Filled = false; box.Visible = false
    local text = Drawing.new("Text")
    text.Size = 16; text.Center = false; text.Outline = true; text.Visible = false
    local tracer = Drawing.new("Line")
    tracer.Thickness = 1; tracer.Visible = false
    local skeletonLines = {}
    for i = 1, #R15_BONES do
        local line = Drawing.new("Line")
        line.Thickness = 1; line.Visible = false
        table.insert(skeletonLines, line)
    end
    espCache[player] = {Box = box, Text = text, Tracer = tracer, Skeleton = skeletonLines}
    return espCache[player]
end

Players.PlayerRemoving:Connect(function(player)
    if espCache[player] then
        espCache[player].Box:Remove(); espCache[player].Text:Remove(); espCache[player].Tracer:Remove()
        for _, line in ipairs(espCache[player].Skeleton) do line:Remove() end
        espCache[player] = nil
    end
end)

-- 无限弹药 Hook 设置
local hf = hookfunction
local nc = newcclosure or function(f) return f end
local cf = clonefunction or function(f) return f end

local function keepAmmo(weapon)
    if type(weapon) ~= "table" or not settings.infiniteAmmo then return end
    local max = weapon.MaxMagSize or 30
    weapon.AmmoType = "none"
    weapon.MagAmmo = max + 1
    if weapon._magazines then
        for i = 1, #weapon._magazines do weapon._magazines[i] = max end
    end
end

if hf then
    local ok, FS = pcall(require, ReplicatedStorage.Modules.Shared.FirearmState)
    if ok and FS.Fire then
        local origFire = cf(FS.Fire)
        hf(FS.Fire, nc(function(self, ...)
            if type(self) == "table" then keepAmmo(self) end
            local result = origFire(self, ...)
            if type(self) == "table" then keepAmmo(self) end
            return result
        end))
    end
    if ok and type(FS.GetReserve) == "function" then
        local origReserve = cf(FS.GetReserve)
        hf(FS.GetReserve, nc(function(self, ...)
            local reserve = origReserve(self, ...)
            if settings.infiniteAmmo and type(self) == "table" and reserve <= 0 then return 9999 end
            return reserve
        end))
    end
    local okAP, AP = pcall(require, ReplicatedStorage.Modules.Shared.AmmoPool)
    if okAP and type(AP.ConsumeAmmo) == "function" then
        local origConsume = cf(AP.ConsumeAmmo)
        hf(AP.ConsumeAmmo, nc(function(pool, ammoType, amount, ...)
            if settings.infiniteAmmo then return amount or 1 end
            return origConsume(pool, ammoType, amount, ...)
        end))
    end
end
keepAmmo(Gun.Weapon)
local wallParams = RaycastParams.new()
wallParams.FilterType = Enum.RaycastFilterType.Exclude
wallParams.IgnoreWater = true

local discharge = BulletController.Discharge
BulletController.Discharge = function(self, weapon, eyePos, fireDir, muzzleCf, ...)
    if settings.silentAim and (Gun.FireHeld or isShooting) and target then
        local origin = muzzleCf and muzzleCf.Position or eyePos or Gun:GetMuzzleWorldCFrame().Position
        fireDir = (target - origin).Unit
        local ret = { discharge(self, weapon, eyePos, fireDir, muzzleCf, ...) }
        return table.unpack(ret)
    end
    return discharge(self, weapon, eyePos, fireDir, muzzleCf, ...)
end

local randomCone = SpreadUtil.RandomConeDirection
SpreadUtil.RandomConeDirection = function(dir, ...)
    if settings.silentAim and (Gun.FireHeld or isShooting) and target then
        return dir
    end
    return randomCone(dir, ...)
end

RunService.PreRender:Connect(function()
    if settings.infiniteAmmo and (Gun.FireHeld or isShooting) then
        keepAmmo(Gun.Weapon)
    end

    target, targetPart = nil, nil
    local camera = workspace.CurrentCamera
    local center = camera.ViewportSize / 2
    
    local tracerFrom = Vector2.new(center.X, camera.ViewportSize.Y)
    if settings.tracerOrigin == "Center" then
        tracerFrom = center
    elseif settings.tracerOrigin == "Top" then
        tracerFrom = Vector2.new(center.X, 0)
    end
    
    local hue = (tick() * settings.rainbowSpeed) % 1
    local currentRainbowColor = Color3.fromHSV(hue, 1, 1)
    
    fovCircle.Position = center
    fovCircle.Radius = settings.fov
    fovCircle.Color = currentRainbowColor
    fovCircle.Visible = settings.fovCircle
    
    local eyePos = CameraPOV and CameraPOV.GetEyePosition and CameraPOV.GetEyePosition() or camera.CFrame.Position
    local mercs = workspace:FindFirstChild("MercPlayers")
    
    if not mercs then 
        if isShooting then
            VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
            isShooting = false
        end
        return 
    end
    
    local bestHead, bestDist = nil, settings.fov
    local autoShootTargetFound = false

    for _, player in ipairs(Players:GetPlayers()) do
        local drawings = getEspDrawings(player)
        local box = drawings.Box
        local text = drawings.Text
        local tracer = drawings.Tracer
        local skelLines = drawings.Skeleton
        local renderEsp = false
        
        if player ~= LocalPlayer then
            local hitboxes = mercs:FindFirstChild("MercHitboxes_" .. player.Name)
            if hitboxes and not hitboxes:GetAttribute("Dead") then
                local head = hitboxes:FindFirstChild("Head")
                if head then
                    local distance = (head.Position - eyePos).Magnitude
                    if distance <= settings.maxDist then
                        local boneMap = hitboxes:FindFirstChild("Torso") and R6_BONES or R15_BONES
                        local minX, minY = math.huge, math.huge
                        local maxX, maxY = -math.huge, -math.huge
                        local anyBoneVisible = false
                        
                        for idx, pair in ipairs(boneMap) do
                            local b1 = hitboxes:FindFirstChild(pair[1])
                            local b2 = hitboxes:FindFirstChild(pair[2])
                            local line = skelLines[idx]
                            
                            if b1 and b2 then
                                local p1, v1 = camera:WorldToViewportPoint(b1.Position)
                                local p2, v2 = camera:WorldToViewportPoint(b2.Position)
                                
                                if v1 and v2 and p1.Z > 0 and p2.Z > 0 then
                                    if settings.espEnabled then
                                        anyBoneVisible = true
                                        line.From = Vector2.new(p1.X, p1.Y)
                                        line.To = Vector2.new(p2.X, p2.Y)
                                        line.Color = currentRainbowColor
                                        line.Visible = true
                                    else
                                        line.Visible = false
                                    end
                                    minX = math.min(minX, p1.X, p2.X)
                                    maxX = math.max(maxX, p1.X, p2.X)
                                    minY = math.min(minY, p1.Y, p2.Y)
                                    maxY = math.max(maxY, p1.Y, p2.Y)
                                else
                                    line.Visible = false
                                end
                            else
                                line.Visible = false
                            end
                        end
                        
                        for i = #boneMap + 1, #skelLines do
                            skelLines[i].Visible = false
                        end
                        
                        if anyBoneVisible and settings.espEnabled then
                            renderEsp = true
                            local paddingX = 10
                            local paddingY = 8
                            local boxWidth = (maxX - minX) + (paddingX * 2)
                            local boxHeight = (maxY - minY) + (paddingY * 2)
                            local boxPos = Vector2.new(minX - paddingX, minY - paddingY)
                            
                            box.Size = Vector2.new(boxWidth, boxHeight)
                            box.Position = boxPos
                            box.Color = currentRainbowColor
                            box.Visible = true
                            
                            text.Text = string.format("[ %d Studs ]", math.floor(distance))
                            text.Position = Vector2.new(boxPos.X + boxWidth + 5, boxPos.Y + (boxHeight / 2) - 8)
                            text.Color = currentRainbowColor
                            text.Visible = true
                            
                            local headPos, headVis = camera:WorldToViewportPoint(head.Position)
                            tracer.From = tracerFrom
                            tracer.To = Vector2.new(headPos.X, headPos.Y)
                            tracer.Color = currentRainbowColor
                            tracer.Visible = true
                        end

                        local headPos, headVis = camera:WorldToViewportPoint(head.Position)
                        if headVis and headPos.Z > 0 then
                            local aim = head.Position + Vector3.new(0, head.Size.Y * 0.15, 0)
                            local clear = true
                            
                            if settings.wallcheck then
                                wallParams.FilterDescendantsInstances = { LocalPlayer.Character, camera, mercs }
                                clear = workspace:Raycast(eyePos, aim - eyePos, wallParams) == nil
                            end
                            
                            if clear then
                                local px = (Vector2.new(headPos.X, headPos.Y) - center).Magnitude
                                if px < bestDist then
                                    bestDist = px
                                    bestHead = head
                                    if settings.autoShoot then
                                        autoShootTargetFound = true
                                    end
                                end
                            end
                        end

                    end
                end
            end
        end
        
        if not renderEsp or not settings.espEnabled then
            box.Visible = false
            text.Visible = false
            tracer.Visible = false
            for _, line in ipairs(skelLines) do line.Visible = false end
        end
    end
    
    if bestHead and settings.silentAim then
        targetPart = bestHead
        target = bestHead.Position + Vector3.new(0, bestHead.Size.Y * 0.15, 0)
    end

    if autoShootTargetFound and settings.autoShoot then
        local currentTime = tick()
        if not isShooting then
            isShooting = true
            lastShotTime = currentTime
            VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
        elseif currentTime - lastShotTime >= settings.fireRate then
            -- 快速松开再按下，实现连发
            VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
            task.wait()
            VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
            lastShotTime = currentTime
        end
    else
        if isShooting then
            isShooting = false
            VirtualInputManager:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
        end
    end
end)