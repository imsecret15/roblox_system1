-- Bowmode_system.lua

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local Settings
repeat task.wait() until shared.BowModeSettings
Settings = shared.BowModeSettings

local Enabled = false

--------------------------------------------------
-- FIND TARGET
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
-- REMOTE HOOK
--------------------------------------------------

local old
old = hookmetamethod(game,"__namecall",function(self,...)

	local args = {...}
	local method = getnamecallmethod()

	if Enabled and method == "FireServer" then

		if self.Name == "mouse" or self.Name == "hit" then

			local head = getTargetHead()

			if head then
				args[1] = head.Position
			end

			return old(self,unpack(args))
		end
	end

	return old(self,...)
end)

--------------------------------------------------
-- SETTINGS WATCHER
--------------------------------------------------

task.spawn(function()

	while true do
		task.wait(0.15)

		Enabled = Settings.Enabled
	end

end)
