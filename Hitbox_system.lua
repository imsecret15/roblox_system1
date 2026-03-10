-- Hitbox_system.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Settings = shared.HitboxSettings

local OriginalSizes = {}
local PartsToExpand = {
	Head = true,
	UpperTorso = true,
	LowerTorso = true,
	Torso = true
}

--------------------------------------------------
-- APPLY HITBOX
--------------------------------------------------

local function applyHitbox(target)

	if target == player then return end

	local char = target.Character
	if not char then return end

	for partName,_ in pairs(PartsToExpand) do

		local part = char:FindFirstChild(partName)

		if part then

			if not OriginalSizes[part] then
				OriginalSizes[part] = part.Size
			end

			part.Size = OriginalSizes[part] + Vector3.new(Settings.Size,Settings.Size,Settings.Size)
			part.Color = Color3.fromRGB(255,0,0)
			part.Material = Enum.Material.Neon
			part.Transparency = Settings.Visible and 0.3 or 1
			part.CanCollide = false

		end

	end

end

--------------------------------------------------
-- RESET HITBOX
--------------------------------------------------

local function resetHitbox(target)

	local char = target.Character
	if not char then return end

	for partName,_ in pairs(PartsToExpand) do

		local part = char:FindFirstChild(partName)

		if part and OriginalSizes[part] then

			part.Size = OriginalSizes[part]
			part.Transparency = 0
			part.Material = Enum.Material.Plastic

		end

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
	-- clear stored sizes
	for part,_ in pairs(OriginalSizes) do
		if part.Parent == nil then
			OriginalSizes[part] = nil
		end
	end
end)
