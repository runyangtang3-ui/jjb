local WasUIPro = loadstring(game:HttpGet("https://raw.githubusercontent.com/WasKKal/WasUI-For-Roblox/main/WasUIPro.lua", true))()

local Uis = game:GetService("UserInputService")
local Players = game:GetService("Players")

WasUIPro:SetDefaultTheme("Dark")
WasUIPro:SetDefaultRainbowMode("流动")
WasUIPro:SetLanguage("中文")

local mainWindow = WasUIPro:CreateWindow({
    Title = "TrashHub-重型钓鱼",
    MinimizedText = "TrashHub",
    SnowEnabled = true,
    DialogTitle = "确认关闭窗口",
    Folder = "TrashHub_重型钓鱼",
    TitleTag = {
        { text = "伊散", backgroundColor = Color3.fromRGB(255,215,0), textColor = Color3.fromRGB(0,0,0) }
    }
})

task.spawn(function()
    task.wait(0.5)
    WasUIPro:Notify({ Title = "加载完成", Content = "TrashHub-重型钓鱼", Duration = 3 })
end)

local fishingTab = mainWindow:Tab({ Title = "钓鱼" })
local fishingCategory = fishingTab:Category({ Title = "钓鱼功能", IconName = "fish" })
local filterCategory = fishingTab:Category({ Title = "高级过滤", IconName = "sliders" })

local miscTab = mainWindow:Tab({ Title = "杂项" })
local miscCategory = miscTab:Category({ Title = "杂项功能", IconName = "settings" })

local afkTab = mainWindow:Tab({ Title = "挂机" })
local afkCategory = afkTab:Category({ Title = "挂机保护", IconName = "shield" })

local playerTab = mainWindow:Tab({ Title = "人物" })
local playerCategory = playerTab:Category({ Title = "移动增强", IconName = "zap" })

local funTab = mainWindow:Tab({ Title = "娱乐" })
local funCategory = funTab:Category({ Title = "娱乐功能", IconName = "smile" })

local teleportTab = mainWindow:Tab({ Title = "传送" })
local teleportCategory = teleportTab:Category({ Title = "快捷传送", IconName = "map-pin" })

_G.AutoCastEnabled = false
_G.AutoFishingEnabled = false
_G.AutoSkillEnabled = false
_G.AutoSellEnabled = false
_G.AutoTeleToBoss = false
_G.AutoSkillF = false
_G.SkillFDelay = 5
_G.AutoFavoriteRareFish = false
_G.AutoTicketQuest = false
_G.AutoBuyAncestralBait = false
_G.AutoWeatherFarm = false
_G.AutoNormalTicketQuest = false
_G.AutoTeleToMerchant = false
_G.BossLockMode = false

fishingTab:Paragraph({
    Title = "注意事项",
    Desc = "开启过滤之后只钓boss，如果不是boss则自动放弃(暂时用不了在维护)",
    Icon = "alert-circle"
})

fishingCategory:Toggle({
    Title = "自动抛竿",
    Value = false,
    ConfigKey = "auto_cast",
    Callback = function(v) _G.AutoCastEnabled = v end
})

fishingCategory:Toggle({
    Title = "自动钓鱼",
    Value = false,
    ConfigKey = "auto_fish",
    Callback = function(v) _G.AutoFishingEnabled = v end
})

fishingCategory:Toggle({
    Title = "自动技能",
    Value = false,
    ConfigKey = "auto_skill",
    Callback = function(v) _G.AutoSkillEnabled = v end
})

fishingCategory:Toggle({
    Title = "自动卖鱼",
    Value = false,
    ConfigKey = "auto_sell",
    Callback = function(v) _G.AutoSellEnabled = v end
})

local filterEnabled = false
local keepFish = {
    ["Rainbow Dragonfish"] = true,
    ["Sanguine Fish"] = true,
    ["Heavenpiercer Turtle"] = true,
    ["Reborn Puffer Beast"] = true,
    ["Flying Fish Empress"] = true,
    ["Flying Fish Emperor"] = true,
    ["Draconic Koi"] = true,
    ["Elder Scarlet Fish"] = true,
    ["Verdant Bonefang"] = true,
    ["Scarlet Fish"] = true,
    ["Crimson Electric Eel"] = true,
    ["Colossal Tigerfish"] = true,
    ["Ascended Perch"] = true,
    ["Warbringer Shark"] = true,
    ["Frost Kingfish"] = true,
    ["Crimson Bonefang"] = true,
    ["Primordial Kunfish Overlord"] = true
}
local toggleHotbar = game:GetService("ReplicatedStorage").Events.ToggleHotbar
local processedFish = setmetatable({}, { __mode = "k" })

filterCategory:Toggle({
    Title = "自动过滤小鱼",
    Value = false,
    ConfigKey = "filter_small",
    Callback = function(v) filterEnabled = v end
})

task.spawn(function()
    while true do
        task.wait(1.5)
        if filterEnabled then
            for _, obj in pairs(getgc(true)) do
                if type(obj) == "table" then
                    local name = rawget(obj, "FishName")
                    if name and rawget(obj, "Weight") and rawget(obj, "Power") then
                        if not processedFish[obj] then
                            processedFish[obj] = true
                            local fishName = tostring(name)
                            if not keepFish[fishName] then
                                toggleHotbar:InvokeServer("1", nil)
                                task.wait(0.1)
                                toggleHotbar:InvokeServer("1", nil)
                            else
                                print("保留" .. fishName)
                            end
                        end
                    end
                end
            end
        end
    end
end)

fishingCategory:Toggle({
    Title = "抢Boss",
    Desc = "开了这个功能之后 自动功能不能用否则会冲突",
    Value = false,
    ConfigKey = "boss_lock",
    Callback = function(v)
        _G.BossLockMode = v
        if not v then
            _G.AutoFishingEnabled = false
            _G.AutoCastEnabled = false
            _G.AutoSkillEnabled = false
        end
    end
})

task.spawn(function()
    local wasBoss = false
    while true do
        task.wait(0.01)
        if _G.BossLockMode then
            local ocean = workspace:FindFirstChild("Ocean")
            local boss = ocean and ocean:FindFirstChild("Boss")
            local player = game.Players.LocalPlayer
            local char = player.Character
            if boss and char and char:FindFirstChild("HumanoidRootPart") then
                local bossPos = boss:GetPivot().Position
                local root = char.HumanoidRootPart
                local diff = (root.Position - bossPos)
                local dir = diff.Magnitude > 0.1 and diff.Unit or Vector3.new(1,0,0)
                local targetPos = bossPos + (dir * 20) + Vector3.new(0,10,0)
                char:PivotTo(CFrame.lookAt(targetPos, bossPos))
                if not wasBoss then
                    _G.AutoFishingEnabled = true
                    _G.AutoSkillEnabled = true
                    _G.AutoCastEnabled = true
                    wasBoss = true
                    warn("!!! 已检测到 Boss，开启自动功能并执行锁定 !!!")
                end
            else
                if wasBoss then
                    _G.AutoFishingEnabled = false
                    _G.AutoCastEnabled = false
                    _G.AutoSkillEnabled = false
                    wasBoss = false
                    warn("!!! Boss 已消失，自动功能已关闭 !!!")
                end
            end
        end
    end
end)

local autoWeather = false
local islands = {
    Bass = { Pos = Vector3.new(-62.20, 9.28, -1350.26), Look = Vector3.new(0.00873366, 0, -0.99996185) },
    Bamboo = { Pos = Vector3.new(-1292.66, 9.76, -42.57), Look = Vector3.new(-0.99991846, 0, 0.01276829) },
    Coconut = { Pos = Vector3.new(1413.75, 9.28, -1452.20), Look = Vector3.new(-0.03845364, 0, 0.99926036) }
}

local function teleportToIsland(data)
    local player = game.Players.LocalPlayer
    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    hrp.CFrame = CFrame.new(data.Pos, data.Pos + data.Look)
end

local function getCurrentWeather()
    local weatherFolder = game.ReplicatedStorage.ClientModule.Weather.Weather
    local sky = game.Lighting:FindFirstChildOfClass("Sky")
    if not sky then return nil end
    for _, weather in pairs(weatherFolder:GetChildren()) do
        local skybox = weather:FindFirstChild("Sky")
        if skybox and skybox.SkyboxBk == sky.SkyboxBk then
            return weather.Name
        end
    end
    return nil
end

local function createWeatherUI()
    local player = game.Players.LocalPlayer
    local gui = Instance.new("ScreenGui")
    gui.Name = "WeatherUI"
    gui.Parent = player:WaitForChild("PlayerGui")
    gui.ResetOnSpawn = false
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 40)
    frame.Position = UDim2.new(1, -210, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,30)
    frame.BorderSizePixel = 0
    frame.BackgroundTransparency = 0.3
    frame.Parent = gui
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,0,1,0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.Font = Enum.Font.SourceSansBold
    label.TextSize = 20
    label.Text = "当前天气: -"
    label.Parent = frame
    return frame, label
end

local weatherFrame, weatherLabel = createWeatherUI()

local function updateWeatherUI(weather)
    if weather then
        weatherLabel.Text = "当前天气: " .. weather
    else
        weatherLabel.Text = "当前天气: 未知"
    end
    if weather == "Foggy" then
        weatherFrame.BackgroundColor3 = Color3.fromRGB(150,150,150)
    elseif weather == "Thunderstorm" then
        weatherFrame.BackgroundColor3 = Color3.fromRGB(30,30,80)
    elseif weather == "Windy" then
        weatherFrame.BackgroundColor3 = Color3.fromRGB(100,150,255)
    elseif weather == "Clear" then
        weatherFrame.BackgroundColor3 = Color3.fromRGB(255,200,50)
    else
        weatherFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
    end
end

fishingCategory:Toggle({
    Title = "自动天气传送",
    Value = false,
    ConfigKey = "weather_tp",
    Callback = function(v)
        autoWeather = v
        if v then
            task.spawn(function()
                local last = ""
                while autoWeather do
                    local weather = getCurrentWeather()
                    updateWeatherUI(weather)
                    if weather ~= last then
                        last = weather
                        warn("检测到天气: " .. tostring(weather))
                        if weather == "Foggy" then
                            teleportToIsland(islands.Coconut)
                        elseif weather == "Thunderstorm" then
                            teleportToIsland(islands.Bamboo)
                        elseif weather == "Windy" or weather == "Clear" then
                            teleportToIsland(islands.Bass)
                        end
                    end
                    task.wait(2)
                end
            end)
        end
    end
})

fishingCategory:Toggle({
    Title = "杆门断自动释放",
    Value = false,
    ConfigKey = "auto_skill_f",
    Callback = function(v) _G.AutoSkillF = v end
})

fishingCategory:TextInput({
    Title = "杆门断释放延迟时间",
    Placeholder = "默认30秒",
    Value = "30",
    ConfigKey = "skill_f_delay",
    Callback = function(text)
        local num = tonumber(text)
        if num and num >= 0 then _G.SkillFDelay = num end
    end
})

fishingCategory:Button({
    Text = "打开饵料商城",
    Icon = "shopping-cart",
    Callback = function()
        game:GetService("ReplicatedStorage").Events.ChooseDialogueOption:FireServer("BuyBait", 1, "BaitShop", nil)
    end
})

miscCategory:Button({
    Text = "打开饵料制作",
    Icon = "hammer",
    Callback = function()
        game:GetService("ReplicatedStorage").Events.ChooseDialogueOption:FireServer("BuyBait", 2, "CraftBait", nil)
    end
})

miscCategory:Toggle({
    Title = "自动传送Boss",
    Value = false,
    ConfigKey = "auto_tp_boss",
    Callback = function(v) _G.AutoTeleToBoss = v end
})

miscCategory:Toggle({
    Title = "自动收藏稀有鱼",
    Value = false,
    ConfigKey = "auto_fav",
    Callback = function(v) _G.AutoFavoriteRareFish = v end
})

miscTab:Paragraph({
    Title = "注意事项",
    Desc = "自动接刘老板任务接完以后，挂机把所有刘老板任务做完，然后在认领任务",
    Icon = "alert-circle"
})

miscCategory:Toggle({
    Title = "自动接刘老板困难任务",
    Value = false,
    ConfigKey = "auto_hard_quest",
    Callback = function(v) _G.AutoTicketQuest = v end
})

miscCategory:Toggle({
    Title = "自动认领刘老板任务",
    Value = false,
    ConfigKey = "auto_claim_quest",
    Callback = function(v) _G.AutoNormalTicketQuest = v end
})

miscCategory:Toggle({
    Title = "自动购买祖先饵料",
    Value = false,
    ConfigKey = "auto_ancestral",
    Callback = function(v) _G.AutoBuyAncestralBait = v end
})

miscCategory:Toggle({
    Title = "自动传送小道士",
    Value = false,
    ConfigKey = "auto_tp_merchant",
    Callback = function(v) _G.AutoTeleToMerchant = v end
})

local antiAFK = false
afkCategory:Toggle({
    Title = "阻止自动换服",
    Value = false,
    ConfigKey = "anti_afk_kick",
    Callback = function(v)
        antiAFK = v
        if v then
            local searchAreas = { game.Players.LocalPlayer, workspace, game:GetService("ReplicatedStorage"), game:GetService("Lighting") }
            local function wipe()
                local count = 0
                for _, area in ipairs(searchAreas) do
                    for _, obj in ipairs(area:GetDescendants()) do
                        if obj.Name == "AFK" or string.match(string.upper(obj.Name), "^AFK$") then
                            if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then obj.Disabled = true end
                            obj:Destroy()
                            count = count + 1
                        end
                    end
                end
                return count
            end
            local c = wipe()
            warn("首次清理了 " .. c .. " 个 AFK 相关对象")
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "AFK 清理启动",
                Text = "已删除 " .. c .. " 个对象，后台持续监控中...",
                Duration = 3
            })
            task.spawn(function()
                while antiAFK do
                    task.wait(1.5)
                    wipe()
                end
            end)
        end
    end
})

local afkConn = nil
afkCategory:Toggle({
    Title = "AFK(必开)",
    Value = false,
    ConfigKey = "afk_bypass",
    Callback = function(v)
        if v then
            afkConn = game.Players.LocalPlayer.Idled:Connect(function()
                game:GetService("VirtualUser"):CaptureController()
                game:GetService("VirtualUser"):ClickButton2(Vector2.new(0,0))
            end)
        else
            if afkConn then afkConn:Disconnect() afkConn = nil end
        end
    end
})

local speedEnabled = false
local speedValue = 50
playerCategory:Toggle({
    Title = "加速",
    Value = false,
    ConfigKey = "speed_toggle",
    Callback = function(v)
        speedEnabled = v
        if not v then
            local player = game.Players.LocalPlayer
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = 16
            end
        end
    end
})

playerCategory:Slider({
    Title = "移动速度",
    Value = { Min = 16, Max = 200, Default = 50 },
    ConfigKey = "speed_value",
    Callback = function(v)
        speedValue = v
        if speedEnabled then
            local player = game.Players.LocalPlayer
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = speedValue
            end
        end
    end
})

local attachSpirit = false
funCategory:Toggle({
    Title = "获取饮料的老婆",
    Value = false,
    ConfigKey = "attach_spirit",
    Callback = function(v) attachSpirit = v end
})

game:GetService("RunService").Heartbeat:Connect(function()
    if not attachSpirit then return end
    local player = game.Players.LocalPlayer
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local spirit = workspace:FindFirstChild("NPC") and workspace.NPC:FindFirstChild("Spirit")
    if spirit then
        if spirit:IsA("Model") and not spirit.PrimaryPart then
            spirit.PrimaryPart = spirit:FindFirstChildWhichIsA("BasePart")
        end
        spirit:PivotTo(char.HumanoidRootPart.CFrame * CFrame.new(0,5,4))
    end
end)

local function teleportTo(coords)
    local player = game.Players.LocalPlayer
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        player.Character.HumanoidRootPart.CFrame = CFrame.new(coords)
    end
end

local locations = {
    { Name = "初始岛屿", Coords = Vector3.new(-283.78, 11.06, 37.06) },
    { Name = "竹子岛", Coords = Vector3.new(-1194.62, 5.57, -30.08) },
    { Name = "核弹岛", Coords = Vector3.new(-48.12, 5.88, 1234.68) },
    { Name = "主权岛屿", Coords = Vector3.new(-1174.37, 7.26, 1279.27) },
    { Name = "鲈鱼岛", Coords = Vector3.new(-63.82, 11.11, -1361.63) },
    { Name = "冰霜岛屿", Coords = Vector3.new(-1389.85, 9.50, -1397.23) },
    { Name = "椰子岛", Coords = Vector3.new(1431.24, 11.14, -1445.49) },
    { Name = "琥珀岛", Coords = Vector3.new(1123.59, 10.86, 1414.99) },
    { Name = "战场岛", Coords = Vector3.new(1342.56, 9.64, 229.71) }
}

for _, loc in ipairs(locations) do
    teleportCategory:Button({
        Text = "传送至: " .. loc.Name,
        Icon = "map-pin",
        Callback = function() teleportTo(loc.Coords) end
    })
end

task.spawn(function()
    while true do
        if _G.AutoTeleToBoss then
            local boss = workspace:FindFirstChild("Ocean") and workspace.Ocean:FindFirstChild("Boss")
            if boss and game.Players.LocalPlayer.Character then
                game.Players.LocalPlayer.Character:PivotTo(boss:GetPivot() * CFrame.new(0,5,0))
            end
        end
        task.wait(0.5)
    end
end)

task.spawn(function()
    local player = game.Players.LocalPlayer
    local events = game:GetService("ReplicatedStorage"):WaitForChild("Events")
    local inMinigame = false
    task.spawn(function()
        while true do
            task.wait(1)
            if _G.AutoCastEnabled and not workspace:FindFirstChild(player.Name):FindFirstChild("Buoy") then
                events.Fishing:FireServer()
            end
        end
    end)
    task.spawn(function()
        while true do
            task.wait()
            if not _G.AutoFishingEnabled or not inMinigame then continue end
            local fishingGui = player.PlayerGui.MainGui.Fishing
            if fishingGui and fishingGui.Visible then
                local bar = fishingGui.BarFrame.Bar
                bar.Position = UDim2.new(0.5,0,0.5,0)
            else
                inMinigame = false
            end
        end
    end)
    events.Slam.OnClientEvent:Connect(function()
        if _G.AutoFishingEnabled then
            player.PlayerGui.MainGui.Fishing.TrashCan.Slam.Button.MouseButton1Click:Fire()
        end
    end)
    events.Charge.OnClientEvent:Connect(function()
        if _G.AutoFishingEnabled then
            player.PlayerGui.MainGui.Fishing.TrashCan.Charge.Button.MouseButton1Click:Fire()
        end
    end)
    events.FishingMinigame.OnClientEvent:Connect(function()
        if _G.AutoFishingEnabled then inMinigame = true end
    end)
end)

task.spawn(function()
    local useSkill = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("UseSkill")
    local keys = {"Z","C","V","X"}
    while true do
        if _G.AutoSkillEnabled then
            for _, key in ipairs(keys) do useSkill:FireServer(key) end
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    getgenv().AutoFavoriteFish = getgenv().AutoFavoriteFish or {}
    local rep = game:GetService("ReplicatedStorage")
    local player = game.Players.LocalPlayer
    local inv = rep:WaitForChild("Data"):WaitForChild(tostring(player.UserId)):WaitForChild("Inventory")
    local favEvent = rep:WaitForChild("Events"):WaitForChild("FavoriteItem")
    local targetFish = {
        ["Rainbow Dragonfish"] = true,
        ["Sanguine Fish"] = true,
        ["Heavenpiercer Turtle"] = true,
        ["Reborn Puffer Beast"] = true,
        ["Flying Fish Empress"] = true,
        ["Flying Fish Emperor"] = true,
        ["Draconic Koi"] = true,
        ["Elder Scarlet Fish"] = true,
        ["Verdant Bonefang"] = true,
        ["Scarlet Fish"] = true,
        ["Crimson Electric Eel"] = true,
        ["Colossal Tigerfish"] = true,
        ["Ascended Perch"] = true,
        ["Warbringer Shark"] = true,
        ["Frost Kingfish"] = true,
        ["Crimson Bonefang"] = true,
        ["Primordial Kunfish Overlord"] = true
    }
    local function autoFav(fish)
        if not _G.AutoFavoriteRareFish then return end
        if not fish or not fish.Name then return end
        local full = fish.Name
        local typ = string.match(full, "^(.-)%s*|") or full
        typ = typ:gsub("%s+$","")
        if not targetFish[typ] then return end
        if getgenv().AutoFavoriteFish[full] then return end
        getgenv().AutoFavoriteFish[full] = true
        task.wait(0.2)
        favEvent:FireServer(full)
        print("[自动收藏]", full)
    end
    inv.ChildAdded:Connect(function(fish) task.spawn(function() autoFav(fish) end) end)
end)

task.spawn(function()
    local rep = game:GetService("ReplicatedStorage")
    local player = game.Players.LocalPlayer
    local inv = rep:WaitForChild("Data")[tostring(player.UserId)]:WaitForChild("Inventory")
    local sellEvent = rep:WaitForChild("Events"):WaitForChild("SellFish")
    getgenv().AutoFavoriteFish = getgenv().AutoFavoriteFish or {}
    while true do
        if _G.AutoSellEnabled then
            for _, fish in ipairs(inv:GetChildren()) do
                if not getgenv().AutoFavoriteFish[fish.Name] then
                    sellEvent:FireServer(fish.Name)
                end
            end
        end
        task.wait(10)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if speedEnabled then
            local player = game.Players.LocalPlayer
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                if player.Character.Humanoid.WalkSpeed ~= speedValue then
                    player.Character.Humanoid.WalkSpeed = speedValue
                end
            end
        end
    end
end)

task.spawn(function()
    local vim = game:GetService("VirtualInputManager")
    local player = game.Players.LocalPlayer
    local animIds = {
        "rbxassetid://139310377090355",
        "rbxassetid://126829237727532",
        "rbxassetid://93648246978510"
    }
    local busy = false
    local function hookChar(char)
        local humanoid = char:WaitForChild("Humanoid")
        humanoid.AnimationPlayed:Connect(function(track)
            local anim = track.Animation
            if not _G.AutoSkillF or busy or not anim then return end
            local matched = false
            for _, id in ipairs(animIds) do
                if anim.AnimationId == id then matched = true break end
            end
            if matched then
                busy = true
                task.delay(_G.SkillFDelay, function()
                    vim:SendKeyEvent(true, Enum.KeyCode.F, false, game)
                    task.wait(0.05)
                    vim:SendKeyEvent(false, Enum.KeyCode.F, false, game)
                    task.wait(1)
                    busy = false
                end)
            end
        end)
    end
    if player.Character then hookChar(player.Character) end
    player.CharacterAdded:Connect(hookChar)
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoTeleToMerchant then
            local player = game.Players.LocalPlayer
            local char = player.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local npcFolder = workspace:FindFirstChild("NPC")
                if npcFolder then
                    local merchant = npcFolder:FindFirstChild("Merchant", true)
                    if merchant and merchant:IsA("Model") then
                        char:PivotTo(merchant:GetPivot() * CFrame.new(0,0,-3))
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    local choose = game:GetService("ReplicatedStorage").Events.ChooseDialogueOption
    while true do
        if _G.AutoTicketQuest then
            choose:FireServer("Ticket Quest Giver", 2, "HardAcceptQuest", {
                workspace.NPC.Function["Ticket Quest Giver"],
                "Ticket Quest"
            })
        end
        task.wait(3)
    end
end)

task.spawn(function()
    local buy = game:GetService("ReplicatedStorage").Events.BuyBait
    while true do
        if _G.AutoBuyAncestralBait then
            buy:FireServer("Ancestral Bait")
        end
        task.wait(0.1)
    end
end)

task.spawn(function()
    local choose = game:GetService("ReplicatedStorage").Events.ChooseDialogueOption
    while true do
        if _G.AutoNormalTicketQuest then
            choose:FireServer("Ticket Quest Giver", 1, "Quest", {
                workspace.NPC.Function["Ticket Quest Giver"]
            })
        end
        task.wait(3)
    end
end)

local lighting = game:GetService("Lighting")
local tween = game:GetService("TweenService")
local blur = lighting:FindFirstChildOfClass("BlurEffect")
if not blur then
    blur = Instance.new("BlurEffect")
    blur.Size = 0
    blur.Parent = lighting
end

task.spawn(function()
    local lastVisible = false
    while true do
        task.wait(0.1)
        local main = mainWindow.UIElements and mainWindow.UIElements.Main
        local visible = main and main.Visible or false
        if visible ~= lastVisible then
            lastVisible = visible
            tween:Create(blur, TweenInfo.new(0.3), { Size = visible and 20 or 0 }):Play()
        end
    end
end)

local runService = game:GetService("RunService")
local rainbowConn = nil
local speedAnim = 5

local function createRainbowBorder()
    local main = mainWindow.UIElements.Main
    if not main then return nil end
    local existing = main:FindFirstChild("RainbowStroke")
    if existing then existing:Destroy() end
    if not main:FindFirstChildOfClass("UICorner") then
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0,16)
        corner.Parent = main
    end
    local stroke = Instance.new("UIStroke")
    stroke.Name = "RainbowStroke"
    stroke.Thickness = 2
    stroke.Color = Color3.new(1,1,1)
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.LineJoinMode = Enum.LineJoinMode.Round
    stroke.Parent = main
    local gradient = Instance.new("UIGradient")
    gradient.Name = "GlowEffect"
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHex("FF0000")),
        ColorSequenceKeypoint.new(0.16, Color3.fromHex("FFA500")),
        ColorSequenceKeypoint.new(0.33, Color3.fromHex("FFFF00")),
        ColorSequenceKeypoint.new(0.5, Color3.fromHex("00FF00")),
        ColorSequenceKeypoint.new(0.66, Color3.fromHex("0000FF")),
        ColorSequenceKeypoint.new(0.83, Color3.fromHex("4B0082")),
        ColorSequenceKeypoint.new(1, Color3.fromHex("EE82EE"))
    })
    gradient.Rotation = 0
    gradient.Parent = stroke
    return stroke
end

local function startRainbowAnim()
    local main = mainWindow.UIElements.Main
    if not main then return nil end
    local stroke = main:FindFirstChild("RainbowStroke")
    if not stroke then return nil end
    local grad = stroke:FindFirstChild("GlowEffect")
    if not grad then return nil end
    return runService.Heartbeat:Connect(function()
        if not stroke or stroke.Parent == nil then return end
        grad.Rotation = (tick() * speedAnim * 10) % 360
    end)
end

local border = createRainbowBorder()
if border then
    rainbowConn = startRainbowAnim()
end

local visibleState = true
Uis.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        visibleState = not visibleState
        mainWindow:SetVisible(visibleState)
    end
end)

WasUIPro:Notify({ Title = "TrashHub", Content = "加载完成", Duration = 4 })