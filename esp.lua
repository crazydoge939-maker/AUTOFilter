local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local toolsToManage = {
	"Oil Cup",
	"Blood Cup",
	"Acid Cup",
	"Light Cup",
	"Gold",
	"Metal",
	"Stone",
	"Wood",
	"Leather",
	"Meat",
	"Rope",
	"Orb",
	"Cursed Orb",
	"Holy Orb"
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AutoFilter"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Создаем основной фрейм
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 325)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(1, 1, 1)
frame.Parent = screenGui

-- Перетаскивание фрейма
local dragging = false
local dragInput, dragStart, startPos

frame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = frame.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

frame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		dragInput = input
	end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		local delta = input.Position - dragStart
		frame.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
	end
end)

-- Заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Auto Filter"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

-- Кнопка скрытия
local hideBtn = Instance.new("TextButton")
hideBtn.Size = UDim2.new(1, -20, 0, 30)
hideBtn.Position = UDim2.new(0, 10, 0, 40)
hideBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
hideBtn.Text = "Скрыть консоль"
hideBtn.TextColor3 = Color3.new(1,1,1)
hideBtn.Font = Enum.Font.SourceSans
hideBtn.TextSize = 16
hideBtn.Parent = frame

-- Создаем кнопку для возвращения, вне фрейма
local showBtn = Instance.new("TextButton")
showBtn.Size = UDim2.new(0, 50, 0, 50)
showBtn.Position = UDim2.new(0.5, -75, 0.9, -15)
showBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
showBtn.Text = "Вернуть консоль"
showBtn.TextColor3 = Color3.new(1,1,1)
showBtn.Font = Enum.Font.SourceSans
showBtn.TextSize = 16
showBtn.TextScaled = true
showBtn.Parent = screenGui
showBtn.Active = true -- чтобы можно было перетаскивать
showBtn.Draggable = true -- включаем перетаскивание
showBtn.Visible = false -- изначально скрыта

local consoleVisible = true

hideBtn.MouseButton1Click:Connect(function()
	frame.Visible = false
	consoleVisible = false
	hideBtn.Visible = false
	showBtn.Visible = true
end)

showBtn.MouseButton1Click:Connect(function()
	frame.Visible = true
	consoleVisible = true
	hideBtn.Visible = true
	showBtn.Visible = false
end)

-- Создаем кнопки инструментов
local buttons = {}
local activeStates = {}
local startY = 80

local buttonsPerRow = 4 -- Количество кнопок в строке
local buttonSize = UDim2.new(0, 50, 0, 50) -- Размер кнопки (квадратной)
local spacingX = 10 -- Расстояние между кнопками по горизонтали
local spacingY = 10 -- Расстояние между кнопками по вертикали
local startX = 10 -- Начальная позиция X
local startY = 80 -- Начальная позиция Y (под заголовком)

for i, toolName in ipairs(toolsToManage) do
	local row = math.floor((i - 1) / buttonsPerRow)
	local col = (i - 1) % buttonsPerRow

	local btn = Instance.new("TextButton")
	btn.Size = buttonSize
	btn.Position = UDim2.new(0, startX + col * (buttonSize.X.Offset + spacingX),
		0, startY + row * (buttonSize.Y.Offset + spacingY))
	btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	btn.Text = toolName .. " (Отключен)"
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.SourceSans
	btn.TextSize = 14
	btn.TextScaled = true
	btn.Parent = frame
	buttons[toolName] = btn

	btn.MouseButton1Click:Connect(function()
		activeStates[toolName] = not activeStates[toolName]
		if activeStates[toolName] then
			btn.Text = toolName .. " (Активен)"
			btn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
			btn.TextScaled = true
		else
			btn.Text = toolName .. " (Отключен)"
			btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
			btn.TextScaled = true
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
