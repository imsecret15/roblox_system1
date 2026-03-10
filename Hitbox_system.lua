-- Hitbox_system.lua

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Settings = shared.HitboxSettings

local OriginalSizes = {}

local function applyHitbox(plr)

	if plr == player then return end

	local char = plr.Character
	if not char then return end

	local head = char:FindFirstChild("Head")
	if not head then return end

	if not OriginalSizes[plr] then
		OriginalSizes[plr] = head.Size
	end

	head.Size = OriginalSizes[plr] + Vector3.new(Settings.Size,Settings.Size,Settings.Size)
	head.Transparency = Settings.Visible and 0.3 or 1
	head.Material = Enum.Material.Neon
	head.Color = Color3.fromRGB(255,0,0)

end


local function resetHitbox(plr)

	local char = plr.Character
	if not char then return end

	local head = char:FindFirstChild("Head")
	if not head then return end

	if OriginalSizes[plr] then
		head.Size = OriginalSizes[plr]
		head.Transparency = 0
		head.Material = Enum.Material.Plastic
	end

end


while true do
	task.wait(0.2)

	for _,plr in pairs(Players:GetPlayers()) do

		if plr ~= player then

			if Settings.Enabled then
				applyHitbox(plr)
			else
				resetHitbox(plr)
			end

		end

	end

end
