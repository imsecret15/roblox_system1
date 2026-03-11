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

	local char = plr.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- remove old
	if Hitboxes[plr] then
		if Hitboxes[plr].folder then
			Hitboxes[plr].folder:Destroy()
		end
	end

	local folder = Instance.new("Folder")
	folder.Name = "ExtraHitbox"
	folder.Parent = workspace.CurrentCamera

	local parts = {}

	local offsets = {
		Vector3.new(0,0,0),
		Vector3.new(1,0,0),
		Vector3.new(-1,0,0),
		Vector3.new(0,0,1),
		Vector3.new(0,0,-1),
		Vector3.new(0,1,0),
		Vector3.new(0,-1,0)
	}

	for _,offset in ipairs(offsets) do

		local part = Instance.new("Part")

		part.Anchored = true
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false

		part.Material = Enum.Material.Neon
		part.Color = Color3.fromRGB(255,0,0)

		part.Transparency = Settings.Visible and 0.4 or 1
		part.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)

		part.Parent = folder

		table.insert(parts,{
			part = part,
			offset = offset
		})

	end

	Hitboxes[plr] = {
		root = root,
		parts = parts,
		folder = folder
	}

end

--------------------------------------------------
-- UPDATE HITBOXES
--------------------------------------------------

RunService.RenderStepped:Connect(function()

	if not Enabled then return end

	for plr,data in pairs(Hitboxes) do

		local root = data.root

		if not root or not root.Parent then
			createHitbox(plr)
			continue
		end

		for _,info in pairs(data.parts) do

			local part = info.part
			local offset = info.offset

			part.CFrame = root.CFrame * CFrame.new(offset * Settings.Size)

			part.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)
			part.Transparency = Settings.Visible and 0.4 or 1

		end

	end

end)

--------------------------------------------------
-- AUTO SCANNER (FIXES MISSING HITBOXES)
--------------------------------------------------

task.spawn(function()

	while true do

		task.wait(1)

		if not Enabled then continue end

		for _,plr in pairs(Players:GetPlayers()) do

			if plr ~= player then

				if not Hitboxes[plr] then
					createHitbox(plr)
				end

			end

		end

	end

end)

--------------------------------------------------
-- REMOVE
--------------------------------------------------

local function removeHitbox(plr)

	local data = Hitboxes[plr]

	if data then
		if data.folder then
			data.folder:Destroy()
		end
		Hitboxes[plr] = nil
	end

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
