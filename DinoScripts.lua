-- =================================================================
-- MERGED HUB (LinoriaLib UI)
-- =================================================================

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

-- ===================== SERVICES =====================
local function getSvc(serviceName)
	local s = game:GetService(serviceName)
	return (cloneref and cloneref(s)) or s
end

local Players = getSvc("Players")
local RunService = getSvc("RunService")
local HttpService = getSvc("HttpService")
local ContentProvider = getSvc("ContentProvider")
local Workspace = getSvc("Workspace")

local LocalPlayer = Players.LocalPlayer

-- ===================== INFO TAB LOGIC =====================
local ExecCount = 1
pcall(function()
	if isfile and readfile and writefile then
		if isfile("MergedHub_Execs.txt") then
			ExecCount = tonumber(readfile("MergedHub_Execs.txt")) or 0
			ExecCount = ExecCount + 1
		end
		writefile("MergedHub_Execs.txt", tostring(ExecCount))
	end
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

-- ===================== UI SETUP =====================
local Window = Library:CreateWindow({
    Title = "Custom Script Hub",
    Center = true,
    AutoShow = true,
    ShowCustomCursor = true
})

-- Creating Tabs with Icons
local Tabs = {
	Info = Window:AddTab("Info", "info"),
	Player = Window:AddTab("Player", "user"),
	Esp = Window:AddTab("Esp", "eye"),
    Halloween = Window:AddTab("Halloween", "ghost")
}

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
	local ok, content = pcall(function() 
        return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420) 
    end)
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

local lastFpsTick = tick()
RunService.RenderStepped:Connect(function(dt)
	if tick() - lastFpsTick >= 0.5 then
		pcall(function() 
            FPSLabel:SetText("FPS: " .. math.round(1 / dt))
            PingLabel:SetText("Ping: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000) .. " ms") 
            AgeLabel:SetText("Age: " .. FormatServerAge(workspace.DistributedGameTime))
            PlayersLabel:SetText("Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers)
        end)
		lastFpsTick = tick()
	end
end)

-- ===================== TAB: PLAYER =====================
local speedEnabled = false
local bonusSpeed = 1.5

local MoveBox = Tabs.Player:AddLeftGroupbox("Movement Enhancements")

MoveBox:AddToggle("SpeedBypass", { 
    Text = "Speed Bypass", 
    Default = false, 
    Tooltip = "Enables bypassed speed modifications" 
}):OnChanged(function(v) 
    speedEnabled = v 
end)

MoveBox:AddSlider("SpeedBonus", { 
    Text = "Bonus Speed", 
    Default = 1.5, 
    Min = 0.1, 
    Max = 20.0, 
    Rounding = 1, 
    Tooltip = "Adjust your extra movement speed" 
}):OnChanged(function(v) 
    bonusSpeed = v 
end)

local SpeedLabel = MoveBox:AddLabel("Studs/s: 0.0")

-- Speedometer & Speed Bypass Loop
local pauseTimer = 0
local lastPosition = nil
local smoothedSpeed = 0

RunService.Heartbeat:Connect(function(deltaTime)
    local char = LocalPlayer.Character
    if not char then 
        lastPosition = nil
        smoothedSpeed = 0
        SpeedLabel:SetText("Studs/s: 0.0")
        return 
    end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local hrp = char:FindFirstChild("HumanoidRootPart")

    -- Real Position Speed Calculation
    if hrp and deltaTime > 0 then
        local currentPos = Vector3.new(hrp.Position.X, 0, hrp.Position.Z)
        
        if lastPosition then
            local distanceMoved = (currentPos - lastPosition).Magnitude
            local rawSpeed = distanceMoved / deltaTime
            
            if distanceMoved < 60 then
                smoothedSpeed = smoothedSpeed + (rawSpeed - smoothedSpeed) * math.min(deltaTime * 10, 1)
            else
                smoothedSpeed = 0
            end
        end
        lastPosition = currentPos
        SpeedLabel:SetText(string.format("Studs/s: %.1f", smoothedSpeed))
    else
        lastPosition = nil
        smoothedSpeed = 0
        SpeedLabel:SetText("Studs/s: 0.0")
    end

    -- Bypass Speed Injection Logic
    if not speedEnabled or not humanoid or not hrp or humanoid.Health <= 0 then return end
    if humanoid.FloorMaterial == Enum.Material.Air then return end

    -- Simulate network latency jitter
    pauseTimer = pauseTimer + deltaTime
    if pauseTimer > math.random(4, 7) then
        pauseTimer = 0
        return
    end

    local moveDir = humanoid.MoveDirection
    if moveDir.Magnitude > 0.1 then
        local extraVector = moveDir * (bonusSpeed * deltaTime)
        hrp.CFrame = hrp.CFrame + extraVector
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    lastPosition = nil
    smoothedSpeed = 0
end)

-- ===================== TAB: ESP =====================
local EspBox = Tabs.Esp:AddLeftGroupbox("Player ESP Settings")
EspBox:AddLabel("ESP Features coming soon...")

-- ===================== TAB: HALLOWEEN =====================
local espEnabled = false
local HalloweenBox = Tabs.Halloween:AddLeftGroupbox("Event Helpers")

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
    highlight.FillColor = Color3.fromRGB(170, 0, 255)
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

local function scanAndApplyESP()
    local purpleFolder = Workspace:FindFirstChild("PurplePumpkins")
    local itemsToScan = {}

    if purpleFolder then
        for _, child in ipairs(purpleFolder:GetChildren()) do
            table.insert(itemsToScan, child)
        end
    end

    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name == "PurplePumpkin" then
            table.insert(itemsToScan, desc)
        end
    end

    for _, item in ipairs(itemsToScan) do
        if item.Name == "PurplePumpkin" then
            if espEnabled then
                applyPumpkinESP(item)
            else
                removePumpkinESP(item)
            end
        end
    end
end

HalloweenBox:AddToggle("PumpkinESP", { 
    Text = "Pumpkin ESP", 
    Default = false, 
    Tooltip = "Highlights all Purple Pumpkins through walls" 
}):OnChanged(function(v) 
    espEnabled = v 
    scanAndApplyESP()
end)

-- Listeners for Pumpkins
Workspace.DescendantAdded:Connect(function(descendant)
    if espEnabled and descendant.Name == "PurplePumpkin" then
        task.wait(0.1)
        applyPumpkinESP(descendant)
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        if espEnabled then
            scanAndApplyESP()
        end
    end
end)

-- ===================== UI INITIALIZATION =====================
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder('CustomHub')
SaveManager:SetFolder('CustomHub/Configs')

-- Build config section inside a dedicated Settings tab if needed, 
-- or just initialize default theme parameters
Library:SetWatermark("Custom Hub | Premium")
Library:Notify("Script Loaded Successfully", 3)
