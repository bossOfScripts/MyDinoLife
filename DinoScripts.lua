-- =================================================================
-- CHRONO HUB (LinoriaLib UI) - PREMIUM EDITION
-- =================================================================

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local function getSvc(serviceName)
	local s = game:GetService(serviceName)
	return (cloneref and cloneref(s)) or s
end

local CoreGui = getSvc("CoreGui")
local Players = getSvc("Players")
local RunService = getSvc("RunService")
local UserInputService = getSvc("UserInputService")
local TeleportService = getSvc("TeleportService")
local HttpService = getSvc("HttpService")
local Lighting = getSvc("Lighting")
local ContentProvider = getSvc("ContentProvider")
local VirtualUser = getSvc("VirtualUser")

local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ExecCount = 1
pcall(function()
	if isfile and readfile and writefile then
		if isfile("ChronoHub_Execs.txt") then
			ExecCount = tonumber(readfile("ChronoHub_Execs.txt")) or 0
			ExecCount = ExecCount + 1
		end
		writefile("ChronoHub_Execs.txt", tostring(ExecCount))
	end
end)

local function RndName()
	local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	local str = ""
	for i = 1, math.random(12, 18) do
		local r = math.random(1, #chars)
		str = str .. string.sub(chars, r, r)
	end
	return str
end

local ObfuscatedNames = { GUI = RndName(), FCPart = RndName(), Highlight = RndName(), AirWalk = RndName() }
if setfpscap then setfpscap(9999) end

-- ===================== STATE VARIABLES =====================
local ESPSettings = { Master = false, Highlight = true, Box = false, Name = false, HP = false, Studs = false, Skeleton = false }
local ESPColor = Color3.fromRGB(255, 50, 50)
local HitboxEnabled, HitboxSize, KickStuffEnabled = false, 10, true
local SpeedEnabled, TargetSpeed, NoclipEnabled, InfJumpEnabled, FlyEnabled, FlySpeed = false, 16, false, false, false, 50
local VelManipEnabled, VelManipSpeed = false, 1
local AimbotEnabled, AimbotTarget, WallCheckEnabled, FOVEnabled, FOVRadius, Smoothness, RainbowFOVEnabled = false, "Head", true, false, 180, 0, false
local NoFogEnabled, FullbrightEnabled, FOVChangerEnabled, CustomFOV = false, false, false, 90
local NoCamShakeEnabled, NoCamBobbingEnabled = false, false
local EnableJumpToggle = false
local ShiftlockEnabled, ShiftlockOffset, DisableCollisionEnabled = false, 2, false
local InvisibleEnabled, RealCharacter, FakeCharacter = false, nil, nil
local FPSUnlockerEnabled, CamUnlockerEnabled = true, false
local FreeCamEnabled, FreezeDuringEnabled, FC_Speed, fwdDown, bwdDown = false, false, 60, false, false
local SpectateEnabled, SpectateTargetPlayer = false, nil
local WhitelistedNames, OriginalSizes, OriginalNoclipStates = {}, {}, {}

-- Speed Bypass Variables
local speedBypassEnabled = false
local speedBypassBonus = 1.5
local speedBypassMax = 15.0
local pauseTimer = 0
local lastPosition = nil
local smoothedSpeed = 0
local SpeedometerLabel = nil

-- Pumpkin ESP Variables
local pumpkinEspEnabled = false
local pumpkinEspColor = Color3.fromRGB(170, 0, 255)

local OriginalGravity = workspace.Gravity
local GravityEnabled, CustomGravity = false, 50
local AirWalkEnabled, AirWalkY = false, 0
local AirWalkPart = Instance.new("Part")
AirWalkPart.Name = ObfuscatedNames.AirWalk
AirWalkPart.Size = Vector3.new(6, 1, 6)
AirWalkPart.Transparency = 1
AirWalkPart.Anchored = true
AirWalkPart.CanCollide = true

local AntiAfkEnabled = false
local AntiAfkConnection = nil

local PerfSettings = { Textures = false, Particles = false, Animations = false }
local cacheMaterials, cacheDecals, cacheParticles = {}, {}, {}

local CustomAnims = {
    Run = { ID = "", Active = false },
    Jump = { ID = "", Active = false },
    Idle = { ID = "", Active = false }
}
local OriginalAnims = {}

-- ===================== OVERLAY GUI =====================
local TargetGuiParent = (gethui and gethui()) or CoreGui
local OverlayGui = Instance.new("ScreenGui")
OverlayGui.Name = ObfuscatedNames.GUI
OverlayGui.ResetOnSpawn = false
OverlayGui.IgnoreGuiInset = true
OverlayGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local success, err = pcall(function() OverlayGui.Parent = TargetGuiParent end)
if not success then OverlayGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local ESP_Folder = Instance.new("Folder", OverlayGui)
ESP_Folder.Name = RndName()
local ESP_Elements = {}

local FOVCircleUI = Instance.new("Frame", OverlayGui)
FOVCircleUI.Size = UDim2.new(0, FOVRadius * 2, 0, FOVRadius * 2)
FOVCircleUI.Position = UDim2.new(0.5, -FOVRadius, 0.5, -FOVRadius)
FOVCircleUI.BackgroundTransparency = 1
FOVCircleUI.Visible = false
local UIStroke = Instance.new("UIStroke", FOVCircleUI)
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 1.5
Instance.new("UICorner", FOVCircleUI).CornerRadius = UDim.new(1, 0)

local FCMobileUI = Instance.new("Frame", OverlayGui)
FCMobileUI.Size = UDim2.new(0, 70, 0, 160)
FCMobileUI.Position = UDim2.new(0, 15, 0.5, -80)
FCMobileUI.BackgroundTransparency = 1
FCMobileUI.Visible = false

local btnFwd = Instance.new("TextButton", FCMobileUI)
btnFwd.Size = UDim2.new(1, 0, 0.45, 0); btnFwd.BackgroundColor3 = Color3.fromRGB(30,30,30); btnFwd.Text = "▲"; btnFwd.TextColor3 = Color3.fromRGB(255,255,255); btnFwd.TextScaled = true; btnFwd.BackgroundTransparency = 0.5; Instance.new("UICorner", btnFwd).CornerRadius = UDim.new(0.2,0)
local btnBwd = Instance.new("TextButton", FCMobileUI)
btnBwd.Size = UDim2.new(1, 0, 0.45, 0); btnBwd.Position = UDim2.new(0, 0, 0.55, 0); btnBwd.BackgroundColor3 = Color3.fromRGB(30,30,30); btnBwd.Text = "▼"; btnBwd.TextColor3 = Color3.fromRGB(255,255,255); btnBwd.TextScaled = true; btnBwd.BackgroundTransparency = 0.5; Instance.new("UICorner", btnBwd).CornerRadius = UDim.new(0.2,0)

btnFwd.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then fwdDown = true end end)
btnFwd.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then fwdDown = false end end)
btnBwd.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then bwdDown = true end end)
btnBwd.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then bwdDown = false end end)

-- ===================== LINORIA INTERFACE =====================
Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({ Title = "Chrono Hub", Footer = "Premium Edition", Icon = "clock", NotifySide = "Right", ShowCustomCursor = true })
local Tabs = {
	Info = Window:AddTab("Info", "info"),
	Main = Window:AddTab("Main", "house"),
	Visuals = Window:AddTab("Visuals", "eye"),
	Player = Window:AddTab("Player", "user"),
	Combat = Window:AddTab("Combat", "swords"),
	TeamCheck = Window:AddTab("Team Check", "users"),
	FreeCam = Window:AddTab("Free Camera", "camera"),
	UISettings = Window:AddTab("UI Settings", "settings"),
}

local function GetPlayerNames()
    local names = {"None"}
    for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(names, p.Name) end end
    return names
end

-- ===================== PUMPKIN ESP FUNCTIONS =====================
local function applyPumpkinESP(pumpkinModel)
    if not pumpkinModel or not (pumpkinModel:IsA("Model") or pumpkinModel:IsA("BasePart")) then return end
    if pumpkinModel:FindFirstChild("PumpkinESPContainer") then return end

    local targetPart = pumpkinModel:FindFirstChild("HumanoidRootPart") 
        or (pumpkinModel:IsA("Model") and pumpkinModel.PrimaryPart) 
        or pumpkinModel:FindFirstChildWhichIsA("BasePart") 
        or pumpkinModel

    local container = Instance.new("Folder")
    container.Name = "PumpkinESPContainer"
    container.Parent = pumpkinModel

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.FillColor = pumpkinEspColor
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.Adornee = targetPart
    highlight.Parent = container

    if targetPart:IsA("BasePart") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESPText"
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 120, 0, 30)
        billboard.StudsOffset = Vector3.new(0, 2.5, 0)
        billboard.Adornee = targetPart
        billboard.Parent = container

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = "🎃 Pumpkin"
        label.TextColor3 = Color3.fromRGB(210, 100, 255)
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        label.Font = Enum.Font.SourceSansBold
        label.TextSize = 14
        label.Parent = billboard
    end
end

local function removePumpkinESP(pumpkinModel)
    if pumpkinModel and pumpkinModel:FindFirstChild("PumpkinESPContainer") then
        pumpkinModel.PumpkinESPContainer:Destroy()
    end
end

local function scanAndApplyPumpkinESP()
    local purpleFolder = workspace:FindFirstChild("PurplePumpkins")
    local itemsToScan = {}

    if purpleFolder then
        for _, child in ipairs(purpleFolder:GetChildren()) do
            table.insert(itemsToScan, child)
        end
    end

    for _, desc in ipairs(workspace:GetDescendants()) do
        if desc.Name == "PurplePumpkin" then
            table.insert(itemsToScan, desc)
        end
    end

    for _, item in ipairs(itemsToScan) do
        if item.Name == "PurplePumpkin" then
            if pumpkinEspEnabled then
                applyPumpkinESP(item)
            else
                removePumpkinESP(item)
            end
        end
    end
end

workspace.DescendantAdded:Connect(function(descendant)
    if pumpkinEspEnabled and descendant.Name == "PurplePumpkin" then
        task.wait(0.1)
        applyPumpkinESP(descendant)
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if pumpkinEspEnabled then
            scanAndApplyPumpkinESP()
        end
    end
end)

-- ===================== TAB: INFO =====================
local UserBox = Tabs.Info:AddLeftGroupbox("User Profile")
local AvatarContainer = Instance.new("Frame", UserBox.Container)
AvatarContainer.Size = UDim2.new(1, 0, 0, 200)
AvatarContainer.BackgroundTransparency = 1
local AvatarImage = Instance.new("ImageLabel", AvatarContainer)
AvatarImage.Size = UDim2.new(0, 180, 0, 180)
AvatarImage.Position = UDim2.new(0.5, -90, 0.5, -90)
AvatarImage.BackgroundTransparency = 1
Instance.new("UICorner", AvatarImage).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", AvatarImage).Color = Color3.fromRGB(50, 50, 50)

task.spawn(function()
	local ok, content = pcall(function() return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) end)
	if ok and content then
		AvatarImage.Image = content; pcall(function() ContentProvider:PreloadAsync({AvatarImage}) end)
	else
		AvatarImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=420&h=420"
	end
end)

local InfoBox = Tabs.Info:AddRightGroupbox("Player Information")
InfoBox:AddLabel("Username: " .. LocalPlayer.Name)
InfoBox:AddLabel("Display Name: " .. LocalPlayer.DisplayName)
InfoBox:AddLabel("Player ID: " .. LocalPlayer.UserId)
InfoBox:AddLabel("Total Executions: " .. tostring(ExecCount))

local StatsBox = Tabs.Info:AddRightGroupbox("Game Stats")
local FPSLabel = StatsBox:AddLabel("FPS: Calculating...")
local PingLabel = StatsBox:AddLabel("Ping: Calculating...")

local ServerBox = Tabs.Info:AddRightGroupbox("Server Info")
local CountryLabel = ServerBox:AddLabel("Country: Fetching...")
local AgeLabel = ServerBox:AddLabel("Age: 00m 00s")
local PlayersLabel = ServerBox:AddLabel("Players: 0/0")

task.spawn(function()
    local req = (syn and syn.request) or request or http_request or (fluxus and fluxus.request)
    if req then
        pcall(function()
            local res = req({Url = "http://ip-api.com/json/", Method = "GET"})
            if res and res.Body then
                local data = HttpService:JSONDecode(res.Body)
                if data and data.country then
                    CountryLabel:SetText("Country: 🌍 " .. data.country)
                    return
                end
            end
        end)
    end
    CountryLabel:SetText("Country: Unknown")
end)

local function FormatServerAge(seconds)
    local d = math.floor(seconds / 86400)
    local h = math.floor((seconds % 86400) / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = math.floor(seconds % 60)
    
    local str = ""
    if d > 0 then str = str .. d .. "d " end
    if h > 0 or d > 0 then str = str .. h .. "h " end
    str = str .. string.format("%02dm %02ds", m, s)
    return str
end

-- ===================== TAB: MAIN =====================
local ESPBox = Tabs.Main:AddLeftGroupbox("ESP Settings")
local ESPMasterTog = ESPBox:AddToggle("ESPMaster", { Text = "Enable ESP", Default = false, Tooltip = "Enables main ESP system" })
ESPMasterTog:OnChanged(function(v) ESPSettings.Master = v end)
ESPMasterTog:AddColorPicker("ESPColor", { Default = Color3.fromRGB(255, 50, 50), Title = "ESP Color", Tooltip = "Color for all ESP elements" })
Library.Options.ESPColor:OnChanged(function() ESPColor = Library.Options.ESPColor.Value end)
ESPBox:AddToggle("ESPHighlight", { Text = "ESP Highlight", Default = true, Tooltip = "Highlights players through walls" }):OnChanged(function(v) ESPSettings.Highlight = v end)
ESPBox:AddToggle("ESPBox", { Text = "ESP Box", Default = false, Tooltip = "Draws a box around players" }):OnChanged(function(v) ESPSettings.Box = v end)
ESPBox:AddToggle("ESPName", { Text = "ESP Name", Default = false, Tooltip = "Shows player names" }):OnChanged(function(v) ESPSettings.Name = v end)
ESPBox:AddToggle("ESPHP", { Text = "ESP Health", Default = false, Tooltip = "Shows player health bars" }):OnChanged(function(v) ESPSettings.HP = v end)
ESPBox:AddToggle("ESPStuds", { Text = "ESP Distance (Studs)", Default = false, Tooltip = "Shows distance to players" }):OnChanged(function(v) ESPSettings.Studs = v end)
ESPBox:AddToggle("ESPSkeleton", { Text = "ESP Skeleton", Default = false, Tooltip = "Shows player skeleton" }):OnChanged(function(v) ESPSettings.Skeleton = v end)

-- Pumpkin ESP Module
local PumpkinESPBox = Tabs.Main:AddLeftGroupbox("Pumpkin ESP")
local PumpkinESPTog = PumpkinESPBox:AddToggle("PumpkinESPTog", { Text = "Enable Pumpkin ESP", Default = false, Tooltip = "Highlights PurplePumpkin models in workspace" })
PumpkinESPTog:OnChanged(function(v)
    pumpkinEspEnabled = v
    scanAndApplyPumpkinESP()
end)
PumpkinESPTog:AddColorPicker("PumpkinESPColor", { Default = Color3.fromRGB(170, 0, 255), Title = "Pumpkin ESP Color" })
Library.Options.PumpkinESPColor:OnChanged(function()
    pumpkinEspColor = Library.Options.PumpkinESPColor.Value
    scanAndApplyPumpkinESP()
end)

local MainControlsBox = Tabs.Main:AddRightGroupbox("Controls & Hitbox")
MainControlsBox:AddToggle("EnableJump", { Text = "Enable Jump", Default = false, Tooltip = "Enables jump and mobile jump button" }):OnChanged(function(v) EnableJumpToggle = v end)

MainControlsBox:AddToggle("GravityTog", { Text = "Gravity Changer", Default = false, Tooltip = "Enable custom gravity" }):OnChanged(function(v)
    GravityEnabled = v
    workspace.Gravity = v and CustomGravity or OriginalGravity
end
