local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local vehiclesFolder = ReplicatedStorage:WaitForChild("Vehicles")
local spawnPoint = Workspace:WaitForChild("VehicleSpawnPoint")

local spawnEvent = ReplicatedStorage:FindFirstChild("RemoteSpawnVehicle")
if not spawnEvent then
	spawnEvent = Instance.new("RemoteEvent")
	spawnEvent.Name = "RemoteSpawnVehicle"
	spawnEvent.Parent = ReplicatedStorage
end

if game:GetService("RunService"):IsServer() then
	local currentVehicles = {}

	spawnEvent.OnServerEvent:Connect(function(player, vehicleName)
		local targetVehicle = vehiclesFolder:FindFirstChild(vehicleName)
		if not targetVehicle then return end
		
		if currentVehicles[player.UserId] and currentVehicles[player.UserId]:Parent() then
			currentVehicles[player.UserId]:Destroy()
		end
		
		local newCar = targetVehicle:Clone()
		newCar:PivotTo(spawnPoint.CFrame + Vector3.new(0, 3, 0))
		newCar.Parent = Workspace
		
		local ownerVal = Instance.new("ObjectValue")
		ownerVal.Name = "Owner"
		ownerVal.Value = player
		ownerVal.Parent = newCar
		
		currentVehicles[player.UserId] = newCar
	end)

	Players.PlayerRemoving:Connect(function(player)
		if currentVehicles[player.UserId] and currentVehicles[player.UserId]:Parent() then
			currentVehicles[player.UserId]:Destroy()
			currentVehicles[player.UserId] = nil
		end
	end)
end

local function createVehicleGui(player)
	local playerGui = player:WaitForChild("PlayerGui")
	
	if playerGui:FindFirstChild("VehicleSpawnerGui") then
		playerGui.VehicleSpawnerGui:Destroy()
	end
	
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "VehicleSpawnerGui"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = playerGui
	
	local scrollFrame = Instance.new("ScrollingFrame")
	scrollFrame.Size = UDim2.new(0, 250, 0, 350)
	scrollFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
	scrollFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	scrollFrame.BackgroundTransparency = 0.2
	scrollFrame.BorderSizePixel = 0
	scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scrollFrame.ScrollBarThickness = 6
	scrollFrame.Parent = screenGui
	
	local guiCorner = Instance.new("UICorner")
	guiCorner.CornerRadius = UDim.new(0, 8)
	guiCorner.Parent = scrollFrame
	
	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 6)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Parent = scrollFrame
	
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingTop = UDim.new(0, 8)
	uiPadding.Parent = scrollFrame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0.9, 0, 0, 30)
	titleLabel.Text = "Choose Vehicle"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 16
	titleLabel.BackgroundTransparency = 1
	titleLabel.Parent = scrollFrame

	for _, carModel in ipairs(vehiclesFolder:GetChildren()) do
		if carModel:IsA("Model") then
			local carButton = Instance.new("TextButton")
			carButton.Size = UDim2.new(0.9, 0, 0, 40)
			carButton.Text = carModel.Name
			carButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			carButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
			carButton.Font = Enum.Font.SourceSansBold
			carButton.TextSize = 16
			carButton.BorderSizePixel = 0
			
			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(0, 4)
			btnCorner.Parent = carButton
			
			carButton.MouseButton1Click:Connect(function()
				spawnEvent:FireServer(carModel.Name)
			end)
			
			carButton.Parent = scrollFrame
		end
	end
end

if game:GetService("RunService"):IsClient() then
	createVehicleGui(Players.LocalPlayer)
end
