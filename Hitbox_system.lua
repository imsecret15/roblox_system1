-- Hitbox_system.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local Hitboxes = {}
local Enabled = false

--------------------------------------------------
-- SAFE SETTINGS
--------------------------------------------------

local function getSettings()

	if shared.HitboxSettings then
		return shared.HitboxSettings
	end

	return {
		Enabled = false,
		Size = 5,
		Visible = true
	}

end

--------------------------------------------------
-- CREATE HITBOX
--------------------------------------------------

local function createHitbox(plr)

	if plr == player then return end

	local char = plr.Character
	if not char then return end

	local root =
		char:FindFirstChild("HumanoidRootPart")
		or char:FindFirstChild("UpperTorso")
		or char:FindFirstChild("Torso")
		or char:FindFirstChild("LowerTorso")
		or char:FindFirstChild("Head")

	if not root then return end

	if Hitboxes[plr] then
		if Hitboxes[plr].folder then
			Hitboxes[plr].folder:Destroy()
		end
	end

	local folder = Instance.new("Folder")
	folder.Name = "ExtraHitbox"
	folder.Parent = workspace

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

	local Settings = getSettings()

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
-- UPDATE
--------------------------------------------------

RunService.RenderStepped:Connect(function()

	local Settings = getSettings()

	if not Settings.Enabled then return end

	for _,plr in pairs(Players:GetPlayers()) do

		if plr ~= player then

			local char = plr.Character
			if not char then continue end

			local root =
				char:FindFirstChild("HumanoidRootPart")
				or char:FindFirstChild("UpperTorso")
				or char:FindFirstChild("Torso")
				or char:FindFirstChild("LowerTorso")
				or char:FindFirstChild("Head")

			if not root then continue end

			if not Hitboxes[plr] then
				createHitbox(plr)
			end

			local data = Hitboxes[plr]
			if not data then continue end

			for _,info in pairs(data.parts) do

				local part = info.part
				local offset = info.offset

				part.CFrame = root.CFrame * CFrame.new(offset)

				part.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)
				part.Transparency = Settings.Visible and 0.4 or 1

			end

		end

	end

end)

--------------------------------------------------
-- CLEANUP
--------------------------------------------------

Players.PlayerRemoving:Connect(function(plr)

	local data = Hitboxes[plr]

	if data and data.folder then
		data.folder:Destroy()
	end

	Hitboxes[plr] = nil

end)
