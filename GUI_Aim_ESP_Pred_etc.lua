-- GUI_Aim_ESP_Pred_etc.lua
-- Hold RIGHT MOUSE BUTTON to aimlock on closest player's head

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--------------------------------------------------
-- SETTINGS
--------------------------------------------------

--------------------------------------------------
-- CIRCLE VISIBLE SETTINGS
--------------------------------------------------

local CircleVisible = true

------------------------------------------------

local Prediction = 0.14
local HeadOffset = Vector3.new(0,-0.19,0)

--------------------------------------------------
-- ESP SETTINGS
--------------------------------------------------

local ESPEnabled = false
local ESPBoxes = {}
local ESPConnections = {}

--------------------------------------------------
-- SILENT AIM SETTINGS
--------------------------------------------------

local SilentAimEnabled = false

--------------------------------------------------
-- NAME ESP SETTINGS
--------------------------------------------------

local NameESPEnabled = false
local NameTags = {}
local NameConnections = {}

--------------------------------------------------
-- AIM PART SETTINGS
--------------------------------------------------

local AimPart = "Head" -- Head or Body

--------------------------------------------------
-- AIM CIRCLE SIZE
--------------------------------------------------

local CircleSize = 60

--------------------------------------------------
-- HITBOX SETTINGS
--------------------------------------------------

shared.HitboxSettings = {
	Enabled = false,
	Visible = true,
	Size = 8
}

--------------------------------------------------
-- BOW MODE SETTINGS
--------------------------------------------------

shared.BowModeSettings = {
	Enabled = false,
	Visible = true
}

--------------------------------------------------
-- LOAD HITBOX SYSTEM
--------------------------------------------------

task.spawn(function()
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/imsecret15/roblox_system1/main/Hitbox_system.lua"))()
    end)

    if not success then
        warn("Hitbox system failed:", err)
    end
end)

--------------------------------------------------
-- LOAD BOWMODE SYSTEM
--------------------------------------------------

task.spawn(function()
    local success, err = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/imsecret15/roblox_system1/main/Bowmode_system.lua"))()
    end)

    if not success then
        warn("Bowmode system failed:", err)
    end
end)

--------------------------------------------------
-- MAIN GUI
--------------------------------------------------

local mainGui = Instance.new("ScreenGui")
mainGui.ResetOnSpawn = false
mainGui.Name = "ExploitMenu"
mainGui.Parent = player:WaitForChild("PlayerGui")

--------------------------------------------------
-- LEFT OPEN BUTTON
--------------------------------------------------

local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0,55,0,55)
openButton.Position = UDim2.new(0,10,0.5,-30)
openButton.Text = "≡"
openButton.TextSize = 28
openButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
openButton.TextColor3 = Color3.new(1,1,1)
openButton.Parent = mainGui

local openCorner = Instance.new("UICorner")
openCorner.Parent = openButton

--------------------------------------------------
-- MENU FRAME
--------------------------------------------------

local menuFrame = Instance.new("Frame")
menuFrame.Parent = mainGui

--------------------------------------------------
-- MM MENU FRAME
--------------------------------------------------

local mmFrame = Instance.new("Frame")
mmFrame.Size = UDim2.new(0,500,0,300)
mmFrame.Position = UDim2.new(0.5,-250,0.5,-150)
mmFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
mmFrame.Visible = false
mmFrame.Parent = mainGui

local mmCorner = Instance.new("UICorner")
mmCorner.Parent = mmFrame

local mmClose = Instance.new("TextButton")
mmClose.Size = UDim2.new(0,80,0,35)
mmClose.Position = UDim2.new(1,-90,0,10)
mmClose.Text = "Close"
mmClose.BackgroundColor3 = Color3.fromRGB(50,50,50)
mmClose.TextColor3 = Color3.new(1,1,1)
mmClose.Parent = mmFrame

local mmCloseCorner = Instance.new("UICorner")
mmCloseCorner.Parent = mmClose

--------------------------------------------------
-- TAB BAR
--------------------------------------------------

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1,0,0,40)
tabBar.BackgroundTransparency = 1
tabBar.Parent = menuFrame

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.Padding = UDim.new(0,10)
tabLayout.Parent = tabBar

local function createTab(name)

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0.25,-10,1,0)
	button.Text = name
	button.TextSize = 18
	button.BackgroundColor3 = Color3.fromRGB(40,40,40)
	button.TextColor3 = Color3.new(1,1,1)
	button.Parent = tabBar

	local corner = Instance.new("UICorner")
	corner.Parent = button

	return button
end

local aimTabButton = createTab("Aim")
local visualsTabButton = createTab("Visuals")
local hitboxTabButton = createTab("Hitbox")
local mmMenuButton = createTab("MM Menu")

menuFrame.Size = UDim2.new(0,460,0,420)
menuFrame.Position = UDim2.new(0,75,0.5,-210)
menuFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
menuFrame.Visible = false

local menuCorner = Instance.new("UICorner")
menuCorner.Parent = menuFrame

--------------------------------------------------
-- TAB PAGES
--------------------------------------------------

local function createPage()

	local page = Instance.new("ScrollingFrame")
	page.Size = UDim2.new(1,-20,1,-60)
	page.Position = UDim2.new(0,10,0,50)
	page.CanvasSize = UDim2.new(0,0,0,0)
	page.ScrollBarThickness = 6
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = menuFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0,10)
	layout.Parent = page

	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
	end)

	return page
end

local aimPage = createPage()
local visualsPage = createPage()
local hitboxPage = createPage()

local function switchTab(page)

	aimPage.Visible = false
	visualsPage.Visible = false
	hitboxPage.Visible = false

	page.Visible = true

end

aimTabButton.MouseButton1Click:Connect(function()
	switchTab(aimPage)
end)

visualsTabButton.MouseButton1Click:Connect(function()
	switchTab(visualsPage)
end)

hitboxTabButton.MouseButton1Click:Connect(function()
	switchTab(hitboxPage)
end)

mmMenuButton.MouseButton1Click:Connect(function()
	mmFrame.Visible = true
end)

switchTab(aimPage)

--------------------------------------------------
-- BUTTON CREATOR FUNCTION
--------------------------------------------------

local function createButton(text)

	local button = Instance.new("TextButton")
	button.Size = UDim2.new(1,-10,0,42)
	button.Text = text
	button.TextSize = 18
	button.BackgroundColor3 = Color3.fromRGB(40,40,40)
	button.TextColor3 = Color3.new(1,1,1)
	button.Parent = aimPage

	local corner = Instance.new("UICorner")
	corner.Parent = button

	return button
end

--------------------------------------------------
-- SETTING FRAME CREATOR
--------------------------------------------------

local function createSetting(labelText, defaultValue)

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1,-10,0,45)
	frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
	frame.Parent = aimPage

	local frameCorner = Instance.new("UICorner")
	frameCorner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.6,0,1,0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.TextSize = 18
	label.Font = Enum.Font.SourceSansBold
	label.TextColor3 = Color3.new(1,1,1)
	label.Parent = frame

	local box = Instance.new("TextBox")
	box.Size = UDim2.new(0.35,-5,0,30)
	box.Position = UDim2.new(0.65,0,0.5,-15)
	box.BackgroundColor3 = Color3.fromRGB(30,30,30)
	box.TextColor3 = Color3.new(1,1,1)
	box.TextSize = 16
	box.Text = tostring(defaultValue)
	box.ClearTextOnFocus = false
	box.Parent = frame

	local boxCorner = Instance.new("UICorner")
	boxCorner.Parent = box

	return frame, box
end

--------------------------------------------------
-- BUTTONS
--------------------------------------------------

local espButton = createButton("ESP : OFF")
local nameButton = createButton("Player Names : OFF")
local aimModeButton = createButton("Aim : Disabled")
local aimPartButton = createButton("Aim Part : Head")
local circleButton = createButton("Aim Circle : ON")

-- move ESP buttons to visuals tab
espButton.Parent = visualsPage
nameButton.Parent = visualsPage
--------------------------------------------------
-- SETTINGS
--------------------------------------------------

local predictionFrame, predictionBox = createSetting("Prediction:", Prediction)

local headOffsetFrame, headOffsetBox =
	createSetting("Head Offset:", string.format("%.2f", HeadOffset.Y))

local circleSizeFrame, circleSizeBox =
	createSetting("Circle Size:", CircleSize)

--------------------------------------------------
-- HITBOX
--------------------------------------------------

local hitboxButton = createButton("Hitbox : OFF")
local hitboxVisibleButton = createButton("Hitbox Visible : ON")

local hitboxSizeFrame, hitboxSizeBox =
	createSetting("Hitbox Size:", shared.HitboxSettings.Size)

hitboxButton.Parent = hitboxPage
hitboxVisibleButton.Parent = hitboxPage
hitboxSizeFrame.Parent = hitboxPage

--------------------------------------------------
-- BOW MODE
--------------------------------------------------

local bowButton = createButton("Bow Mode : OFF")

--------------------------------------------------
-- CLOSE BUTTON
--------------------------------------------------

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0,90,0,40)
closeButton.Position = UDim2.new(0,450,0.5,-200)
closeButton.Text = "Close"
closeButton.TextSize = 18
closeButton.BackgroundColor3 = Color3.fromRGB(50,50,50)
closeButton.TextColor3 = Color3.new(1,1,1)
closeButton.Parent = mainGui
closeButton.Visible = false

local closeCorner = Instance.new("UICorner")
closeCorner.Parent = closeButton

--------------------------------------------------
-- BUTTON LOGIC
--------------------------------------------------

openButton.MouseButton1Click:Connect(function()
	menuFrame.Visible = true
	closeButton.Visible = true
end)

closeButton.MouseButton1Click:Connect(function()
	menuFrame.Visible = false
	closeButton.Visible = false
end)

--------------------------------------------------
-- MM MENU BUTTON
--------------------------------------------------

mmMenuButton.MouseButton1Click:Connect(function()

	mmFrame.Visible = true

	local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
	local Window = Library.CreateLib("Mortem Metallum [Alpha]", "DarkTheme")

	local Tab = Window:NewTab("Main")
	local Section = Tab:NewSection("Test")

	Section:NewLabel("MM Menu Loaded")

end)

mmClose.MouseButton1Click:Connect(function()

	mmFrame.Visible = false
	menuFrame.Visible = true

end)

--------------------------------------------------
-- AIM MODE LOGIC
--------------------------------------------------

local aimMode = "Disabled"

aimModeButton.MouseButton1Click:Connect(function()

	if aimMode == "Disabled" then
		aimMode = "Lock"
		aimModeButton.Text = "Aim : Lock"
		SilentAimEnabled = false

	elseif aimMode == "Lock" then
		aimMode = "Silent"
		aimModeButton.Text = "Aim : Silent"
		SilentAimEnabled = true

	elseif aimMode == "Silent" then
		aimMode = "Disabled"
		aimModeButton.Text = "Aim : Disabled"
		SilentAimEnabled = false

		aiming = false
		lockedTarget = nil
	end

end)

--------------------------------------------------
-- PREDICTION VALUE UPDATE
--------------------------------------------------

predictionBox.FocusLost:Connect(function(enterPressed)

	if enterPressed then

		local value = tonumber(predictionBox.Text)

		if value then
			Prediction = value
			predictionBox.Text = tostring(value)
		else
			predictionBox.Text = tostring(Prediction)
		end

	end

end)

--------------------------------------------------
-- HEAD OFFSET UPDATE
--------------------------------------------------

headOffsetBox.FocusLost:Connect(function(enterPressed)

	if enterPressed then

		local value = tonumber(headOffsetBox.Text)

		if value then

			value = math.floor(value * 100 + 0.5) / 100
			HeadOffset = Vector3.new(0,value,0)

			headOffsetBox.Text = string.format("%.2f", value)

		else
			headOffsetBox.Text = string.format("%.2f", HeadOffset.Y)
		end

	end

end)

--------------------------------------------------
-- ESP FUNCTIONS
--------------------------------------------------

local function createESP(target)

    if target == player then return end
    if ESPBoxes[target] then return end

    local function applyESP(char)

        if ESPBoxes[target] then
            ESPBoxes[target]:Destroy()
        end

        local highlight = Instance.new("Highlight")
        highlight.Name = "ESPHighlight"
        highlight.FillTransparency = 0.85
        highlight.OutlineColor = Color3.fromRGB(255,0,0)
        highlight.OutlineTransparency = 0.6
        highlight.Adornee = char
        highlight.Parent = game.CoreGui

        ESPBoxes[target] = highlight
    end

    if target.Character then
        applyESP(target.Character)
    end

    target.CharacterAdded:Connect(function(char)
        if ESPEnabled then
            task.wait(0.2)
            applyESP(char)
        end
    end)
end

local function removeESP(target)

    if ESPBoxes[target] then
        ESPBoxes[target]:Destroy()
        ESPBoxes[target] = nil
    end

end

espButton.MouseButton1Click:Connect(function()

    ESPEnabled = not ESPEnabled

    if ESPEnabled then
        espButton.Text = "ESP : ON"

        for _,plr in pairs(Players:GetPlayers()) do
            createESP(plr)
        end

    else
        espButton.Text = "ESP : OFF"

        for _,plr in pairs(Players:GetPlayers()) do
            removeESP(plr)
        end

    end

end)

--------------------------------------------------
-- NAME ESP FUNCTIONS
--------------------------------------------------

local function createNameESP(target)

	if target == player then return end
	if NameTags[target] then return end

	local function applyName(char)

		if NameTags[target] then
			NameTags[target]:Destroy()
		end

		local head = char:FindFirstChild("Head")
		if not head then return end

		local billboard = Instance.new("BillboardGui")
		billboard.Name = "NameESP"
		billboard.Size = UDim2.new(0,200,0,20)
		billboard.StudsOffset = Vector3.new(0,2.5,0)
		billboard.AlwaysOnTop = true
		billboard.Adornee = head
		billboard.Parent = game.CoreGui

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1,0,1,0)
		label.BackgroundTransparency = 1
		label.Text = target.Name
		label.TextColor3 = Color3.fromRGB(255,140,0)
		label.TextStrokeColor3 = Color3.new(0,0,0)
        label.TextStrokeTransparency = 0
		label.TextScaled = true
		label.Font = Enum.Font.SourceSansBold
		label.Parent = billboard

		NameTags[target] = billboard
	end

	if target.Character then
		applyName(target.Character)
	end

	if not NameConnections[target] then
	NameConnections[target] = target.CharacterAdded:Connect(function(char)
		if NameESPEnabled then
			task.wait(0.2)
			applyName(char)
		end
	end)
end

end


local function removeNameESP(target)

	if NameTags[target] then
		NameTags[target]:Destroy()
		NameTags[target] = nil
	end

end

nameButton.MouseButton1Click:Connect(function()

	NameESPEnabled = not NameESPEnabled

	if NameESPEnabled then
		nameButton.Text = "Player Names : ON"

		for _,plr in pairs(Players:GetPlayers()) do
			createNameESP(plr)
		end

	else
		nameButton.Text = "Player Names : OFF"

		for _,plr in pairs(Players:GetPlayers()) do
			removeNameESP(plr)
		end

	end

end)

--------------------------------------------------
-- AIM PART TOGGLE
--------------------------------------------------

aimPartButton.MouseButton1Click:Connect(function()

	if AimPart == "Head" then
		AimPart = "Body"
		aimPartButton.Text = "Aim Part : Body"
	else
		AimPart = "Head"
		aimPartButton.Text = "Aim Part : Head"
	end

end)

--------------------------------------------------
-- AIM CIRCLE UI (HOLLOW CIRCLE)
--------------------------------------------------

local circle = Instance.new("Frame")
circle.Size = UDim2.new(0,CircleSize,0,CircleSize)
circle.Position = UDim2.new(0.5,-CircleSize/2,0.5,-CircleSize/2)
circle.BackgroundTransparency = 1
circle.BorderSizePixel = 0
circle.Parent = mainGui
circle.Visible = CircleVisible

--------------------------------------------------
-- BOW MODE INDICATOR
--------------------------------------------------

local bowIndicator = Instance.new("Frame")
bowIndicator.Size = UDim2.new(0,12,0,12)
bowIndicator.Position = UDim2.new(0,10,0,10)
bowIndicator.BackgroundColor3 = Color3.fromRGB(255,50,50)
bowIndicator.BorderSizePixel = 0
bowIndicator.Visible = false
bowIndicator.ZIndex = 999
bowIndicator.Parent = mainGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(1,0)
corner.Parent = circle

local stroke = Instance.new("UIStroke")
stroke.Thickness = 1
stroke.Color = Color3.fromRGB(255,255,255)
stroke.Transparency = 0.6
stroke.Parent = circle

--------------------------------------------------
-- CIRCLE SIZE UPDATE
--------------------------------------------------

circleSizeBox.FocusLost:Connect(function()

	local value = tonumber(circleSizeBox.Text)

	if value then
		CircleSize = value
		circle.Size = UDim2.new(0,CircleSize,0,CircleSize)
		circle.Position = UDim2.new(0.5,-CircleSize/2,0.5,-CircleSize/2)
		circleSizeBox.Text = tostring(CircleSize)
	else
		circleSizeBox.Text = tostring(CircleSize)
	end

end)

--------------------------------------------------
-- AIM CIRCLE TOGGLE
--------------------------------------------------

circleButton.MouseButton1Click:Connect(function()

	CircleVisible = not CircleVisible

	if CircleVisible then
		circle.Visible = true
		circleButton.Text = "Aim Circle : ON"
	else
		circle.Visible = false
		circleButton.Text = "Aim Circle : OFF"
	end

end)

--------------------------------------------------
-- HITBOX VISIBILITY TOGGLE
--------------------------------------------------

hitboxVisibleButton.MouseButton1Click:Connect(function()

	shared.HitboxSettings.Visible = not shared.HitboxSettings.Visible

if shared.HitboxSettings.Visible then
	hitboxVisibleButton.Text = "Hitbox Visible : ON"
else
	hitboxVisibleButton.Text = "Hitbox Visible : OFF"
end

end)

--------------------------------------------------
-- HITBOX SIZE UPDATE
--------------------------------------------------

hitboxSizeBox.FocusLost:Connect(function()

	local value = tonumber(hitboxSizeBox.Text)

	if value then
		shared.HitboxSettings.Size = value
		hitboxSizeBox.Text = tostring(shared.HitboxSettings.Size)
	else
		hitboxSizeBox.Text = tostring(shared.HitboxSettings.Size)
	end

end)

--------------------------------------------------
-- HITBOX ENABLE TOGGLE
--------------------------------------------------

hitboxButton.MouseButton1Click:Connect(function()

	shared.HitboxSettings.Enabled = not shared.HitboxSettings.Enabled

	if shared.HitboxSettings.Enabled then
		hitboxButton.Text = "Hitbox : ON"
	else
		hitboxButton.Text = "Hitbox : OFF"
	end

end)

--------------------------------------------------
-- BOW MODE TOGGLE
--------------------------------------------------

bowButton.MouseButton1Click:Connect(function()

	shared.BowModeSettings.Enabled = not shared.BowModeSettings.Enabled

	if shared.BowModeSettings.Enabled then
		bowButton.Text = "Bow Mode : ON"
		bowIndicator.Visible = true
	else
		bowButton.Text = "Bow Mode : OFF"
		bowIndicator.Visible = false
	end

end)

--------------------------------------------------
-- Aimlock System
--------------------------------------------------

local aiming = false
local lockedTarget = nil

local function getClosestPlayer()

	local closestPlayer = nil
	local shortestDistance = math.huge

	local screenCenter = Vector2.new(
		camera.ViewportSize.X/2,
		camera.ViewportSize.Y/2
	)

	local FOV = (circle.AbsoluteSize.X / 2) + 6

	for _,v in pairs(Players:GetPlayers()) do

		if v ~= player and v.Character then

			local head = v.Character:FindFirstChild("Head")
			local root = v.Character:FindFirstChild("HumanoidRootPart")

			if head and root then

				local pos, visible = camera:WorldToViewportPoint(head.Position)

				if visible then

					local dist = (Vector2.new(pos.X,pos.Y) - screenCenter).Magnitude

					if dist < shortestDistance and dist <= FOV then
						shortestDistance = dist
						closestPlayer = v
					end

				end
			end
		end
	end

	return closestPlayer
end

--------------------------------------------------
-- SILENT AIM TARGET FUNCTION
--------------------------------------------------

local function getSilentAimTarget()

	if not SilentAimEnabled then
		return nil
	end

	local target = getClosestPlayer()

	if target and target.Character then

		if AimPart == "Head" then
			return target.Character:FindFirstChild("Head")
		else
			return target.Character:FindFirstChild("HumanoidRootPart")
		end

	end

	return nil
end

--------------------------------------------------
-- Mouse Input
--------------------------------------------------

UserInputService.InputBegan:Connect(function(input,gpe)

	if gpe then return end

	if input.UserInputType == Enum.UserInputType.MouseButton2 and aimMode == "Lock" then
		aiming = true

		if not lockedTarget then
			lockedTarget = getClosestPlayer()
		end
	end

end)

UserInputService.InputEnded:Connect(function(input)

	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		aiming = false
		lockedTarget = nil
	end

end)

--------------------------------------------------
-- Camera Lock Loop
--------------------------------------------------

RunService.RenderStepped:Connect(function()

	if not aiming then
		stroke.Color = Color3.fromRGB(255,255,255)
		return
	end

	if not lockedTarget then
		lockedTarget = getClosestPlayer()
		shared.AimTarget = lockedTarget

		if not lockedTarget then
			stroke.Color = Color3.fromRGB(255,255,255)
			return
		end
	end

	local char = lockedTarget.Character
	if not char then
		lockedTarget = nil
		return
	end

local targetPart

if AimPart == "Head" then
	targetPart = char:FindFirstChild("Head")
else
	targetPart = char:FindFirstChild("HumanoidRootPart")
end

if not targetPart then
	lockedTarget = nil
	return
end

	stroke.Color = Color3.fromRGB(255,0,0)

local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end

local velocity = root.AssemblyLinearVelocity

	local distance = (camera.CFrame.Position - targetPart.Position).Magnitude

	local pred = Prediction
	if distance < 20 then
		pred = Prediction * 0.4
	elseif distance < 40 then
		pred = Prediction * 0.7
	end

	local predictedPosition = targetPart.Position + (velocity * pred) + (AimPart == "Head" and HeadOffset or Vector3.new())

	camera.CFrame = CFrame.new(
		camera.CFrame.Position,
		predictedPosition
	)

end)

--------------------------------------------------
-- PLAYER JOIN SUPPORT
--------------------------------------------------

Players.PlayerAdded:Connect(function(plr)

	plr.CharacterAdded:Connect(function()
		if ESPEnabled then
			task.wait(0.5)
			createESP(plr)
		end

		if NameESPEnabled then
			task.wait(0.5)
			createNameESP(plr)
		end
	end)

end)
