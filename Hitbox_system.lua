-- Hitbox_system.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Settings = shared.HitboxSettings

local StoredSizes = {}

local Parts = {
	Head = true,
	UpperTorso = true,
	LowerTorso = true,
	Torso = true
}

--------------------------------------------------
-- SAVE ORIGINAL SIZES
--------------------------------------------------

local function storeSizes(plr)

	local char = plr.Character
	if not char then return end

	if not StoredSizes[plr] then
		StoredSizes[plr] = {}
	end

	for name,_ in pairs(Parts) do
		local part = char:FindFirstChild(name)

		if part and not StoredSizes[plr][name] then
			StoredSizes[plr][name] = part.Size
		end
	end

end

--------------------------------------------------
-- APPLY HITBOX
--------------------------------------------------

local function applyHitbox(plr)

	local char = plr.Character
	if not char then return end

	storeSizes(plr)

	for name,_ in pairs(Parts) do

		local part = char:FindFirstChild(name)

		if part and StoredSizes[plr][name] then

			part.Size = StoredSizes[plr][name] + Vector3.new(Settings.Size,Settings.Size,Settings.Size)
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

local function resetHitbox(plr)

	local char = plr.Character
	if not char then return end

	if not StoredSizes[plr] then return end

	for name,size in pairs(StoredSizes[plr]) do

		local part = char:FindFirstChild(name)

		if part then
			part.Size = size
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
-- PLAYER RESPAWN SUPPORT
--------------------------------------------------

Players.PlayerAdded:Connect(function(plr)

	plr.CharacterAdded:Connect(function()

		task.wait(0.5)

		if Settings.Enabled then
			applyHitbox(plr)
		end

	end)

end)

--------------------------------------------------
-- CLEANUP
--------------------------------------------------

Players.PlayerRemoving:Connect(function(plr)
	StoredSizes[plr] = nil
end)
