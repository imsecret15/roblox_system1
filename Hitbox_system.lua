-- Hitbox_system.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Settings = shared.HitboxSettings

local Enabled = false
local Modified = {}

--------------------------------------------------
-- APPLY HITBOX
--------------------------------------------------

local function applyHitbox(plr)

	if plr == player then return end

	local char = plr.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	local head = char:FindFirstChild("Head")

	if root then

		if not Modified[root] then
			Modified[root] = root.Size
		end

		root.Size = Vector3.new(Settings.Size, Settings.Size, Settings.Size)
		root.CanCollide = false
		root.Transparency = Settings.Visible and 0.5 or 1

	end

	if head then

		if not Modified[head] then
			Modified[head] = head.Size
		end

		head.Size = Vector3.new(Settings.Size/2, Settings.Size/2, Settings.Size/2)
		head.CanCollide = false
		head.Transparency = Settings.Visible and 0.5 or 1

	end

end

--------------------------------------------------
-- RESTORE HITBOX
--------------------------------------------------

local function restoreHitbox(plr)

	local char = plr.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	local head = char:FindFirstChild("Head")

	if root and Modified[root] then
		root.Size = Modified[root]
		root.Transparency = 0
	end

	if head and Modified[head] then
		head.Size = Modified[head]
		head.Transparency = 0
	end

end

--------------------------------------------------
-- UPDATE LOOP
--------------------------------------------------

RunService.Heartbeat:Connect(function()

	if not Enabled then return end

	for _,plr in pairs(Players:GetPlayers()) do
		applyHitbox(plr)
	end

end)

--------------------------------------------------
-- ENABLE
--------------------------------------------------

local function enableHitbox()

	Enabled = true

	for _,plr in pairs(Players:GetPlayers()) do
		applyHitbox(plr)
	end

end

--------------------------------------------------
-- DISABLE
--------------------------------------------------

local function disableHitbox()

	Enabled = false

	for _,plr in pairs(Players:GetPlayers()) do
		restoreHitbox(plr)
	end

end

--------------------------------------------------
-- SETTINGS WATCHER
--------------------------------------------------

task.spawn(function()

	while true do

		task.wait(0.15)

		if Settings.Enabled and not Enabled then
			enableHitbox()

		elseif not Settings.Enabled and Enabled then
			disableHitbox()
		end

	end

end)

--------------------------------------------------
-- PLAYER JOIN SUPPORT
--------------------------------------------------

Players.PlayerAdded:Connect(function(plr)

	plr.CharacterAdded:Connect(function()

		task.wait(0.5)

		if Settings.Enabled then
			applyHitbox(plr)
		end

	end)

end)
