-- Скрипт для удаления определённых инструментов и управления консолью

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Список инструментов для управления
local toolsToManage = {
    "Oil Cup",
    "Blood Cup",
    "Acid Cup",
    "Laight Cup",
    "Gold",
    "Leather",
    "Meat",
    "Rope"
}

-- Создаем GUI фрейм
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ToolRemovalConsole"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 400)
frame.Position = UDim2.new(0.5, -150, 0.5, -200)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 2
frame.BorderColor3 = Color3.new(1, 1, 1)
frame.Parent = screenGui

-- Сделать окно перетаскиваемым
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

-- Создаем заголовок
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.Text = "Tool Removal Console"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.Parent = frame

-- Создаем кнопки для переключения инструментов
local buttons = {}
local activeStates = {} -- хранит состояние "активен" или "не активен" для каждого инструмента

local buttonSize = UDim2.new(1, -20, 0, 30)
local startY = 80

for i, toolName in ipairs(toolsToManage) do
    -- Инициализируем состояние как "активен" (true)
    activeStates[toolName] = true

    local btn = Instance.new("TextButton")
    btn.Size = buttonSize
    btn.Position = UDim2.new(0, 10, 0, startY + (i - 1) * 35)
    btn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    btn.Text = toolName .. " (Активен)"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.Parent = frame
    buttons[toolName] = btn

    -- Обработка нажатия для переключения состояния
    btn.MouseButton1Click:Connect(function()
        activeStates[toolName] = not activeStates[toolName]
        if activeStates[toolName] then
            btn.Text = toolName .. " (Активен)"
            btn.BackgroundColor3 = Color3.fromRGB(100, 200, 100) -- зеленый для активного
        else
            btn.Text = toolName .. " (Отключен)"
            btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- красный для отключенного
        end
    end)
end

-- Постоянная проверка и удаление активных инструментов
game:GetService("RunService").Stepped:Connect(function()
    local backpack = player.Backpack
    local character = player.Character

    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and activeStates[tool.Name] then
            if table.find(toolsToManage, tool.Name) then
                tool:Destroy()
            end
        end
    end

    if character then
        for _, tool in ipairs(character:GetChildren()) do
            if tool:IsA("Tool") and activeStates[tool.Name] then
                if table.find(toolsToManage, tool.Name) then
                    tool:Destroy()
                end
            end
        end
    end
end)
