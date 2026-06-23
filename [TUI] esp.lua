local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")

local toolsToManage = {
	"Oil Cup",
	"Blood Cup",
	"Acid Cup",
	"Light Cup",
	"Gold",
	"Metal",
	"Rusty Metal",
	"Stone",
	"Wood",
	"Leather",
	"Line Paper",
	"Meat",
	"Rope",
	"Holy Chain",
	"Shattered Chain",
	"Coal",
	"Orb",
	"Cursed Orb",
	"Holy Orb",
	"Meteorite",
	"Alien Tech",

	"Firework",
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFilter"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Контейнер (перетаскиваемый, прозрачный фон)
local container = Instance.new("Frame")
container.Name = "Container"
container.Size = UDim2.new(0.16, 0, 0.5, 0)
container.Position = UDim2.new(0.2, 0, 0.25, 0)
container.BackgroundTransparency = 1
container.Parent = screenGui

-- Основная панель (88% ширины контейнера)
local frame = Instance.new("Frame")
frame.Name = "Panel"
frame.Size = UDim2.new(0.88, 0, 1, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(1, 1, 1)
frame.Parent = container

-- Вкладка (таб) на правом краю — всегда видима, переключает панель
local tabBtn = Instance.new("TextButton")
tabBtn.Name = "TabButton"
tabBtn.Size = UDim2.new(0.12, 0, 0.16, 0)
tabBtn.Position = UDim2.new(0.88, 0, 0.1, 0)
tabBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
tabBtn.BorderSizePixel = 2
tabBtn.BorderColor3 = Color3.new(1, 1, 1)
tabBtn.Text = "◀"
tabBtn.TextColor3 = Color3.new(1, 1, 1)
tabBtn.Font = Enum.Font.SourceSansBold
tabBtn.TextScaled = true
tabBtn.Parent = container

-- Перетаскивание контейнера (работает и с панели, и с вкладки)
local dragging = false
local dragInput, dragStart, startPos
local dragDistance = 0

local function onInputBegan(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = container.Position
		dragDistance = 0
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end

local function onInputChanged(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end

frame.InputBegan:Connect(onInputBegan)
tabBtn.InputBegan:Connect(onInputBegan)
frame.InputChanged:Connect(onInputChanged)
tabBtn.InputChanged:Connect(onInputChanged)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		dragDistance = delta.Magnitude
		container.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
	end
end)

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0.08, 0)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Auto Filter"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextScaled = true
title.Parent = frame

-- Переключение панели через вкладку (клик, не перетаскивание)
local consoleVisible = true

tabBtn.MouseButton1Click:Connect(function()
	if dragDistance < 5 then
		if consoleVisible then
			frame.Visible = false
			consoleVisible = false
			tabBtn.Text = "▶"
		else
			frame.Visible = true
			consoleVisible = true
			tabBtn.Text = "◀"
		end
	end
end)

-- Создаем кнопки инструментов (всё на scale)
local buttons = {}
local activeStates = {}

local buttonsPerRow = 4
local btnW = 0.21
local btnH = 0.13
local spacingX = 0.025
local spacingY = 0.02
local startX = 0.025
local startY = 0.1

for i, toolName in ipairs(toolsToManage) do
	local row = math.floor((i - 1) / buttonsPerRow)
	local col = (i - 1) % buttonsPerRow

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(btnW, 0, btnH, 0)
	btn.Position = UDim2.new(startX + col * (btnW + spacingX), 0,
		startY + row * (btnH + spacingY), 0)
	btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	btn.Text = toolName .. " [OFF]"
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSans
	btn.TextScaled = true
	btn.Parent = frame
	buttons[toolName] = btn

	btn.MouseButton1Click:Connect(function()
		activeStates[toolName] = not activeStates[toolName]
		if activeStates[toolName] then
			btn.Text = toolName .. " [ON]"
			btn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
		else
			btn.Text = toolName .. " [OFF]"
			btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		end
	end)
end

-- Постоянная проверка и удаление активных инструментов
game:GetService("RunService").Stepped:Connect(function()
	local backpack = player.Backpack

	for _, tool in ipairs(backpack:GetChildren()) do
		if tool:IsA("Tool") and activeStates[tool.Name] then
			if table.find(toolsToManage, tool.Name) then
				tool:Destroy()
			end
		end
	end
end)
