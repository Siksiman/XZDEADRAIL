local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local uis = game:GetService("UserInputService")
local cam = workspace.CurrentCamera
local rs = game:GetService("RunService")

local function getRainbowColor(hueOffset)
	return Color3.fromHSV((tick() / 5 + hueOffset) % 1, 1, 1)
end

local function getClosestNPC()
	local shortest = math.huge
	local closest = nil
	for _, npc in pairs(workspace:GetDescendants()) do
		if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") and not game.Players:GetPlayerFromCharacter(npc) then
			local head = npc:FindFirstChild("Head")
			if head and npc:FindFirstChildOfClass("Humanoid").Health > 0 then
				local dist = (head.Position - player.Character.HumanoidRootPart.Position).Magnitude
				if dist < shortest then
					shortest = dist
					closest = npc
				end
			end
		end
	end
	return closest
end

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "XzAimGui"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 300, 0, 180)
main.Position = UDim2.new(0.5, -150, 0.5, -90)
main.BackgroundColor3 = Color3.new(0, 0, 0)
main.BackgroundTransparency = 0.2
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

local rainbow = Instance.new("UIStroke", main)
rainbow.Thickness = 3
rainbow.LineJoinMode = Enum.LineJoinMode.Round
rs.RenderStepped:Connect(function()
	rainbow.Color = getRainbowColor(0)
end)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -10, 0, 30)
title.Position = UDim2.new(0, 5, 0, 5)
title.BackgroundTransparency = 1
title.Text = "XzAimGui - Dead Rail"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true

local fullBrightBtn = Instance.new("TextButton", main)
fullBrightBtn.Size = UDim2.new(0, 120, 0, 25)
fullBrightBtn.Position = UDim2.new(0.5, -60, 1, -60)
fullBrightBtn.BackgroundColor3 = Color3.new(0, 0, 0)
fullBrightBtn.TextColor3 = Color3.new(1, 1, 1)
fullBrightBtn.Text = "Full Bright"
fullBrightBtn.Font = Enum.Font.GothamBold
fullBrightBtn.TextScaled = true
fullBrightBtn.AutoButtonColor = true
Instance.new("UICorner", fullBrightBtn).CornerRadius = UDim.new(0, 8)

local fullBrightEnabled = false
fullBrightBtn.MouseButton1Click:Connect(function()
	fullBrightEnabled = not fullBrightEnabled
	fullBrightBtn.Text = "Full Bright [" .. (fullBrightEnabled and "ON" or "OFF") .. "]"
	if fullBrightEnabled then
		for _, part in pairs(workspace:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Material = Enum.Material.SmoothPlastic
				part.Color = Color3.fromRGB(255, 255, 255)
			end
		end
	else
		for _, part in pairs(workspace:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Material = Enum.Material.Plastic
			end
		end
	end
end)

local lockBtn = Instance.new("TextButton", main)
lockBtn.Size = UDim2.new(0, 120, 0, 35)
lockBtn.Position = UDim2.new(0.5, -60, 0.5, -20)
lockBtn.BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
lockBtn.TextColor3 = Color3.new(1, 1, 1)
lockBtn.Text = "Lock [OFF]"
lockBtn.Font = Enum.Font.GothamBold
lockBtn.TextScaled = true
Instance.new("UICorner", lockBtn).CornerRadius = UDim.new(0, 10)

local locked = false
local currentTarget = nil
local camLoop = nil
local deathConn = nil

local function startLock()
	currentTarget = getClosestNPC()
	if not currentTarget then return end
	local head = currentTarget:FindFirstChild("Head")
	if not head then return end

	local humanoid = currentTarget:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	if deathConn then deathConn:Disconnect() end
	deathConn = humanoid.Died:Connect(function()
		startLock()
	end)

	if camLoop then camLoop:Disconnect() end
	camLoop = rs.RenderStepped:Connect(function()
		if head and head.Parent then
			cam.CameraSubject = head
		end
	end)
end

local function stopLock()
	if camLoop then camLoop:Disconnect() end
	if deathConn then deathConn:Disconnect() end
	currentTarget = nil
	cam.CameraSubject = player.Character:FindFirstChild("Humanoid")
end

lockBtn.MouseButton1Click:Connect(function()
	locked = not locked
	lockBtn.Text = "Lock [" .. (locked and "ON" or "OFF") .. "]"
	if locked then
		startLock()
	else
		stopLock()
	end
end)

local noclipBtn = Instance.new("TextButton", main)
noclipBtn.Size = UDim2.new(0, 120, 0, 25)
noclipBtn.Position = UDim2.new(0.5, -60, 1, -90)
noclipBtn.BackgroundColor3 = Color3.new(0, 0, 0)
noclipBtn.TextColor3 = Color3.new(1, 1, 1)
noclipBtn.Text = "Noclip [OFF]"
noclipBtn.Font = Enum.Font.GothamBold
noclipBtn.TextScaled = true
noclipBtn.AutoButtonColor = true
Instance.new("UICorner", noclipBtn).CornerRadius = UDim.new(0, 8)

local noclip = false
local noclipConn
noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = "Noclip [" .. (noclip and "ON" or "OFF") .. "]"
	if noclip then
		noclipConn = rs.Stepped:Connect(function()
			for _, part in pairs(player.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end)
	else
		if noclipConn then noclipConn:Disconnect() end
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = true
			end
		end
	end
end)
