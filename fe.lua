-- MM2 Role ESP (Mobile + PC)
-- Draggable UI + ESP Toggle
-- Credit // FADEDYK
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local roles = {}
local ESPEnabled = true

local Murder, Sheriff, Hero

--// UI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2ESP_UI"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Parent = ScreenGui
Frame.Size = UDim2.new(0, 180, 0, 80)
Frame.Position = UDim2.new(0.5, -90, 0.1, 0)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0

Instance.new("UICorner", Frame)

local Title = Instance.new("TextLabel")
Title.Parent = Frame
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "MM2 Role ESP"
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextScaled = true

local ToggleButton = Instance.new("TextButton")
ToggleButton.Parent = Frame
ToggleButton.Size = UDim2.new(0.9, 0, 0, 35)
ToggleButton.Position = UDim2.new(0.05, 0, 0.5, 0)
ToggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleButton.TextColor3 = Color3.fromRGB(255,255,255)
ToggleButton.TextScaled = true
ToggleButton.Text = "ESP : ON"

Instance.new("UICorner", ToggleButton)

--// Mobile + PC Drag
local dragging = false
local dragInput
local dragStart
local startPos

Frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
	or input.UserInputType == Enum.UserInputType.MouseButton1 then

		dragging = true
		dragStart = input.Position
		startPos = Frame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

Frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch
	or input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragging and input == dragInput then
		local delta = input.Position - dragStart

		Frame.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

--// Toggle ESP
ToggleButton.MouseButton1Click:Connect(function()
	ESPEnabled = not ESPEnabled

	ToggleButton.Text = ESPEnabled and "ESP : ON" or "ESP : OFF"

	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("Highlight") then
			player.Character.Highlight.Enabled = ESPEnabled
		end
	end
end)

--// Functions
local function IsAlive(Player)
	for i, v in pairs(roles) do
		if Player.Name == i then
			return not v.Killed and not v.Dead
		end
	end
	return false
end

local function CreateHighlight()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character and not plr.Character:FindFirstChild("Highlight") then
			local h = Instance.new("Highlight")
			h.FillTransparency = 0.3
			h.OutlineTransparency = 0
			h.Parent = plr.Character
		end
	end
end

local function UpdateHighlights()
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP and plr.Character and plr.Character:FindFirstChild("Highlight") then
			local h = plr.Character.Highlight

			h.Enabled = ESPEnabled

			if ESPEnabled then
				if plr.Name == Murder and IsAlive(plr) then
					h.FillColor = Color3.fromRGB(255, 0, 0) -- Red
				elseif plr.Name == Sheriff and IsAlive(plr) then
					h.FillColor = Color3.fromRGB(0, 0, 255) -- Blue
				elseif plr.Name == Hero and IsAlive(plr) then
					h.FillColor = Color3.fromRGB(255, 255, 0) -- Yellow
				else
					h.FillColor = Color3.fromRGB(0, 255, 0) -- Green
				end
			end
		end
	end
end

--// Main Loop
RunService.RenderStepped:Connect(function()
	local Remote = ReplicatedStorage:FindFirstChild("GetPlayerData", true)

	if Remote then
		local success, data = pcall(function()
			return Remote:InvokeServer()
		end)

		if success and data then
			roles = data

			Murder = nil
			Sheriff = nil
			Hero = nil

			for name, info in pairs(roles) do
				if info.Role == "Murderer" then
					Murder = name
				elseif info.Role == "Sheriff" then
					Sheriff = name
				elseif info.Role == "Hero" then
					Hero = name
				end
			end

			CreateHighlight()
			UpdateHighlights()
		end
	end
end)