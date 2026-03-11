-- Hitbox_system.lua (stable version)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local Hitboxes = {}
local LastEnabled = false

---

## -- SAFE SETTINGS

local function getSettings()
if shared and shared.HitboxSettings then
return shared.HitboxSettings
end

```
return {
	Enabled = false,
	Visible = true,
	Size = 5
}
```

end

---

## -- REMOVE HITBOX

local function removeHitbox(plr)
local data = Hitboxes[plr]
if data then
if data.folder then
data.folder:Destroy()
end
Hitboxes[plr] = nil
end
end

---

## -- REMOVE ALL

local function removeAll()
for plr,_ in pairs(Hitboxes) do
removeHitbox(plr)
end
end

---

## -- CREATE HITBOX

local function createHitbox(plr)

```
if plr == player then return end

local char = plr.Character
if not char then return end

local root = char:FindFirstChild("HumanoidRootPart")
if not root then return end

removeHitbox(plr)

local folder = Instance.new("Folder")
folder.Name = "ExtraHitbox"
folder.Parent = workspace

local parts = {}
local Settings = getSettings()

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

	part.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)
	part.Transparency = Settings.Visible and 0.4 or 1

	part.Parent = folder

	table.insert(parts,{
		part = part,
		offset = offset
	})
end

Hitboxes[plr] = {
	parts = parts,
	folder = folder
}
```

end

---

## -- UPDATE LOOP

RunService.RenderStepped:Connect(function()

```
local Settings = getSettings()

-- Handle toggle changes
if Settings.Enabled ~= LastEnabled then

	if not Settings.Enabled then
		removeAll()
	else
		for _,plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				createHitbox(plr)
			end
		end
	end

	LastEnabled = Settings.Enabled
end

if not Settings.Enabled then return end

for _,plr in ipairs(Players:GetPlayers()) do

	if plr ~= player then

		local char = plr.Character
		if not char then continue end

		local root = char:FindFirstChild("HumanoidRootPart")
		if not root then continue end

		if not Hitboxes[plr] then
			createHitbox(plr)
		end

		local data = Hitboxes[plr]
		if not data then continue end

		for _,info in ipairs(data.parts) do
			local part = info.part
			local offset = info.offset

			part.CFrame = root.CFrame * CFrame.new(offset)
			part.Size = Vector3.new(Settings.Size,Settings.Size,Settings.Size)
			part.Transparency = Settings.Visible and 0.4 or 1
		end
	end
end
```

end)

---

## -- PLAYER EVENTS

Players.PlayerRemoving:Connect(removeHitbox)

Players.PlayerAdded:Connect(function(plr)
plr.CharacterAdded:Connect(function()
if getSettings().Enabled then
task.wait(0.2)
createHitbox(plr)
end
end)
end)
