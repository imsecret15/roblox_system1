-- Hitbox_system.lua (Improved)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

--------------------------------------------------
-- WAIT FOR SETTINGS
--------------------------------------------------

local Settings
repeat
	task.wait()
	Settings = shared.HitboxSettings
until Settings

--------------------------------------------------
-- VARIABLES
--------------------------------------------------

local Hitboxes = {}
local Enabled = false

--------------------------------------------------
-- CREATE VISUAL BOX
--------------------------------------------------

local function createVisual(root)

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "HitboxVisual"

	box.Adornee = root
	box.AlwaysOnTop = true
	box.ZIndex = 5

	box.Color3 = Color3.fromRGB(255,0,0)
	box.Transparency = 0.5

	box.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)

	box.Parent = root

	return box

end

--------------------------------------------------
-- APPLY HITBOX
--------------------------------------------------

local function applyHitbox(plr)

	if plr == player then return end

	local char = plr.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if Hitboxes[plr] then return end

	local data = {}

	data.root = root
	data.originalSize = root.Size

	-- expand root
	root.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)
	root.CanCollide = false

	-- optional visual
	if Settings.Visible then
		data.visual = createVisual(root)
	end

	Hitboxes[plr] = data

end

--------------------------------------------------
-- REMOVE HITBOX
--------------------------------------------------

local function removeHitbox(plr)

	local data = Hitboxes[plr]
	if not data then return end

	if data.root and data.root.Parent then
		data.root.Size = data.originalSize
	end

	if data.visual then
		data.visual:Destroy()
	end

	Hitboxes[plr] = nil

end

--------------------------------------------------
-- UPDATE LOOP
--------------------------------------------------

RunService.RenderStepped:Connect(function()

	if not Enabled then return end

	for _,plr in pairs(Players:GetPlayers()) do

		if plr == player then continue end

		local char = plr.Character
		if not char then continue end

		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then continue end

		if not Hitboxes[plr] then
			applyHitbox(plr)
			continue
		end

		local data = Hitboxes[plr]

		if not data.root or not data.root.Parent then
			removeHitbox(plr)
			applyHitbox(plr)
			continue
		end

		-- live update size
		data.root.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)

		if data.visual then
			data.visual.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)
		end

	end

end)

--------------------------------------------------
-- ENABLE
--------------------------------------------------

local function enable()

	Enabled = true

	for _,plr in pairs(Players:GetPlayers()) do
		applyHitbox(plr)
	end

end

--------------------------------------------------
-- DISABLE
--------------------------------------------------

local function disable()

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
			enable()

		elseif not Settings.Enabled and Enabled then
			disable()
		end

	end

end)

--------------------------------------------------
-- PLAYER REMOVAL
--------------------------------------------------

Players.PlayerRemoving:Connect(removeHitbox)

--------------------------------------------------
-- RESPAWN SUPPORT
--------------------------------------------------

Players.PlayerAdded:Connect(function(plr)

	plr.CharacterAdded:Connect(function()

		removeHitbox(plr)

		task.wait(0.5)

		if Enabled then
			applyHitbox(plr)
		end

	end)

end)
