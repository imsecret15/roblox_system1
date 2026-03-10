-- Hitbox_system.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Settings = shared.HitboxSettings
local Hitboxes = {}

--------------------------------------------------
-- CREATE HITBOX
--------------------------------------------------

local function createHitbox(target)

	if target == player then return end
	if Hitboxes[target] then return end

	local char = target.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local hitbox = Instance.new("Part")
	hitbox.Name = "FakeHitbox"
	hitbox.Size = Vector3.new(Settings.Size, Settings.Size, Settings.Size)
	hitbox.Color = Color3.fromRGB(255,0,0)
	hitbox.Material = Enum.Material.Neon
	hitbox.Transparency = Settings.Visible and 0.3 or 1
	hitbox.CanCollide = false
	hitbox.Anchored = false
	hitbox.Massless = true
	hitbox.Parent = char

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hitbox
	weld.Part1 = root
	weld.Parent = hitbox

	hitbox.CFrame = root.CFrame

	Hitboxes[target] = hitbox

end

--------------------------------------------------
-- REMOVE HITBOX
--------------------------------------------------

local function removeHitbox(target)

	local box = Hitboxes[target]

	if box then
		box:Destroy()
		Hitboxes[target] = nil
	end

end

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------

RunService.Heartbeat:Connect(function()

	if not Settings.Enabled then

		for plr,_ in pairs(Hitboxes) do
			removeHitbox(plr)
		end

		return
	end

	for _,plr in pairs(Players:GetPlayers()) do

		if plr ~= player then

			createHitbox(plr)

			local box = Hitboxes[plr]

			if box then
				box.Size = Vector3.new(Settings.Size, Settings.Size, Settings.Size)
				box.Transparency = Settings.Visible and 0.3 or 1
			end

		end

	end

end)

--------------------------------------------------
-- PLAYER JOIN / RESPAWN
--------------------------------------------------

Players.PlayerAdded:Connect(function(plr)

	plr.CharacterAdded:Connect(function()
		task.wait(0.5)

		if Settings.Enabled then
			createHitbox(plr)
		end
	end)

end)

Players.PlayerRemoving:Connect(function(plr)
	removeHitbox(plr)
end)
