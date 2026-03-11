-- Hitbox_system.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Settings = shared.HitboxSettings

local Enabled = false

--------------------------------------------------
-- APPLY HITBOX
--------------------------------------------------

local function applyHitbox(plr)

	if plr == player then return end

	local char = plr.Character
	if not char then return end

	local head = char:FindFirstChild("Head")
	local root = char:FindFirstChild("HumanoidRootPart")

	if head then
		head.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)
		head.Material = Enum.Material.Neon
		head.Color = Color3.fromRGB(255,0,0)
		head.Transparency = Settings.Visible and 0.4 or 1
		head.CanCollide = false
	end

	if root then
		root.Size = Vector3.new(Settings.Size*1.5,Settings.Size*1.5,Settings.Size*1.5)
		root.CanCollide = false
	end

end

--------------------------------------------------
-- UPDATE LOOP
--------------------------------------------------

RunService.RenderStepped:Connect(function()

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

end

--------------------------------------------------
-- DISABLE
--------------------------------------------------

local function disableHitbox()

	Enabled = false

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
