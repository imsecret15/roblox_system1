-- Hitbox_system.lua

local Players = game:GetService("Players")

local player = Players.LocalPlayer
local Settings = shared.HitboxSettings

local ModifiedHeads = {}
local Enabled = false

--------------------------------------------------
-- APPLY HITBOX
--------------------------------------------------

local function applyHitbox(plr)

	if plr == player then return end
	if not plr.Character then return end

	local char = plr.Character
	local head = char:FindFirstChild("Head")

	if not head then return end

	-- Save original size if not stored
	if not ModifiedHeads[plr] then
		ModifiedHeads[plr] = {
			Head = head,
			OriginalSize = head.Size
		}
	end

	head.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)
	head.Material = Enum.Material.Neon
	head.Color = Color3.fromRGB(255,0,0)
	head.Transparency = Settings.Visible and 0.3 or 1

end

--------------------------------------------------
-- RESET HITBOX
--------------------------------------------------

local function resetHitbox(plr)

	local data = ModifiedHeads[plr]

	if data and data.Head then
		local head = data.Head

		head.Size = data.OriginalSize
		head.Transparency = 0
		head.Material = Enum.Material.Plastic

		ModifiedHeads[plr] = nil
	end

end

--------------------------------------------------
-- ENABLE
--------------------------------------------------

local function enableHitbox()

	for _,plr in pairs(Players:GetPlayers()) do
		applyHitbox(plr)
	end

end

--------------------------------------------------
-- DISABLE
--------------------------------------------------

local function disableHitbox()

	for plr,_ in pairs(ModifiedHeads) do
		resetHitbox(plr)
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
			Enabled = true
		elseif not Settings.Enabled and Enabled then
			disableHitbox()
			Enabled = false
		end

		if Enabled then
			for plr,data in pairs(ModifiedHeads) do
				if plr.Character and data.Head then
					data.Head.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)
					data.Head.Transparency = Settings.Visible and 0.3 or 1
				end
			end
		end

	end

end)

--------------------------------------------------
-- PLAYER JOIN
--------------------------------------------------

Players.PlayerAdded:Connect(function(plr)

	plr.CharacterAdded:Connect(function()

		task.wait(0.3)

		if Settings.Enabled then
			applyHitbox(plr)
		end

	end)

end)

--------------------------------------------------
-- PLAYER RESPAWN SUPPORT
--------------------------------------------------

for _,plr in pairs(Players:GetPlayers()) do

	plr.CharacterAdded:Connect(function()

		task.wait(0.3)

		if Settings.Enabled then
			applyHitbox(plr)
		end

	end)

end

--------------------------------------------------
-- CLEANUP
--------------------------------------------------

Players.PlayerRemoving:Connect(function(plr)
	resetHitbox(plr)
end)
