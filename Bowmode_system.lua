-- Bowmode_system.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

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

	if Boxes[plr] then return end

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "BowModeBox"
	box.Adornee = head
	box.AlwaysOnTop = true
	box.ZIndex = 10

	box.Size = Vector3.new(3,3,3)
	box.Color3 = Color3.fromRGB(255, 50, 50)
	box.Transparency = Settings.Visible and 0.4 or 1

	box.Parent = head

	Boxes[plr] = box

end

--------------------------------------------------
-- UPDATE
--------------------------------------------------

RunService.RenderStepped:Connect(function()

	if not Enabled then return end

	for _,plr in pairs(Players:GetPlayers()) do

		if plr ~= player then

			local char = plr.Character
			if not char then continue end

			local head = char:FindFirstChild("Head")
			if not head then continue end

			if not Boxes[plr] then
				createBox(plr)
			end

			local box = Boxes[plr]

			if box then
				box.Transparency = Settings.Visible and 0.4 or 1
			end

		end

	end

end)

--------------------------------------------------
-- BOW HIT SYSTEM
--------------------------------------------------

local function getClosestHead()

	local closest
	local dist = math.huge

	for _,plr in pairs(Players:GetPlayers()) do

		if plr ~= player then

			local char = plr.Character
			if not char then continue end

			local head = char:FindFirstChild("Head")
			if not head then continue end

			local magnitude = (head.Position - workspace.CurrentCamera.CFrame.Position).Magnitude

			if magnitude < dist then
				dist = magnitude
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

	if obj.Name:lower():find("arrow") or obj.Name:lower():find("projectile") then

		local head = getClosestHead()

		if head then
			obj.CFrame = head.CFrame
		end

	end

end)

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
