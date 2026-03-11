-- Hitbox_system.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local Settings = shared.HitboxSettings

local Hitboxes = {}
local Enabled = false

--------------------------------------------------
-- CREATE HITBOX PART
--------------------------------------------------

local function createPart(parent, size)

	local p = Instance.new("Part")
	p.Size = size
	p.Anchored = false
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.Massless = true

	p.Color = Color3.fromRGB(255,0,0)
	p.Material = Enum.Material.Neon
	p.Transparency = Settings.Visible and 0.4 or 1

	p.Parent = parent

	return p

end

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

	local folder = Instance.new("Folder")
	folder.Name = "ExtraHitbox"
	folder.Parent = char

	local size = Settings.Size

	local offsets = {

		Vector3.new(0,0,0),
		Vector3.new(size,0,0),
		Vector3.new(-size,0,0),

		Vector3.new(0,0,size),
		Vector3.new(0,0,-size),

		Vector3.new(0,size,0),
		Vector3.new(0,-size,0)

	}

	for _,offset in ipairs(offsets) do

		local part = createPart(folder, Vector3.new(size,size,size))

		local weld = Instance.new("WeldConstraint")
		weld.Part0 = root
		weld.Part1 = part
		weld.Parent = part

		part.CFrame = root.CFrame * CFrame.new(offset)

	end

	Hitboxes[plr] = folder

end

--------------------------------------------------
-- UPDATE VISUALS
--------------------------------------------------

RunService.Heartbeat:Connect(function()

	if not Enabled then return end

	for plr,folder in pairs(Hitboxes) do

		for _,part in pairs(folder:GetChildren()) do

			part.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)
			part.Transparency = Settings.Visible and 0.4 or 1

		end

	end

end)

--------------------------------------------------
-- REMOVE
--------------------------------------------------

local function removeHitbox(plr)

	local folder = Hitboxes[plr]

	if folder then
		folder:Destroy()
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
