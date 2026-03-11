-- Hitbox_system.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local Settings
repeat
	task.wait()
	Settings = shared.HitboxSettings
until Settings

local Hitboxes = {}
local Enabled = false

--------------------------------------------------
-- CREATE HITBOX
--------------------------------------------------

local function createHitbox(plr)

	if plr == player then return end

	local char = plr.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	local head = char:FindFirstChild("Head")

	if not root then return end
	if Hitboxes[plr] then return end

	local folder = Instance.new("Folder")
	folder.Name = "HitboxFolder"
	folder.Parent = char

	local function makePart(size, parentPart)

		local part = Instance.new("Part")
		part.Name = "ExtraHitbox"
		part.Anchored = false
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = true
		part.Massless = true
		part.Transparency = Settings.Visible and 0.4 or 1
		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(255,0,0)
		part.Size = Vector3.new(size,size,size)
		part.Parent = folder

		local weld = Instance.new("Weld")
		weld.Part0 = parentPart
		weld.Part1 = part
		weld.C0 = CFrame.new()
		weld.Parent = part

		part.CFrame = parentPart.CFrame

		return part
	end

	local rootBox = makePart(Settings.Size, root)
	local headBox

	if head then
		headBox = makePart(Settings.Size * 0.7, head)
	end

	Hitboxes[plr] = {
		root = rootBox,
		head = headBox,
		folder = folder
	}

end

--------------------------------------------------
-- UPDATE
--------------------------------------------------

RunService.Heartbeat:Connect(function()

	if not Enabled then return end

	for _,plr in pairs(Players:GetPlayers()) do

		if plr == player then continue end

		local char = plr.Character
		if not char then continue end

		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then continue end

		if not Hitboxes[plr] then
			createHitbox(plr)
		end

		local data = Hitboxes[plr]
		if not data then continue end

		if data.root then
			data.root.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)
			data.root.Transparency = Settings.Visible and 0.4 or 1
		end

		if data.head then
			local size = Settings.Size * 0.7
			data.head.Size = Vector3.new(size,size,size)
			data.head.Transparency = Settings.Visible and 0.4 or 1
		end

	end

end)

--------------------------------------------------
-- REMOVE
--------------------------------------------------

local function removeHitbox(plr)

	local data = Hitboxes[plr]
	if not data then return end

	if data.folder then
		data.folder:Destroy()
	end

	Hitboxes[plr] = nil

end

--------------------------------------------------
-- ENABLE
--------------------------------------------------

local function enableHitbox()

	Enabled = true

	for _,plr in pairs(Players:GetPlayers()) do
		createHitbox(plr)
	end

end

--------------------------------------------------
-- DISABLE
--------------------------------------------------

local function disableHitbox()

	Enabled = false

	for plr,_ in pairs(Hitboxes) do
		removeHitbox(plr)
	end

end

--------------------------------------------------
-- SETTINGS WATCHER
--------------------------------------------------

task.spawn(function()

	while true do

		task.wait(0.2)

		if Settings.Enabled and not Enabled then
			enableHitbox()

		elseif not Settings.Enabled and Enabled then
			disableHitbox()
		end

	end

end)

--------------------------------------------------
-- PLAYER CLEANUP
--------------------------------------------------

Players.PlayerRemoving:Connect(removeHitbox)

--------------------------------------------------
-- RESPAWN SUPPORT
--------------------------------------------------

Players.PlayerAdded:Connect(function(plr)

	plr.CharacterAdded:Connect(function()

		task.wait(1)

		if Enabled then
			createHitbox(plr)
		end

	end)

end)
