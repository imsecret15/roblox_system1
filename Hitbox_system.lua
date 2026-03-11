-- Hitbox_system.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local Settings
repeat
	task.wait()
	Settings = shared.HitboxSettings
until Settings

local Hitboxes = {}
local Enabled = false

--------------------------------------------------
-- CREATE HITBOX
--------------------------------------------------

local function createHitbox(plr)

	if plr == player then return end

	local char = plr.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if Hitboxes[plr] then return end

	local part = Instance.new("Part")
	part.Name = "ExtraHitbox"

	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false

	part.Material = Enum.Material.Neon
	part.Color = Color3.fromRGB(255,0,0)
	part.CastShadow = false

	part.Transparency = 0
	part.LocalTransparencyModifier = Settings.Visible and 0.6 or 1

	part.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)

	part.Parent = workspace
	part.CFrame = root.CFrame

	Hitboxes[plr] = {
		part = part,
		root = root
	}

end

--------------------------------------------------
-- UPDATE
--------------------------------------------------

RunService.RenderStepped:Connect(function()

	if not Enabled then return end

	for _,plr in pairs(Players:GetPlayers()) do

		if plr == player then continue end

		local char = plr.Character
		if not char then continue end

		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then continue end

		if not Hitboxes[plr] then
			createHitbox(plr)
		end

		local data = Hitboxes[plr]
		if not data then continue end

		local part = data.part

		if not part or not part.Parent then
			Hitboxes[plr] = nil
			createHitbox(plr)
			continue
		end

		data.root = root

		part.CFrame = data.root.CFrame
		part.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)
		part.LocalTransparencyModifier = Settings.Visible and 0.6 or 1

	end

end)

--------------------------------------------------
-- REMOVE
--------------------------------------------------

local function removeHitbox(plr)

	local data = Hitboxes[plr]
	if not data then return end

	if data.part then
		data.part:Destroy()
	end

	Hitboxes[plr] = nil

end

--------------------------------------------------
-- ENABLE
--------------------------------------------------

local function enableHitbox()

	Enabled = true

	for _,plr in pairs(Players:GetPlayers()) do
		createHitbox(plr)
	end

end

--------------------------------------------------
-- DISABLE
--------------------------------------------------

local function disableHitbox()

	Enabled = false

	for plr,_ in pairs(Hitboxes) do
		removeHitbox(plr)
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
-- PLAYER CLEANUP
--------------------------------------------------

Players.PlayerRemoving:Connect(removeHitbox)

--------------------------------------------------
-- RESPAWN SUPPORT
--------------------------------------------------

Players.PlayerAdded:Connect(function(plr)

	plr.CharacterAdded:Connect(function()

		removeHitbox(plr)

		task.wait(0.5)

		if Enabled then
			createHitbox(plr)
		end

	end)

end)
