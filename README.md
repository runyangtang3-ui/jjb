--[[
    脚本名称：屋内の礼物
    作者：屋内の礼物
    基于 WindUI 库
    功能：飞行、加速开关、无限跳跃、音乐播放器
--]]

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local cloneref = (cloneref or clonereference or function(instance) return instance end)

-- 加载 WindUI
local WindUI
do
    local ok, result = pcall(function() return require("./src/Init") end)
    if ok then
        WindUI = result
    else
        if RunService:IsStudio() then
            WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
        else
            WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end
    end
end

-- 窗口
local Window = WindUI:CreateWindow({
    Title = "屋内の礼物",
    Icon = "star",
    Folder = "IndoorGift",
    NewElements = true,
    OpenButton = {
        Title = "打开屋内の礼物",
        Enabled = true,
        Draggable = true,
    },
})

-- 顶部标签
Window:Tag({
    Title = "屋内の礼物",
    Icon = "star",
    Color = Color3.fromHex("#FFD700"),
    Border = true,
})

-- ======== 第一页：首页 (私人定制) ========
local MainTab = Window:Tab({
    Title = "🏡 我的窝",
    Icon = "home",
})

MainTab:Section({
    Title = "👋 哟，来了啊",
    TextSize = 24,
    FontWeight = Enum.FontWeight.Bold,
})

MainTab:Space()

MainTab:Section({
    Title = "这就是我自个儿用的脚本\n没啥花里胡哨，想咋搞咋搞\n切到「功能」和「音乐」页面玩吧～",
    TextSize = 18,
    TextTransparency = 0.3,
})

-- ======== 第二页：功能 ========
local FeaturesTab = Window:Tab({
    Title = "功能",
    Icon = "tools",
})

FeaturesTab:Section({
    Title = "基础能力",
})

-- 状态管理
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

local state = {
    fly = false,
    infiniteJump = false,
    speedEnabled = false,
}

local function onCharacterAdded(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    if state.fly then enableFly() end
    if state.speedEnabled then
        humanoid.WalkSpeed = 60
    else
        humanoid.WalkSpeed = 16
    end
    if state.infiniteJump then enableInfiniteJump() end
end
player.CharacterAdded:Connect(onCharacterAdded)

-- ------------------- 飞行 -------------------
local flyConn, bodyGyro, bodyVel

local function enableFly()
    local root = character:WaitForChild("HumanoidRootPart")
    if bodyGyro then bodyGyro:Destroy() end
    if bodyVel then bodyVel:Destroy() end

    bodyGyro = Instance.new("BodyGyro")
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = root.CFrame
    bodyGyro.Parent = root

    bodyVel = Instance.new("BodyVelocity")
    bodyVel.Velocity = Vector3.zero
    bodyVel.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVel.Parent = root

    if flyConn then flyConn:Disconnect() end
    flyConn = RunService.Heartbeat:Connect(function()
        if not state.fly or not character or not character.Parent then return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end
        if dir.Magnitude > 0 then
            bodyVel.Velocity = dir * 50
        else
            bodyVel.Velocity = Vector3.zero
        end
        bodyGyro.CFrame = cam.CFrame
    end)
end

local function disableFly()
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if bodyGyro then bodyGyro:Destroy(); bodyGyro = nil end
    if bodyVel then bodyVel:Destroy(); bodyVel = nil end
end

-- ------------------- 无限跳跃 -------------------
local jumpConn
local function enableInfiniteJump()
    if humanoid then humanoid.JumpPower = 50 end
    if jumpConn then jumpConn:Disconnect() end
    jumpConn = UserInputService.JumpRequest:Connect(function()
        if state.infiniteJump and humanoid and humanoid.Health > 0 then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)
end

local function disableInfiniteJump()
    if humanoid then humanoid.JumpPower = 50 end
    if jumpConn then jumpConn:Disconnect(); jumpConn = nil end
end

-- ---- 控件 ----
FeaturesTab:Toggle({
    Title = "飞行",
    Default = false,
    Callback = function(value)
        state.fly = value
        if value then enableFly() else disableFly() end
    end,
})

FeaturesTab:Toggle({
    Title = "加速 (60)",
    Default = false,
    Callback = function(value)
        state.speedEnabled = value
        if humanoid then
            humanoid.WalkSpeed = value and 60 or 16
        end
    end,
})

FeaturesTab:Toggle({
    Title = "无限跳跃",
    Default = false,
    Callback = function(value)
        state.infiniteJump = value
        if value then enableInfiniteJump() else disableInfiniteJump() end
    end,
})

-- ======== 第三页：音乐播放器 ========
local MusicTab = Window:Tab({
    Title = "音乐",
    Icon = "music",
})

local currentSound = nil
local searchId = ""

local nowPlayingSection = MusicTab:Section({
    Title = "♫ 未选择歌曲",
    TextSize = 18,
    TextTransparency = 0.4,
})

local function updateNowPlaying(name)
    if nowPlayingSection then
        nowPlayingSection:SetTitle("♫ 正在播放：" .. name)
    end
end

local function playMusic(id, songName)
    if currentSound then
        currentSound:Stop()
        currentSound:Destroy()
        currentSound = nil
    end
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://" .. id
    sound.Volume = 1.5
    sound.Parent = workspace
    sound:Play()
    currentSound = sound
    updateNowPlaying(songName)
end

MusicTab:Section({ Title = "🔍 搜索ID播放" })

MusicTab:Input({
    Title = "输入音乐ID",
    Placeholder = "例如：74173898692517",
    Callback = function(text)
        searchId = text
    end,
})

MusicTab:Button({
    Title = "播放输入的ID",
    Color = Color3.fromHex("#4CAF50"),
    Callback = function()
        if searchId ~= "" and tonumber(searchId) then
            playMusic(searchId, "自定义音乐 (" .. searchId .. ")")
        end
    end,
})

MusicTab:Space({ Columns = 2 })

MusicTab:Button({
    Title = "⏸ 暂停/继续",
    Color = Color3.fromHex("#FF9800"),
    Callback = function()
        if currentSound then
            if currentSound.IsPlaying then
                currentSound:Pause()
            else
                currentSound:Resume()
            end
        end
    end,
})

MusicTab:Button({
    Title = "⏹ 停止",
    Color = Color3.fromHex("#F44336"),
    Ca
