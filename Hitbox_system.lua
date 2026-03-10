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
	hitbox.Name = "Head"
	hitbox.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)
	hitbox.Color = Color3.fromRGB(255,0,0)
	hitbox.Material = Enum.Material.Neon
	hitbox.Transparency = Settings.Visible and 0.3 or 1
	hitbox.CanCollide = false
    hitbox.Anchored = true
    hitbox.Massless = true
    hitbox.Parent = char

    hitbox:SetAttribute("OriginalPart","Head")

	hitbox.CFrame = head.CFrame
    RunService.RenderStepped:Connect(function()

	if not Settings.Enabled then return end

	if plr.Character then
		local head = plr.Character:FindFirstChild("Head")
		if head then
			hitbox.CFrame = head.CFrame
		end
	end

end)

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
-- ENABLE HITBOX
--------------------------------------------------

local function enableHitbox()

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player then
			createHitbox(plr)
		end
	end

end

--------------------------------------------------
-- DISABLE HITBOX
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

		task.wait(0.2)

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
