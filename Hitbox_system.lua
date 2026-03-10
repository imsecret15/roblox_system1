-- Hitbox_system.lua

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local Settings = shared.HitboxSettings

local Stored = {}
local Enabled = false

local Parts = {
	Head = true,
	UpperTorso = true,
	LowerTorso = true,
	Torso = true
}

--------------------------------------------------
-- STORE ORIGINAL SIZES
--------------------------------------------------

local function store(plr)

	local char = plr.Character
	if not char then return end

	if not Stored[plr] then
		Stored[plr] = {}
	end

	for name,_ in pairs(Parts) do
		local part = char:FindFirstChild(name)

		if part and not Stored[plr][name] then
			Stored[plr][name] = part.Size
		end
	end

end

--------------------------------------------------
-- APPLY HITBOX
--------------------------------------------------

local function apply(plr)

	if plr == player then return end

	local char = plr.Character
	if not char then return end

	store(plr)

	for name,size in pairs(Stored[plr]) do

		local part = char:FindFirstChild(name)

		if part then

			part.Size = size + Vector3.new(Settings.Size,Settings.Size,Settings.Size)
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

local function reset(plr)

	local char = plr.Character
	if not char then return end

	if not Stored[plr] then return end

	for name,size in pairs(Stored[plr]) do

		local part = char:FindFirstChild(name)

		if part then
			part.Size = size
			part.Transparency = 0
			part.Material = Enum.Material.Plastic
		end

	end

end

--------------------------------------------------
-- ENABLE / DISABLE
--------------------------------------------------

local function enable()

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player then
			apply(plr)
		end
	end

end

local function disable()

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player then
			reset(plr)
		end
	end

end

--------------------------------------------------
-- SETTINGS WATCHER
--------------------------------------------------

task.spawn(function()

	while true do
		task.wait(0.2)

		if Settings.Enabled and not Enabled then
			enable()
			Enabled = true
		elseif not Settings.Enabled and Enabled then
			disable()
			Enabled = false
		end

	end

end)

--------------------------------------------------
-- PLAYER RESPAWN
--------------------------------------------------

Players.PlayerAdded:Connect(function(plr)

	plr.CharacterAdded:Connect(function()

		task.wait(0.5)

		if Settings.Enabled then
			apply(plr)
		end

	end)

end)

--------------------------------------------------
-- CLEANUP
--------------------------------------------------

Players.PlayerRemoving:Connect(function(plr)
	Stored[plr] = nil
end)
