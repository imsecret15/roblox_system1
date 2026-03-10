-- Hitbox_system.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Settings = shared.HitboxSettings

local Hitboxes = {}

--------------------------------------------------
-- CREATE HITBOX
--------------------------------------------------

local function createHitbox(plr)

	if not Settings.Enabled then return end
	if plr == player then return end
	if Hitboxes[plr] then return end

	local char = plr.Character
	if not char then return end

	local head = char:FindFirstChild("Head")
	if not head then return end

	local hitbox = Instance.new("Part")
	hitbox.Name = "ExtraHitbox"
	hitbox.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)
	hitbox.Color = Color3.fromRGB(255,0,0)
	hitbox.Material = Enum.Material.Neon
	hitbox.Transparency = Settings.Visible and 0.3 or 1
	hitbox.CanCollide = false
	hitbox.Anchored = false
	hitbox.Massless = true
	hitbox.Parent = char

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hitbox
	weld.Part1 = head
	weld.Parent = hitbox

	hitbox.CFrame = head.CFrame

	Hitboxes[plr] = hitbox

end

--------------------------------------------------
-- REMOVE HITBOX
--------------------------------------------------

local function removeHitbox(plr)

	local box = Hitboxes[plr]

	if box then
		box:Destroy()
		Hitboxes[plr] = nil
	end

end

--------------------------------------------------
-- UPDATE LOOP
--------------------------------------------------

RunService.Heartbeat:Connect(function()

	for _,plr in pairs(Players:GetPlayers()) do

		if plr ~= player then

			if Settings.Enabled then

				createHitbox(plr)

				local box = Hitboxes[plr]

				if box then
					box.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)
					box.Transparency = Settings.Visible and 0.3 or 1
				end

			else
				removeHitbox(plr)
			end

		end

	end

end)

--------------------------------------------------
-- RESPAWN SUPPORT
--------------------------------------------------

Players.PlayerAdded:Connect(function(plr)

	plr.CharacterAdded:Connect(function()

		task.wait(0.5)

		if Settings.Enabled then
			createHitbox(plr)
		end

	end)

end)

--------------------------------------------------
-- CLEANUP
--------------------------------------------------

Players.PlayerRemoving:Connect(function(plr)
	removeHitbox(plr)
end)
