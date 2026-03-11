-- Bowmode_system.lua

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Settings
repeat task.wait() until shared.BowModeSettings
Settings = shared.BowModeSettings

local Boxes = {}
local Enabled = false

--------------------------------------------------
-- HEAD BOX
--------------------------------------------------

local function createBox(plr)

	if plr == player then return end
	if not plr.Character then return end

	local head = plr.Character:FindFirstChild("Head")
	if not head then return end

	if Boxes[plr] then
		if Boxes[plr].Adornee == head then return end
		Boxes[plr]:Destroy()
	end

	local box = Instance.new("BoxHandleAdornment")
	box.Name = "BowModeBox"
	box.Adornee = head
	box.Size = Vector3.new(3,3,3)
	box.Color3 = Color3.fromRGB(255,50,50)
	box.AlwaysOnTop = true
	box.ZIndex = 10
	box.Transparency = Settings.Visible and 0.4 or 1
	box.Parent = head

	Boxes[plr] = box

end

--------------------------------------------------
-- TARGET HEAD
--------------------------------------------------

local function getTargetHead()

	local cam = workspace.CurrentCamera
	local camPos = cam.CFrame.Position

	-- priority: aimlock
	if shared.AimTarget and shared.AimTarget.Character then
		local head = shared.AimTarget.Character:FindFirstChild("Head")
		local root = shared.AimTarget.Character:FindFirstChild("HumanoidRootPart")

		if head and root then
			local dist = (head.Position - camPos).Magnitude

			local prediction = root.Velocity * (dist * 0.0025)
			local drop = Vector3.new(0, dist * 0.0015, 0)

			return {
				head = head,
				position = head.Position + prediction + drop
			}
		end
	end

	-- fallback: closest player
	local closest
	local bestDist = math.huge

	for _,plr in pairs(Players:GetPlayers()) do

		if plr ~= player and plr.Character then

			local head = plr.Character:FindFirstChild("Head")
			local root = plr.Character:FindFirstChild("HumanoidRootPart")

			if head and root then

				local dist = (head.Position - camPos).Magnitude

				if dist < bestDist then
					bestDist = dist

					local prediction = root.Velocity * (dist * 0.0025)
					local drop = Vector3.new(0, dist * 0.0015, 0)

					closest = {
						head = head,
						position = head.Position + prediction + drop
					}

				end

			end

		end

	end

	return closest

end

--------------------------------------------------
-- REMOTE HOOK (REAL FIX)
--------------------------------------------------

local mt = getrawmetatable(game)
setreadonly(mt,false)

local old = mt.__namecall

mt.__namecall = newcclosure(function(self,...)

	local args = {...}
	local method = getnamecallmethod()

	if Enabled and method == "FireServer" then

		if typeof(args[3]) == "string" and args[3] == "S" then

			local target = getTargetHead()

			if target then
				args[1] = target.position
			end

			return old(self,unpack(args))

		end

	end

	return old(self,...)

end)

setreadonly(mt,true)

--------------------------------------------------
-- UPDATE BOXES
--------------------------------------------------

game:GetService("RunService").RenderStepped:Connect(function()

	if not Enabled then return end

	for _,plr in pairs(Players:GetPlayers()) do
		createBox(plr)
	end

end)

--------------------------------------------------
-- RESPAWN SUPPORT
--------------------------------------------------

local function connect(plr)

	plr.CharacterAdded:Connect(function()
		task.wait(0.4)
		if Enabled then
			createBox(plr)
		end
	end)

end

for _,plr in pairs(Players:GetPlayers()) do
	connect(plr)
end

Players.PlayerAdded:Connect(connect)

--------------------------------------------------
-- ENABLE / DISABLE
--------------------------------------------------

local function enable()

	Enabled = true

	for _,plr in pairs(Players:GetPlayers()) do
		createBox(plr)
	end

end

local function disable()

	Enabled = false

	for _,v in pairs(Boxes) do
		v:Destroy()
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
