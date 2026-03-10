-- Hitbox_system.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Settings = shared.HitboxSettings

local OriginalSizes = {}
local ModifiedPlayers = {}

local PartsToExpand = {
	Head = true,
	UpperTorso = true,
	LowerTorso = true,
	Torso = true
}

--------------------------------------------------
-- APPLY HITBOX
--------------------------------------------------

local function applyHitbox(plr)

	if plr == player then return end
	if ModifiedPlayers[plr] then return end

	local char = plr.Character
	if not char then return end

	for name,_ in pairs(PartsToExpand) do

		local part = char:FindFirstChild(name)

		if part then

			if not OriginalSizes[part] then
				OriginalSizes[part] = part.Size
			end

			part.Size = part.Size + Vector3.new(Settings.Size,Settings.Size,Settings.Size)
			part.Color = Color3.fromRGB(255,0,0)
			part.Material = Enum.Material.Neon
			part.Transparency = Settings.Visible and 0.3 or 1
			part.CanCollide = false

		end

	end

	ModifiedPlayers[plr] = true

end

--------------------------------------------------
-- RESET HITBOX
--------------------------------------------------

local function resetHitbox(plr)

	local char = plr.Character
	if not char then return end

	for name,_ in pairs(PartsToExpand) do

		local part = char:FindFirstChild(name)

		if part and OriginalSizes[part] then

			part.Size = OriginalSizes[part]
			part.Transparency = 0
			part.Material = Enum.Material.Plastic

		end

	end

	ModifiedPlayers[plr] = nil

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
	ModifiedPlayers[plr] = nil
end)
