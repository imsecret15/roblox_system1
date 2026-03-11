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

local function setPartHitbox(part, size)
	if not part then return end

	if not Modified[part] then
		Modified[part] = part.Size
	end

	part.Size = Vector3.new(size, size, size)
	part.CanCollide = false
	part.CanTouch = false
	part.Transparency = Settings.Visible and 0.5 or 1
end


local function applyHitbox(plr)

	if plr == player then return end

	local char = plr.Character
	if not char then return end

	setPartHitbox(char:FindFirstChild("HumanoidRootPart"), Settings.Size)
	setPartHitbox(char:FindFirstChild("Head"), Settings.Size/2)
	setPartHitbox(char:FindFirstChild("Torso"), Settings.Size)
	setPartHitbox(char:FindFirstChild("UpperTorso"), Settings.Size)
	setPartHitbox(char:FindFirstChild("LowerTorso"), Settings.Size)

end

--------------------------------------------------
-- RESTORE HITBOX
--------------------------------------------------

local function restoreHitbox(plr)

	local char = plr.Character
	if not char then return end

	for part,originalSize in pairs(Modified) do
		if part and part.Parent == char then
			part.Size = originalSize
			part.Transparency = 0
		end
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
