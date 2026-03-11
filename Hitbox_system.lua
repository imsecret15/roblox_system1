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

	local head = char:FindFirstChild("Head")
	if not head then return end

	local hitbox = Instance.new("Part")
	hitbox.Name = "ExtraHitbox"
	hitbox.Size = Vector3.new(Settings.Size, Settings.Size, Settings.Size)
	hitbox.Color = Color3.fromRGB(255,0,0)
	hitbox.Material = Enum.Material.Neon

	hitbox.Transparency = Settings.Visible and 0.35 or 1

	hitbox.CanCollide = false
	hitbox.CanQuery = false
	hitbox.CanTouch = false
	hitbox.Anchored = true
	hitbox.Massless = true

	-- keep arrows from hitting it
	hitbox.Parent = workspace.CurrentCamera

	Hitboxes[plr] = hitbox

end

--------------------------------------------------
-- UPDATE / FOLLOW HEAD
--------------------------------------------------

RunService.Heartbeat:Connect(function()

	if not Enabled then return end

	for plr, hitbox in pairs(Hitboxes) do

		local char = plr.Character
		if not char then continue end

		local head = char:FindFirstChild("Head")
		if not head then continue end

		-- follow player
		hitbox.CFrame = head.CFrame * CFrame.new(0,0,-0.25)

		-- update size if changed
		local newSize = Vector3.new(Settings.Size, Settings.Size, Settings.Size)
		if hitbox.Size ~= newSize then
			hitbox.Size = newSize
		end

		-- update visibility toggle
		local newTransparency = Settings.Visible and 0.35 or 1
		if hitbox.Transparency ~= newTransparency then
			hitbox.Transparency = newTransparency
		end

	end

end)

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
-- ENABLE
--------------------------------------------------

local function enableHitbox()

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player then
			createHitbox(plr)
		end
	end

end

--------------------------------------------------
-- DISABLE
--------------------------------------------------

local function disableHitbox()

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
			Enabled = true

		elseif not Settings.Enabled and Enabled then
			disableHitbox()
			Enabled = false
		end

	end

end)

--------------------------------------------------
-- PLAYER JOIN SUPPORT
--------------------------------------------------

Players.PlayerAdded:Connect(function(plr)

	plr.CharacterAdded:Connect(function()

		task.wait(0.4)

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
