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
local HeadOffset = Vector3.new(0,-0.12,0)

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
mainGui.Parent = player:WaitForChild("PlayerGui")

--------------------------------------------------
-- LEFT OPEN BUTTON
--------------------------------------------------

local openButton = Instance.new("TextButton")
openButton.Size = UDim2.new(0,40,0,40)
openButton.Position = UDim2.new(0,10,0.5,-20)
openButton.Text = "≡"
openButton.TextScaled = true
openButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
openButton.TextColor3 = Color3.new(1,1,1)
openButton.Parent = mainGui

local openCorner = Instance.new("UICorner")
openCorner.Parent = openButton

--------------------------------------------------
-- MENU FRAME
--------------------------------------------------

local menuFrame = Instance.new("Frame")
menuFrame.Size = UDim2.new(0,220,0,180)
menuFrame.Position = UDim2.new(0,60,0.5,-90)
menuFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
menuFrame.Visible = false
menuFrame.Parent = mainGui

local menuCorner = Instance.new("UICorner")
menuCorner.Parent = menuFrame

--------------------------------------------------
-- SCROLLING CONTAINER
--------------------------------------------------

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1,-10,1,-10)
scrollFrame.Position = UDim2.new(0,5,0,5)
scrollFrame.CanvasSize = UDim2.new(0,0,0,0)
scrollFrame.ScrollBarThickness = 4
scrollFrame.BackgroundTransparency = 1
scrollFrame.Parent = menuFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0,8)
layout.Parent = scrollFrame

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)



--------------------------------------------------
-- ESP TOGGLE BUTTON
--------------------------------------------------

local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(1,-10,0,35)
espButton.Text = "ESP : OFF"
espButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
espButton.TextColor3 = Color3.new(1,1,1)
espButton.Parent = scrollFrame

local espCorner = Instance.new("UICorner")
espCorner.Parent = espButton

--------------------------------------------------
-- NAME ESP BUTTON
--------------------------------------------------

local nameButton = Instance.new("TextButton")
nameButton.Size = UDim2.new(1,-10,0,35)
nameButton.Text = "Player Names : OFF"
nameButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
nameButton.TextColor3 = Color3.new(1,1,1)
nameButton.Parent = scrollFrame

local nameCorner = Instance.new("UICorner")
nameCorner.Parent = nameButton

--------------------------------------------------
-- AIM MODE BUTTON
--------------------------------------------------

local aimMode = "Disabled"

local aimModeButton = Instance.new("TextButton")
aimModeButton.Size = UDim2.new(1,-10,0,35)
aimModeButton.Text = "Aim : Disabled"
aimModeButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
aimModeButton.TextColor3 = Color3.new(1,1,1)
aimModeButton.Parent = scrollFrame

local aimModeCorner = Instance.new("UICorner")
aimModeCorner.Parent = aimModeButton

--------------------------------------------------
-- AIM MODE BUTTON LOGIC
--------------------------------------------------

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
-- AIM PART BUTTON
--------------------------------------------------

local aimPartButton = Instance.new("TextButton")
aimPartButton.Size = UDim2.new(1,-10,0,35)
aimPartButton.Text = "Aim Part : Head"
aimPartButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
aimPartButton.TextColor3 = Color3.new(1,1,1)
aimPartButton.Parent = scrollFrame

local aimCorner = Instance.new("UICorner")
aimCorner.Parent = aimPartButton

--------------------------------------------------
-- AIM CIRCLE TOGGLE BUTTON
--------------------------------------------------

local circleButton = Instance.new("TextButton")
circleButton.Size = UDim2.new(1,-10,0,35)
circleButton.Text = "Aim Circle : ON"
circleButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
circleButton.TextColor3 = Color3.new(1,1,1)
circleButton.Parent = scrollFrame

local circleCorner = Instance.new("UICorner")
circleCorner.Parent = circleButton

--------------------------------------------------
-- PREDICTION SETTING
--------------------------------------------------

local predictionFrame = Instance.new("Frame")
predictionFrame.Size = UDim2.new(1,-10,0,35)
predictionFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
predictionFrame.Parent = scrollFrame

local frameCorner = Instance.new("UICorner")
frameCorner.Parent = predictionFrame

-- Label

local predictionLabel = Instance.new("TextLabel")
predictionLabel.Size = UDim2.new(0.6,0,1,0)
predictionLabel.BackgroundTransparency = 1
predictionLabel.Text = "Prediction:"
predictionLabel.TextColor3 = Color3.new(1,1,1)
predictionLabel.TextScaled = true
predictionLabel.Parent = predictionFrame

-- Textbox

local predictionBox = Instance.new("TextBox")
predictionBox.Size = UDim2.new(0.4,-5,0.8,0)
predictionBox.Position = UDim2.new(0.6,5,0.1,0)
predictionBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
predictionBox.TextColor3 = Color3.new(1,1,1)
predictionBox.Text = tostring(Prediction)
predictionBox.TextScaled = true
predictionBox.ClearTextOnFocus = false
predictionBox.Parent = predictionFrame

local boxCorner = Instance.new("UICorner")
boxCorner.Parent = predictionBox

--------------------------------------------------
-- AIM CIRCLE SIZE SETTING
--------------------------------------------------

local circleSizeFrame = Instance.new("Frame")
circleSizeFrame.Size = UDim2.new(1,-10,0,35)
circleSizeFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
circleSizeFrame.Parent = scrollFrame

local circleFrameCorner = Instance.new("UICorner")
circleFrameCorner.Parent = circleSizeFrame

local circleSizeLabel = Instance.new("TextLabel")
circleSizeLabel.Size = UDim2.new(0.6,0,1,0)
circleSizeLabel.BackgroundTransparency = 1
circleSizeLabel.Text = "Circle Size:"
circleSizeLabel.TextColor3 = Color3.new(1,1,1)
circleSizeLabel.TextScaled = true
circleSizeLabel.Parent = circleSizeFrame

local circleSizeBox = Instance.new("TextBox")
circleSizeBox.Size = UDim2.new(0.4,-5,0.8,0)
circleSizeBox.Position = UDim2.new(0.6,5,0.1,0)
circleSizeBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
circleSizeBox.TextColor3 = Color3.new(1,1,1)
circleSizeBox.Text = tostring(CircleSize)
circleSizeBox.TextScaled = true
circleSizeBox.ClearTextOnFocus = false
circleSizeBox.Parent = circleSizeFrame

local circleBoxCorner = Instance.new("UICorner")
circleBoxCorner.Parent = circleSizeBox

--------------------------------------------------
-- HITBOX TOGGLE BUTTON
--------------------------------------------------

local hitboxButton = Instance.new("TextButton")
hitboxButton.Size = UDim2.new(1,-10,0,35)
hitboxButton.Text = "Hitbox : OFF"
hitboxButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
hitboxButton.TextColor3 = Color3.new(1,1,1)
hitboxButton.Parent = scrollFrame

local hitboxCorner = Instance.new("UICorner")
hitboxCorner.Parent = hitboxButton

hitboxButton.MouseButton1Click:Connect(function()

	shared.HitboxSettings.Enabled = not shared.HitboxSettings.Enabled

	if shared.HitboxSettings.Enabled then
		hitboxButton.Text = "Hitbox : ON"
	else
		hitboxButton.Text = "Hitbox : OFF"
	end

end)

--------------------------------------------------
-- HITBOX VISIBILITY BUTTON
--------------------------------------------------

local hitboxVisibleButton = Instance.new("TextButton")
hitboxVisibleButton.Size = UDim2.new(1,-10,0,35)
hitboxVisibleButton.Text = "Hitbox Visible : ON"
hitboxVisibleButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
hitboxVisibleButton.TextColor3 = Color3.new(1,1,1)
hitboxVisibleButton.Parent = scrollFrame

local visibleCorner = Instance.new("UICorner")
visibleCorner.Parent = hitboxVisibleButton

--------------------------------------------------
-- HITBOX SIZE SETTING
--------------------------------------------------

local hitboxSizeFrame = Instance.new("Frame")
hitboxSizeFrame.Size = UDim2.new(1,-10,0,35)
hitboxSizeFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
hitboxSizeFrame.Parent = scrollFrame

local hitboxFrameCorner = Instance.new("UICorner")
hitboxFrameCorner.Parent = hitboxSizeFrame

local hitboxSizeLabel = Instance.new("TextLabel")
hitboxSizeLabel.Size = UDim2.new(0.6,0,1,0)
hitboxSizeLabel.BackgroundTransparency = 1
hitboxSizeLabel.Text = "Hitbox Size:"
hitboxSizeLabel.TextColor3 = Color3.new(1,1,1)
hitboxSizeLabel.TextScaled = true
hitboxSizeLabel.Parent = hitboxSizeFrame

local hitboxSizeBox = Instance.new("TextBox")
hitboxSizeBox.Size = UDim2.new(0.4,-5,0.8,0)
hitboxSizeBox.Position = UDim2.new(0.6,5,0.1,0)
hitboxSizeBox.BackgroundColor3 = Color3.fromRGB(30,30,30)
hitboxSizeBox.TextColor3 = Color3.new(1,1,1)
hitboxSizeBox.Text = tostring(HitboxSize)
hitboxSizeBox.TextScaled = true
hitboxSizeBox.ClearTextOnFocus = false
hitboxSizeBox.Parent = hitboxSizeFrame

local hitboxSizeCorner = Instance.new("UICorner")
hitboxSizeCorner.Parent = hitboxSizeBox

--------------------------------------------------
-- BOW MODE BUTTON
--------------------------------------------------

local bowButton = Instance.new("TextButton")
bowButton.Size = UDim2.new(1,-10,0,35)
bowButton.Text = "Bow Mode : OFF"
bowButton.BackgroundColor3 = Color3.fromRGB(40,40,40)
bowButton.TextColor3 = Color3.new(1,1,1)
bowButton.Parent = scrollFrame

local bowCorner = Instance.new("UICorner")
bowCorner.Parent = bowButton

--------------------------------------------------
-- CLOSE BUTTON
--------------------------------------------------

local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0,60,0,30)
closeButton.Position = UDim2.new(0,290,0.5,-80)
closeButton.Text = "Close"
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
-- BOW MODE TOGGLE
--------------------------------------------------

bowButton.MouseButton1Click:Connect(function()

	shared.BowModeSettings.Enabled = not shared.BowModeSettings.Enabled

	if shared.BowModeSettings.Enabled then
		bowButton.Text = "Bow Mode : ON"
	else
		bowButton.Text = "Bow Mode : OFF"
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
