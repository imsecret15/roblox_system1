-- Bowmode_system.lua

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Settings
repeat task.wait() until shared.BowModeSettings
Settings = shared.BowModeSettings

local Boxes = {}
local Enabled = false

--------------------------------------------------
-- FIND BOW
--------------------------------------------------

local function getBow()

	local char = player.Character
	if not char then return end

	for _,tool in pairs(player.Backpack:GetChildren()) do
		if tool:FindFirstChild("mouse") then
			return tool
		end
	end

	if char then
		for _,tool in pairs(char:GetChildren()) do
			if tool:FindFirstChild("mouse") then
				return tool
			end
		end
	end

end

--------------------------------------------------
-- TARGET SELECTION
--------------------------------------------------

local function getTargetHead()

	if shared.AimTarget and shared.AimTarget.Character then
		return shared.AimTarget.Character:FindFirstChild("Head")
	end

	local closest
	local shortest = math.huge

	for _,plr in pairs(Players:GetPlayers()) do

		if plr ~= player and plr.Character then

			local head = plr.Character:FindFirstChild("Head")
			if not head then continue end

			local pos, visible = camera:WorldToViewportPoint(head.Position)
			if not visible then continue end

			local dist = (Vector2.new(pos.X,pos.Y) -
				Vector2.new(camera.ViewportSize.X/2,camera.ViewportSize.Y/2)).Magnitude

			if dist < shortest then
				shortest = dist
				closest = head
			end

		end

	end

	return closest

end

--------------------------------------------------
-- BOX VISUAL
--------------------------------------------------

local function createBox(plr)

	if plr == player then return end
	if not plr.Character then return end

	local head = plr.Character:FindFirstChild("Head")
	if not head then return end

	if Boxes[plr] then return end

	local box = Instance.new("BoxHandleAdornment")
	box.Adornee = head
	box.Size = Vector3.new(3,3,3)
	box.Color3 = Color3.fromRGB(255,50,50)
	box.AlwaysOnTop = true
	box.Transparency = Settings.Visible and 0.4 or 1
	box.Parent = head

	Boxes[plr] = box

end

--------------------------------------------------
-- BOW HOOK
--------------------------------------------------

local function hookBow()

	local bow = getBow()
	if not bow then return end

	local mouseEvent = bow:FindFirstChild("mouse")
	if not mouseEvent then return end

	local old
	old = hookmetamethod(game,"__namecall",function(self,...)

		local args = {...}
		local method = getnamecallmethod()

		if Enabled and self == mouseEvent and method == "FireServer" then

			local head = getTargetHead()

			if head then
				args[1] = head.Position
			end

			return old(self,unpack(args))
		end

		return old(self,...)

	end)

end

--------------------------------------------------
-- ENABLE / DISABLE
--------------------------------------------------

local function enable()

	Enabled = true

	for _,plr in pairs(Players:GetPlayers()) do
		createBox(plr)
	end

	hookBow()

end

local function disable()

	Enabled = false

	for _,box in pairs(Boxes) do
		box:Destroy()
	end

	table.clear(Boxes)

end

--------------------------------------------------
-- SETTINGS WATCHER
--------------------------------------------------

task.spawn(function()

	while true do

		task.wait(0.15)

		if Settings.Enabled and not Enabled then
			enable()

		elseif not Settings.Enabled and Enabled then
			disable()
		end

	end

end)
