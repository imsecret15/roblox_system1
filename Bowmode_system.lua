-- Bowmode_system.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Settings
repeat
	task.wait()
	Settings = shared.BowModeSettings
until Settings

local Boxes = {}
local Enabled = false

--------------------------------------------------
-- CREATE HEAD BOX
--------------------------------------------------

local function createBox(plr)

	if plr == player then return end

	local char = plr.Character
	if not char then return end

	local head = char:FindFirstChild("Head")
	if not head then return end

	if Boxes[plr] then
		if Boxes[plr].Adornee == head then return end
		Boxes[plr]:Destroy()
	end

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "BowModeBox"
	box.Adornee = head
	box.AlwaysOnTop = true
	box.ZIndex = 10
	box.Size = Vector3.new(3,3,3)
	box.Color3 = Color3.fromRGB(255,50,50)
	box.Transparency = Settings.Visible and 0.4 or 1
	box.Parent = head

	Boxes[plr] = box

end

--------------------------------------------------
-- CLEANUP
--------------------------------------------------

local function removeBox(plr)

	if Boxes[plr] then
		Boxes[plr]:Destroy()
		Boxes[plr] = nil
	end

end

--------------------------------------------------
-- TARGET SELECTION
--------------------------------------------------

local function getTargetHead()

	-- priority: aimlock target
	if shared.AimTarget and shared.AimTarget.Character then

		local head = shared.AimTarget.Character:FindFirstChild("Head")
		if head then
			return head
		end

	end

	-- fallback: closest to crosshair
	local closest
	local shortest = math.huge

	for _,plr in pairs(Players:GetPlayers()) do

		if plr ~= player then

			local char = plr.Character
			if not char then continue end

			local head = char:FindFirstChild("Head")
			if not head then continue end

			local pos, visible = camera:WorldToViewportPoint(head.Position)
			if not visible then continue end

			local dist = (Vector2.new(pos.X,pos.Y) -
				Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)).Magnitude

			if dist < shortest then
				shortest = dist
				closest = head
			end

		end

	end

	return closest

end

--------------------------------------------------
-- ARROW REDIRECT
--------------------------------------------------

workspace.ChildAdded:Connect(function(obj)

	if not Enabled then return end
	if not obj:IsA("BasePart") then return end

	local name = obj.Name:lower()

	if name:find("arrow") or name:find("projectile") then

		local head = getTargetHead()

		if head then

			local direction = (head.Position - camera.CFrame.Position).Unit

			obj.CFrame = CFrame.new(
				head.Position - direction * 2,
				head.Position
			)

		end

	end

end)

--------------------------------------------------
-- UPDATE BOXES
--------------------------------------------------

RunService.RenderStepped:Connect(function()

	if not Enabled then return end

	for _,plr in pairs(Players:GetPlayers()) do

		if plr ~= player then
			createBox(plr)
		end

	end

end)

--------------------------------------------------
-- RESPAWN SUPPORT
--------------------------------------------------

Players.PlayerAdded:Connect(function(plr)

	plr.CharacterAdded:Connect(function()

		task.wait(0.5)

		if Enabled then
			createBox(plr)
		end

	end)

end)

Players.PlayerRemoving:Connect(removeBox)

--------------------------------------------------
-- ENABLE / DISABLE
--------------------------------------------------

local function enable()

	Enabled = true

	for _,plr in pairs(Players:GetPlayers()) do
		createBox(plr)
	end

end

local function disable()

	Enabled = false

	for _,box in pairs(Boxes) do
		box:Destroy()
	end

	table.clear(Boxes)

end

--------------------------------------------------
-- SETTINGS WATCHER
--------------------------------------------------

task.spawn(function()

	while true do

		task.wait(0.15)

		if Settings.Enabled and not Enabled then
			enable()

		elseif not Settings.Enabled and Enabled then
			disable()
		end

	end

end)
