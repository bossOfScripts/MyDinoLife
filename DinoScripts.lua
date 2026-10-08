-- =================================================================
-- MY DINO LIFE SCRIPT HUB WITH KEY SYSTEM
-- =================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ===================== KEY SYSTEM CONFIG =====================
local CorrectKey = "release" -- ВСТАВТЕ СЮДИ ВАШ АКТУАЛЬНИЙ КЛЮЧ
local DiscordLink = "https://discord.gg/N8VDYjAhSz"
local KeyFileName = "MyDinoLife_SavedKey.txt"

-- Список ID гравців, яким НІКОЛИ не потрібно вводити ключ:
local WhitelistedIDs = {
    [23990447199] = true,
    [15610523877] = true,
    [117343840833] = true
}

-- ===================== MAIN SCRIPT FUNCTION =====================
local function LoadMainScript()
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

    local RunService = getSvc("RunService")
    local HttpService = getSvc("HttpService")
    local ContentProvider = getSvc("ContentProvider")
    local Workspace = getSvc("Workspace")

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
        Halloween = Window:AddTab('<font color="#FFA500">Halloween</font>', "ghost"),
        Discord = Window:AddTab('<font color="#00BFFF">Discord</font>', "message-circle")
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

    local TopbarFix = Instance.new("Frame", Topbar)
    TopbarFix.Size = UDim2.new(1, 0, 0.5, 0)
    TopbarFix.Position = UDim2.new(0, 0, 0.5, 0)
    TopbarFix.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    TopbarFix.BorderSizePixel = 0

    local TitleLabel = Instance.new("TextLabel", Topbar)
    TitleLabel.Size = UDim2.new(1, -10, 1, 0)
    TitleLabel.Position = UDim2.new(0, 10, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "Live Coordinates"
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

    local setfps = setfpscap or set_fps_cap
    StatsBox:AddToggle("FPSUnlocker", {
        Text = "FPS Unlocker",
        Default = true,
        Tooltip = "Unlocks maximum FPS limit"
    }):OnChanged(function(v)
        if setfps then setfps(v and 240 or 60) end
    end)
    if setfps then setfps(240) end

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

    MoveBox:AddToggle("FlyToggle", { 
        Text = "Fly", 
        Default = false, 
        Tooltip = "Enable Flight (Compatible with Mobile Joystick)" 
    }):OnChanged(function(v) 
        flyEnabled = v 
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.PlatformStand = v
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

    -- ===================== SURVIVAL & UTILITY =====================
    local SurvivalBox = Tabs.Player:AddRightGroupbox("Survival & Utility")

    local autoSaveEnabled = false
    local autoSaveThreshold = 30
    local noclipEnabled = false

    SurvivalBox:AddToggle("AutoSaveToggle", {
        Text = "Auto Save",
        Default = false,
        Tooltip = "Teleports to safe zone when HP is low"
    }):OnChanged(function(v)
        autoSaveEnabled = v
    end)

    SurvivalBox:AddSlider("AutoSaveThreshold", {
        Text = "If HP bellow:",
        Default = 30,
        Min = 10,
        Max = 50,
        Rounding = 0,
        Tooltip = "HP threshold to trigger Auto Save"
    }):OnChanged(function(v)
        autoSaveThreshold = v
    end)

    SurvivalBox:AddDivider()

    SurvivalBox:AddToggle("NoclipToggle", {
        Text = "Noclip",
        Default = false,
        Tooltip = "Walk through walls (Undetected)"
    }):OnChanged(function(v)
        noclipEnabled = v
    end)

    -- AUTO SAVE GUI & LOGIC
    local safeZonePos = Vector3.new(-740.4, 46.0, -54.0)
    local safeZoneCFrame = CFrame.new(safeZonePos)
    local platformPos = Vector3.new(-740.4, 43.0, -54.0)
    local leaveCFrame = CFrame.new(-615.0, 41.4, -52.8)

    local inSafeZone = false
    local safePlatform = nil

    local SafeZoneGui = Instance.new("ScreenGui")
    SafeZoneGui.Name = "MyDinoLife_SafeZoneGui"
    SafeZoneGui.ResetOnSpawn = false
    SafeZoneGui.Parent = targetParent 

    local LeaveBtn = Instance.new("TextButton", SafeZoneGui)
    LeaveBtn.Size = UDim2.new(0, 160, 0, 45)
    LeaveBtn.Position = UDim2.new(0.5, -80, 0.05, 0)
    LeaveBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    LeaveBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    LeaveBtn.Font = Enum.Font.GothamBold
    LeaveBtn.TextSize = 16
    LeaveBtn.Text = "Leave Safe Zone"
    LeaveBtn.Visible = false
    Instance.new("UICorner", LeaveBtn).CornerRadius = UDim.new(0, 8)

    local NotifText = Instance.new("TextLabel", SafeZoneGui)
    NotifText.Size = UDim2.new(0, 300, 0, 50)
    NotifText.Position = UDim2.new(0.5, -150, 0.65, 0)
    NotifText.BackgroundTransparency = 1
    NotifText.Text = "Auto Save is OFF!"
    NotifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    NotifText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    NotifText.TextStrokeTransparency = 0
    NotifText.Font = Enum.Font.GothamBlack
    NotifText.TextScaled = true
    NotifText.Visible = false

    local function managePlatform(create)
        if create then
            if not safePlatform or not safePlatform.Parent then
                safePlatform = Instance.new("Part")
                safePlatform.Name = "AutoSavePlatform"
                safePlatform.Size = Vector3.new(150, 5, 150)
                safePlatform.Position = platformPos
                safePlatform.Anchored = true
                safePlatform.CanCollide = true
                safePlatform.Transparency = 0.5
                safePlatform.BrickColor = BrickColor.new("Bright blue")
                safePlatform.Material = Enum.Material.SmoothPlastic
                safePlatform.Parent = Workspace
            end
        else
            if safePlatform then
                safePlatform:Destroy()
                safePlatform = nil
            end
        end
    end

    LeaveBtn.MouseButton1Click:Connect(function()
        inSafeZone = false
        LeaveBtn.Visible = false
        managePlatform(false)
        
        if Toggles.AutoSaveToggle then
            Toggles.AutoSaveToggle:SetValue(false)
        end
        
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = leaveCFrame
        end
        
        NotifText.Visible = true
        task.delay(3, function() NotifText.Visible = false end)
    end)

    RunService.Heartbeat:Connect(function()
        if autoSaveEnabled then
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if hum and hrp and hum.Health > 0 then
                if not inSafeZone and hum.Health < autoSaveThreshold then
                    inSafeZone = true
                    managePlatform(true)
                    hrp.CFrame = safeZoneCFrame
                    LeaveBtn.Visible = true
                elseif inSafeZone then
                    local dist = (hrp.Position - safeZonePos).Magnitude
                    if dist > 120 then
                        hrp.CFrame = safeZoneCFrame
                    end
                end
            end
        else
            if inSafeZone then
                inSafeZone = false
                LeaveBtn.Visible = false
                managePlatform(false)
            end
        end
    end)

    local pauseTimer = 0
    local lastPosition = nil
    local smoothedSpeed = 0

    RunService.Stepped:Connect(function(_, deltaTime)
        if noclipEnabled then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end

        if flyEnabled then
            local char = LocalPlayer.Character
            if not char then return end
            local hum = char:FindFirstChildOfClass("Humanoid")
            local hrp = char:FindFirstChild("HumanoidRootPart")
            
            if hum and hrp and hum.Health > 0 then
                hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

                local moveDir = hum.MoveDirection
                if moveDir.Magnitude > 0 then
                    local camCFrame = Workspace.CurrentCamera.CFrame
                    local flatCamLook = Vector3.new(camCFrame.LookVector.X, 0, camCFrame.LookVector.Z).Unit
                    local camRight = camCFrame.RightVector
                    local forwardDot = moveDir:Dot(flatCamLook)
                    local rightDot = moveDir:Dot(camRight)
                    local finalDirection = (camCFrame.LookVector * forwardDot) + (camCFrame.RightVector * rightDot)
                    hrp.CFrame = hrp.CFrame + (finalDirection * (Options.FlySpeed.Value * deltaTime))
                end
            end
        end
    end)

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

        if CoordsGui.Enabled and hrp then
            local p = hrp.Position
            XYZLabel.Text = string.format("X: %.1f | Y: %.1f | Z: %.1f", p.X, p.Y, p.Z)
        end

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

    -- BOSS ESP LOGIC
    local BossEspBox = Tabs.Esp:AddRightGroupbox("Boss ESP Settings")

    BossEspBox:AddToggle("BossESP", { Text = "ESP Bosses", Default = false })
    BossEspBox:AddDropdown("BossFilter", {
        Values = { "Megalodon", "D-Rex" },
        Default = { "Megalodon", "D-Rex" },
        Multi = true,
        Text = "Select Boss"
    })

    local function applyBossESP(model, bossName, displayColor)
        if not model then return end
        local enabled = Toggles.BossESP and Toggles.BossESP.Value
        local selectedBosses = Options.BossFilter and Options.BossFilter.Value or {}
        
        local container = model:FindFirstChild("BossESPContainer")

        if enabled and selectedBosses[bossName] then
            if not container then
                local targetPart = model.PrimaryPart or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart", true)
                if not targetPart then return end

                container = Instance.new("Folder")
                container.Name = "BossESPContainer"
                container.Parent = model

                local hl = Instance.new("Highlight")
                hl.FillColor = displayColor
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.3
                hl.OutlineTransparency = 0
                hl.Adornee = model
                hl.Parent = container

                local bb = Instance.new("BillboardGui")
                bb.AlwaysOnTop = true
                bb.Size = UDim2.new(0, 150, 0, 30)
                bb.StudsOffset = Vector3.new(0, 5, 0)
                bb.Adornee = targetPart
                bb.Parent = container

                local label = Instance.new("TextLabel")
                label.Size = UDim2.new(1, 0, 1, 0)
                label.BackgroundTransparency = 1
                label.Text = bossName
                label.TextColor3 = displayColor
                label.TextStrokeTransparency = 0
                label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                label.Font = Enum.Font.SourceSansBold
                label.TextSize = 16
                label.Parent = bb
            end
        else
            if container then container:Destroy() end
        end
    end

    local function updateBossESP()
        local megalodon = Workspace:FindFirstChild("MEGALODON")
        if megalodon then applyBossESP(megalodon, "Megalodon", Color3.fromRGB(0, 150, 255)) end

        local drex = Workspace:FindFirstChild("D-REX")
        if drex then applyBossESP(drex, "D-Rex", Color3.fromRGB(255, 50, 50)) end
    end

    Toggles.BossESP:OnChanged(updateBossESP)
    Options.BossFilter:OnChanged(updateBossESP)

    -- ===================== TAB: HALLOWEEN =====================
    local HalloweenBox = Tabs.Halloween:AddLeftGroupbox('<font color="#FFA500">Halloween Events</font>')

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
        label.Text = "Pumpkin"
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
        Text = '<font color="#FFA500">Pumpkin ESP</font>', 
        Default = false, 
        Tooltip = "Highlights all Purple Pumpkins" 
    }):OnChanged(function(v) 
        pumpkinEspEnabled = v 
        scanAndApplyPumpkins()
    end)

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
                label.Text = "Candy"
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
        Text = '<font color="#FFA500">ESP Candy</font>', 
        Default = false, 
        Tooltip = "Highlights Halloween Candies in Workspace.Food" 
    }):OnChanged(updateCandyESP)

    local HalloweenEnemiesBox = Tabs.Halloween:AddRightGroupbox('<font color="#FFA500">Halloween Enemies</font>')

    HalloweenEnemiesBox:AddToggle("EnemiesESP", { Text = '<font color="#FFA500">ESP Enemies</font>', Default = false })
    HalloweenEnemiesBox:AddDropdown("EnemiesFilter", {
        Values = { "Witch", "Bone", "Spider" },
        Default = { "Witch", "Bone", "Spider" },
        Multi = true,
        Text = '<font color="#FFA500">Select Enemies</font>'
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
                label.Text = shortName
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

    -- ===================== TAB: DISCORD =====================
    local DiscordBox = Tabs.Discord:AddLeftGroupbox('<font color="#00BFFF">Join Community</font>')

    DiscordBox:AddButton("Copy Discord Link", function()
        local setclip = setclipboard or toclipboard or set_clipboard
        if setclip then
            setclip(DiscordLink)
            Library:Notify("Discord link copied to clipboard!", 3)
        else
            Library:Notify("Your executor doesn't support clipboard copying.", 3)
        end
    end)

    -- MAIN LOOP
    task.spawn(function()
        while true do
            task.wait(1.5)
            pcall(function()
                if pumpkinEspEnabled then scanAndApplyPumpkins() end
                if Toggles.FoodESP and Toggles.FoodESP.Value then updateFoodESP() end
                if Toggles.CandyESP and Toggles.CandyESP.Value then updateCandyESP() end
                if Toggles.EnemiesESP and Toggles.EnemiesESP.Value then updateEnemiesESP() end
                if Toggles.BossESP and Toggles.BossESP.Value then updateBossESP() end
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
end

-- ===================== CHECK KEY / WHITELIST LOGIC =====================
local isWhitelisted = WhitelistedIDs[LocalPlayer.UserId] == true

if isWhitelisted then
    LoadMainScript()
    return
end

local isSavedKeyValid = false

pcall(function()
    if isfile and readfile and isfile(KeyFileName) then
        local saved = readfile(KeyFileName)

        if saved and saved == CorrectKey then
            isSavedKeyValid = true
        else
            if delfile then
                delfile(KeyFileName)
            end
        end
    end
end)

if isSavedKeyValid then
    LoadMainScript()
    return
end

-- ===================== KEY GUI CREATION =====================
local parentGui = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")

local KeyGui = Instance.new("ScreenGui")
KeyGui.Name = "MyDinoLife_KeySystem"
KeyGui.ResetOnSpawn = false
KeyGui.Parent = parentGui

local MainFrame = Instance.new("Frame", KeyGui)
MainFrame.Size = UDim2.new(0, 360, 0, 240)
MainFrame.Position = UDim2.new(0.5, -180, 0.5, -120)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.BackgroundTransparency = 1
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(60, 60, 80)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 1

-- TOPBAR (DRAGGABLE)
local Topbar = Instance.new("Frame", MainFrame)
Topbar.Size = UDim2.new(1, 0, 0, 35)
Topbar.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
Topbar.BorderSizePixel = 0
Instance.new("UICorner", Topbar).CornerRadius = UDim.new(0, 10)

local TopbarFix = Instance.new("Frame", Topbar)
TopbarFix.Size = UDim2.new(1, 0, 0.5, 0)
TopbarFix.Position = UDim2.new(0, 0, 0.5, 0)
TopbarFix.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
TopbarFix.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Topbar)
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Key System — My Dino Life"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", Topbar)
CloseBtn.Size = UDim2.new(0, 35, 1, 0)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14

CloseBtn.MouseEnter:Connect(function() CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80) end)
CloseBtn.MouseLeave:Connect(function() CloseBtn.TextColor3 = Color3.fromRGB(180, 180, 180) end)
CloseBtn.MouseButton1Click:Connect(function() KeyGui:Destroy() end)

-- DRAGGING LOGIC
local dragging, dragInput, mousePos, framePos
Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
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
        MainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

-- INPUT BOX
local KeyInput = Instance.new("TextBox", MainFrame)
KeyInput.Size = UDim2.new(0.88, 0, 0, 42)
KeyInput.Position = UDim2.new(0.06, 0, 0.25, 0)
KeyInput.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderText = "Enter Key Here..."
KeyInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
KeyInput.Font = Enum.Font.GothamMedium
KeyInput.TextSize = 13
KeyInput.Text = ""
KeyInput.ClearTextOnFocus = false
Instance.new("UICorner", KeyInput).CornerRadius = UDim.new(0, 8)

local InputStroke = Instance.new("UIStroke", KeyInput)
InputStroke.Color = Color3.fromRGB(50, 50, 65)
InputStroke.Thickness = 1

-- STATUS LABEL
local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(0.88, 0, 0, 22)
StatusLabel.Position = UDim2.new(0.06, 0, 0.48, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = ""
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 12

-- BUTTONS CONTAINER
local ConfirmBtn = Instance.new("TextButton", MainFrame)
ConfirmBtn.Size = UDim2.new(0.42, 0, 0, 38)
ConfirmBtn.Position = UDim2.new(0.06, 0, 0.68, 0)
ConfirmBtn.BackgroundColor3 = Color3.fromRGB(40, 167, 69) -- Green
ConfirmBtn.Text = "Confirm"
ConfirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ConfirmBtn.Font = Enum.Font.GothamBold
ConfirmBtn.TextSize = 13
Instance.new("UICorner", ConfirmBtn).CornerRadius = UDim.new(0, 8)

local GetKeyBtn = Instance.new("TextButton", MainFrame)
GetKeyBtn.Size = UDim2.new(0.42, 0, 0, 38)
GetKeyBtn.Position = UDim2.new(0.52, 0, 0.68, 0)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 122, 255) -- Blue
GetKeyBtn.Text = "Get Key"
GetKeyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GetKeyBtn.Font = Enum.Font.GothamBold
GetKeyBtn.TextSize = 13
Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 8)

-- ANIMATED OPENING
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    BackgroundTransparency = 0,
    Position = UDim2.new(0.5, -180, 0.5, -120)
}):Play()
TweenService:Create(MainStroke, TweenInfo.new(0.4), {Transparency = 0}):Play()

-- BUTTON HANDLERS
GetKeyBtn.MouseButton1Click:Connect(function()
    local setclip = setclipboard or toclipboard or set_clipboard
    if setclip then
        setclip(DiscordLink)
        StatusLabel.TextColor3 = Color3.fromRGB(0, 191, 255)
        StatusLabel.Text = "Discord link copied to clipboard!"
    else
        StatusLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
        StatusLabel.Text = "Clipboard not supported!"
    end
end)

ConfirmBtn.MouseButton1Click:Connect(function()
    local enteredKey = KeyInput.Text
    if enteredKey == CorrectKey then
        StatusLabel.TextColor3 = Color3.fromRGB(46, 204, 113)
        StatusLabel.Text = "Valid Key. Executing..."
        
        pcall(function()
            if writefile then
                writefile(KeyFileName, enteredKey)
            end
        end)
        
        task.wait(0.8)
        
        local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 320, 0, 200),
            Position = UDim2.new(0.5, -160, 0.5, -100)
        })
        TweenService:Create(MainStroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        closeTween:Play()
        closeTween.Completed:Wait()
        
        KeyGui:Destroy()
        LoadMainScript()
    else
        StatusLabel.TextColor3 = Color3.fromRGB(231, 76, 60)
        StatusLabel.Text = "Wrong Key."
    end
end)
