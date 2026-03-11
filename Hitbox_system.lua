-- Hitbox_system.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Settings = shared.HitboxSettings

local Hitboxes = {}
local Enabled = false

--------------------------------------------------
-- CREATE HITBOX
--------------------------------------------------

local function createHitbox(plr)

	if plr == player then return end
	if Hitboxes[plr] then return end

	local char = plr.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local box = Instance.new("Part")
	box.Name = "ExtraHitbox"
	box.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)

	box.Anchored = false
	box.CanCollide = false
	box.CanTouch = false
	box.CanQuery = false

	box.Massless = true
	box.Material = Enum.Material.Neon
	box.Color = Color3.fromRGB(255,0,0)
	box.Transparency = Settings.Visible and 0.4 or 1

	box.Parent = char

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = box
	weld.Parent = box

	box.CFrame = root.CFrame

	Hitboxes[plr] = box

end

--------------------------------------------------
-- UPDATE
--------------------------------------------------

RunService.Heartbeat:Connect(function()

	if not Enabled then return end

	for plr,box in pairs(Hitboxes) do

		if not box then continue end

		local newSize = Vector3.new(Settings.Size,Settings.Size,Settings.Size)

		if box.Size ~= newSize then
			box.Size = newSize
		end

		box.Transparency = Settings.Visible and 0.4 or 1

	end

end)

--------------------------------------------------
-- REMOVE
--------------------------------------------------

local function removeHitbox(plr)

	local box = Hitboxes[plr]

	if box then
		box:Destroy()
		Hitboxes[plr] = nil
	end

end

--------------------------------------------------
-- ENABLE
--------------------------------------------------

local function enableHitbox()

	for _,plr in pairs(Players:GetPlayers()) do
		createHitbox(plr)
	end

	Enabled = true

end

--------------------------------------------------
-- DISABLE
--------------------------------------------------

local function disableHitbox()

	for plr,_ in pairs(Hitboxes) do
		removeHitbox(plr)
	end

	Enabled = false

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
-- PLAYER JOIN
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
