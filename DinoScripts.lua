-- =================================================================
-- MY DINO LIFE SCRIPT HUB (LinoriaLib UI) - UPDATED
-- =================================================================

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

-- Shortcuts for LinoriaLib Flags
local Toggles = Library.Toggles
local Options = Library.Options

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
local UserInputService = getSvc("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ===================== INFO TAB LOGIC =====================
local ExecCount = 1
pcall(function()
	if isfile and readfile and writefile then
		if isfile("MyDinoLife_Execs.txt") then
			ExecCount = tonumber(readfile("MyDinoLife_Execs.txt")) or 0
			ExecCount = ExecCount + 1
		end
		writefile("MyDinoLife_Execs.txt", tostring(ExecCount))
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
    Title = "My Dino Life",
    Center = true,
    AutoShow = true,
    ShowCustomCursor = true
})

local Tabs = {
	Info = Window:AddTab("Info", "info"),
	Player = Window:AddTab("Player", "user"),
	Esp = Window:AddTab("ESP", "eye"),
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

-- DRAGGABLE COORDS GUI (Standalone)
local targetParent = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
local CoordsGui = Instance.new("ScreenGui")
CoordsGui.Name = "MyDinoLife_CoordsGui"
CoordsGui.Parent = targetParent
CoordsGui.Enabled = false

local CoordsFrame = Instance.new("Frame", CoordsGui)
CoordsFrame.Size = UDim2.new(0, 220, 0, 80)
CoordsFrame.Position = UDim2.new(0.5, -110, 0.1, 0)
CoordsFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
CoordsFrame.BorderSizePixel = 0
Instance.new("UICorner", CoordsFrame).CornerRadius = UDim.new(0, 8)

local Topbar = Instance.new("Frame", CoordsFrame)
Topbar.Size = UDim2.new(1, 0, 0, 22)
Topbar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 8)

-- Скриваем нижні кути топбару, щоб виглядав прикріпленим
local TopbarFix = Instance.new("Frame", Topbar)
TopbarFix.Size = UDim2.new(1, 0, 0.5, 0)
TopbarFix.Position = UDim2.new(0, 0, 0.5, 0)
TopbarFix.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TopbarFix.BorderSizePixel = 0

local TitleLabel = Instance.new("TextLabel", Topbar)
TitleLabel.Size = UDim2.new(1, -10, 1, 0)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "📍 Live Coordinates"
TitleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 12
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local XYZLabel = Instance.new("TextLabel", CoordsFrame)
XYZLabel.Size = UDim2.new(1, 0, 0, 25)
XYZLabel.Position = UDim2.new(0, 0, 0, 25)
XYZLabel.BackgroundTransparency = 1
XYZLabel.Text = "X: 0 | Y: 0 | Z: 0"
XYZLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
XYZLabel.Font = Enum.Font.GothamSemibold
XYZLabel.TextSize = 13

local CopyBtn = Instance.new("TextButton", CoordsFrame)
CopyBtn.Size = UDim2.new(0.8, 0, 0, 22)
CopyBtn.Position = UDim2.new(0.1, 0, 0, 52)
CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
CopyBtn.Text = "Copy to Clipboard"
CopyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyBtn.Font = Enum.Font.Gotham
CopyBtn.TextSize = 12
Instance.new("UICorner", CopyBtn).CornerRadius = UDim.new(0, 4)

-- Logic for Draggable Frame
local dragging, dragInput, mousePos, framePos
Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = CoordsFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
Topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        CoordsFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

-- Copy Button Logic
CopyBtn.MouseButton1Click:Connect(function()
    local setclip = setclipboard or toclipboard or set_clipboard
    if setclip then
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local pos = hrp.Position
            setclip(string.format("%.1f, %.1f, %.1f", pos.X, pos.Y, pos.Z))
            CopyBtn.Text = "Copied!"
            CopyBtn.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
            task.delay(1.5, function() 
                CopyBtn.Text = "Copy to Clipboard" 
                CopyBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            end)
        end
    else
        CopyBtn.Text = "Executor doesn't support copy"
        task.delay(1.5, function() CopyBtn.Text = "Copy to Clipboard" end)
    end
end)

local ServerBox = Tabs.Info:AddRightGroupbox("Server Info")
local CountryLabel = ServerBox:AddLabel("Country: Fetching...")
local AgeLabel = ServerBox:AddLabel("Age: 00m 00s")
local PlayersLabel = ServerBox:AddLabel("Players: 0/0")

-- FPS Unlocker Toggle
local setfps = setfpscap or set_fps_cap
StatsBox:AddToggle("FPSUnlocker", {
    Text = "FPS Unlocker",
    Default = true,
    Tooltip = "Unlocks maximum FPS limit"
}):OnChanged(function(v)
    if setfps then setfps(v and 240 or 60) end
end)
if setfps then setfps(240) end

-- Show Coordinates Toggle
StatsBox:AddToggle("ShowCoordsToggle", {
    Text = "Show Coordinates",
    Default = false,
    Tooltip = "Spawns a draggable panel with your XYZ location"
}):OnChanged(function(v)
    CoordsGui.Enabled = v
end)

task.spawn(function()
    local req = (syn and syn.request) or request or http_request or (fluxus and fluxus.request)
    if req then
        pcall(function()
            local res = req({Url = "http://ip-api.com/json/", Method = "GET"})
            if res and res.Body then
                local data = HttpService:JSONDecode(res.Body)
                if data and data.country then
                    CountryLabel:SetText("Country: " .. data.country)
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
local flyEnabled = false

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

MoveBox:AddDivider()

-- FLY FEATURE (Mobile + AntiCheat safe)
MoveBox:AddToggle("FlyToggle", { 
    Text = "Fly", 
    Default = false, 
    Tooltip = "Enable Flight (Compatible with Mobile Joystick)" 
}):OnChanged(function(v) 
    flyEnabled = v 
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.PlatformStand = v -- Prevents tripping or attempting to walk on invisible objects
    end
end)

MoveBox:AddSlider("FlySpeed", { 
    Text = "Fly Speed", 
    Default = 50, 
    Min = 10, 
    Max = 200, 
    Rounding = 0, 
    Tooltip = "Adjust your flight speed" 
})

local pauseTimer = 0
local lastPosition = nil
local smoothedSpeed = 0

-- Stepped Loop: Best for Fly logic (runs before physics simulate to bypass AC checks)
RunService.Stepped:Connect(function(_, deltaTime)
    if flyEnabled then
        local char = LocalPlayer.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        
        if hum and hrp and hum.Health > 0 then
            -- Neutralize gravity falling (Bypasses BodyMover AC checks)
            hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

            local moveDir = hum.MoveDirection
            if moveDir.Magnitude > 0 then
                local camCFrame = Workspace.CurrentCamera.CFrame
                
                -- Translates mobile joystick/WASD input into the exact direction the camera is looking
                local flatCamLook = Vector3.new(camCFrame.LookVector.X, 0, camCFrame.LookVector.Z).Unit
                local camRight = camCFrame.RightVector
                
                local forwardDot = moveDir:Dot(flatCamLook)
                local rightDot = moveDir:Dot(camRight)
                
                local finalDirection = (camCFrame.LookVector * forwardDot) + (camCFrame.RightVector * rightDot)
                
                -- Stealthy CFrame manipulation
                hrp.CFrame = hrp.CFrame + (finalDirection * (Options.FlySpeed.Value * deltaTime))
            end
        end
    end
end)

-- Heartbeat Loop: For Speed bypass and UI updating
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

    -- UPDATE COORDS GUI
    if CoordsGui.Enabled and hrp then
        local p = hrp.Position
        XYZLabel.Text = string.format("X: %.1f | Y: %.1f | Z: %.1f", p.X, p.Y, p.Z)
    end

    -- SPEED CALCULATOR
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

    -- SPEED BYPASS LOGIC (Disabled if flying to avoid conflicts)
    if flyEnabled or not speedEnabled or not humanoid or not hrp or humanoid.Health <= 0 then return end
    if humanoid.FloorMaterial == Enum.Material.Air then return end

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

LocalPlayer.CharacterAdded:Connect(function(char)
    lastPosition = nil
    smoothedSpeed = 0
    local hum = char:WaitForChild("Humanoid", 5)
    if hum and flyEnabled then
        hum.PlatformStand = true
    end
end)

-- ===================== TAB: ESP =====================
local PlayerEspBox = Tabs.Esp:AddLeftGroupbox("Player ESP Settings")

local playerEspToggle = PlayerEspBox:AddToggle("PlayerESP", {
    Text = "ESP Players",
    Default = false,
    Tooltip = "Highlights players with ESP features"
})

playerEspToggle:AddColorPicker("PlayerESPColor", {
    Default = Color3.fromRGB(255, 50, 50),
    Title = "ESP Color"
})

PlayerEspBox:AddToggle("ESP_Snapline", { Text = "Snapline", Default = false })
PlayerEspBox:AddToggle("ESP_Name", { Text = "Name", Default = false })
PlayerEspBox:AddToggle("ESP_Health", { Text = "Health", Default = false })

local PlayerESP_Data = {}

local function createPlayerESP(player)
    if player == LocalPlayer then return end
    
    local espObj = {
        Player = player,
        Highlight = nil,
        Billboard = nil,
        NameLabel = nil,
        HealthLabel = nil,
        Line = nil
    }

    if Drawing then
        pcall(function()
            local line = Drawing.new("Line")
            line.Thickness = 1.5
            line.Transparency = 1
            line.Visible = false
            espObj.Line = line
        end)
    end

    PlayerESP_Data[player] = espObj
end

local function removePlayerESP(player)
    local espObj = PlayerESP_Data[player]
    if not espObj then return end

    if espObj.Highlight then espObj.Highlight:Destroy() end
    if espObj.Billboard then espObj.Billboard:Destroy() end
    if espObj.Line then pcall(function() espObj.Line:Remove() end) end

    PlayerESP_Data[player] = nil
end

for _, plr in ipairs(Players:GetPlayers()) do createPlayerESP(plr) end
Players.PlayerAdded:Connect(createPlayerESP)
Players.PlayerRemoving:Connect(removePlayerESP)

RunService.RenderStepped:Connect(function()
    local mainEnabled = Toggles.PlayerESP and Toggles.PlayerESP.Value
    local snapEnabled = Toggles.ESP_Snapline and Toggles.ESP_Snapline.Value
    local nameEnabled = Toggles.ESP_Name and Toggles.ESP_Name.Value
    local hpEnabled = Toggles.ESP_Health and Toggles.ESP_Health.Value
    local espColor = Options.PlayerESPColor and Options.PlayerESPColor.Value or Color3.fromRGB(255, 50, 50)

    for plr, data in pairs(PlayerESP_Data) do
        pcall(function()
            local char = plr.Character
            local hrp = char and (char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head"))
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if mainEnabled and char and hrp and hum and hum.Health > 0 then
                -- Highlight
                if not data.Highlight or data.Highlight.Parent ~= char then
                    if data.Highlight then data.Highlight:Destroy() end
                    local hl = Instance.new("Highlight")
                    hl.Name = "PlayerHighlight"
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                    hl.Adornee = char
                    hl.Parent = char
                    data.Highlight = hl
                end
                data.Highlight.FillColor = espColor
                data.Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                data.Highlight.Enabled = true

                -- Billboard GUI (Name/Health)
                if not data.Billboard or data.Billboard.Parent ~= hrp then
                    if data.Billboard then data.Billboard:Destroy() end
                    
                    local bb = Instance.new("BillboardGui")
                    bb.Name = "PlayerESP_Text"
                    bb.AlwaysOnTop = true
                    bb.Size = UDim2.new(0, 150, 0, 40)
                    bb.StudsOffset = Vector3.new(0, 3, 0)
                    bb.Adornee = hrp

                    local frame = Instance.new("Frame", bb)
                    frame.Size = UDim2.new(1, 0, 1, 0)
                    frame.BackgroundTransparency = 1

                    local layout = Instance.new("UIListLayout", frame)
                    layout.SortOrder = Enum.SortOrder.LayoutOrder
                    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

                    local nameL = Instance.new("TextLabel", frame)
                    nameL.Size = UDim2.new(1, 0, 0, 18)
                    nameL.BackgroundTransparency = 1
                    nameL.Font = Enum.Font.SourceSansBold
                    nameL.TextSize = 14
                    nameL.TextStrokeTransparency = 0

                    local hpL = Instance.new("TextLabel", frame)
                    hpL.Size = UDim2.new(1, 0, 0, 16)
                    hpL.BackgroundTransparency = 1
                    hpL.Font = Enum.Font.SourceSansBold
                    hpL.TextSize = 13
                    hpL.TextColor3 = Color3.fromRGB(100, 255, 100)
                    hpL.TextStrokeTransparency = 0

                    bb.Parent = hrp
                    data.Billboard = bb
                    data.NameLabel = nameL
                    data.HealthLabel = hpL
                end

                data.NameLabel.Visible = nameEnabled
                data.NameLabel.Text = plr.DisplayName or plr.Name
                data.NameLabel.TextColor3 = espColor

                data.HealthLabel.Visible = hpEnabled
                data.HealthLabel.Text = string.format("HP: %d/%d", math.floor(hum.Health), math.floor(hum.MaxHealth))

                -- Snapline
                if data.Line then
                    if snapEnabled then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                        if onScreen then
                            data.Line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            data.Line.To = Vector2.new(screenPos.X, screenPos.Y)
                            data.Line.Color = espColor
                            data.Line.Visible = true
                        else
                            data.Line.Visible = false
                        end
                    else
                        data.Line.Visible = false
                    end
                end
            else
                if data.Highlight then data.Highlight.Enabled = false end
                if data.Billboard then data.Billboard.Parent = nil end
                if data.Line then data.Line.Visible = false end
            end
        end)
    end
end)

-- Food ESP Section
local FoodEspBox = Tabs.Esp:AddRightGroupbox("Food ESP Settings")

FoodEspBox:AddToggle("FoodESP", { Text = "ESP Food", Default = false })
FoodEspBox:AddDropdown("FoodFilter", {
    Values = { "Red Orb", "Yellow Orb", "Blue Orb" },
    Default = { "Red Orb", "Yellow Orb", "Blue Orb" },
    Multi = true,
    Text = "Select Food Types"
})

local function getOrbTypeAndColor(item)
    local part = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
    if not part then return nil, nil end

    local c = part.Color
    local r, g, b = math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5)

    if math.abs(r - 210) <= 30 and math.abs(g - 45) <= 30 and math.abs(b - 60) <= 30 then
        return "Red Orb", Color3.fromRGB(210, 45, 60)
    elseif math.abs(r - 255) <= 30 and math.abs(g - 200) <= 30 and math.abs(b - 40) <= 30 then
        return "Yellow Orb", Color3.fromRGB(255, 200, 40)
    elseif math.abs(r - 60) <= 30 and math.abs(g - 170) <= 30 and math.abs(b - 255) <= 30 then
        return "Blue Orb", Color3.fromRGB(60, 170, 255)
    end
    return nil, nil
end

local function applyFoodESP(item)
    local orbType, orbColor = getOrbTypeAndColor(item)
    local enabled = Toggles.FoodESP and Toggles.FoodESP.Value
    local selectedTypes = Options.FoodFilter and Options.FoodFilter.Value or {}

    local container = item:FindFirstChild("FoodESPContainer")

    if enabled and orbType and selectedTypes[orbType] then
        if not container then
            local targetPart = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
            if not targetPart then return end

            container = Instance.new("Folder")
            container.Name = "FoodESPContainer"
            container.Parent = item

            local hl = Instance.new("Highlight")
            hl.Name = "FoodHL"
            hl.FillTransparency = 0.4
            hl.OutlineTransparency = 0
            hl.FillColor = orbColor
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.Adornee = item
            hl.Parent = container

            local bb = Instance.new("BillboardGui")
            bb.Name = "FoodText"
            bb.AlwaysOnTop = true
            bb.Size = UDim2.new(0, 120, 0, 30)
            bb.StudsOffset = Vector3.new(0, 1.5, 0)
            bb.Adornee = targetPart
            bb.Parent = container

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = orbType
            label.TextColor3 = orbColor
            label.TextStrokeTransparency = 0
            label.Font = Enum.Font.SourceSansBold
            label.TextSize = 14
            label.Parent = bb
        end
    else
        if container then container:Destroy() end
    end
end

local function updateFoodESP()
    local foodFolder = Workspace:FindFirstChild("Food")
    if not foodFolder then return end
    for _, item in ipairs(foodFolder:GetChildren()) do
        applyFoodESP(item)
    end
end

Toggles.FoodESP:OnChanged(updateFoodESP)
Options.FoodFilter:OnChanged(updateFoodESP)

-- ===================== TAB: HALLOWEEN =====================
local HalloweenBox = Tabs.Halloween:AddLeftGroupbox("Halloween Events")

-- Pumpkin ESP
local pumpkinEspEnabled = false
local function applyPumpkinESP(pumpkinModel)
    if not pumpkinModel then return end
    if pumpkinModel:FindFirstChild("PumpkinESPContainer") then return end

    local targetPart = pumpkinModel:FindFirstChild("HumanoidRootPart") 
        or (pumpkinModel:IsA("Model") and pumpkinModel.PrimaryPart) 
        or pumpkinModel:FindFirstChildWhichIsA("BasePart", true) 

    if not targetPart then return end

    local container = Instance.new("Folder")
    container.Name = "PumpkinESPContainer"
    container.Parent = pumpkinModel

    local highlight = Instance.new("Highlight")
    highlight.Name = "ESPHighlight"
    highlight.FillColor = Color3.fromRGB(170, 0, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.Adornee = pumpkinModel
    highlight.Parent = container

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

local function removePumpkinESP(pumpkinModel)
    if pumpkinModel and pumpkinModel:FindFirstChild("PumpkinESPContainer") then
        pumpkinModel.PumpkinESPContainer:Destroy()
    end
end

local function scanAndApplyPumpkins()
    local purpleFolder = Workspace:FindFirstChild("PurplePumpkins")
    local itemsToScan = {}

    if purpleFolder then
        for _, child in ipairs(purpleFolder:GetChildren()) do table.insert(itemsToScan, child) end
    end

    for _, desc in ipairs(Workspace:GetDescendants()) do
        if desc.Name == "PurplePumpkin" then table.insert(itemsToScan, desc) end
    end

    for _, item in ipairs(itemsToScan) do
        if item.Name == "PurplePumpkin" then
            if pumpkinEspEnabled then applyPumpkinESP(item) else removePumpkinESP(item) end
        end
    end
end

HalloweenBox:AddToggle("PumpkinESP", { 
    Text = "Pumpkin ESP", 
    Default = false, 
    Tooltip = "Highlights all Purple Pumpkins" 
}):OnChanged(function(v) 
    pumpkinEspEnabled = v 
    scanAndApplyPumpkins()
end)

-- Candy ESP
local function checkIsCandy(obj)
    if not obj then return false end
    local mesh = obj:IsA("MeshPart") and obj or obj:FindFirstChildWhichIsA("MeshPart", true)
    if mesh and mesh.TextureID == "rbxassetid://134929231564985" then
        return true
    end
    local specialMesh = obj:FindFirstChildWhichIsA("SpecialMesh", true)
    if specialMesh and specialMesh.TextureId == "rbxassetid://134929231564985" then
        return true
    end
    return false
end

local function applyCandyESP(item)
    if not checkIsCandy(item) then return end
    local enabled = Toggles.CandyESP and Toggles.CandyESP.Value
    local container = item:FindFirstChild("CandyESPContainer")

    if enabled then
        if not container then
            local targetPart = item:IsA("BasePart") and item or item:FindFirstChildWhichIsA("BasePart", true)
            if not targetPart then return end

            container = Instance.new("Folder")
            container.Name = "CandyESPContainer"
            container.Parent = item

            local hl = Instance.new("Highlight")
            hl.FillColor = Color3.fromRGB(255, 140, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.FillTransparency = 0.3
            hl.Adornee = item
            hl.Parent = container

            local bb = Instance.new("BillboardGui")
            bb.AlwaysOnTop = true
            bb.Size = UDim2.new(0, 120, 0, 30)
            bb.StudsOffset = Vector3.new(0, 2, 0)
            bb.Adornee = targetPart
            bb.Parent = container

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = "🍬 Candy"
            label.TextColor3 = Color3.fromRGB(255, 140, 0)
            label.TextStrokeTransparency = 0
            label.Font = Enum.Font.SourceSansBold
            label.TextSize = 14
            label.Parent = bb
        end
    else
        if container then container:Destroy() end
    end
end

local function updateCandyESP()
    local foodFolder = Workspace:FindFirstChild("Food")
    if not foodFolder then return end
    for _, child in ipairs(foodFolder:GetChildren()) do
        applyCandyESP(child)
    end
end

HalloweenBox:AddToggle("CandyESP", { 
    Text = "ESP Candy", 
    Default = false, 
    Tooltip = "Highlights Halloween Candies in Workspace.Food" 
}):OnChanged(updateCandyESP)

-- Halloween Enemies ESP
local HalloweenEnemiesBox = Tabs.Halloween:AddRightGroupbox("Halloween Enemies")

HalloweenEnemiesBox:AddToggle("EnemiesESP", { Text = "ESP Enemies", Default = false })
HalloweenEnemiesBox:AddDropdown("EnemiesFilter", {
    Values = { "Witch", "Bone", "Spider" },
    Default = { "Witch", "Bone", "Spider" },
    Multi = true,
    Text = "Select Enemies"
})

local enemyNameMap = {
    ["Witch Therizinosaurus"] = "Witch",
    ["Bone Dilophosaurus"] = "Bone",
    ["Spider Dilophosaurus"] = "Spider"
}

local function applyEnemyESP(model)
    if not model then return end
    local shortName = enemyNameMap[model.Name]
    if not shortName then
        if model.Name:find("Witch") then shortName = "Witch"
        elseif model.Name:find("Bone") then shortName = "Bone"
        elseif model.Name:find("Spider") then shortName = "Spider" end
    end
    if not shortName then return end

    local enabled = Toggles.EnemiesESP and Toggles.EnemiesESP.Value
    local selectedEnemies = Options.EnemiesFilter and Options.EnemiesFilter.Value or {}
    local container = model:FindFirstChild("EnemyESPContainer")

    if enabled and selectedEnemies[shortName] then
        if not container then
            local targetPart = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart", true)
            if not targetPart then return end

            container = Instance.new("Folder")
            container.Name = "EnemyESPContainer"
            container.Parent = model

            local hl = Instance.new("Highlight")
            hl.FillColor = Color3.fromRGB(255, 80, 0)
            hl.OutlineColor = Color3.fromRGB(255, 255, 0)
            hl.FillTransparency = 0.3
            hl.Adornee = model
            hl.Parent = container

            local bb = Instance.new("BillboardGui")
            bb.AlwaysOnTop = true
            bb.Size = UDim2.new(0, 120, 0, 30)
            bb.StudsOffset = Vector3.new(0, 3, 0)
            bb.Adornee = targetPart
            bb.Parent = container

            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, 0, 1, 0)
            label.BackgroundTransparency = 1
            label.Text = "👾 " .. shortName
            label.TextColor3 = Color3.fromRGB(255, 120, 0)
            label.TextStrokeTransparency = 0
            label.Font = Enum.Font.SourceSansBold
            label.TextSize = 15
            label.Parent = bb
        end
    else
        if container then container:Destroy() end
    end
end

local function updateEnemiesESP()
    local enemiesFolder = Workspace:FindFirstChild("HalloweenEnemies")
    if not enemiesFolder then return end
    for _, enemy in ipairs(enemiesFolder:GetChildren()) do
        applyEnemyESP(enemy)
    end
end

Toggles.EnemiesESP:OnChanged(updateEnemiesESP)
Options.EnemiesFilter:OnChanged(updateEnemiesESP)

-- Continuous Scanner Thread for Workspace Events
task.spawn(function()
    while true do
        task.wait(1.5)
        pcall(function()
            if pumpkinEspEnabled then scanAndApplyPumpkins() end
            if Toggles.FoodESP and Toggles.FoodESP.Value then updateFoodESP() end
            if Toggles.CandyESP and Toggles.CandyESP.Value then updateCandyESP() end
            if Toggles.EnemiesESP and Toggles.EnemiesESP.Value then updateEnemiesESP() end
        end)
    end
end)

-- ===================== UI INITIALIZATION =====================
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
ThemeManager:SetFolder('MyDinoLife')
SaveManager:SetFolder('MyDinoLife/Configs')

Library:SetWatermark("My Dino Life | Premium")
Library:Notify("My Dino Life Loaded Successfully!", 3)
