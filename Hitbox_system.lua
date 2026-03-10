local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

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
	hitbox.Size = Vector3.new(HitboxSize,HitboxSize,HitboxSize)
	hitbox.Color = Color3.fromRGB(255,0,0)
	hitbox.Material = Enum.Material.Neon
	hitbox.Transparency = HitboxVisible and 0.3 or 1
	hitbox.CanCollide = false
	hitbox.Anchored = false
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

	if Hitboxes[target] then
		Hitboxes[target]:Destroy()
		Hitboxes[target] = nil
	end

end

--------------------------------------------------
-- UPDATE LOOP
--------------------------------------------------

RunService.Heartbeat:Connect(function()

	if HitboxEnabled then

		for _,v in pairs(Players:GetPlayers()) do
			createHitbox(v)
		end

		for plr,box in pairs(Hitboxes) do

			if box then
				box.Size = Vector3.new(HitboxSize,HitboxSize,HitboxSize)
				box.Transparency = HitboxVisible and 0.3 or 1
			end

		end

	else

		for plr,_ in pairs(Hitboxes) do
			removeHitbox(plr)
		end

	end

end)

--------------------------------------------------
-- PLAYER JOIN SUPPORT
--------------------------------------------------

Players.PlayerAdded:Connect(function(plr)

	plr.CharacterAdded:Connect(function()
		task.wait(0.5)

		if HitboxEnabled then
			createHitbox(plr)
		end
	end)

end)
