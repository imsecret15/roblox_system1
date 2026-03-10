-- Hitbox_system.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Settings = shared.HitboxSettings

local OriginalSizes = {}

--------------------------------------------------
-- APPLY HITBOX
--------------------------------------------------

local function applyHitbox(target)

	if target == player then return end

	local char = target.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if not OriginalSizes[target] then
		OriginalSizes[target] = root.Size
	end

	root.Size = Vector3.new(Settings.Size, Settings.Size, Settings.Size)
	root.Transparency = Settings.Visible and 0.3 or 1

end

--------------------------------------------------
-- RESET HITBOX
--------------------------------------------------

local function resetHitbox(target)

	local char = target.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if OriginalSizes[target] then
		root.Size = OriginalSizes[target]
		root.Transparency = 1
	end

end

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------

RunService.Heartbeat:Connect(function()

	for _,plr in pairs(Players:GetPlayers()) do

		if plr ~= player then

			if Settings.Enabled then
				applyHitbox(plr)
			else
				resetHitbox(plr)
			end

		end

	end

end)

--------------------------------------------------
-- CLEANUP
--------------------------------------------------

Players.PlayerRemoving:Connect(function(plr)
	OriginalSizes[plr] = nil
end)
